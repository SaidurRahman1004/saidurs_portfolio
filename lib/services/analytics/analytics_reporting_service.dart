import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../models/analytics_report_models.dart';

/// Secure client service for invoking the server-side [getAnalyticsReport] Cloud Function.
///
/// NOTE: Privileged GA4 credentials, service account keys, and Property IDs are NEVER
/// bundled or executed in Flutter Web. All reporting queries are executed on the secure
/// Firebase Functions backend with strict admin authentication.
class AnalyticsReportingService {
  static final AnalyticsReportingService _instance = AnalyticsReportingService._internal();

  factory AnalyticsReportingService() => _instance;

  AnalyticsReportingService._internal();

  static AnalyticsReportingService get instance => _instance;

  FirebaseFunctions? _functionsInstance;

  @visibleForTesting
  void setFunctionsInstanceForTesting(FirebaseFunctions functions) {
    _functionsInstance = functions;
  }

  FirebaseFunctions get _functions => _functionsInstance ?? FirebaseFunctions.instance;

  /// Fetches aggregated GA4 metrics and dimension breakdowns for the specified [dateRange].
  Future<AnalyticsReportResponse> getReport({
    AnalyticsDateRange dateRange = AnalyticsDateRange.last7Days,
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'getAnalyticsReport',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      final payload = <String, dynamic>{
        'dateRange': dateRange.code,
        'forceRefresh': forceRefresh,
      };

      if (dateRange == AnalyticsDateRange.custom) {
        if (startDate != null && startDate.isNotEmpty) payload['startDate'] = startDate;
        if (endDate != null && endDate.isNotEmpty) payload['endDate'] = endDate;
      }

      final result = await callable.call(payload);

      if (result.data == null || result.data is! Map) {
        return AnalyticsReportResponse.unconfigured(
          message: 'Malformed response received from Analytics backend.',
        );
      }

      final dataMap = Map<String, dynamic>.from(result.data as Map);
      return AnalyticsReportResponse.fromMap(dataMap);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[AnalyticsReportingService] Firebase Functions error: ${e.code} - ${e.message}');
      if (e.code == 'unauthenticated') {
        return AnalyticsReportResponse.unconfigured(
          message: 'Authentication required. Please log into the Admin Dashboard.',
        );
      } else if (e.code == 'permission-denied') {
        return AnalyticsReportResponse.unconfigured(
          message: 'Access denied. You do not have administrator permissions for Analytics.',
        );
      } else if (e.code == 'failed-precondition' || e.code == 'not-found') {
        return AnalyticsReportResponse.unconfigured(
          message: e.message ?? 'GA4 Data API is not configured on the backend.',
        );
      }
      return AnalyticsReportResponse.unconfigured(
        message: 'Backend error: ${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('[AnalyticsReportingService] Unexpected error: $e');
      return AnalyticsReportResponse.unconfigured(
        message: 'Unable to connect to Analytics reporting service: $e',
      );
    }
  }
}
