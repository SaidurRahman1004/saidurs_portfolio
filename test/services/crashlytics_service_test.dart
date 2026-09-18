import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/services/crashlytics/crashlytics_delegate.dart';
import 'package:futter_portfileo_website/services/crashlytics/crashlytics_service.dart';

class FakeTestCrashlyticsDelegate implements CrashlyticsDelegate {
  bool initialized = false;
  bool enabled = true;
  final List<String> logs = [];
  final Map<String, Object> customKeys = {};
  String? userId;
  dynamic lastRecordedException;
  StackTrace? lastRecordedStack;
  String? lastRecordedReason;
  bool? lastRecordedFatal;
  FlutterErrorDetails? lastRecordedFlutterError;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({bool enableInDebug = false}) async {
    initialized = true;
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    lastRecordedException = exception;
    lastRecordedStack = stack;
    lastRecordedReason = reason;
    lastRecordedFatal = fatal;
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    lastRecordedFlutterError = details;
    lastRecordedFatal = fatal;
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  Future<void> setUserId(String identifier) async {
    userId = identifier;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool isEnabled) async {
    enabled = isEnabled;
  }
}

void main() {
  group('CrashlyticsService Core & Singleton Tests', () {
    late CrashlyticsService service;

    setUp(() {
      service = CrashlyticsService.instance;
      service.resetForTesting();
    });

    test('is a singleton instance', () {
      final s1 = CrashlyticsService();
      final s2 = CrashlyticsService.instance;
      expect(identical(s1, s2), isTrue);
    });

    test('initializes safely without throwing', () async {
      expect(service.isInitialized, isFalse);
      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    test('ignores duplicate initialize calls', () async {
      await service.initialize();
      expect(service.isInitialized, isTrue);

      await service.initialize();
      expect(service.isInitialized, isTrue);
    });
  });

  group('Crashlytics Zero-PII Security Tests', () {
    late CrashlyticsService service;
    late FakeTestCrashlyticsDelegate fakeDelegate;

    setUp(() {
      service = CrashlyticsService.instance;
      service.resetForTesting();
      fakeDelegate = FakeTestCrashlyticsDelegate();
      service.setDelegateForTesting(fakeDelegate);
    });

    test('blocks all forbidden PII keys from customKeys', () async {
      final forbiddenKeys = [
        'password',
        'token',
        'auth_token',
        'email',
        'email_address',
        'phone',
        'phone_number',
        'whatsapp_number',
        'message',
        'contact_message',
        'user_data',
        'private_data',
        'credit_card',
      ];

      for (final key in forbiddenKeys) {
        expect(service.isForbiddenKeyForTesting(key), isTrue);
        await service.setCustomKey(key, 'sensitive_value');
        expect(fakeDelegate.customKeys.containsKey(key), isFalse,
            reason: '$key should have been blocked');
      }
    });

    test('redacts email addresses embedded in customKey string values', () async {
      await service.setCustomKey('user_note', 'Please email contact@example.com for info');
      expect(fakeDelegate.customKeys['user_note'],
          equals('Please email [REDACTED_EMAIL] for info'));
    });

    test('redacts email addresses from log breadcrumbs', () async {
      await service.log('User logged in with email john.doe@company.org');
      expect(fakeDelegate.logs.length, equals(1));
      expect(fakeDelegate.logs.first,
          equals('User logged in with email [REDACTED_EMAIL]'));
    });

    test('blocks user ID when it looks like an email address', () async {
      await service.setUserId('john.doe@gmail.com');
      expect(fakeDelegate.userId, isNull);

      // Safe alphanumeric ID should be allowed
      await service.setUserId('user_abc_123');
      expect(fakeDelegate.userId, equals('user_abc_123'));
    });
  });

  group('Crashlytics Contextual Error Recording Tests', () {
    late CrashlyticsService service;
    late FakeTestCrashlyticsDelegate fakeDelegate;

    setUp(() {
      service = CrashlyticsService.instance;
      service.resetForTesting();
      fakeDelegate = FakeTestCrashlyticsDelegate();
      service.setDelegateForTesting(fakeDelegate);
    });

    test('recordError enriches error with contextual parameters and sanitized keys', () async {
      final error = Exception('Firestore query timeout');
      final stack = StackTrace.current;

      await service.recordError(
        error,
        stack,
        reason: 'Failed to load user projects',
        fatal: false,
        route: '/projects',
        feature: 'portfolio_projects',
        operation: 'fetch_projects_list',
        customKeys: {
          'retry_count': 3,
          'cache_hit': false,
          'email': 'ignore_me@leak.com', // forbidden key
        },
      );

      expect(fakeDelegate.lastRecordedException, equals(error));
      expect(fakeDelegate.lastRecordedFatal, isFalse);
      expect(fakeDelegate.lastRecordedReason, equals('Failed to load user projects'));
      expect(fakeDelegate.customKeys['current_route'], equals('/projects'));
      expect(fakeDelegate.customKeys['feature'], equals('portfolio_projects'));
      expect(fakeDelegate.customKeys['operation'], equals('fetch_projects_list'));
      expect(fakeDelegate.customKeys['retry_count'], equals(3));
      expect(fakeDelegate.customKeys['cache_hit'], equals(false));
      expect(fakeDelegate.customKeys.containsKey('email'), isFalse);
    });

    test('recordFlutterError enriches framework error details', () async {
      final details = FlutterErrorDetails(
        exception: FlutterError('RenderFlex overflowed by 20 pixels on the bottom'),
        library: 'widgets library',
      );

      await service.recordFlutterError(
        details,
        fatal: true,
        route: '/admin/dashboard',
        feature: 'admin_panel',
      );

      expect(fakeDelegate.lastRecordedFlutterError, equals(details));
      expect(fakeDelegate.lastRecordedFatal, isTrue);
      expect(fakeDelegate.customKeys['current_route'], equals('/admin/dashboard'));
      expect(fakeDelegate.customKeys['feature'], equals('admin_panel'));
    });

    test('recordTestCrash attaches distinguishable test metadata', () async {
      await service.recordTestCrash(testId: 'qa_verify_001', fatal: false);

      expect(fakeDelegate.lastRecordedFatal, isFalse);
      expect(fakeDelegate.customKeys['is_test'], isTrue);
      expect(fakeDelegate.customKeys['test_id'], equals('qa_verify_001'));
      expect(fakeDelegate.customKeys.containsKey('test_timestamp'), isTrue);
      expect(fakeDelegate.logs.any((l) => l.contains('qa_verify_001')), isTrue);
      expect(fakeDelegate.lastRecordedReason, contains('verification test'));
    });
  });
}
