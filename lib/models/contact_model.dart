import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String id;
  final String email;
  final String phone;
  final String githubUrl;
  final String? linkedinUrl; // Optional
  final String? resumeUrl; // Optional
  final String location;
  final String whatsappNumber;
  final String? profileImageUrl;
  final String? heroImageUrl;
  final DateTime? updatedAt;

  ContactModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.githubUrl,
    this.linkedinUrl,
    this.resumeUrl,
    required this.location,
    required this.whatsappNumber,
    this.profileImageUrl,
    this.heroImageUrl,
    this.updatedAt,
  });

  factory ContactModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? parsedUpdateDate;
    if (data['updatedAt'] is Timestamp) {
      parsedUpdateDate = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      parsedUpdateDate = DateTime.tryParse(data['updatedAt']);
    }

    return ContactModel(
      id: id,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      linkedinUrl: data['linkedinUrl'],
      resumeUrl: data['resumeUrl'],
      location: data['location'] ?? 'Bangladesh',
      whatsappNumber: data['whatsappNumber'] ?? data['phone'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      heroImageUrl: data['heroImageUrl'],
      updatedAt: parsedUpdateDate,
    );
  }

  //dart to json Sent Data to Firebase //admin panel modification functions
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'resumeUrl': resumeUrl,
      'location': location,
      'whatsappNumber': whatsappNumber,
      'updatedAt': FieldValue.serverTimestamp(),
      'profileImageUrl': profileImageUrl,
      'heroImageUrl': heroImageUrl,
    };
  }

  //change Some feild by copying object ,immutable pattern ,use it state management,visibility changes
  ContactModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? githubUrl,
    String? linkedinUrl,
    String? resumeUrl,
    String? location,
    String? whatsappNumber,
    String? profileImageUrl,
    String? heroImageUrl,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      location: location ?? this.location,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
