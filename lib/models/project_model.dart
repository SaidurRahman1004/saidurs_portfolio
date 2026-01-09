class ProjectModel{
  final String id;
  final String name;
  final String description;
  final List<String> techStack;   // which fetuers use
  final String githubUrl;
  final String?  liveUrl;          // Optional
  final String? imageUrl;         // Optional
  final bool isFeatured;          // Featured = homepage এ highlight
  final bool isVisible;
  final int order;
  final DateTime createdAt;
  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this. techStack,
    required this. githubUrl,
    this. liveUrl,
    this. imageUrl,
    this.isFeatured = false,
    this.isVisible = true,
    this.order = 0,
    required this.createdAt,
  });

  ////json to dart model Map<String, dynamic> formet,Receved Data from Firebase
  factory ProjectModel.fromFirestore(String id, Map<String, dynamic> data){
    return ProjectModel(
      id: id,
      name: data['name'] ??  '',
      description: data['description'] ?? '',
      techStack: List<String>.from(data['techStack'] ?? []),

      githubUrl: data['githubUrl'] ?? '',
      liveUrl: data['liveUrl'],  // Nullable,no default value
      imageUrl: data['imageUrl'],
      isFeatured: data['isFeatured'] ?? false,
      isVisible:  data['isVisible'] ?? true,
      order: data['order'] ?? 0,

      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
//dart to json Sent Data to Firebase //admin panel modification functions
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'techStack': techStack,  // Save list Directly
      'githubUrl':  githubUrl,
      'liveUrl': liveUrl,
      'imageUrl': imageUrl,
      'isFeatured':  isFeatured,
      'isVisible': isVisible,
      'order': order,
      'createdAt': createdAt. toIso8601String(),  // convert DateTime to String
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
//change Some feild by copying object ,immutable pattern ,use it state management,visibility changes
  ProjectModel copyWith({
    String? id,
    String?  name,
    String? description,
    List<String>? techStack,
    String? githubUrl,
    String? liveUrl,
    String? imageUrl,
    bool? isFeatured,
    bool? isVisible,
    int? order,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      githubUrl: githubUrl ?? this. githubUrl,
      liveUrl: liveUrl ?? this. liveUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured:  isFeatured ?? this.isFeatured,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}