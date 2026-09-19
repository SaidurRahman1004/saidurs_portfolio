import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/analytics_report_models.dart';
import 'package:futter_portfileo_website/models/project_model.dart';
import 'package:futter_portfileo_website/providers/analytics_dashboard_provider.dart';
import 'package:futter_portfileo_website/services/analytics/analytics_reporting_service.dart';
import 'package:futter_portfileo_website/widgets/admin/analytics/analytics_conversion_funnel.dart';
import 'package:futter_portfileo_website/widgets/admin/analytics/analytics_distribution_card.dart';
import 'package:futter_portfileo_website/widgets/admin/analytics/analytics_timeseries_chart.dart';
import 'package:futter_portfileo_website/widgets/admin/analytics/project_analytics_table.dart';

/// Fake AnalyticsReportingService for unit and widget testing.
class FakeAnalyticsReportingService implements AnalyticsReportingService {
  AnalyticsReportResponse responseToReturn;
  bool shouldThrow;
  int callCount = 0;

  FakeAnalyticsReportingService({
    required this.responseToReturn,
    this.shouldThrow = false,
  });

  @override
  void setFunctionsInstanceForTesting(dynamic functions) {}

  @override
  Future<AnalyticsReportResponse> getReport({
    AnalyticsDateRange dateRange = AnalyticsDateRange.last7Days,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Network timeout connecting to Cloud Function.');
    }
    return responseToReturn;
  }
}

void main() {
  final sampleOverview = const AnalyticsOverviewModel(
    activeUsers: 142,
    newUsers: 95,
    sessions: 210,
    screenPageViews: 580,
    engagementRate: 0.642,
    averageSessionDuration: 115.0,
    eventCount: 1250,
  );

  final sampleTimeseries = [
    const AnalyticsTimeseriesPoint(date: '2026-09-12', activeUsers: 20, screenPageViews: 75, sessions: 28),
    const AnalyticsTimeseriesPoint(date: '2026-09-13', activeUsers: 25, screenPageViews: 90, sessions: 35),
    const AnalyticsTimeseriesPoint(date: '2026-09-14', activeUsers: 18, screenPageViews: 65, sessions: 24),
    const AnalyticsTimeseriesPoint(date: '2026-09-15', activeUsers: 32, screenPageViews: 120, sessions: 45),
    const AnalyticsTimeseriesPoint(date: '2026-09-16', activeUsers: 28, screenPageViews: 110, sessions: 40),
    const AnalyticsTimeseriesPoint(date: '2026-09-17', activeUsers: 30, screenPageViews: 105, sessions: 38),
    const AnalyticsTimeseriesPoint(date: '2026-09-18', activeUsers: 35, screenPageViews: 130, sessions: 48),
  ];

  final sampleContentInteractions = const ContentInteractionsModel(
    projects: ProjectEngagementMetrics(
      detailsOpened: 45,
      githubClicks: 18,
      liveDemoClicks: 26,
      googlePlayClicks: 8,
      appStoreClicks: 5,
      galleryInteractions: 14,
    ),
    resume: ResumeEngagementMetrics(
      viewed: 38,
      downloaded: 22,
    ),
    contact: ContactEngagementMetrics(
      ctaClicks: 52,
      formStarts: 24,
      formSubmits: 14,
      formSuccess: 12,
      formErrors: 2,
    ),
  );

  final sampleDevices = [
    const AnalyticsBreakdownItem(label: 'desktop', count: 90, percentage: 63.4),
    const AnalyticsBreakdownItem(label: 'mobile', count: 45, percentage: 31.7),
    const AnalyticsBreakdownItem(label: 'tablet', count: 7, percentage: 4.9),
  ];

  final sampleBrowsers = [
    const AnalyticsBreakdownItem(label: 'Chrome', count: 85, percentage: 59.9),
    const AnalyticsBreakdownItem(label: 'Safari', count: 32, percentage: 22.5),
    const AnalyticsBreakdownItem(label: 'Firefox', count: 15, percentage: 10.6),
  ];

  final sampleCountries = [
    const AnalyticsBreakdownItem(label: 'United States', count: 62, percentage: 43.7),
    const AnalyticsBreakdownItem(label: 'Bangladesh', count: 40, percentage: 28.2),
    const AnalyticsBreakdownItem(label: 'Germany', count: 18, percentage: 12.7),
  ];

  final sampleEvents = [
    const AnalyticsBreakdownItem(label: 'email_click', count: 9, percentage: 0.7),
    const AnalyticsBreakdownItem(label: 'whatsapp_click', count: 6, percentage: 0.5),
    const AnalyticsBreakdownItem(label: 'linkedin_click', count: 14, percentage: 1.1),
    const AnalyticsBreakdownItem(label: 'github_click', count: 25, percentage: 2.0),
    const AnalyticsBreakdownItem(label: 'project_share', count: 7, percentage: 0.6),
  ];

  final mockReport = AnalyticsReportResponse(
    configured: true,
    propertyId: '123456789',
    message: 'Live GA4 Report',
    cached: false,
    timestamp: DateTime.now(),
    dateRange: '7d',
    overview: sampleOverview,
    timeseries: sampleTimeseries,
    devices: sampleDevices,
    browsers: sampleBrowsers,
    countries: sampleCountries,
    events: sampleEvents,
    contentInteractions: sampleContentInteractions,
  );

  group('Phase 7: AnalyticsDashboardProvider Tests', () {
    test('initializes with default date range and default chart metric', () {
      final fakeService = FakeAnalyticsReportingService(responseToReturn: mockReport);
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      expect(provider.selectedDateRange, equals(AnalyticsDateRange.last7Days));
      expect(provider.activeChartMetric, equals('activeUsers'));
      expect(provider.isLoading, isFalse);
      expect(provider.report, isNull);
    });

    test('loads analytics successfully and populates report and baselines', () async {
      final fakeService = FakeAnalyticsReportingService(responseToReturn: mockReport);
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      await provider.loadAnalytics();

      expect(provider.report, isNotNull);
      expect(provider.report!.configured, isTrue);
      expect(provider.isConfigured, isTrue);
      expect(provider.sevenDayActiveUsers, equals(142));
      expect(provider.todayActiveUsers, equals(35)); // from last timeseries point
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('switching date ranges calls reporting service with new range', () async {
      final fakeService = FakeAnalyticsReportingService(responseToReturn: mockReport);
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      await provider.setDateRange(AnalyticsDateRange.today);
      expect(provider.selectedDateRange, equals(AnalyticsDateRange.today));

      await provider.setDateRange(AnalyticsDateRange.last30Days);
      expect(provider.selectedDateRange, equals(AnalyticsDateRange.last30Days));

      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 15);
      await provider.setDateRange(AnalyticsDateRange.custom, customStart: start, customEnd: end);
      expect(provider.selectedDateRange, equals(AnalyticsDateRange.custom));
      expect(provider.customStartDate, equals(start));
      expect(provider.customEndDate, equals(end));
    });

    test('toggles active chart metric smoothly', () {
      final fakeService = FakeAnalyticsReportingService(responseToReturn: mockReport);
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      expect(provider.activeChartMetric, equals('activeUsers'));
      provider.setActiveChartMetric('screenPageViews');
      expect(provider.activeChartMetric, equals('screenPageViews'));
      provider.setActiveChartMetric('sessions');
      expect(provider.activeChartMetric, equals('sessions'));
    });

    test('handles reporting service exceptions gracefully with error message', () async {
      final fakeService = FakeAnalyticsReportingService(
        responseToReturn: mockReport,
        shouldThrow: true,
      );
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      await provider.loadAnalytics();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Failed to load analytics'));
    });

    test('uses memory cache for duplicate date range queries unless forceRefresh is true', () async {
      final fakeService = FakeAnalyticsReportingService(responseToReturn: mockReport);
      final provider = AnalyticsDashboardProvider(reportingService: fakeService);

      await provider.loadAnalytics();
      final initialCount = fakeService.callCount;

      // Calling loadAnalytics again with same range should hit cache
      await provider.loadAnalytics(forceRefresh: false);
      expect(fakeService.callCount, equals(initialCount));

      // Force refresh bypasses cache
      await provider.loadAnalytics(forceRefresh: true);
      expect(fakeService.callCount, greaterThan(initialCount));
    });
  });

  group('Phase 7: Analytics UI Widgets Tests', () {
    testWidgets('AnalyticsTimeseriesChart renders metric buttons and loyalty segment', (tester) async {
      String selectedMetric = 'activeUsers';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsTimeseriesChart(
                points: sampleTimeseries,
                activeMetric: selectedMetric,
                onMetricChanged: (m) => selectedMetric = m,
                newUsers: 95,
                totalActiveUsers: 142,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Traffic Over Time'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Page Views'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.textContaining('New Users: 95'), findsOneWidget);
    });

    testWidgets('AnalyticsDistributionCard renders items with percentages and icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsDistributionCard(
                title: 'Device Categories',
                icon: Icons.devices_rounded,
                items: sampleDevices,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Device Categories'), findsOneWidget);
      expect(find.text('desktop'), findsOneWidget);
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('63.4%'), findsOneWidget);
      expect(find.text('31.7%'), findsOneWidget);
      expect(find.text('4.9%'), findsOneWidget);
    });

    testWidgets('AnalyticsConversionFunnel renders contact steps and resume metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsConversionFunnel(
                contentInteractions: sampleContentInteractions,
                events: sampleEvents,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Contact & Inquiries Conversion Funnel'), findsOneWidget);
      expect(find.text('CTA & Hire Me Clicks'), findsOneWidget);
      expect(find.text('Contact Form Starts'), findsOneWidget);
      expect(find.text('Submissions Attempted'), findsOneWidget);
      expect(find.text('Successful Deliveries'), findsOneWidget);
      expect(find.text('Resume & CV Performance'), findsOneWidget);
      expect(find.text('Direct & Social Outreach'), findsOneWidget);
      expect(find.text('9 clicks'), findsOneWidget); // Email clicks
    });

    testWidgets('ProjectAnalyticsTable renders popular project banner and table', (tester) async {
      final projects = [
        ProjectModel(
          id: 'p1',
          title: 'Antigravity AI IDE',
          category: 'Developer Tools',
          createdAt: DateTime.now(),
          githubUrl: 'https://github.com/test/antigravity',
          liveUrl: 'https://antigravity.demo',
        ),
        ProjectModel(
          id: 'p2',
          title: 'Saidurs Portfolio',
          category: 'Portfolio Web',
          createdAt: DateTime.now(),
          githubUrl: 'https://github.com/test/portfolio',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectAnalyticsTable(
                projects: projects,
                contentInteractions: sampleContentInteractions,
                pages: const [AnalyticsBreakdownItem(label: '/project/antigravity', count: 42, percentage: 50.0)],
                events: sampleEvents,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Content Analytics: Projects'), findsOneWidget);
      expect(find.text('MOST POPULAR PROJECT'), findsOneWidget);
      expect(find.text('Antigravity AI IDE'), findsWidgets);
    });
  });
}
