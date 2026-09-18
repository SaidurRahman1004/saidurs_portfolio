import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a structured error report logged from Flutter Web or mobile platforms.
class ErrorReportModel {
  final String fingerprint;
  final String type;
  final String severity; // 'low' | 'medium' | 'high' | 'critical'
  final String status; // 'open' | 'investigating' | 'resolved' | 'ignored'
  final String message;
  final String route;
  final String operation;
  final String platform;
  final String browser;
  final String appVersion;
  final String stackTrace;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;
  final int occurrenceCount;
  final String? assignedTo;
  final List<String> notes;

  const ErrorReportModel({
    required this.fingerprint,
    required this.type,
    required this.severity,
    this.status = 'open',
    required this.message,
    this.route = '/',
    this.operation = 'unknown',
    this.platform = 'web',
    this.browser = 'unknown',
    this.appVersion = '1.0.0+1',
    this.stackTrace = '',
    this.firstSeenAt,
    this.lastSeenAt,
    this.occurrenceCount = 1,
    this.assignedTo,
    this.notes = const [],
  });

  /// Short reference code for user-friendly UI display (e.g. '#e4d7a8')
  String get referenceCode => '#${fingerprint.length >= 6 ? fingerprint.substring(0, 6) : fingerprint}';

  /// Status helpers
  bool get isOpen => status == 'open' || status == 'unresolved';
  bool get isInvestigating => status == 'investigating';
  bool get isResolved => status == 'resolved';
  bool get isIgnored => status == 'ignored';

  /// Severity helpers
  bool get isCritical => severity.toLowerCase() == 'critical';
  bool get isHigh => severity.toLowerCase() == 'high';
  bool get isMedium => severity.toLowerCase() == 'medium';
  bool get isLow => severity.toLowerCase() == 'low';

  /// Returns true if this error has occurred within the last 24 hours
  bool get isLast24Hours {
    final timestamp = lastSeenAt ?? firstSeenAt;
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp).inHours < 24;
  }

  /// User-friendly relative or calendar string for last occurrence
  String get formattedLastSeen {
    if (lastSeenAt == null) return 'Never';
    final diff = DateTime.now().difference(lastSeenAt!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastSeenAt!.year}-${lastSeenAt!.month.toString().padLeft(2, '0')}-${lastSeenAt!.day.toString().padLeft(2, '0')}';
  }

  /// User-friendly calendar string for first occurrence
  String get formattedFirstSeen {
    if (firstSeenAt == null) return 'Unknown';
    return '${firstSeenAt!.year}-${firstSeenAt!.month.toString().padLeft(2, '0')}-${firstSeenAt!.day.toString().padLeft(2, '0')} ${firstSeenAt!.hour.toString().padLeft(2, '0')}:${firstSeenAt!.minute.toString().padLeft(2, '0')}';
  }

  /// Serializes model into a payload for the [reportWebError] Callable Cloud Function.
  Map<String, dynamic> toCallablePayload() {
    return {
      'fingerprint': fingerprint,
      'type': type,
      'severity': severity,
      'message': message,
      'route': route,
      'operation': operation,
      'platform': platform,
      'browser': browser,
      'appVersion': appVersion,
      'stackTrace': stackTrace,
    };
  }

  /// Serializes model into Firestore document format.
  Map<String, dynamic> toFirestore() {
    return {
      'fingerprint': fingerprint,
      'type': type,
      'severity': severity,
      'status': status,
      'message': message,
      'route': route,
      'operation': operation,
      'platform': platform,
      'browser': browser,
      'appVersion': appVersion,
      'stackTrace': stackTrace,
      'firstSeenAt': firstSeenAt != null ? Timestamp.fromDate(firstSeenAt!) : FieldValue.serverTimestamp(),
      'lastSeenAt': lastSeenAt != null ? Timestamp.fromDate(lastSeenAt!) : FieldValue.serverTimestamp(),
      'occurrenceCount': occurrenceCount,
      'assignedTo': assignedTo,
      'notes': notes,
    };
  }

  /// Parses model from a Firestore snapshot.
  factory ErrorReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ErrorReportModel.fromMap(data, id: doc.id);
  }

  /// Parses model from a plain map.
  factory ErrorReportModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    final rawStatus = map['status'] as String? ?? 'open';
    // Normalize legacy 'unresolved' to 'open'
    final normalizedStatus = rawStatus == 'unresolved' ? 'open' : rawStatus;

    return ErrorReportModel(
      fingerprint: id ?? (map['fingerprint'] as String? ?? 'unknown_fingerprint'),
      type: map['type'] as String? ?? 'unknown_error',
      severity: map['severity'] as String? ?? 'medium',
      status: normalizedStatus,
      message: map['message'] as String? ?? '',
      route: map['route'] as String? ?? '/',
      operation: map['operation'] as String? ?? 'unknown',
      platform: map['platform'] as String? ?? 'web',
      browser: map['browser'] as String? ?? 'unknown',
      appVersion: map['appVersion'] as String? ?? '1.0.0+1',
      stackTrace: map['stackTrace'] as String? ?? '',
      firstSeenAt: parseDate(map['firstSeenAt']),
      lastSeenAt: parseDate(map['lastSeenAt']),
      occurrenceCount: (map['occurrenceCount'] as num?)?.toInt() ?? 1,
      assignedTo: map['assignedTo'] as String?,
      notes: (map['notes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  ErrorReportModel copyWith({
    String? fingerprint,
    String? type,
    String? severity,
    String? status,
    String? message,
    String? route,
    String? operation,
    String? platform,
    String? browser,
    String? appVersion,
    String? stackTrace,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    int? occurrenceCount,
    String? assignedTo,
    List<String>? notes,
  }) {
    return ErrorReportModel(
      fingerprint: fingerprint ?? this.fingerprint,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      message: message ?? this.message,
      route: route ?? this.route,
      operation: operation ?? this.operation,
      platform: platform ?? this.platform,
      browser: browser ?? this.browser,
      appVersion: appVersion ?? this.appVersion,
      stackTrace: stackTrace ?? this.stackTrace,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
    );
  }
}
