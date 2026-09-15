import 'package:cloud_firestore/cloud_firestore.dart';

class EducationModel {
  final String id;
  final String degree;
  final String field;
  final String institution;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;
  final int order;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EducationModel({
    required this.id,
    required this.degree,
    this.field = '',
    required this.institution,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    required this.description,
    this.order = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationModel.fromFirestore(String id, Map<String, dynamic> data) {
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

    return EducationModel(
      id: id,
      degree: data['degree'] ?? '',
      field: data['field'] ?? '',
      institution: data['institution'] ?? '',
      location: data['location'] ?? '',
      startDate: parseDate(data['startDate']),
      endDate: parseOptionalDate(data['endDate']),
      isCurrent: data['isCurrent'] ?? false,
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      createdAt: parseOptionalDate(data['createdAt']),
      updatedAt: parseOptionalDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'degree': degree,
      'field': field,
      'institution': institution,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'description': description,
      'order': order,
      'isVisible': isVisible,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  EducationModel copyWith({
    String? id,
    String? degree,
    String? field,
    String? institution,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
    int? order,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationModel(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      institution: institution ?? this.institution,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
