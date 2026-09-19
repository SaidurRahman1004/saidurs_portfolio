import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates stable, deterministic error fingerprints for deduplicating
/// repeated error events without creating noisy document churn.
class ErrorFingerprinter {
  static final RegExp _uuidRegex = RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
  );

  static final RegExp _hexIdRegex = RegExp(r'\b[0-9a-fA-F]{16,64}\b');
  static final RegExp _numberRegex = RegExp(r'\b\d+\b');
  static final RegExp _lineNumberRegex = RegExp(r':\d+(:\d+)?');

  /// Computes a stable, 16-character hexadecimal fingerprint based on technical error data.
  static String computeFingerprint({
    required String type,
    required String message,
    String stackTrace = '',
  }) {
    // 1. Normalize message template (strip dynamic IDs, numbers, UUIDs)
    var normalizedMessage = message.trim().toLowerCase();
    normalizedMessage = normalizedMessage.replaceAll(_uuidRegex, '[UUID]');
    normalizedMessage = normalizedMessage.replaceAll(_hexIdRegex, '[HEX_ID]');
    normalizedMessage = normalizedMessage.replaceAll(_numberRegex, '[NUM]');

    // 2. Normalize top stack trace frames (strip line numbers so minor edits preserve fingerprint)
    final topFrames = _extractTopFrames(stackTrace);

    // 3. Composite technical string
    final rawSignature = '$type|$normalizedMessage|$topFrames';

    // 4. SHA-256 hash
    final bytes = utf8.encode(rawSignature);
    final digest = sha256.convert(bytes);

    // Return the first 16 characters of the hex digest
    return digest.toString().substring(0, 16);
  }

  /// Extracts and normalizes the top 2-3 significant stack frames.
  static String _extractTopFrames(String stackTrace, {int frameCount = 3}) {
    if (stackTrace.trim().isEmpty) return 'no_stack';

    final lines = stackTrace.split('\n');
    final significantFrames = <String>[];

    for (final rawLine in lines) {
      var line = rawLine.trim();
      if (line.isEmpty) continue;

      // Strip line and column numbers (:123:45 -> '')
      line = line.replaceAll(_lineNumberRegex, '');
      significantFrames.add(line);

      if (significantFrames.length >= frameCount) break;
    }

    return significantFrames.join(';');
  }
}
