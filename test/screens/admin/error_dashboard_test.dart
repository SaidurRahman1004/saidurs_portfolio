import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/error_report_model.dart';

void main() {
  group('Phase 5: ErrorReportModel Status & Diagnostic Helpers', () {
    test('normalizes legacy "unresolved" status to "open"', () {
      final model = ErrorReportModel.fromMap({
        'fingerprint': 'abc1234567890def',
        'type': 'framework_error',
        'severity': 'high',
        'status': 'unresolved',
        'message': 'RenderFlex overflowed',
      });

      expect(model.status, equals('open'));
      expect(model.isOpen, isTrue);
      expect(model.isInvestigating, isFalse);
      expect(model.isResolved, isFalse);
      expect(model.isIgnored, isFalse);
    });

    test('correctly identifies investigating, resolved, and ignored statuses', () {
      final investigating = const ErrorReportModel(
        fingerprint: '111',
        type: 'async_error',
        severity: 'critical',
        status: 'investigating',
        message: 'Future failure',
      );
      final resolved = const ErrorReportModel(
        fingerprint: '222',
        type: 'network_error',
        severity: 'medium',
        status: 'resolved',
        message: 'Socket timeout',
      );
      final ignored = const ErrorReportModel(
        fingerprint: '333',
        type: 'widget_error',
        severity: 'low',
        status: 'ignored',
        message: 'Minor warning',
      );

      expect(investigating.isInvestigating, isTrue);
      expect(investigating.isOpen, isFalse);

      expect(resolved.isResolved, isTrue);
      expect(resolved.isOpen, isFalse);

      expect(ignored.isIgnored, isTrue);
      expect(ignored.isOpen, isFalse);
    });

    test('correctly identifies severity tiers', () {
      final crit = const ErrorReportModel(
        fingerprint: '1',
        type: 't',
        severity: 'critical',
        message: 'm',
      );
      final high = const ErrorReportModel(
        fingerprint: '2',
        type: 't',
        severity: 'high',
        message: 'm',
      );
      final med = const ErrorReportModel(
        fingerprint: '3',
        type: 't',
        severity: 'medium',
        message: 'm',
      );
      final low = const ErrorReportModel(
        fingerprint: '4',
        type: 't',
        severity: 'low',
        message: 'm',
      );

      expect(crit.isCritical, isTrue);
      expect(high.isHigh, isTrue);
      expect(med.isMedium, isTrue);
      expect(low.isLow, isTrue);
    });

    test('isLast24Hours returns true for recent errors and false for older ones', () {
      final recent = ErrorReportModel(
        fingerprint: 'recent',
        type: 't',
        severity: 'high',
        message: 'm',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final older = ErrorReportModel(
        fingerprint: 'older',
        type: 't',
        severity: 'high',
        message: 'm',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 36)),
      );

      expect(recent.isLast24Hours, isTrue);
      expect(older.isLast24Hours, isFalse);
    });

    test('formats relative time strings accurately', () {
      final justNow = ErrorReportModel(
        fingerprint: '1',
        type: 't',
        severity: 'low',
        message: 'm',
        lastSeenAt: DateTime.now().subtract(const Duration(seconds: 15)),
      );
      final minutesAgo = ErrorReportModel(
        fingerprint: '2',
        type: 't',
        severity: 'low',
        message: 'm',
        lastSeenAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      final hoursAgo = ErrorReportModel(
        fingerprint: '3',
        type: 't',
        severity: 'low',
        message: 'm',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(justNow.formattedLastSeen, equals('Just now'));
      expect(minutesAgo.formattedLastSeen, equals('10m ago'));
      expect(hoursAgo.formattedLastSeen, equals('3h ago'));
    });

    test('preserves and updates notes timeline in model copyWith', () {
      final initial = const ErrorReportModel(
        fingerprint: 'f1',
        type: 't',
        severity: 'high',
        message: 'm',
        notes: ['[Admin] Initial note'],
      );

      final updated = initial.copyWith(
        notes: [...initial.notes, '[Admin] Second triage update'],
        status: 'investigating',
      );

      expect(updated.notes.length, equals(2));
      expect(updated.notes.last, contains('Second triage update'));
      expect(updated.status, equals('investigating'));
    });
  });

  group('Phase 5: Error Dashboard Metrics & Filtering Logic', () {
    final sampleReports = [
      ErrorReportModel(
        fingerprint: 'crit_open',
        type: 'framework_error',
        severity: 'critical',
        status: 'open',
        message: 'LateInitializationError: field not ready',
        route: '/admin',
        operation: 'widget_build',
        platform: 'web',
        browser: 'Chrome',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 1)),
        occurrenceCount: 5,
      ),
      ErrorReportModel(
        fingerprint: 'high_inv',
        type: 'async_error',
        severity: 'high',
        status: 'investigating',
        message: 'Unhandled Exception: FirebaseException quota exceeded',
        route: '/projects',
        operation: 'fetch_projects',
        platform: 'web',
        browser: 'Firefox',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 5)),
        occurrenceCount: 12,
      ),
      ErrorReportModel(
        fingerprint: 'med_resolved',
        type: 'network_error',
        severity: 'medium',
        status: 'resolved',
        message: 'ClientException: connection reset by peer',
        route: '/',
        operation: 'contact_submit',
        platform: 'web',
        browser: 'Safari',
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 20)),
        occurrenceCount: 2,
      ),
      ErrorReportModel(
        fingerprint: 'low_ignored',
        type: 'widget_error',
        severity: 'low',
        status: 'ignored',
        message: 'A RenderFlex overflowed by 2.5 pixels',
        route: '/admin/settings',
        operation: 'theme_switch',
        platform: 'web',
        browser: 'Chrome',
        lastSeenAt: DateTime.now().subtract(const Duration(days: 3)),
        occurrenceCount: 1,
      ),
    ];

    test('computes accurate aggregate counts across severity and status', () {
      final total = sampleReports.length;
      final open = sampleReports.where((e) => e.isOpen).length;
      final investigating = sampleReports.where((e) => e.isInvestigating).length;
      final resolved = sampleReports.where((e) => e.isResolved).length;
      final ignored = sampleReports.where((e) => e.isIgnored).length;
      final critical = sampleReports.where((e) => e.isCritical).length;
      final last24Hours = sampleReports.where((e) => e.isLast24Hours).length;

      expect(total, equals(4));
      expect(open, equals(1));
      expect(investigating, equals(1));
      expect(resolved, equals(1));
      expect(ignored, equals(1));
      expect(critical, equals(1));
      expect(last24Hours, equals(3));
    });

    test('filters error reports by status correctly', () {
      final openOnly = sampleReports.where((e) => e.isOpen).toList();
      final resolvedOnly = sampleReports.where((e) => e.isResolved).toList();

      expect(openOnly.length, equals(1));
      expect(openOnly.first.fingerprint, equals('crit_open'));

      expect(resolvedOnly.length, equals(1));
      expect(resolvedOnly.first.fingerprint, equals('med_resolved'));
    });

    test('filters error reports by severity correctly', () {
      final criticalOnly = sampleReports.where((e) => e.isCritical).toList();
      final highOnly = sampleReports.where((e) => e.isHigh).toList();

      expect(criticalOnly.length, equals(1));
      expect(criticalOnly.first.severity, equals('critical'));

      expect(highOnly.length, equals(1));
      expect(highOnly.first.severity, equals('high'));
    });

    test('filters error reports by search query across multiple fields', () {
      // Search by message content
      final searchQuota = sampleReports.where((e) => e.message.toLowerCase().contains('quota')).toList();
      expect(searchQuota.length, equals(1));
      expect(searchQuota.first.fingerprint, equals('high_inv'));

      // Search by route
      final searchSettings = sampleReports.where((e) => e.route.toLowerCase().contains('settings')).toList();
      expect(searchSettings.length, equals(1));
      expect(searchSettings.first.fingerprint, equals('low_ignored'));

      // Search by browser
      final searchFirefox = sampleReports.where((e) => e.browser.toLowerCase().contains('firefox')).toList();
      expect(searchFirefox.length, equals(1));
      expect(searchFirefox.first.fingerprint, equals('high_inv'));
    });

    test('filters error reports by date timeframe', () {
      final now = DateTime.now();
      final last24h = sampleReports.where((e) {
        final ts = e.lastSeenAt;
        return ts != null && now.difference(ts).inHours < 24;
      }).toList();

      final olderThan24h = sampleReports.where((e) {
        final ts = e.lastSeenAt;
        return ts != null && now.difference(ts).inHours >= 24;
      }).toList();

      expect(last24h.length, equals(3));
      expect(olderThan24h.length, equals(1));
      expect(olderThan24h.first.fingerprint, equals('low_ignored'));
    });
  });
}
