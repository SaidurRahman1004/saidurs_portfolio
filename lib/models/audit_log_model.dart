import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable model representing an administrator action or operational security event.
/// Strictly enforces PII redaction and omits passwords, auth tokens, secrets, or personal messages.
class AuditLogModel {
  final String id;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final String adminEmail;
  final String adminRole;
  final String result; // 'success' or 'failure'
  final Map<String, dynamic> metadata;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    required this.adminEmail,
    this.adminRole = 'admin',
    required this.result,
    this.metadata = const {},
  });

  bool get isSuccess => result.toLowerCase() == 'success';

  /// Human-readable title for the audit action
  String get actionTitle {
    switch (action.toLowerCase()) {
      case 'admin_login':
        return 'Admin Login';
      case 'admin_logout':
        return 'Admin Logout';
      case 'project_create':
        return 'Create Project';
      case 'project_update':
        return 'Update Project';
      case 'project_delete':
        return 'Delete Project';
      case 'visibility_toggle':
        return 'Toggle Visibility';
      case 'featured_toggle':
        return 'Toggle Featured Status';
      case 'skill_create':
        return 'Create Skill';
      case 'skill_update':
        return 'Update Skill';
      case 'skill_delete':
        return 'Delete Skill';
      case 'experience_update':
        return 'Update Experience';
      case 'education_update':
        return 'Update Education';
      case 'certification_update':
        return 'Update Certification';
      case 'profile_update':
        return 'Update Bio & Profile';
      case 'resume_update':
        return 'Update Resume';
      case 'contact_update':
        return 'Update Contact Info';
      case 'settings_update':
        return 'Update Settings';
      case 'inquiry_status_update':
        return 'Update Inquiry Status';
      case 'inquiry_delete':
        return 'Delete Inquiry';
      case 'error_status_update':
        return 'Triage Error Report';
      case 'failed_privileged_operation':
        return 'Failed Privileged Action';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  factory AuditLogModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    if (data['timestamp'] is Timestamp) {
      parsedDate = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      parsedDate = DateTime.tryParse(data['timestamp'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawMeta = data['metadata'];
    final sanitizedMeta = rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : <String, dynamic>{};

    return AuditLogModel(
      id: id,
      action: data['action']?.toString() ?? 'unknown_action',
      resourceType: data['resourceType']?.toString() ?? 'general',
      resourceId: data['resourceId']?.toString() ?? 'none',
      timestamp: parsedDate,
      adminEmail: data['adminEmail']?.toString() ?? 'unknown',
      adminRole: data['adminRole']?.toString() ?? 'admin',
      result: data['result']?.toString() ?? 'success',
      metadata: sanitizeMetadata(sanitizedMeta),
    );
  }

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuditLogModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'timestamp': FieldValue.serverTimestamp(),
      'adminEmail': adminEmail,
      'adminRole': adminRole,
      'result': result,
      'metadata': sanitizeMetadata(metadata),
    };
  }

  /// Strictly strips sensitive keys (passwords, tokens, credentials, inquiry text, secrets)
  static Map<String, dynamic> sanitizeMetadata(Map<String, dynamic>? input) {
    if (input == null || input.isEmpty) return {};

    final sanitized = <String, dynamic>{};
    final forbiddenKeys = [
      'password',
      'token',
      'secret',
      'apikey',
      'api_key',
      'credential',
      'auth',
      'message',
      'inquiry_body',
    ];

    for (final entry in input.entries) {
      final lowerKey = entry.key.toLowerCase();
      final isForbidden = forbiddenKeys.any((fk) => lowerKey.contains(fk));

      if (!isForbidden) {
        if (entry.value is String || entry.value is num || entry.value is bool || entry.value is List) {
          sanitized[entry.key] = entry.value;
        }
      }
    }

    return sanitized;
  }
}
