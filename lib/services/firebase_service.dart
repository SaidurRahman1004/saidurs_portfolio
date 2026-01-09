import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/contact_model.dart';

class FirebaseService {
  //Singleton Define for access Anywhere/Global access,Memory efficient,not create for object

  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  static FirebaseService get instance => _instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //iNSTANCE FOR FIREBASE
  //CREATE fIREsTORE cOLLECTION rEF
  CollectionReference get _skillsCollections =>
      _firestore.collection('skills'); //Skil Coll Ref
  CollectionReference get _projectsCollection =>
      _firestore.collection('projects'); //Skil Coll Ref
  CollectionReference get _contactCollection =>
      _firestore.collection('contact'); //Skil Coll Ref
  ///Skills Operations
  //fetch All Skills data  For Publicly from Firebase
  Stream<List<SkillModel>> getSkills() {
    return _skillsCollections
        .where('isVisible', isEqualTo: true) //only Visible data
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SkillModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

//fetch All Skills data  For Admin from Firebase(visible/hidden)
  Stream<List<SkillModel>> getAllSkills() {
    return _skillsCollections
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SkillModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  //Add New Skill Data to Firebase Admin operation
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _skillsCollections.add(skill.toFirestoreMapJson());
    } catch (e) {
      print('Failed to adding skill: $e');
    }
  }

  //Update Skill Data to Firebase Admin operation

  Future<void> updateSkill(String id, SkillModel skill) async {
    try {
      await _skillsCollections.doc(id).update(skill.toFirestoreMapJson());
    } catch (e) {
      print('Failed to Update skill: $e');
    }
  }

  //Delete Skill
  Future<void> deleteSkill(String id) async {
    try {
      await _skillsCollections.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  ///Project Operations
  //fetch All Project data  For Publicly from Firebase
  Stream<List<ProjectModel>> getProjects() {
    return _projectsCollection
        .where('isVisible', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  //Show featured projects highlight in Publicly
  Stream<List<ProjectModel>> getFeaturedProjects() {
    return _projectsCollection
        .where('isVisible', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .orderBy('order')
        .limit(3) // onLy 3 featured project
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  //Fetch All Projects For Admin
  Stream<List<ProjectModel>> getAllProjects() {
    return _projectsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  //Add New Project Data to Firebase Admin operation
  Future<void> addProject(ProjectModel project) async {
    try {
      await _projectsCollection.add(project.toFirestore());
    } catch (e) {
      throw Exception('Failed to add project: $e');
    }
  }

  // Project update
  Future<void> updateProject(String id, ProjectModel project) async {
    try {
      await _projectsCollection.doc(id).update(project.toFirestore());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  // Project delete
  Future<void> deleteProject(String id) async {
    try {
      await _projectsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  ///CONTACT INFO OPERATIONS
  //fetch All Contact data  For Publicly from Firebase itas Single Doc
  Stream<ContactModel?> getContactInfo() {
    return _contactCollection
        .doc('info') // Fixed document ID
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ContactModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    });
  }

  /// Contact info update (Admin)
  Future<void> updateContactInfo(ContactModel contact) async {
    try {
      await _contactCollection.doc('info').set(
        contact.toFirestore(),
        SetOptions(merge: true), // Merge = update existing data
      );
    } catch (e) {
      throw Exception('Failed to update contact info: $e');
    }
  }

  //Create Initial Contact First Time
  Future<void> initializeContactInfo() async {
    try {
      final doc = await _contactCollection
          .doc('info')
          .get(); //check if doc exists
      if (!doc.exists) {
        //Default Contact
        final defaultContact = ContactModel(id: 'info',
            email: 'saidurrahman1004@gmail.com',
            phone: '+8801795664122',
            githubUrl: 'https://github.com/SaidurRahman1004',
            location: 'Bangladesh',
            whatsappNumber: '+8801795664122');
        await _contactCollection.doc('info').set(defaultContact.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to initialize contact info: $e');
    }
  }


}
