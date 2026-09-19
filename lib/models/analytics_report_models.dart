/// Supported analytics date range filters for admin reporting.
enum AnalyticsDateRange {
  today('today', 'Today'),
  last7Days('7d', 'Last 7 Days'),
  last30Days('30d', 'Last 30 Days'),
  custom('custom', 'Custom Range');

  final String code;
  final String label;

  const AnalyticsDateRange(this.code, this.label);

  static AnalyticsDateRange fromCode(String code) {
    switch (code) {
      case 'today':
        return AnalyticsDateRange.today;
      case '7d':
        return AnalyticsDateRange.last7Days;
      case '30d':
        return AnalyticsDateRange.last30Days;
      case 'custom':
        return AnalyticsDateRange.custom;
      default:
        return AnalyticsDateRange.last7Days;
    }
  }
}

/// Aggregate overview metrics for the selected time window.
class AnalyticsOverviewModel {
  final int activeUsers;
  final int newUsers;
  final int sessions;
  final int screenPageViews;
  final double engagementRate;
  final double averageSessionDuration;
  final int eventCount;

  const AnalyticsOverviewModel({
    this.activeUsers = 0,
    this.newUsers = 0,
    this.sessions = 0,
    this.screenPageViews = 0,
    this.engagementRate = 0.0,
    this.averageSessionDuration = 0.0,
    this.eventCount = 0,
  });

  factory AnalyticsOverviewModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AnalyticsOverviewModel.empty();

    return AnalyticsOverviewModel(
      activeUsers: (map['activeUsers'] as num?)?.toInt() ?? 0,
      newUsers: (map['newUsers'] as num?)?.toInt() ?? 0,
      sessions: (map['sessions'] as num?)?.toInt() ?? 0,
      screenPageViews: (map['screenPageViews'] as num?)?.toInt() ?? 0,
      engagementRate: (map['engagementRate'] as num?)?.toDouble() ?? 0.0,
      averageSessionDuration: (map['averageSessionDuration'] as num?)?.toDouble() ?? 0.0,
      eventCount: (map['eventCount'] as num?)?.toInt() ?? 0,
    );
  }

  const AnalyticsOverviewModel.empty()
      : activeUsers = 0,
        newUsers = 0,
        sessions = 0,
        screenPageViews = 0,
        engagementRate = 0.0,
        averageSessionDuration = 0.0,
        eventCount = 0;

  /// Formatted engagement rate percentage (e.g. "64.2%")
  String get formattedEngagementRate => '${(engagementRate * 100).toStringAsFixed(1)}%';

  /// Formatted average session duration (e.g. "1m 45s" or "32s")
  String get formattedAverageDuration {
    final totalSeconds = averageSessionDuration.round();
    if (totalSeconds < 60) return '${totalSeconds}s';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Average screen views per session
  double get viewsPerSession => sessions > 0 ? screenPageViews / sessions : 0.0;
}

/// Single point in the daily timeseries.
class AnalyticsTimeseriesPoint {
  final String date; // 'YYYY-MM-DD' or 'YYYYMMDD'
  final int activeUsers;
  final int screenPageViews;
  final int sessions;

  const AnalyticsTimeseriesPoint({
    required this.date,
    this.activeUsers = 0,
    this.screenPageViews = 0,
    this.sessions = 0,
  });

  factory AnalyticsTimeseriesPoint.fromMap(Map<String, dynamic> map) {
    return AnalyticsTimeseriesPoint(
      date: map['date']?.toString() ?? '',
      activeUsers: (map['activeUsers'] as num?)?.toInt() ?? 0,
      screenPageViews: (map['screenPageViews'] as num?)?.toInt() ?? 0,
      sessions: (map['sessions'] as num?)?.toInt() ?? 0,
    );
  }

  /// Parses date string to DateTime
  DateTime? get parsedDate {
    if (date.isEmpty) return null;
    if (date.contains('-')) return DateTime.tryParse(date);
    if (date.length == 8) {
      final y = int.tryParse(date.substring(0, 4)) ?? 2026;
      final m = int.tryParse(date.substring(4, 6)) ?? 1;
      final d = int.tryParse(date.substring(6, 8)) ?? 1;
      return DateTime(y, m, d);
    }
    return null;
  }

  /// User-friendly date string (e.g. 'Sep 18')
  String get formattedDate {
    final dt = parsedDate;
    if (dt == null) return date;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

/// Categorical breakdown item (pages, events, devices, browsers, countries, sources).
class AnalyticsBreakdownItem {
  final String label;
  final int count;
  final double percentage;

  const AnalyticsBreakdownItem({
    required this.label,
    required this.count,
    this.percentage = 0.0,
  });

  factory AnalyticsBreakdownItem.fromMap(Map<String, dynamic> map) {
    return AnalyticsBreakdownItem(
      label: map['label']?.toString() ?? (map['name']?.toString() ?? 'Unknown'),
      count: (map['count'] as num?)?.toInt() ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

/// Content interactions for projects.
class ProjectEngagementMetrics {
  final int detailsOpened;
  final int githubClicks;
  final int liveDemoClicks;
  final int googlePlayClicks;
  final int appStoreClicks;
  final int galleryInteractions;

  const ProjectEngagementMetrics({
    this.detailsOpened = 0,
    this.githubClicks = 0,
    this.liveDemoClicks = 0,
    this.googlePlayClicks = 0,
    this.appStoreClicks = 0,
    this.galleryInteractions = 0,
  });

  int get totalExternalClicks => githubClicks + liveDemoClicks + googlePlayClicks + appStoreClicks;

  factory ProjectEngagementMetrics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ProjectEngagementMetrics();
    return ProjectEngagementMetrics(
      detailsOpened: (map['detailsOpened'] as num?)?.toInt() ?? 0,
      githubClicks: (map['githubClicks'] as num?)?.toInt() ?? 0,
      liveDemoClicks: (map['liveDemoClicks'] as num?)?.toInt() ?? 0,
      googlePlayClicks: (map['googlePlayClicks'] as num?)?.toInt() ?? 0,
      appStoreClicks: (map['appStoreClicks'] as num?)?.toInt() ?? 0,
      galleryInteractions: (map['galleryInteractions'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Content interactions for resume.
class ResumeEngagementMetrics {
  final int viewed;
  final int downloaded;

  const ResumeEngagementMetrics({
    this.viewed = 0,
    this.downloaded = 0,
  });

  factory ResumeEngagementMetrics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ResumeEngagementMetrics();
    return ResumeEngagementMetrics(
      viewed: (map['viewed'] as num?)?.toInt() ?? 0,
      downloaded: (map['downloaded'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Content interactions for contact CTA and form funnel.
class ContactEngagementMetrics {
  final int ctaClicks;
  final int formStarts;
  final int formSubmits;
  final int formSuccess;
  final int formErrors;

  const ContactEngagementMetrics({
    this.ctaClicks = 0,
    this.formStarts = 0,
    this.formSubmits = 0,
    this.formSuccess = 0,
    this.formErrors = 0,
  });

  /// Conversion rate from form start to success
  double get conversionRate => formStarts > 0 ? (formSuccess / formStarts) * 100 : 0.0;

  String get formattedConversionRate => '${conversionRate.toStringAsFixed(1)}%';

  factory ContactEngagementMetrics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ContactEngagementMetrics();
    return ContactEngagementMetrics(
      ctaClicks: (map['ctaClicks'] as num?)?.toInt() ?? 0,
      formStarts: (map['formStarts'] as num?)?.toInt() ?? 0,
      formSubmits: (map['formSubmits'] as num?)?.toInt() ?? 0,
      formSuccess: (map['formSuccess'] as num?)?.toInt() ?? 0,
      formErrors: (map['formErrors'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Combined content interactions model.
class ContentInteractionsModel {
  final ProjectEngagementMetrics projects;
  final ResumeEngagementMetrics resume;
  final ContactEngagementMetrics contact;

  const ContentInteractionsModel({
    this.projects = const ProjectEngagementMetrics(),
    this.resume = const ResumeEngagementMetrics(),
    this.contact = const ContactEngagementMetrics(),
  });

  factory ContentInteractionsModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ContentInteractionsModel();
    return ContentInteractionsModel(
      projects: ProjectEngagementMetrics.fromMap(map['projects'] as Map<String, dynamic>?),
      resume: ResumeEngagementMetrics.fromMap(map['resume'] as Map<String, dynamic>?),
      contact: ContactEngagementMetrics.fromMap(map['contact'] as Map<String, dynamic>?),
    );
  }
}

/// Setup guidance when GA4 API credentials are not yet configured on the server.
class AnalyticsConfigurationGuide {
  final List<String> requiredEnvVars;
  final String serviceAccount;
  final String permissions;
  final String enableApi;

  const AnalyticsConfigurationGuide({
    this.requiredEnvVars = const [],
    this.serviceAccount = '',
    this.permissions = '',
    this.enableApi = '',
  });

  factory AnalyticsConfigurationGuide.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AnalyticsConfigurationGuide();
    return AnalyticsConfigurationGuide(
      requiredEnvVars: (map['requiredEnvVars'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      serviceAccount: map['serviceAccount']?.toString() ?? '',
      permissions: map['permissions']?.toString() ?? '',
      enableApi: map['enableApi']?.toString() ?? '',
    );
  }
}

/// Complete aggregated response returned by the [getAnalyticsReport] Cloud Function.
class AnalyticsReportResponse {
  final bool configured;
  final String? propertyId;
  final String message;
  final bool cached;
  final DateTime timestamp;
  final String dateRange;
  final AnalyticsOverviewModel overview;
  final List<AnalyticsTimeseriesPoint> timeseries;
  final List<AnalyticsBreakdownItem> pages;
  final List<AnalyticsBreakdownItem> events;
  final List<AnalyticsBreakdownItem> devices;
  final List<AnalyticsBreakdownItem> browsers;
  final List<AnalyticsBreakdownItem> countries;
  final List<AnalyticsBreakdownItem> trafficSources;
  final ContentInteractionsModel contentInteractions;
  final AnalyticsConfigurationGuide? configurationGuide;

  const AnalyticsReportResponse({
    required this.configured,
    this.propertyId,
    required this.message,
    this.cached = false,
    required this.timestamp,
    required this.dateRange,
    required this.overview,
    this.timeseries = const [],
    this.pages = const [],
    this.events = const [],
    this.devices = const [],
    this.browsers = const [],
    this.countries = const [],
    this.trafficSources = const [],
    this.contentInteractions = const ContentInteractionsModel(),
    this.configurationGuide,
  });

  factory AnalyticsReportResponse.fromMap(Map<String, dynamic> map) {
    List<AnalyticsBreakdownItem> parseBreakdown(dynamic list) {
      if (list is! List) return const [];
      return list.map((item) => AnalyticsBreakdownItem.fromMap(item as Map<String, dynamic>)).toList();
    }

    return AnalyticsReportResponse(
      configured: map['configured'] as bool? ?? false,
      propertyId: map['propertyId'] as String?,
      message: map['message'] as String? ?? '',
      cached: map['cached'] as bool? ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateRange: map['dateRange'] as String? ?? '7d',
      overview: AnalyticsOverviewModel.fromMap(map['overview'] as Map<String, dynamic>?),
      timeseries: (map['timeseries'] as List<dynamic>?)
              ?.map((item) => AnalyticsTimeseriesPoint.fromMap(item as Map<String, dynamic>))
              .toList() ??
          const [],
      pages: parseBreakdown(map['pages']),
      events: parseBreakdown(map['events']),
      devices: parseBreakdown(map['devices']),
      browsers: parseBreakdown(map['browsers']),
      countries: parseBreakdown(map['countries']),
      trafficSources: parseBreakdown(map['trafficSources']),
      contentInteractions: ContentInteractionsModel.fromMap(map['contentInteractions'] as Map<String, dynamic>?),
      configurationGuide: map['configurationGuide'] != null
          ? AnalyticsConfigurationGuide.fromMap(map['configurationGuide'] as Map<String, dynamic>)
          : null,
    );
  }

  factory AnalyticsReportResponse.unconfigured({String? message}) {
    return AnalyticsReportResponse(
      configured: false,
      message: message ??
          'GA4 Data API is not yet configured. Please set GA4_PROPERTY_ID in Cloud Functions and grant the service account Viewer access.',
      timestamp: DateTime.now(),
      dateRange: '7d',
      overview: const AnalyticsOverviewModel.empty(),
    );
  }
}
