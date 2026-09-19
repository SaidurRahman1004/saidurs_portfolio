import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String id;
  final String name;
  final String category;
  final int iconCode; //numerical code for Material Icon
  final int order; //sorting
  final bool isVisible; //Show Hide
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.iconCode,
    this.order = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SkillModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? parsedCreatedDate;
    if (data['createdAt'] is Timestamp) {
      parsedCreatedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedCreatedDate = DateTime.tryParse(data['createdAt']);
    }

    DateTime? parsedUpdateDate;
    if (data['updatedAt'] is Timestamp) {
      parsedUpdateDate = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      parsedUpdateDate = DateTime.tryParse(data['updatedAt']);
    }

    return SkillModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      iconCode: data['iconCode'] is int ? data['iconCode'] : (int.tryParse(data['iconCode']?.toString() ?? '58240') ?? 58240),
      order: data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      createdAt: parsedCreatedDate,
      updatedAt: parsedUpdateDate,
    );
  }

  Map<String, dynamic> toFirestoreMapJson() {
    return {
      'name': name,
      'category': category,
      'iconCode': iconCode,
      'order': order,
      'isVisible': isVisible,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    int? iconCode,
    int? order,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}