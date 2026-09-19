import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futter_portfileo_website/models/professional_experience_model.dart';
import 'package:futter_portfileo_website/models/education_model.dart';

void main() {
  group('ProfessionalExperienceModel Tests', () {
    test('fromFirestore parses companyUrl, parentCompany, employmentType, promotions, and responsibilities', () {
      final data = {
        'title': 'Junior Executive, Mobile App',
        'company': 'SM Technology',
        'companyUrl': 'https://smtech24.com/',
        'parentCompany': 'Betopia Group',
        'parentCompanyUrl': 'https://betopiagroup.com/',
        'location': 'Dhaka, Bangladesh',
        'employmentType': 'Full-time • On-site',
        'startDate': Timestamp.fromDate(DateTime(2026, 3, 1)),
        'isCurrentRole': true,
        'description': 'Mobile engineering',
        'responsibilities': ['Developing Flutter apps', 'Play Store releases'],
        'skills': ['Flutter', 'Dart'],
        'promotions': [
          {
            'title': 'Junior Executive, Mobile App',
            'period': 'March 2026 — Present',
            'type': 'Promoted Role',
            'note': 'Promoted to lead production app releases'
          },
          {
            'title': 'Junior Flutter Developer',
            'period': 'Oct 2025 — Feb 2026',
            'type': 'Initial Position',
          }
        ],
        'order': 1,
        'isVisible': true,
      };

      final exp = ProfessionalExperienceModel.fromFirestore('exp_1', data);
      expect(exp.id, 'exp_1');
      expect(exp.title, 'Junior Executive, Mobile App');
      expect(exp.companyUrl, 'https://smtech24.com/');
      expect(exp.parentCompany, 'Betopia Group');
      expect(exp.parentCompanyUrl, 'https://betopiagroup.com/');
      expect(exp.employmentType, 'Full-time • On-site');
      expect(exp.responsibilities.length, 2);
      expect(exp.responsibilities.first, 'Developing Flutter apps');
      expect(exp.promotions.length, 2);
      expect(exp.promotions.first.title, 'Junior Executive, Mobile App');
      expect(exp.promotions.first.note, 'Promoted to lead production app releases');
      expect(exp.promotions.last.title, 'Junior Flutter Developer');
      expect(exp.isCurrentRole, true);
    });

    test('toFirestore serializes new fields correctly', () {
      final exp = ProfessionalExperienceModel(
        id: 'exp_2',
        title: 'Flutter Developer',
        company: 'SM Technology',
        companyUrl: 'https://smtech24.com/',
        parentCompany: 'Betopia Group',
        parentCompanyUrl: 'https://betopiagroup.com/',
        location: 'Dhaka',
        employmentType: 'Contract • Remote',
        startDate: DateTime(2026, 3, 1),
        description: 'Test desc',
        responsibilities: ['Responsibility 1'],
        skills: ['Dart'],
        promotions: [
          const ExperiencePromotionModel(
            title: 'Flutter Developer',
            period: '2026',
            type: 'Promotion',
            note: 'Great milestone',
          ),
        ],
      );

      final map = exp.toFirestore();
      expect(map['companyUrl'], 'https://smtech24.com/');
      expect(map['parentCompany'], 'Betopia Group');
      expect(map['parentCompanyUrl'], 'https://betopiagroup.com/');
      expect(map['employmentType'], 'Contract • Remote');
      expect(map['responsibilities'], ['Responsibility 1']);
      expect((map['promotions'] as List).length, 1);
      expect((map['promotions'] as List).first['title'], 'Flutter Developer');
    });
  });

  group('EducationModel Tests', () {
    test('fromFirestore parses institutionUrl and details', () {
      final data = {
        'degree': 'Diploma in Computer Engineering',
        'institution': 'Dhaka Polytechnic Institute',
        'institutionUrl': 'https://dhaka.polytech.gov.bd/',
        'field': 'Computer Science & Technology',
        'location': 'Dhaka, Bangladesh',
        'startDate': Timestamp.fromDate(DateTime(2022, 1, 1)),
        'endDate': Timestamp.fromDate(DateTime(2026, 6, 30)),
        'isCurrent': true,
        'description': 'Studying core CS disciplines',
        'order': 1,
        'isVisible': true,
      };

      final edu = EducationModel.fromFirestore('edu_1', data);
      expect(edu.id, 'edu_1');
      expect(edu.institutionUrl, 'https://dhaka.polytech.gov.bd/');
      expect(edu.field, 'Computer Science & Technology');
      expect(edu.degree, 'Diploma in Computer Engineering');
    });

    test('toFirestore serializes institutionUrl', () {
      final edu = EducationModel(
        id: 'edu_2',
        degree: 'SSC',
        institution: 'Ali Ahmed School and College',
        institutionUrl: 'http://aasac.edu.bd/',
        field: 'Science',
        location: 'Dhaka',
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2021, 12, 31),
        isCurrent: false,
        description: 'Science background',
      );

      final map = edu.toFirestore();
      expect(map['institutionUrl'], 'http://aasac.edu.bd/');
      expect(map['field'], 'Science');
    });
  });
}
