
class SkillModel {
  final String id;
  final String name;
  final String category;
  final int iconCode; //numerical code for Material Icon
  final int order; //sorting
  final bool isVisible; //Show Hide


  SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.iconCode,
    this.order = 0,
    this.isVisible = true,
  });

//json to dart model Map<String, dynamic> formet,Receved Data from Firebase
  factory SkillModel.fromFirestore(String id, Map<String, dynamic> data){
    return SkillModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      iconCode: data['iconCode'] is int ? data['iconCode'] : (int.tryParse(data['iconCode']?.toString() ?? '58240') ?? 58240),
      // Default icon code
      order: data['order'] ?? 0,
      isVisible: data['isVisible'] ?? true,
    );
  }

  //dart to json Sent Data to Firebase //admin panel modification functions
  Map<String, dynamic> toFirestoreMapJson() {
    return {
      'name': name,
      'category': category,
      'iconCode': iconCode,
      'order': order,
      'isVisible': isVisible,
      'updatedAt': DateTime.now().toIso8601String(), // Last update time track
    };
  }

  //change Some feild by copying object ,immutable pattern ,use it state management,visibility changes
  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    int? iconCode,
    int? order,
    bool? isVisible,
  }) {
    return SkillModel(
      id: id ??  this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconCode: iconCode ??  this.iconCode,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

}