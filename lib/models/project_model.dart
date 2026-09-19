import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String slug;
  final String shortDescription;
  final String fullDescription;
  final String? role;
  final List<String> technologies;
  final List<String> keyFeatures;
  final String? challenges;
  final String? category;
  final bool featured;
  final String? status;
  final String? imageUrl;
  final List<String> screenshots;
  final String? githubUrl;
  final String? liveUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? otherUrl;
  final String? otherUrlLabel;
  final String? projectType; // 'App', 'Web', 'CMS', 'CRM', 'Other'
  final String? customProjectType;
  final int sortOrder;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Legacy Getters to not break existing UI
  String get name => title;
  String get description => fullDescription;
  List<String> get techStack => technologies;
  bool get isFeatured => featured;
  int get order => sortOrder;

  String get displayProjectType {
    if (projectType == 'Other' && customProjectType != null && customProjectType!.trim().isNotEmpty) {
      return customProjectType!.trim();
    }
    return projectType ?? '';
  }

  ProjectModel({
    required this.id,
    String? title,
    String? name,
    this.slug = '',
    this.shortDescription = '',
    String? fullDescription,
    String? description,
    this.role,
    List<String>? technologies,
    List<String>? techStack,
    this.keyFeatures = const [],
    this.challenges,
    this.category,
    bool? featured,
    bool? isFeatured,
    this.status,
    this.imageUrl,
    this.screenshots = const [],
    this.githubUrl,
    this.liveUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.otherUrl,
    this.otherUrlLabel,
    this.projectType,
    this.customProjectType,
    int? sortOrder,
    int? order,
    this.isVisible = true,
    required this.createdAt,
    this.updatedAt,
  }) : 
    title = title ?? name ?? '',
    fullDescription = fullDescription ?? description ?? '',
    technologies = technologies ?? techStack ?? [],
    featured = featured ?? isFeatured ?? false,
    sortOrder = sortOrder ?? order ?? 0;

  factory ProjectModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedUpdateDate;
    if (data['updatedAt'] is Timestamp) {
      parsedUpdateDate = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      parsedUpdateDate = DateTime.tryParse(data['updatedAt']);
    }

    return ProjectModel(
      id: id,
      title: data['title'] ?? data['name'] ?? '',
      slug: data['slug'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      fullDescription: data['fullDescription'] ?? data['description'] ?? '',
      role: data['role'],
      technologies: List<String>.from(data['technologies'] ?? data['techStack'] ?? []),
      keyFeatures: List<String>.from(data['keyFeatures'] ?? []),
      challenges: data['challenges'],
      category: data['category'],
      featured: data['featured'] ?? data['isFeatured'] ?? false,
      status: data['status'],
      imageUrl: data['imageUrl'],
      screenshots: List<String>.from(data['screenshots'] ?? []),
      githubUrl: data['githubUrl'],
      liveUrl: data['liveUrl'],
      playStoreUrl: data['playStoreUrl'],
      appStoreUrl: data['appStoreUrl'],
      otherUrl: data['otherUrl'],
      otherUrlLabel: data['otherUrlLabel'],
      projectType: data['projectType'],
      customProjectType: data['customProjectType'],
      sortOrder: data['sortOrder'] ?? data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
      createdAt: parsedDate,
      updatedAt: parsedUpdateDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'name': title, // Keeping legacy for DB compatibility if needed
      'slug': slug,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'description': fullDescription, // Keeping legacy
      'role': role,
      'technologies': technologies,
      'techStack': technologies, // Keeping legacy
      'keyFeatures': keyFeatures,
      'challenges': challenges,
      'category': category,
      'featured': featured,
      'isFeatured': featured, // Keeping legacy
      'status': status,
      'imageUrl': imageUrl,
      'screenshots': screenshots,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'playStoreUrl': playStoreUrl,
      'appStoreUrl': appStoreUrl,
      'otherUrl': otherUrl,
      'otherUrlLabel': otherUrlLabel,
      'projectType': projectType,
      'customProjectType': customProjectType,
      'sortOrder': sortOrder,
      'order': sortOrder, // Keeping legacy
      'isVisible': isVisible,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? name, // Support old copyWith calls
    String? slug,
    String? shortDescription,
    String? fullDescription,
    String? description, // Support old copyWith calls
    String? role,
    List<String>? technologies,
    List<String>? techStack, // Support old copyWith calls
    List<String>? keyFeatures,
    String? challenges,
    String? category,
    bool? featured,
    bool? isFeatured, // Support old copyWith calls
    String? status,
    String? imageUrl,
    List<String>? screenshots,
    String? githubUrl,
    String? liveUrl,
    String? playStoreUrl,
    String? appStoreUrl,
    String? otherUrl,
    String? otherUrlLabel,
    String? projectType,
    String? customProjectType,
    int? sortOrder,
    int? order, // Support old copyWith calls
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? name ?? this.title,
      slug: slug ?? this.slug,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? description ?? this.fullDescription,
      role: role ?? this.role,
      technologies: technologies ?? techStack ?? this.technologies,
      keyFeatures: keyFeatures ?? this.keyFeatures,
      challenges: challenges ?? this.challenges,
      category: category ?? this.category,
      featured: featured ?? isFeatured ?? this.featured,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      screenshots: screenshots ?? this.screenshots,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      otherUrl: otherUrl ?? this.otherUrl,
      otherUrlLabel: otherUrlLabel ?? this.otherUrlLabel,
      projectType: projectType ?? this.projectType,
      customProjectType: customProjectType ?? this.customProjectType,
      sortOrder: sortOrder ?? order ?? this.sortOrder,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
