import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/audit_log_model.dart';

void main() {
  group('AuditLogModel Tests', () {
    final testDate = DateTime(2026, 9, 18, 14, 30, 0);

    test('fromMap with Timestamp parses data correctly', () {
      final data = {
        'action': 'project_create',
        'resourceType': 'project',
        'resourceId': 'proj_101',
        'timestamp': Timestamp.fromDate(testDate),
        'adminEmail': 'saidurrahman1004@gmail.com',
        'adminRole': 'super_admin',
        'result': 'success',
        'metadata': {
          'title': 'EzyDash AI',
          'category': 'Mobile Application',
        },
      };

      final log = AuditLogModel.fromMap('log_1', data);

      expect(log.id, 'log_1');
      expect(log.action, 'project_create');
      expect(log.resourceType, 'project');
      expect(log.resourceId, 'proj_101');
      expect(log.timestamp, testDate);
      expect(log.adminEmail, 'saidurrahman1004@gmail.com');
      expect(log.adminRole, 'super_admin');
      expect(log.result, 'success');
      expect(log.isSuccess, isTrue);
      expect(log.metadata['title'], 'EzyDash AI');
      expect(log.actionTitle, 'Create Project');
    });

    test('fromMap with String timestamp parses correctly', () {
      final data = {
        'action': 'admin_login',
        'resourceType': 'auth',
        'resourceId': 'usr_admin',
        'timestamp': testDate.toIso8601String(),
        'adminEmail': 'admin@domain.com',
        'result': 'success',
      };

      final log = AuditLogModel.fromMap('log_2', data);

      expect(log.timestamp.year, testDate.year);
      expect(log.timestamp.minute, testDate.minute);
      expect(log.adminRole, 'admin'); // Default
      expect(log.actionTitle, 'Admin Login');
    });

    test('fromMap fallback when timestamp is invalid or absent', () {
      final data = {
        'action': 'skill_delete',
        'resourceType': 'skill',
        'resourceId': 'skill_99',
        'result': 'failure',
      };

      final log = AuditLogModel.fromMap('log_3', data);

      expect(log.timestamp, isA<DateTime>());
      expect(log.isSuccess, isFalse);
      expect(log.actionTitle, 'Delete Skill');
    });

    test('toFirestore serializes fields and sets serverTimestamp', () {
      final log = AuditLogModel(
        id: 'log_4',
        action: 'visibility_toggle',
        resourceType: 'project',
        resourceId: 'proj_202',
        timestamp: testDate,
        adminEmail: 'saidurrahman1004@gmail.com',
        adminRole: 'admin',
        result: 'success',
        metadata: {'isVisible': false},
      );

      final map = log.toFirestore();

      expect(map['action'], 'visibility_toggle');
      expect(map['resourceType'], 'project');
      expect(map['resourceId'], 'proj_202');
      expect(map['adminEmail'], 'saidurrahman1004@gmail.com');
      expect(map['adminRole'], 'admin');
      expect(map['result'], 'success');
      expect(map['metadata']['isVisible'], false);
      expect(map['timestamp'], isA<FieldValue>());
    });

    test('actionTitle formats recognized and unrecognized actions', () {
      final recognized = AuditLogModel(
        id: '1',
        action: 'failed_privileged_operation',
        resourceType: 'security',
        resourceId: 'none',
        timestamp: DateTime.now(),
        adminEmail: 'test@test.com',
        result: 'failure',
      );
      expect(recognized.actionTitle, 'Failed Privileged Action');

      final unrecognized = AuditLogModel(
        id: '2',
        action: 'custom_cache_flush',
        resourceType: 'system',
        resourceId: 'none',
        timestamp: DateTime.now(),
        adminEmail: 'test@test.com',
        result: 'success',
      );
      expect(unrecognized.actionTitle, 'CUSTOM CACHE FLUSH');
    });

    test('sanitizeMetadata strips sensitive keys and passwords', () {
      final input = {
        'safeField': 'Safe Value',
        'user_password': 'SuperSecretPassword123!',
        'auth_token': 'eyJh...token...string',
        'secret_key': '09f87d6e5a4',
        'apiKey': 'AIzaSy1234567890',
        'inquiry_message': 'Confidential client message text',
        'credential_ref': 'service-account.json',
        'numericMetric': 42,
        'booleanFlag': true,
        'listValues': ['item1', 'item2'],
      };

      final sanitized = AuditLogModel.sanitizeMetadata(input);

      // Safe fields preserved
      expect(sanitized['safeField'], 'Safe Value');
      expect(sanitized['numericMetric'], 42);
      expect(sanitized['booleanFlag'], true);
      expect(sanitized['listValues'], ['item1', 'item2']);

      // Sensitive fields redacted / omitted
      expect(sanitized.containsKey('user_password'), isFalse);
      expect(sanitized.containsKey('auth_token'), isFalse);
      expect(sanitized.containsKey('secret_key'), isFalse);
      expect(sanitized.containsKey('apiKey'), isFalse);
      expect(sanitized.containsKey('inquiry_message'), isFalse);
      expect(sanitized.containsKey('credential_ref'), isFalse);
    });

    test('sanitizeMetadata handles empty or null input gracefully', () {
      expect(AuditLogModel.sanitizeMetadata(null), isEmpty);
      expect(AuditLogModel.sanitizeMetadata({}), isEmpty);
    });
  });
}
