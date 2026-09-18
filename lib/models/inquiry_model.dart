import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String subject;
  final String message;
  final String projectType;
  final bool isRead;
  final bool isStarred;
  final DateTime createdAt;

  const InquiryModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.subject,
    required this.message,
    this.projectType = 'General Inquiry',
    this.isRead = false,
    this.isStarred = false,
    required this.createdAt,
  });

  factory InquiryModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parsedDate = DateTime.now();
    final rawDate = data['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return InquiryModel(
      id: id,
      name: data['name'] ?? 'Anonymous Visitor',
      email: data['email'] ?? '',
      phone: data['phone'],
      subject: data['subject'] ?? 'No Subject',
      message: data['message'] ?? '',
      projectType: data['projectType'] ?? 'General Inquiry',
      isRead: data['isRead'] ?? false,
      isStarred: data['isStarred'] ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
      'projectType': projectType,
      'isRead': isRead,
      'isStarred': isStarred,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  InquiryModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subject,
    String? message,
    String? projectType,
    bool? isRead,
    bool? isStarred,
    DateTime? createdAt,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      projectType: projectType ?? this.projectType,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
