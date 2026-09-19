import 'package:cloud_firestore/cloud_firestore.dart';

class ExperiencePromotionModel {
  final String title;
  final String period;
  final String type;
  final String? note;

  const ExperiencePromotionModel({
    required this.title,
    required this.period,
    this.type = 'Promoted Role',
    this.note,
  });

  factory ExperiencePromotionModel.fromMap(Map<String, dynamic> map) {
    return ExperiencePromotionModel(
      title: (map['title'] ?? map['position'] ?? map['role'] ?? '').toString(),
      period: (map['period'] ?? map['date'] ?? map['duration'] ?? '').toString(),
      type: (map['type'] ?? map['badge'] ?? 'Promoted Role').toString(),
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'period': period,
      'type': type,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

class ProfessionalExperienceModel {
  final String id;
  final String title;
  final String company;
  final String? companyUrl;
  final String? parentCompany;
  final String? parentCompanyUrl;
  final String location;
  final String employmentType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentRole;
  final String description;
  final List<String> responsibilities;
  final List<String> skills;
  final List<ExperiencePromotionModel> promotions;
  final int order;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfessionalExperienceModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyUrl,
    this.parentCompany,
    this.parentCompanyUrl,
    required this.location,
    this.employmentType = 'Full-time • On-site',
    required this.startDate,
    this.endDate,
    this.isCurrentRole = false,
    required this.description,
    this.responsibilities = const [],
    this.skills = const [],
    this.promotions = const [],
    this.order = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfessionalExperienceModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        return val
            .split(RegExp(r'[\n,]'))
            .map((e) => e.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    List<ExperiencePromotionModel> parsePromotions(dynamic val) {
      if (val is List) {
        return val
            .whereType<Map>()
            .map((e) => ExperiencePromotionModel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    int parseOrder(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val, {bool defaultValue = true}) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      if (val is num) return val != 0;
      return defaultValue;
    }

    return ProfessionalExperienceModel(
      id: id,
      title: (data['title'] ?? data['role'] ?? data['position'] ?? '').toString(),
      company: (data['company'] ?? data['companyName'] ?? data['organization'] ?? '').toString(),
      companyUrl: data['companyUrl']?.toString(),
      parentCompany: data['parentCompany']?.toString(),
      parentCompanyUrl: data['parentCompanyUrl']?.toString(),
      location: (data['location'] ?? '').toString(),
      employmentType: (data['employmentType'] ?? data['type'] ?? 'Full-time • On-site').toString(),
      startDate: parseDate(data['startDate'] ?? data['start_date'] ?? data['from']),
      endDate: parseOptionalDate(data['endDate'] ?? data['end_date'] ?? data['to']),
      isCurrentRole: parseBool(data['isCurrentRole'] ?? data['isCurrent'] ?? data['current'], defaultValue: false),
      description: (data['description'] ?? data['details'] ?? '').toString(),
      responsibilities: parseList(data['responsibilities'] ?? data['contributions'] ?? data['points']),
      skills: parseList(data['skills'] ?? data['technologies'] ?? data['techStack']),
      promotions: parsePromotions(data['promotions'] ?? data['progression']),
      order: parseOrder(data['order'] ?? data['sortOrder']),
      isVisible: parseBool(data['isVisible'] ?? data['visible'], defaultValue: true),
      createdAt: parseOptionalDate(data['createdAt']),
      updatedAt: parseOptionalDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'company': company,
      'companyUrl': companyUrl,
      'parentCompany': parentCompany,
      'parentCompanyUrl': parentCompanyUrl,
      'location': location,
      'employmentType': employmentType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrentRole': isCurrentRole,
      'description': description,
      'responsibilities': responsibilities,
      'skills': skills,
      'promotions': promotions.map((p) => p.toMap()).toList(),
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
    String? companyUrl,
    String? parentCompany,
    String? parentCompanyUrl,
    String? location,
    String? employmentType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentRole,
    String? description,
    List<String>? responsibilities,
    List<String>? skills,
    List<ExperiencePromotionModel>? promotions,
    int? order,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessionalExperienceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyUrl: companyUrl ?? this.companyUrl,
      parentCompany: parentCompany ?? this.parentCompany,
      parentCompanyUrl: parentCompanyUrl ?? this.parentCompanyUrl,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentRole: isCurrentRole ?? this.isCurrentRole,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      skills: skills ?? this.skills,
      promotions: promotions ?? this.promotions,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
