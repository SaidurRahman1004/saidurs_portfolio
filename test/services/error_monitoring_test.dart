import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/error_report_model.dart';
import 'package:futter_portfileo_website/services/error_monitoring/error_fingerprinter.dart';
import 'package:futter_portfileo_website/services/error_monitoring/error_sanitizer.dart';
import 'package:futter_portfileo_website/services/error_monitoring/error_severity_classifier.dart';
import 'package:futter_portfileo_website/services/error_monitoring/web_error_reporter.dart';

void main() {
  group('ErrorSanitizer Security Tests', () {
    test('redacts email addresses from messages and stack traces', () {
      const raw = 'User saidur.dev@gmail.com failed to authenticate with contact.me@example.co.uk';
      final clean = ErrorSanitizer.sanitizeMessage(raw);

      expect(clean.contains('saidur.dev@gmail.com'), isFalse);
      expect(clean.contains('contact.me@example.co.uk'), isFalse);
      expect(clean, contains('[REDACTED_EMAIL]'));
    });

    test('redacts Bearer tokens and JWTs', () {
      const raw = 'Request failed with header Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.t-IDNssOxhXH';
      final clean = ErrorSanitizer.sanitizeMessage(raw);

      expect(clean.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'), isFalse);
      expect(clean, contains('[REDACTED_TOKEN]'));
    });

    test('redacts passwords and secret parameters', () {
      const raw = 'Failed connection on api_key=secretKey123&password=supersecretPass&user=guest';
      final clean = ErrorSanitizer.sanitizeMessage(raw);

      expect(clean.contains('secretKey123'), isFalse);
      expect(clean.contains('supersecretPass'), isFalse);
      expect(clean, contains('[REDACTED_SECRET]'));
    });

    test('strips URL query parameters', () {
      const raw = 'Failed to load https://api.portfolio.com/inquiries?token=xyz123&email=test@test.com';
      final clean = ErrorSanitizer.sanitizeMessage(raw);

      expect(clean.contains('token=xyz123'), isFalse);
      expect(clean, contains('?[REDACTED_QUERY]'));
    });

    test('sanitizes route and operation names', () {
      expect(ErrorSanitizer.sanitizeRoute('/projects?id=123&token=abc'), equals('/projects'));
      expect(ErrorSanitizer.sanitizeOperation('fetch_projects_list'), equals('fetch_projects_list'));
      expect(ErrorSanitizer.sanitizeOperation('submit; DROP TABLE;'), equals('submit__DROP_TABLE_'));
    });
  });

  group('ErrorFingerprinter Deduplication Tests', () {
    test('produces identical 16-character hex fingerprints for the same error', () {
      final fp1 = ErrorFingerprinter.computeFingerprint(
        type: 'network_error',
        message: 'Failed host lookup: api.example.com',
        stackTrace: 'package:app/service.dart:45:12 in fetchProjects',
      );

      final fp2 = ErrorFingerprinter.computeFingerprint(
        type: 'network_error',
        message: 'Failed host lookup: api.example.com',
        stackTrace: 'package:app/service.dart:45:12 in fetchProjects',
      );

      expect(fp1, equals(fp2));
      expect(fp1.length, equals(16));
      expect(RegExp(r'^[a-f0-9]{16}$').hasMatch(fp1), isTrue);
    });

    test('normalizes dynamic numbers, UUIDs, and line numbers to preserve fingerprint', () {
      final fp1 = ErrorFingerprinter.computeFingerprint(
        type: 'firebase_error',
        message: 'Document 12345678-1234-1234-1234-123456789abc not found at index 42',
        stackTrace: 'package:app/service.dart:100:20 in getDoc',
      );

      final fp2 = ErrorFingerprinter.computeFingerprint(
        type: 'firebase_error',
        message: 'Document 87654321-4321-4321-4321-cba987654321 not found at index 999',
        stackTrace: 'package:app/service.dart:105:25 in getDoc',
      );

      expect(fp1, equals(fp2), reason: 'Dynamic UUIDs and numbers should normalize to the same fingerprint');
    });

    test('produces different fingerprints for different error types', () {
      final fp1 = ErrorFingerprinter.computeFingerprint(
        type: 'network_error',
        message: 'Connection timed out',
      );

      final fp2 = ErrorFingerprinter.computeFingerprint(
        type: 'state_error',
        message: 'Connection timed out',
      );

      expect(fp1, isNot(equals(fp2)));
    });
  });

  group('ErrorSeverityClassifier Tests', () {
    test('fatal errors are classified as critical', () {
      final severity = ErrorSeverityClassifier.classify(
        exception: Exception('Any error'),
        fatal: true,
      );
      expect(severity, equals('critical'));
    });

    test('permission and auth exceptions are classified as critical', () {
      final severity = ErrorSeverityClassifier.classify(
        exception: Exception('FirebaseException: [permission-denied] Missing claims'),
        fatal: false,
      );
      expect(severity, equals('critical'));
    });

    test('critical operations or network outages are classified as high', () {
      final s1 = ErrorSeverityClassifier.classify(
        exception: Exception('Request failed'),
        operation: 'submit_inquiry',
      );
      expect(s1, equals('high'));

      final s2 = ErrorSeverityClassifier.classify(
        exception: Exception('SocketException: failed host lookup'),
        operation: 'view_project',
      );
      expect(s2, equals('high'));
    });

    test('user cancellations are classified as low', () {
      final severity = ErrorSeverityClassifier.classify(
        exception: Exception('User-aborted image upload'),
      );
      expect(severity, equals('low'));
    });

    test('general handled errors default to medium', () {
      final severity = ErrorSeverityClassifier.classify(
        exception: Exception('Invalid argument supplied to chip widget'),
      );
      expect(severity, equals('medium'));
    });
  });

  group('ErrorReportModel Tests', () {
    test('toCallablePayload serializes required backend fields correctly', () {
      const model = ErrorReportModel(
        fingerprint: 'a1b2c3d4e5f67890',
        type: 'framework_error',
        severity: 'high',
        message: 'RenderFlex overflowed',
        route: '/projects',
        operation: 'render_grid',
        browser: 'chrome_120',
      );

      final payload = model.toCallablePayload();

      expect(payload['fingerprint'], equals('a1b2c3d4e5f67890'));
      expect(payload['type'], equals('framework_error'));
      expect(payload['severity'], equals('high'));
      expect(payload['message'], equals('RenderFlex overflowed'));
      expect(payload['route'], equals('/projects'));
      expect(payload['operation'], equals('render_grid'));
      expect(payload['platform'], equals('web'));
      expect(payload['browser'], equals('chrome_120'));
      expect(model.referenceCode, equals('#a1b2c3'));
    });

    test('fromMap parses map fields with safe defaults', () {
      final map = {
        'fingerprint': 'test_fp',
        'type': 'network_error',
        'severity': 'medium',
        'occurrenceCount': 5,
        'firstSeenAt': DateTime(2026, 9, 18).toIso8601String(),
      };

      final model = ErrorReportModel.fromMap(map);

      expect(model.fingerprint, equals('test_fp'));
      expect(model.type, equals('network_error'));
      expect(model.occurrenceCount, equals(5));
      expect(model.status, equals('open'));
    });
  });

  group('WebErrorReporter Integration & Deduplication Tests', () {
    late WebErrorReporter reporter;

    setUp(() {
      reporter = WebErrorReporter.instance;
      reporter.resetForTesting();
    });

    test('throttles duplicate errors within the 60-second window', () async {
      final dispatchedPayloads = <Map<String, dynamic>>[];

      reporter.setCallableHandlerForTesting((payload) async {
        dispatchedPayloads.add(payload);
        return {'success': true};
      });

      final exception = Exception('Identical network timeout');
      final stack = StackTrace.current;

      // First report: should be dispatched
      final fp1 = await reporter.reportError(
        exception,
        stack,
        route: '/home',
      );

      expect(fp1, isNotNull);
      expect(dispatchedPayloads.length, equals(1));
      expect(reporter.cacheSizeForTesting, equals(1));

      // Second immediate report with same error: should be throttled (skipped)
      final fp2 = await reporter.reportError(
        exception,
        stack,
        route: '/home',
      );

      expect(fp2, equals(fp1));
      // Length should still be 1 because duplicate was throttled!
      expect(dispatchedPayloads.length, equals(1));
    });

    test('reportFlutterError extracts details and formats framework error', () async {
      Map<String, dynamic>? capturedPayload;

      reporter.setCallableHandlerForTesting((payload) async {
        capturedPayload = payload;
        return {'success': true};
      });

      final details = FlutterErrorDetails(
        exception: FlutterError('RenderFlex overflowed by 15 pixels'),
        library: 'rendering library',
        context: ErrorDescription('during layout'),
      );

      final fp = await reporter.reportFlutterError(
        details,
        route: '/admin',
        feature: 'admin_dashboard',
      );

      expect(fp, isNotNull);
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['type'], equals('framework_error'));
      expect(capturedPayload!['message'], contains('RenderFlex overflowed'));
      expect(capturedPayload!['route'], equals('/admin'));
    });
  });
}
