import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalExperienceModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentRole;
  final String description;
  final List<String> skills;
  final int order;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfessionalExperienceModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentRole = false,
    required this.description,
    this.skills = const [],
    this.order = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfessionalExperienceModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ProfessionalExperienceModel(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      startDate: parseDate(data['startDate']),
      endDate: parseOptionalDate(data['endDate']),
      isCurrentRole: data['isCurrentRole'] ?? false,
      description: data['description'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      order: data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      createdAt: parseOptionalDate(data['createdAt']),
      updatedAt: parseOptionalDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrentRole': isCurrentRole,
      'description': description,
      'skills': skills,
      'order': order,
      'isVisible': isVisible,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProfessionalExperienceModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentRole,
    String? description,
    List<String>? skills,
    int? order,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessionalExperienceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentRole: isCurrentRole ?? this.isCurrentRole,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
