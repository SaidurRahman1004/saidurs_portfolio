import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

class ContactModel {
  final String id;
  final String email;
  final String phone;
  final String githubUrl;
  final String? linkedinUrl;
  final String? resumeUrl;
  final String location;
  final String whatsappNumber;
  final String? profileImageUrl;
  final String? heroImageUrl;
  final DateTime? updatedAt;

  // Dynamic Profile & Bio Customization Fields
  final String fullName;
  final String title;
  final String tagline;
  final String heroDescription;
  final String aboutMe;
  final bool isOpenToWork;
  final String openToWorkText;
  final List<String> animatedRoles;
  final String educationFact;
  final String locationFact;
  final String focusFact;
  final String goalFact;

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
    this.fullName = AppConstants.name,
    this.title = AppConstants.role,
    this.tagline = AppConstants.tagline,
    this.heroDescription = AppConstants.heroDescription,
    this.aboutMe = AppConstants.aboutMe,
    this.isOpenToWork = true,
    this.openToWorkText = 'Available for Opportunities',
    this.animatedRoles = const [
      'Junior Executive, Mobile App',
      'Junior Flutter Developer',
      'Production Mobile Engineer',
    ],
    this.educationFact = 'Diploma in CST - Dhaka Polytechnic Institute',
    this.locationFact = 'Dhaka, Bangladesh',
    this.focusFact = 'Flutter + Firebase + Django',
    this.goalFact = 'Full-Stack Mobile Developer',
  });

  factory ContactModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? parsedUpdateDate;
    if (data['updatedAt'] is Timestamp) {
      parsedUpdateDate = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      parsedUpdateDate = DateTime.tryParse(data['updatedAt']);
    }

    List<String> parsedRoles = [
      'Junior Executive, Mobile App',
      'Junior Flutter Developer',
      'Production Mobile Engineer',
    ];
    if (data['animatedRoles'] is List) {
      final list = (data['animatedRoles'] as List)
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (list.isNotEmpty) {
        parsedRoles = list;
      }
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
      fullName: (data['fullName'] != null && (data['fullName'] as String).trim().isNotEmpty)
          ? data['fullName']
          : AppConstants.name,
      title: (data['title'] != null && (data['title'] as String).trim().isNotEmpty)
          ? data['title']
          : AppConstants.role,
      tagline: (data['tagline'] != null && (data['tagline'] as String).trim().isNotEmpty)
          ? data['tagline']
          : AppConstants.tagline,
      heroDescription: (data['heroDescription'] != null && (data['heroDescription'] as String).trim().isNotEmpty)
          ? data['heroDescription']
          : AppConstants.heroDescription,
      aboutMe: (data['aboutMe'] != null && (data['aboutMe'] as String).trim().isNotEmpty)
          ? data['aboutMe']
          : AppConstants.aboutMe,
      isOpenToWork: data['isOpenToWork'] ?? true,
      openToWorkText: data['openToWorkText'] ?? 'Available for Opportunities',
      animatedRoles: parsedRoles,
      educationFact: data['educationFact'] ?? 'Diploma in CST - Dhaka Polytechnic Institute',
      locationFact: data['locationFact'] ?? 'Dhaka, Bangladesh',
      focusFact: data['focusFact'] ?? 'Flutter + Firebase + Django',
      goalFact: data['goalFact'] ?? 'Full-Stack Mobile Developer',
    );
  }

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
      'fullName': fullName,
      'title': title,
      'tagline': tagline,
      'heroDescription': heroDescription,
      'aboutMe': aboutMe,
      'isOpenToWork': isOpenToWork,
      'openToWorkText': openToWorkText,
      'animatedRoles': animatedRoles,
      'educationFact': educationFact,
      'locationFact': locationFact,
      'focusFact': focusFact,
      'goalFact': goalFact,
    };
  }

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
    String? fullName,
    String? title,
    String? tagline,
    String? heroDescription,
    String? aboutMe,
    bool? isOpenToWork,
    String? openToWorkText,
    List<String>? animatedRoles,
    String? educationFact,
    String? locationFact,
    String? focusFact,
    String? goalFact,
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
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      heroDescription: heroDescription ?? this.heroDescription,
      aboutMe: aboutMe ?? this.aboutMe,
      isOpenToWork: isOpenToWork ?? this.isOpenToWork,
      openToWorkText: openToWorkText ?? this.openToWorkText,
      animatedRoles: animatedRoles ?? this.animatedRoles,
      educationFact: educationFact ?? this.educationFact,
      locationFact: locationFact ?? this.locationFact,
      focusFact: focusFact ?? this.focusFact,
      goalFact: goalFact ?? this.goalFact,
    );
  }
}
