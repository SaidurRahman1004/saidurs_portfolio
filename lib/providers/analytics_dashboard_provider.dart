import 'package:flutter/foundation.dart';
import '../models/analytics_report_models.dart';
import '../services/analytics/analytics_reporting_service.dart';

/// State management provider for the Admin Analytics Dashboard.
///
/// Handles date range filtering, cached report data, active metric selection,
/// and interaction with the Phase 6 secure backend [AnalyticsReportingService].
class AnalyticsDashboardProvider extends ChangeNotifier {
  final AnalyticsReportingService _reportingService;

  AnalyticsDashboardProvider({AnalyticsReportingService? reportingService})
      : _reportingService = reportingService ?? AnalyticsReportingService.instance;

  AnalyticsReportResponse? _report;
  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsDateRange _selectedDateRange = AnalyticsDateRange.last7Days;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Active chart metric: 'activeUsers', 'screenPageViews', or 'sessions'
  String _activeChartMetric = 'activeUsers';

  // Overview headline baseline metrics
  int _todayActiveUsers = 0;
  int _sevenDayActiveUsers = 0;
  int _thirtyDayActiveUsers = 0;

  // Local memory cache keyed by filter
  final Map<String, AnalyticsReportResponse> _cache = {};

  // Getters
  AnalyticsReportResponse? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnalyticsDateRange get selectedDateRange => _selectedDateRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  String get activeChartMetric => _activeChartMetric;

  int get todayActiveUsers => _todayActiveUsers;
  int get sevenDayActiveUsers => _sevenDayActiveUsers;
  int get thirtyDayActiveUsers => _thirtyDayActiveUsers;

  bool get isConfigured => _report?.configured ?? false;

  /// Returns the cache key for the given filter parameters
  String _getCacheKey(AnalyticsDateRange range, DateTime? start, DateTime? end) {
    if (range == AnalyticsDateRange.custom) {
      final s = start?.toIso8601String().split('T').first ?? '';
      final e = end?.toIso8601String().split('T').first ?? '';
      return 'custom_${s}_$e';
    }
    return range.code;
  }

  /// Initial load or refresh of analytics data.
  Future<void> loadAnalytics({bool forceRefresh = false}) async {
    final key = _getCacheKey(_selectedDateRange, _customStartDate, _customEndDate);

    if (forceRefresh) {
      _cache.clear();
    } else if (_cache.containsKey(key)) {
      _report = _cache[key];
      _errorMessage = null;
      _updateBaselineCards(_selectedDateRange, _report!);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? startStr;
      String? endStr;
      if (_selectedDateRange == AnalyticsDateRange.custom) {
        startStr = _customStartDate?.toIso8601String().split('T').first;
        endStr = _customEndDate?.toIso8601String().split('T').first;
      }

      final response = await _reportingService.getReport(
        dateRange: _selectedDateRange,
        startDate: startStr,
        endDate: endStr,
        forceRefresh: forceRefresh,
      );

      _report = response;
      _cache[key] = response;
      _updateBaselineCards(_selectedDateRange, response);

      // Opportunistically populate 7d and today baselines if not populated yet
      if (response.configured && (_todayActiveUsers == 0 || _sevenDayActiveUsers == 0)) {
        _populateSecondaryBaselines(forceRefresh);
      }
    } catch (e) {
      debugPrint('[AnalyticsDashboardProvider] Error loading analytics: $e');
      _errorMessage = 'Failed to load analytics: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateBaselineCards(AnalyticsDateRange range, AnalyticsReportResponse res) {
    if (range == AnalyticsDateRange.today) {
      _todayActiveUsers = res.overview.activeUsers;
    } else if (range == AnalyticsDateRange.last7Days) {
      _sevenDayActiveUsers = res.overview.activeUsers;
      // If timeseries has today's data point at the end, use it
      if (res.timeseries.isNotEmpty) {
        _todayActiveUsers = res.timeseries.last.activeUsers;
      }
    } else if (range == AnalyticsDateRange.last30Days) {
      _thirtyDayActiveUsers = res.overview.activeUsers;
    }
  }

  Future<void> _populateSecondaryBaselines(bool forceRefresh) async {
    try {
      if (_selectedDateRange != AnalyticsDateRange.last7Days && !_cache.containsKey('7d')) {
        final res7 = await _reportingService.getReport(
          dateRange: AnalyticsDateRange.last7Days,
          forceRefresh: forceRefresh,
        );
        _cache['7d'] = res7;
        _sevenDayActiveUsers = res7.overview.activeUsers;
        if (res7.timeseries.isNotEmpty && _todayActiveUsers == 0) {
          _todayActiveUsers = res7.timeseries.last.activeUsers;
        }
      }
      if (_selectedDateRange != AnalyticsDateRange.last30Days && !_cache.containsKey('30d')) {
        final res30 = await _reportingService.getReport(
          dateRange: AnalyticsDateRange.last30Days,
          forceRefresh: forceRefresh,
        );
        _cache['30d'] = res30;
        _thirtyDayActiveUsers = res30.overview.activeUsers;
      }
      notifyListeners();
    } catch (_) {
      // Non-critical background baseline fetch
    }
  }

  /// Changes the active date range and fetches updated data.
  Future<void> setDateRange(
    AnalyticsDateRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    if (_selectedDateRange == range &&
        _customStartDate == customStart &&
        _customEndDate == customEnd) {
      return;
    }

    _selectedDateRange = range;
    _customStartDate = customStart;
    _customEndDate = customEnd;

    await loadAnalytics();
  }

  /// Changes the metric displayed in the main timeseries chart.
  void setActiveChartMetric(String metric) {
    if (_activeChartMetric == metric) return;
    _activeChartMetric = metric;
    notifyListeners();
  }
}
