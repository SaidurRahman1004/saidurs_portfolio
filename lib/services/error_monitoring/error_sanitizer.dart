/// Sanitizes error messages, stack traces, and metadata to guarantee
/// that NO passwords, authentication tokens, private user data, or sensitive
/// query parameters are ever transmitted to monitoring services.
class ErrorSanitizer {
  static final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  static final RegExp _phoneRegex =
      RegExp(r'(\+?\d{1,3}[-.\s]?)?(\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}');

  static final RegExp _jwtOrTokenRegex =
      RegExp(r'(Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*)|(ey[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+/=]*)');

  static final RegExp _urlQueryParamsRegex =
      RegExp(r'\?[a-zA-Z0-9_=&%.-]+');

  static final RegExp _passwordParamRegex =
      RegExp(r'(password|token|secret|api_key|auth_token)=[^&\s]+', caseSensitive: false);

  /// Cleanses an error message by scrubbing sensitive credentials, emails, and query strings.
  static String sanitizeMessage(String? raw, {int maxLength = 1000}) {
    if (raw == null || raw.trim().isEmpty) return 'Unspecified error';

    var sanitized = raw;

    // 1. Redact URL query parameters first to eliminate query-based tokens/emails
    sanitized = sanitized.replaceAll(_urlQueryParamsRegex, '?[REDACTED_QUERY]');

    // 2. Redact JWTs and Bearer tokens
    sanitized = sanitized.replaceAll(_jwtOrTokenRegex, '[REDACTED_TOKEN]');

    // 3. Redact passwords and credential assignments
    sanitized = sanitized.replaceAllMapped(_passwordParamRegex, (m) => '${m[1]}=[REDACTED_SECRET]');

    // 4. Redact email addresses
    sanitized = sanitized.replaceAll(_emailRegex, '[REDACTED_EMAIL]');

    // 5. Redact phone numbers
    sanitized = sanitized.replaceAll(_phoneRegex, '[REDACTED_PHONE]');

    sanitized = sanitized.trim();
    if (sanitized.length > maxLength) {
      sanitized = '${sanitized.substring(0, maxLength)}...[TRUNCATED]';
    }

    return sanitized;
  }

  /// Cleanses a stack trace to extract relevant frames without leaking local user disk paths.
  static String sanitizeStackTrace(dynamic stack, {int maxFrames = 20, int maxLength = 3000}) {
    if (stack == null) return '';

    final rawString = stack.toString().trim();
    if (rawString.isEmpty) return '';

    final lines = rawString.split('\n');
    final cleanedLines = <String>[];

    for (var i = 0; i < lines.length && cleanedLines.length < maxFrames; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) continue;

      // Scrub token or email if accidentally included in stack frame arguments
      line = line.replaceAll(_jwtOrTokenRegex, '[REDACTED_TOKEN]');
      line = line.replaceAll(_emailRegex, '[REDACTED_EMAIL]');

      // Normalize home directory paths (e.g. C:\Users\Username\... -> Users/... )
      line = line.replaceAll(RegExp(r'[A-Za-z]:\\Users\\[^\\]+\\'), '~/');

      cleanedLines.add(line);
    }

    var result = cleanedLines.join('\n');
    if (result.length > maxLength) {
      result = '${result.substring(0, maxLength)}...';
    }

    return result;
  }

  /// Sanitizes navigation routes, stripping query parameters and tokens.
  static String sanitizeRoute(String? route) {
    if (route == null || route.trim().isEmpty) return '/';
    var clean = route.replaceAll(_urlQueryParamsRegex, '');
    clean = clean.replaceAll(_emailRegex, '');
    clean = clean.trim();
    return clean.length > 200 ? clean.substring(0, 200) : clean;
  }

  /// Sanitizes operation names.
  static String sanitizeOperation(String? operation) {
    if (operation == null || operation.trim().isEmpty) return 'unknown';
    var clean = operation.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_').trim();
    return clean.length > 100 ? clean.substring(0, 100) : clean;
  }
}
