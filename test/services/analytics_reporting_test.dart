import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/analytics_report_models.dart';

void main() {
  group('Phase 6: AnalyticsDateRange Enum Tests', () {
    test('serializes correct date range codes', () {
      expect(AnalyticsDateRange.today.code, equals('today'));
      expect(AnalyticsDateRange.last7Days.code, equals('7d'));
      expect(AnalyticsDateRange.last30Days.code, equals('30d'));
      expect(AnalyticsDateRange.custom.code, equals('custom'));
    });

    test('parses from code accurately with safe fallback', () {
      expect(AnalyticsDateRange.fromCode('today'), equals(AnalyticsDateRange.today));
      expect(AnalyticsDateRange.fromCode('7d'), equals(AnalyticsDateRange.last7Days));
      expect(AnalyticsDateRange.fromCode('30d'), equals(AnalyticsDateRange.last30Days));
      expect(AnalyticsDateRange.fromCode('custom'), equals(AnalyticsDateRange.custom));
      expect(AnalyticsDateRange.fromCode('invalid_code'), equals(AnalyticsDateRange.last7Days));
    });
  });

  group('Phase 6: AnalyticsOverviewModel Tests', () {
    test('parses overview metrics from map correctly', () {
      final map = {
        'activeUsers': 150,
        'newUsers': 85,
        'sessions': 210,
        'screenPageViews': 620,
        'engagementRate': 0.654,
        'averageSessionDuration': 105.2,
        'eventCount': 1430,
      };

      final overview = AnalyticsOverviewModel.fromMap(map);

      expect(overview.activeUsers, equals(150));
      expect(overview.newUsers, equals(85));
      expect(overview.sessions, equals(210));
      expect(overview.screenPageViews, equals(620));
      expect(overview.engagementRate, closeTo(0.654, 0.001));
      expect(overview.averageSessionDuration, closeTo(105.2, 0.1));
      expect(overview.eventCount, equals(1430));

      expect(overview.formattedEngagementRate, equals('65.4%'));
      expect(overview.formattedAverageDuration, equals('1m 45s'));
      expect(overview.viewsPerSession, closeTo(2.95, 0.01));
    });

    test('formats duration under 1 minute as seconds', () {
      const overview = AnalyticsOverviewModel(averageSessionDuration: 42.0);
      expect(overview.formattedAverageDuration, equals('42s'));
    });

    test('empty constructor defaults to zero values without null crashes', () {
      const empty = AnalyticsOverviewModel.empty();
      expect(empty.activeUsers, equals(0));
      expect(empty.newUsers, equals(0));
      expect(empty.sessions, equals(0));
      expect(empty.screenPageViews, equals(0));
      expect(empty.engagementRate, equals(0.0));
      expect(empty.averageSessionDuration, equals(0.0));
      expect(empty.eventCount, equals(0));
      expect(empty.viewsPerSession, equals(0.0));
    });
  });

  group('Phase 6: AnalyticsTimeseriesPoint Tests', () {
    test('parses dashed and compact date strings into formatted dates', () {
      final pointDashed = AnalyticsTimeseriesPoint.fromMap({
        'date': '2026-09-18',
        'activeUsers': 25,
        'screenPageViews': 90,
        'sessions': 35,
      });

      final pointCompact = AnalyticsTimeseriesPoint.fromMap({
        'date': '20260918',
        'activeUsers': 30,
        'screenPageViews': 110,
        'sessions': 40,
      });

      expect(pointDashed.formattedDate, equals('Sep 18'));
      expect(pointCompact.formattedDate, equals('Sep 18'));
      expect(pointDashed.activeUsers, equals(25));
      expect(pointCompact.sessions, equals(40));
    });
  });

  group('Phase 6: Content Interactions Funnel Tests', () {
    test('computes project click totals and contact form conversion rate', () {
      final map = {
        'projects': {
          'detailsOpened': 45,
          'githubClicks': 15,
          'liveDemoClicks': 20,
          'googlePlayClicks': 5,
          'appStoreClicks': 2,
          'galleryInteractions': 10,
        },
        'resume': {
          'viewed': 60,
          'downloaded': 18,
        },
        'contact': {
          'ctaClicks': 35,
          'formStarts': 20,
          'formSubmits': 12,
          'formSuccess': 10,
          'formErrors': 2,
        },
      };

      final interactions = ContentInteractionsModel.fromMap(map);

      expect(interactions.projects.detailsOpened, equals(45));
      expect(interactions.projects.totalExternalClicks, equals(42));
      expect(interactions.resume.viewed, equals(60));
      expect(interactions.resume.downloaded, equals(18));
      expect(interactions.contact.formStarts, equals(20));
      expect(interactions.contact.formSuccess, equals(10));
      expect(interactions.contact.conversionRate, equals(50.0));
      expect(interactions.contact.formattedConversionRate, equals('50.0%'));
    });

    test('contact conversion rate handles zero starts safely without division by zero', () {
      const contact = ContactEngagementMetrics();
      expect(contact.conversionRate, equals(0.0));
      expect(contact.formattedConversionRate, equals('0.0%'));
    });
  });

  group('Phase 6: AnalyticsReportResponse Tests', () {
    test('parses unconfigured response with configuration guide', () {
      final map = {
        'configured': false,
        'propertyId': null,
        'message': 'GA4 Property ID is not configured.',
        'cached': false,
        'timestamp': '2026-09-18T12:00:00.000Z',
        'dateRange': '7d',
        'overview': {
          'activeUsers': 0,
          'sessions': 0,
        },
        'timeseries': [],
        'pages': [],
        'events': [],
        'devices': [],
        'browsers': [],
        'countries': [],
        'trafficSources': [],
        'configurationGuide': {
          'requiredEnvVars': ['GA4_PROPERTY_ID'],
          'serviceAccount': 'Firebase Default SA',
          'permissions': 'Viewer',
          'enableApi': 'analyticsdata.googleapis.com',
        },
      };

      final response = AnalyticsReportResponse.fromMap(map);

      expect(response.configured, isFalse);
      expect(response.propertyId, isNull);
      expect(response.message, contains('not configured'));
      expect(response.configurationGuide, isNotNull);
      expect(response.configurationGuide!.requiredEnvVars, contains('GA4_PROPERTY_ID'));
      expect(response.configurationGuide!.permissions, equals('Viewer'));
      expect(response.overview.activeUsers, equals(0));
    });

    test('parses configured live GA4 response with breakdown lists', () {
      final map = {
        'configured': true,
        'propertyId': '123456789',
        'message': 'Successfully retrieved live GA4 analytics metrics.',
        'cached': true,
        'timestamp': '2026-09-18T12:30:00.000Z',
        'dateRange': '7d',
        'overview': {
          'activeUsers': 250,
          'newUsers': 180,
          'sessions': 320,
          'screenPageViews': 850,
          'engagementRate': 0.72,
          'averageSessionDuration': 112.5,
          'eventCount': 2100,
        },
        'pages': [
          {'label': '/', 'count': 500, 'percentage': 58.8},
          {'label': '/admin', 'count': 200, 'percentage': 23.5},
        ],
        'devices': [
          {'label': 'desktop', 'count': 180, 'percentage': 72.0},
          {'label': 'mobile', 'count': 70, 'percentage': 28.0},
        ],
      };

      final response = AnalyticsReportResponse.fromMap(map);

      expect(response.configured, isTrue);
      expect(response.propertyId, equals('123456789'));
      expect(response.cached, isTrue);
      expect(response.overview.activeUsers, equals(250));
      expect(response.pages.length, equals(2));
      expect(response.pages.first.label, equals('/'));
      expect(response.pages.first.count, equals(500));
      expect(response.pages.first.formattedPercentage, equals('58.8%'));
      expect(response.devices.length, equals(2));
      expect(response.devices.first.label, equals('desktop'));
    });
  });
}
