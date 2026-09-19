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

    test('fromFirestore and toFirestore handle dynamic profile and hero CMS fields', () {
      final data = {
        'email': 'saidur@example.com',
        'phone': '+8801795664122',
        'githubUrl': 'https://github.com/SaidurRahman1004',
        'location': 'Dhaka, Bangladesh',
        'whatsappNumber': '+8801795664122',
        'fullName': 'Custom Name',
        'title': 'Senior Flutter Engineer',
        'tagline': 'High Performance Apps',
        'heroDescription': 'Building mobile apps with 99.9% crash-free sessions',
        'aboutMe': 'Passionate engineer with experience in Flutter and backend.',
        'isOpenToWork': true,
        'openToWorkText': 'Available for Freelance & Full-time',
        'animatedRoles': ['Flutter Architect', 'Firebase Specialist'],
        'educationFact': 'Dhaka Poly',
        'locationFact': 'Dhaka',
        'focusFact': 'Flutter & Cloud',
        'goalFact': 'Lead Mobile Architect',
      };

      final contact = ContactModel.fromFirestore('info', data);

      expect(contact.fullName, 'Custom Name');
      expect(contact.title, 'Senior Flutter Engineer');
      expect(contact.tagline, 'High Performance Apps');
      expect(contact.isOpenToWork, isTrue);
      expect(contact.openToWorkText, 'Available for Freelance & Full-time');
      expect(contact.animatedRoles, ['Flutter Architect', 'Firebase Specialist']);
      expect(contact.educationFact, 'Dhaka Poly');

      final serialized = contact.toFirestore();
      expect(serialized['fullName'], 'Custom Name');
      expect(serialized['title'], 'Senior Flutter Engineer');
      expect(serialized['isOpenToWork'], isTrue);
      expect(serialized['animatedRoles'], ['Flutter Architect', 'Firebase Specialist']);
    });
  });
}
