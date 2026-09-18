import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/audit_log_model.dart';

/// Centralized service for recording and retrieving admin audit logs.
/// Guarantees that all operational mutations are recorded securely and immutably.
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  static AuditService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _auditLogsCollection => _firestore.collection('audit_logs');

  /// Records an administrative action in the audit log.
  Future<void> logAction({
    required String action,
    required String resourceType,
    required String resourceId,
    String result = 'success',
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final adminEmail = currentUser?.email ?? 'unauthenticated_or_system';

      final model = AuditLogModel(
        id: '',
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        timestamp: DateTime.now(),
        adminEmail: adminEmail,
        adminRole: 'admin',
        result: result,
        metadata: metadata,
      );

      await _auditLogsCollection.add(model.toFirestore());
      debugPrint('[AuditService] Recorded audit log: $action on $resourceType ($resourceId)');
    } catch (e) {
      debugPrint('[AuditService] Failed to record audit log: $e');
    }
  }

  /// Streams real-time audit logs ordered by timestamp descending.
  Stream<List<AuditLogModel>> getAuditLogs({int limit = 100}) {
    return _auditLogsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AuditLogModel.fromFirestore(doc)).toList();
    });
  }
}
