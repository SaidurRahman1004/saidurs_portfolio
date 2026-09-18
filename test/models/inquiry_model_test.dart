import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/models/inquiry_model.dart';

void main() {
  group('InquiryModel Tests', () {
    test('fromFirestore parses data correctly', () {
      final now = DateTime(2026, 9, 18, 12, 0, 0);
      final data = {
        'name': 'Sarah Jenkins',
        'email': 'sarah@techcorp.com',
        'phone': '+123456789',
        'subject': 'Senior Flutter Role',
        'message': 'We are impressed by your EzyDash work.',
        'projectType': 'Job Opportunity',
        'isRead': false,
        'isStarred': true,
        'createdAt': Timestamp.fromDate(now),
      };

      final inquiry = InquiryModel.fromFirestore('inq_1', data);

      expect(inquiry.id, 'inq_1');
      expect(inquiry.name, 'Sarah Jenkins');
      expect(inquiry.email, 'sarah@techcorp.com');
      expect(inquiry.phone, '+123456789');
      expect(inquiry.subject, 'Senior Flutter Role');
      expect(inquiry.message, 'We are impressed by your EzyDash work.');
      expect(inquiry.projectType, 'Job Opportunity');
      expect(inquiry.isRead, false);
      expect(inquiry.isStarred, true);
      expect(inquiry.createdAt, now);
    });

    test('toFirestore serializes fields correctly', () {
      final inquiry = InquiryModel(
        id: 'inq_2',
        name: 'Alex',
        email: 'alex@startup.io',
        subject: 'Mobile App Project',
        message: 'Need a Flutter app built.',
        projectType: 'Freelance Project',
        createdAt: DateTime.now(),
      );

      final map = inquiry.toFirestore();

      expect(map['name'], 'Alex');
      expect(map['email'], 'alex@startup.io');
      expect(map['subject'], 'Mobile App Project');
      expect(map['message'], 'Need a Flutter app built.');
      expect(map['projectType'], 'Freelance Project');
      expect(map['isRead'], false);
      expect(map['isStarred'], false);
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('copyWith updates fields while preserving others', () {
      final original = InquiryModel(
        id: 'inq_3',
        name: 'Mark',
        email: 'mark@mail.com',
        subject: 'Hello',
        message: 'Quick question',
        createdAt: DateTime(2026, 9, 1),
      );

      final updated = original.copyWith(isRead: true, isStarred: true);

      expect(updated.id, 'inq_3');
      expect(updated.name, 'Mark');
      expect(updated.isRead, true);
      expect(updated.isStarred, true);
    });
  });
}
