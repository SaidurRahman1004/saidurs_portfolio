import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futter_portfileo_website/models/skill_model.dart';

void main() {
  group('SkillModel', () {
    test('fromFirestore parses iconCode from string or int safely', () {
      final dataInt = {
        'name': 'Flutter',
        'category': 'Mobile',
        'iconCode': 12345,
      };

      final dataString = {
        'name': 'Firebase',
        'category': 'Backend',
        'iconCode': '54321',
      };

      final dataInvalid = {
        'name': 'Invalid',
        'category': 'Other',
        'iconCode': 'invalid_string',
      };

      final skillInt = SkillModel.fromFirestore('1', dataInt);
      final skillString = SkillModel.fromFirestore('2', dataString);
      final skillInvalid = SkillModel.fromFirestore('3', dataInvalid);

      expect(skillInt.iconCode, 12345);
      expect(skillString.iconCode, 54321);
      expect(skillInvalid.iconCode, 58240); // default value
    });

    test('toFirestoreMapJson formats timestamps correctly', () {
      final skill = SkillModel(
        id: '1',
        name: 'Test',
        category: 'TestCat',
        iconCode: 123,
        createdAt: DateTime(2023, 1, 1),
      );

      final data = skill.toFirestoreMapJson();

      expect(data['createdAt'], isA<Timestamp>());
      expect(data['updatedAt'], isA<FieldValue>());
    });
  });
}
