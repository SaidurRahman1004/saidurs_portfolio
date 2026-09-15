import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futter_portfileo_website/models/contact_model.dart';

void main() {
  group('ContactModel', () {
    test('fromFirestore handles null urls gracefully', () {
      final data = {
        'email': 'test@test.com',
        'phone': '123456789',
        'githubUrl': 'http://github.com',
        'location': 'Earth',
        'whatsappNumber': '987654321',
        // Optional URLs are intentionally missing
      };

      final contact = ContactModel.fromFirestore('info', data);

      expect(contact.linkedinUrl, isNull);
      expect(contact.resumeUrl, isNull);
      expect(contact.profileImageUrl, isNull);
      expect(contact.heroImageUrl, isNull);
      expect(contact.email, 'test@test.com');
    });

    test('fromFirestore handles timestamps safely', () {
      final timestamp = Timestamp.now();
      final data = {
        'email': 'test@test.com',
        'phone': '123',
        'githubUrl': 'url',
        'location': 'loc',
        'whatsappNumber': '123',
        'updatedAt': timestamp,
      };

      final contact = ContactModel.fromFirestore('info', data);

      expect(contact.updatedAt, timestamp.toDate());
    });

    test('fromFirestore handles String date safely', () {
      final now = DateTime.now();
      final data = {
        'email': 'test@test.com',
        'phone': '123',
        'githubUrl': 'url',
        'location': 'loc',
        'whatsappNumber': '123',
        'updatedAt': now.toIso8601String(),
      };

      final contact = ContactModel.fromFirestore('info', data);

      expect(contact.updatedAt?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toFirestore serializes correctly including server timestamp', () {
      final contact = ContactModel(
        id: 'info',
        email: 'test@test.com',
        phone: '123',
        githubUrl: 'url',
        location: 'loc',
        whatsappNumber: '123',
      );

      final map = contact.toFirestore();

      expect(map['email'], 'test@test.com');
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('copyWith updates fields and preserves updatedAt', () {
      final now = DateTime.now();
      final contact = ContactModel(
        id: 'info',
        email: 'test@test.com',
        phone: '123',
        githubUrl: 'url',
        location: 'loc',
        whatsappNumber: '123',
        updatedAt: now,
      );

      final updated = contact.copyWith(email: 'new@test.com');

      expect(updated.email, 'new@test.com');
      expect(updated.updatedAt, now);
    });
  });
}
