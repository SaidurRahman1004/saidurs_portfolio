import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/contact_model.dart';

import '../models/professional_experience_model.dart';
import '../models/education_model.dart';
import '../models/certification_model.dart';
import '../models/career_config_model.dart';
import '../models/inquiry_model.dart';
import '../models/error_report_model.dart';
import 'portfolio_seed_data.dart';


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
  
  CollectionReference get _experienceCollection =>
      _firestore.collection('experience');
  CollectionReference get _educationCollection =>
      _firestore.collection('education');
  CollectionReference get _certificationsCollection =>
      _firestore.collection('certifications');
  CollectionReference get _inquiriesCollection =>
      _firestore.collection('inquiries');
  CollectionReference get _errorReportsCollection =>
      _firestore.collection('error_reports');
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
      debugPrint('Failed to adding skill: $e');
    }
  }

  //Update Skill Data to Firebase Admin operation

  Future<void> updateSkill(String id, SkillModel skill) async {
    try {
      await _skillsCollections.doc(id).update(skill.toFirestoreMapJson());
    } catch (e) {
      debugPrint('Failed to Update skill: $e');
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

  Stream<List<ProfessionalExperienceModel>> getExperiences({bool includeHidden = false}) {
    final query = includeHidden
        ? _experienceCollection
        : _experienceCollection.where('isVisible', isEqualTo: true);
    return query.snapshots()
        .map((snapshot) {
      final list = <ProfessionalExperienceModel>[];
      for (final doc in snapshot.docs) {
        if (doc.id == 'career_config' || doc.id == '__config') continue;
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            list.add(ProfessionalExperienceModel.fromFirestore(doc.id, data));
          }
        } catch (e) {
          debugPrint('Error parsing experience doc ${doc.id}: $e');
        }
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Stream<CareerConfigModel> getCareerConfig() {
    return _experienceCollection.doc('career_config').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return CareerConfigModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return CareerConfigModel.defaultConfig();
    });
  }

  Future<void> updateCareerConfig(CareerConfigModel config) async {
    try {
      await _experienceCollection
          .doc('career_config')
          .set(config.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update career config: $e');
    }
  }

  Future<void> addExperience(ProfessionalExperienceModel exp) async {
    try {
      if (exp.id.trim().isNotEmpty) {
        await _experienceCollection.doc(exp.id.trim()).set(exp.toFirestore(), SetOptions(merge: true));
      } else {
        await _experienceCollection.add(exp.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to add experience: $e');
    }
  }

  Future<void> updateExperience(String id, ProfessionalExperienceModel exp) async {
    try {
      final targetId = id.trim().isNotEmpty ? id.trim() : (exp.id.trim().isNotEmpty ? exp.id.trim() : null);
      if (targetId == null) {
        await _experienceCollection.add(exp.toFirestore());
      } else {
        await _experienceCollection.doc(targetId).set(exp.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update experience: $e');
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _experienceCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete experience: $e');
    }
  }

  Future<void> seedExperienceData() async {
    try {
      final snapshot = await _experienceCollection.get();
      if (snapshot.docs.isEmpty) {
        for (final exp in PortfolioSeedData.experiences) {
          await _experienceCollection.add(exp.toFirestore());
        }
      }
    } catch (e) {
      debugPrint('Failed to seed experience data: $e');
    }
  }

  /// Education Operations
  Stream<List<EducationModel>> getEducation({bool includeHidden = false}) {
    final query = includeHidden
        ? _educationCollection
        : _educationCollection.where('isVisible', isEqualTo: true);
    return query.snapshots()
        .map((snapshot) {
      final list = <EducationModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            list.add(EducationModel.fromFirestore(doc.id, data));
          }
        } catch (e) {
          debugPrint('Error parsing education doc ${doc.id}: $e');
        }
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> addEducation(EducationModel edu) async {
    try {
      if (edu.id.trim().isNotEmpty) {
        await _educationCollection.doc(edu.id.trim()).set(edu.toFirestore(), SetOptions(merge: true));
      } else {
        await _educationCollection.add(edu.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to add education: $e');
    }
  }

  Future<void> updateEducation(String id, EducationModel edu) async {
    try {
      final targetId = id.trim().isNotEmpty ? id.trim() : (edu.id.trim().isNotEmpty ? edu.id.trim() : null);
      if (targetId == null) {
        await _educationCollection.add(edu.toFirestore());
      } else {
        await _educationCollection.doc(targetId).set(edu.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await _educationCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }

  Future<void> seedEducationData() async {
    try {
      final snapshot = await _educationCollection.get();
      if (snapshot.docs.isEmpty) {
        for (final edu in PortfolioSeedData.educations) {
          await _educationCollection.add(edu.toFirestore());
        }
      }
    } catch (e) {
      debugPrint('Failed to seed education data: $e');
    }
  }

  /// Certification Operations
  Stream<List<CertificationModel>> getCertifications({bool includeHidden = false}) {
    final query = includeHidden
        ? _certificationsCollection
        : _certificationsCollection.where('isVisible', isEqualTo: true);
    return query.snapshots()
        .map((snapshot) {
      final list = <CertificationModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            list.add(CertificationModel.fromFirestore(doc.id, data));
          }
        } catch (e) {
          debugPrint('Error parsing certification doc ${doc.id}: $e');
        }
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<void> addCertification(CertificationModel cert) async {
    try {
      if (cert.id.trim().isNotEmpty) {
        await _certificationsCollection.doc(cert.id.trim()).set(cert.toFirestore(), SetOptions(merge: true));
      } else {
        await _certificationsCollection.add(cert.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to add certification: $e');
    }
  }

  Future<void> updateCertification(String id, CertificationModel cert) async {
    try {
      final targetId = id.trim().isNotEmpty ? id.trim() : (cert.id.trim().isNotEmpty ? cert.id.trim() : null);
      if (targetId == null) {
        await _certificationsCollection.add(cert.toFirestore());
      } else {
        await _certificationsCollection.doc(targetId).set(cert.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  Future<void> deleteCertification(String id) async {
    try {
      await _certificationsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }

  Future<void> seedCertificationData() async {
    try {
      final snapshot = await _certificationsCollection.get();
      if (snapshot.docs.isEmpty) {
        for (final cert in PortfolioSeedData.certifications) {
          await _certificationsCollection.add(cert.toFirestore());
        }
      }
    } catch (e) {
      debugPrint('Failed to seed certification data: $e');
    }
  }

  /// Bulk Seed/Sync Resume Data into Firestore collections
  Future<void> seedResumeData() async {
    try {
      // 1. Contact Info (merge update info doc)
      await _contactCollection.doc('info').set(
        PortfolioSeedData.contactInfo.toFirestore(),
        SetOptions(merge: true),
      );

      // 2. Experience
      final expSnapshot = await _experienceCollection.get();
      final existingCompanies = expSnapshot.docs
          .map((d) => (d.data() as Map<String, dynamic>)['company']?.toString().toLowerCase())
          .toSet();
      for (final exp in PortfolioSeedData.experiences) {
        if (!existingCompanies.contains(exp.company.toLowerCase())) {
          await _experienceCollection.add(exp.toFirestore());
        }
      }

      // 3. Education
      final eduSnapshot = await _educationCollection.get();
      final existingInstitutions = eduSnapshot.docs
          .map((d) => (d.data() as Map<String, dynamic>)['institution']?.toString().toLowerCase())
          .toSet();
      for (final edu in PortfolioSeedData.educations) {
        if (!existingInstitutions.contains(edu.institution.toLowerCase())) {
          await _educationCollection.add(edu.toFirestore());
        }
      }

      // 4. Certifications
      final certSnapshot = await _certificationsCollection.get();
      final existingCerts = certSnapshot.docs
          .map((d) => (d.data() as Map<String, dynamic>)['name']?.toString().toLowerCase())
          .toSet();
      for (final cert in PortfolioSeedData.certifications) {
        if (!existingCerts.contains(cert.name.toLowerCase())) {
          await _certificationsCollection.add(cert.toFirestore());
        }
      }

      // 5. Projects
      final projSnapshot = await _projectsCollection.get();
      final existingTitles = projSnapshot.docs
          .map((d) => (d.data() as Map<String, dynamic>)['title']?.toString().toLowerCase())
          .toSet();
      for (final proj in PortfolioSeedData.projects) {
        if (!existingTitles.contains(proj.title.toLowerCase())) {
          await _projectsCollection.add(proj.toFirestore());
        }
      }

      // 6. Skills
      final skillsSnapshot = await _skillsCollections.get();
      final existingSkills = skillsSnapshot.docs
          .map((d) => (d.data() as Map<String, dynamic>)['name']?.toString().toLowerCase())
          .toSet();
      for (final skill in PortfolioSeedData.skills) {
        if (!existingSkills.contains(skill.name.toLowerCase())) {
          await _skillsCollections.add(skill.toFirestoreMapJson());
        }
      }
    } catch (e) {
      debugPrint('Failed to seed resume data: $e');
      rethrow;
    }
  }

  /// Inquiries / Visitor Contact Operations
  Future<void> submitInquiry(InquiryModel inquiry) async {
    try {
      await _inquiriesCollection.add(inquiry.toFirestore());
    } catch (e) {
      debugPrint('Error submitting inquiry: $e');
      throw Exception('Failed to submit message: $e');
    }
  }

  Stream<List<InquiryModel>> getInquiries() {
    return _inquiriesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InquiryModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> markInquiryAsRead(String id, bool isRead) async {
    try {
      await _inquiriesCollection.doc(id).update({'isRead': isRead});
    } catch (e) {
      throw Exception('Failed to update inquiry status: $e');
    }
  }

  Future<void> toggleInquiryStar(String id, bool isStarred) async {
    try {
      await _inquiriesCollection.doc(id).update({'isStarred': isStarred});
    } catch (e) {
      throw Exception('Failed to toggle star: $e');
    }
  }

  Future<void> deleteInquiry(String id) async {
    try {
      await _inquiriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete inquiry: $e');
    }
  }

  /// Error Reports Operations
  Stream<List<ErrorReportModel>> getErrorReports() {
    return _errorReportsCollection
        .orderBy('lastSeenAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ErrorReportModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateErrorStatus(String fingerprint, String status) async {
    try {
      await _errorReportsCollection.doc(fingerprint).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update error status: $e');
    }
  }

  Future<void> addErrorNote(String fingerprint, String note) async {
    try {
      await _errorReportsCollection.doc(fingerprint).update({
        'notes': FieldValue.arrayUnion([note]),
      });
    } catch (e) {
      throw Exception('Failed to add error note: $e');
    }
  }

  Future<void> deleteErrorReport(String fingerprint) async {
    try {
      await _errorReportsCollection.doc(fingerprint).delete();
    } catch (e) {
      throw Exception('Failed to delete error report: $e');
    }
  }
}

