/// Classifies errors into technical severity levels ('low', 'medium', 'high', 'critical')
/// based on objective failure modes rather than arbitrary assumptions.
class ErrorSeverityClassifier {
  /// Resolves the severity of an error based on technical indicators.
  static String classify({
    required dynamic exception,
    bool fatal = false,
    String? operation,
    String? route,
  }) {
    if (fatal) return 'critical';

    final errorString = exception.toString().toLowerCase();

    // 1. Critical: Security, Auth, Permission Denials, Root Render Failures
    if (errorString.contains('permission-denied') ||
        errorString.contains('unauthenticated') ||
        errorString.contains('securityexception') ||
        errorString.contains('corrupted') ||
        errorString.contains('outofmemory') ||
        errorString.contains('deadlock')) {
      return 'critical';
    }

    // 2. High: Data Mutation / User Action Failures
    final isCriticalOperation = operation != null &&
        (operation.contains('submit') ||
            operation.contains('save') ||
            operation.contains('delete') ||
            operation.contains('update') ||
            operation.contains('login') ||
            operation.contains('auth'));

    if (isCriticalOperation) return 'high';

    if (errorString.contains('unavailable') ||
        errorString.contains('network_error') ||
        errorString.contains('socketexception') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('deadline-exceeded')) {
      return 'high';
    }

    // 3. Low: Soft fallbacks, user cancellations, minor warnings
    if (errorString.contains('cancelled') ||
        errorString.contains('canceled') ||
        errorString.contains('user-aborted') ||
        errorString.contains('not-modified') ||
        errorString.contains('cached_miss')) {
      return 'low';
    }

    // 4. Default: Medium (general UI errors, render warnings, query retryables)
    return 'medium';
  }
}
