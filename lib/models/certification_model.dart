import 'package:cloud_firestore/cloud_firestore.dart';

class CertificationModel {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? imageUrl;
  final int order;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CertificationModel({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
    this.imageUrl,
    this.order = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CertificationModel.fromFirestore(String id, Map<String, dynamic> data) {
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

    return CertificationModel(
      id: id,
      name: data['name'] ?? '',
      issuingOrganization: data['issuingOrganization'] ?? '',
      issueDate: parseDate(data['issueDate']),
      expirationDate: parseOptionalDate(data['expirationDate']),
      credentialId: data['credentialId'],
      credentialUrl: data['credentialUrl'],
      imageUrl: data['imageUrl'],
      order: data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      createdAt: parseOptionalDate(data['createdAt']),
      updatedAt: parseOptionalDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': Timestamp.fromDate(issueDate),
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'imageUrl': imageUrl,
      'order': order,
      'isVisible': isVisible,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CertificationModel copyWith({
    String? id,
    String? name,
    String? issuingOrganization,
    DateTime? issueDate,
    DateTime? expirationDate,
    String? credentialId,
    String? credentialUrl,
    String? imageUrl,
    int? order,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CertificationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      issuingOrganization: issuingOrganization ?? this.issuingOrganization,
      issueDate: issueDate ?? this.issueDate,
      expirationDate: expirationDate ?? this.expirationDate,
      credentialId: credentialId ?? this.credentialId,
      credentialUrl: credentialUrl ?? this.credentialUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
