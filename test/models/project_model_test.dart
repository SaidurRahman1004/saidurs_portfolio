import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futter_portfileo_website/models/project_model.dart';

void main() {
  group('ProjectModel', () {
    test('fromFirestore correctly parses legacy fields', () {
      final data = {
        'name': 'Legacy Project',
        'description': 'A legacy description',
        'techStack': ['Flutter', 'Firebase'],
        'order': 5,
        'isFeatured': true,
        'createdAt': '2023-01-01T00:00:00.000',
      };

      final project = ProjectModel.fromFirestore('test_id', data);

      expect(project.id, 'test_id');
      expect(project.title, 'Legacy Project'); // Falls back to name
      expect(project.fullDescription, 'A legacy description'); // Falls back to description
      expect(project.technologies, ['Flutter', 'Firebase']); // Falls back to techStack
      expect(project.sortOrder, 5); // Falls back to order
      expect(project.featured, true); // Falls back to isFeatured
    });

    test('fromFirestore correctly parses new fields', () {
      final timestamp = Timestamp.now();
      final data = {
        'title': 'New Project',
        'fullDescription': 'A new description',
        'technologies': ['Dart'],
        'sortOrder': 2,
        'featured': false,
        'createdAt': timestamp,
      };

      final project = ProjectModel.fromFirestore('test_id_2', data);

      expect(project.title, 'New Project');
      expect(project.fullDescription, 'A new description');
      expect(project.technologies, ['Dart']);
      expect(project.sortOrder, 2);
      expect(project.featured, false);
      expect(project.createdAt, timestamp.toDate());
    });

    test('toFirestore serializes correctly', () {
      final project = ProjectModel(
        id: '123',
        title: 'Title',
        shortDescription: 'Short',
        fullDescription: 'Full',
        technologies: ['Tech'],
        createdAt: DateTime(2023, 1, 1),
      );

      final data = project.toFirestore();

      expect(data['title'], 'Title');
      expect(data['shortDescription'], 'Short');
      expect(data['fullDescription'], 'Full');
      expect(data['technologies'], ['Tech']);
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['updatedAt'], isA<FieldValue>());
    });
  });
}
