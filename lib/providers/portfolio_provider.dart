import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/contact_model.dart';
import '../models/professional_experience_model.dart';
import '../models/education_model.dart';
import '../models/certification_model.dart';
import '../services/firebase_service.dart';

class PortfolioProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  /// Store All Logics
  List<SkillModel> _skills = [];
  List<ProjectModel> _projects = [];
  ContactModel? _contactInfo;
  
  List<ProfessionalExperienceModel> _experiences = [];
  List<EducationModel> _education = [];
  List<CertificationModel> _certifications = [];

  StreamSubscription? _skillsSub;
  StreamSubscription? _projectsSub;
  StreamSubscription? _contactSub;
  StreamSubscription? _allSkillsSub;
  StreamSubscription? _allProjectsSub;
  
  StreamSubscription? _experiencesSub;
  StreamSubscription? _educationSub;
  StreamSubscription? _certificationsSub;

  // For Admin
  List<SkillModel> _allSkills = [];
  List<ProjectModel> _allProjects = [];

  // getter
  List<SkillModel> get skills => _skills;
  List<ProjectModel> get projects => _projects;
  ContactModel? get contactInfo => _contactInfo;
  List<ProfessionalExperienceModel> get experiences => _experiences;
  List<EducationModel> get education => _education;
  List<CertificationModel> get certifications => _certifications;

  // Admin getter
  List<SkillModel> get allSkills => _allSkills;
  List<ProjectModel> get allProjects => _allProjects;

  /// Loading states
  bool _isLoadingSkills = true;
  bool _isLoadingProjects = true;
  bool _isLoadingContact = true;
  bool _isLoadingExperiences = true;
  bool _isLoadingEducation = true;
  bool _isLoadingCertifications = true;

  // Admin Loaders
  bool _isLoadingAllSkills = false;
  bool _isLoadingAllProjects = false;

  // get Admin loaders
  bool get isLoadingAllSkills => _isLoadingAllSkills;
  bool get isLoadingAllProjects => _isLoadingAllProjects;

  bool get isLoadingSkills => _isLoadingSkills;
  bool get isLoadingProjects => _isLoadingProjects;
  bool get isLoadingContact => _isLoadingContact;
  bool get isLoadingExperiences => _isLoadingExperiences;
  bool get isLoadingEducation => _isLoadingEducation;
  bool get isLoadingCertifications => _isLoadingCertifications;

  // All Data Loading State
  bool get isLoading =>
      _isLoadingSkills || 
      _isLoadingProjects || 
      _isLoadingContact || 
      _isLoadingExperiences || 
      _isLoadingEducation || 
      _isLoadingCertifications;

  /// Error States
  String? _errorSkills;
  String? _errorProjects;
  String? _errorContact;
  String? _errorExperiences;
  String? _errorEducation;
  String? _errorCertifications;

  // Admin error states
  String? _errorAllSkills;
  String? _errorAllProjects;

  // Admin error getters
  String? get errorAllSkills => _errorAllSkills;
  String? get errorAllProjects => _errorAllProjects;

  String? get errorSkills => _errorSkills;
  String? get errorProjects => _errorProjects;
  String? get errorContact => _errorContact;
  String? get errorExperiences => _errorExperiences;
  String? get errorEducation => _errorEducation;
  String? get errorCertifications => _errorCertifications;

  /// Loads Data
  Future<void> loadSkills() async {
    try {
      _isLoadingSkills = true;
      _errorSkills = null;
      notifyListeners();
      _skillsSub?.cancel();
      _skillsSub = _firebaseService.getSkills().listen(
        (skillsList) {
          _skills = skillsList;
          _isLoadingSkills = false;
          _errorSkills = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoadingSkills = false;
          _errorSkills = 'Failed to load skills: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingSkills = false;
      _errorSkills = 'Failed to load skills: $e';
      notifyListeners();
    }
  }

  Future<void> loadAllSkills() async {
    try {
      _isLoadingAllSkills = true;
      _errorAllSkills = null;
      notifyListeners();
      _allSkillsSub?.cancel();
      _allSkillsSub = _firebaseService.getAllSkills().listen(
        (skillsList) {
          _allSkills = skillsList;
          _isLoadingAllSkills = false;
          _errorAllSkills = null;
          notifyListeners();
        },
        onError: (error) {
          _errorAllSkills = 'Failed to load all skills: $error';
          _isLoadingAllSkills = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorAllSkills = 'Unexpected error: $e';
      _isLoadingAllSkills = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    try {
      _isLoadingProjects = true;
      _errorProjects = null;
      notifyListeners();
      _projectsSub?.cancel();
      _projectsSub = _firebaseService.getProjects().listen(
        (projectsList) {
          _projects = projectsList;
          _isLoadingProjects = false;
          _errorProjects = null;
          notifyListeners();
        },
        onError: (error) {
          _errorProjects = 'Failed to load projects: $error';
          _isLoadingProjects = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorProjects = 'Unexpected error: $e';
      _isLoadingProjects = false;
      notifyListeners();
    }
  }

  Future<void> loadAllProjects() async {
    try {
      _isLoadingAllProjects = true;
      _errorAllProjects = null;
      notifyListeners();
      _allProjectsSub?.cancel();
      _allProjectsSub = _firebaseService.getAllProjects().listen(
        (projectsList) {
          _allProjects = projectsList;
          _isLoadingAllProjects = false;
          _errorAllProjects = null;
          notifyListeners();
        },
        onError: (error) {
          _errorAllProjects = 'Failed to load all projects: $error';
          _isLoadingAllProjects = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorAllProjects = 'Unexpected error: $e';
      _isLoadingAllProjects = false;
      notifyListeners();
    }
  }

  Future<void> loadContactInfo() async {
    try {
      _isLoadingContact = true;
      _errorContact = null;
      notifyListeners();
      _contactSub?.cancel();
      _contactSub = _firebaseService.getContactInfo().listen(
        (contact) {
          _contactInfo = contact;
          _isLoadingContact = false;
          _errorContact = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoadingContact = false;
          _errorContact = 'Failed to load contact info: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingContact = false;
      _errorContact = 'Failed to load contact info: $e';
      notifyListeners();
    }
  }
  
  Future<void> loadExperiences() async {
    try {
      _isLoadingExperiences = true;
      _errorExperiences = null;
      notifyListeners();
      _experiencesSub?.cancel();
      _experiencesSub = _firebaseService.getExperiences().listen(
        (list) {
          _experiences = list;
          _isLoadingExperiences = false;
          _errorExperiences = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoadingExperiences = false;
          _errorExperiences = 'Failed to load experiences: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingExperiences = false;
      _errorExperiences = 'Failed to load experiences: $e';
      notifyListeners();
    }
  }

  Future<void> loadEducation() async {
    try {
      _isLoadingEducation = true;
      _errorEducation = null;
      notifyListeners();
      _educationSub?.cancel();
      _educationSub = _firebaseService.getEducation().listen(
        (list) {
          _education = list;
          _isLoadingEducation = false;
          _errorEducation = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoadingEducation = false;
          _errorEducation = 'Failed to load education: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingEducation = false;
      _errorEducation = 'Failed to load education: $e';
      notifyListeners();
    }
  }

  Future<void> loadCertifications() async {
    try {
      _isLoadingCertifications = true;
      _errorCertifications = null;
      notifyListeners();
      _certificationsSub?.cancel();
      _certificationsSub = _firebaseService.getCertifications().listen(
        (list) {
          _certifications = list;
          _isLoadingCertifications = false;
          _errorCertifications = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoadingCertifications = false;
          _errorCertifications = 'Failed to load certifications: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingCertifications = false;
      _errorCertifications = 'Failed to load certifications: $e';
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadSkills(), 
      loadProjects(), 
      loadContactInfo(),
      loadExperiences(),
      loadEducation(),
      loadCertifications()
    ]);
  }

  Future<void> refresh() async {
    await loadAllData();
  }

  // FILTERED DATA
  Map<String, List<SkillModel>> get skillsByCategory {
    final Map<String, List<SkillModel>> grouped = {};
    for (var skill in _skills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]?.add(skill);
    }
    return grouped;
  }

  List<ProjectModel> get featuredProjects {
    return _projects.where((project) => project.featured).toList();
  }

  /// ADMIN OPERATIONS - SKILLS CRUD
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _firebaseService.addSkill(skill);
    } catch (e) {
      throw Exception('Failed to add skill: $e');
    }
  }

  Future<void> updateSkill(String skillId, SkillModel skill) async {
    try {
      await _firebaseService.updateSkill(skillId, skill);
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      await _firebaseService.deleteSkill(skillId);
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  Future<void> toggleSkillVisibility(SkillModel skill) async {
    try {
      final updateSkill = skill.copyWith(isVisible: !skill.isVisible);
      await _firebaseService.updateSkill(skill.id, updateSkill);
    } catch (e) {
      throw Exception('Failed to toggle skill visibility: $e');
    }
  }

  /// ADMIN OPERATIONS - PROJECTS CRUD
  Future<void> addProject(ProjectModel project) async {
    try {
      await _firebaseService.addProject(project);
    } catch (e) {
      throw Exception('Failed to add project:  $e');
    }
  }

  Future<void> updateProject(String projectId, ProjectModel project) async {
    try {
      await _firebaseService.updateProject(projectId, project);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firebaseService.deleteProject(projectId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<void> toggleProjectVisibility(ProjectModel project) async {
    try {
      final updateProject = project.copyWith(isVisible: !project.isVisible);
      await _firebaseService.updateProject(project.id, updateProject);
    } catch (e) {
      throw Exception('Failed to toggle project visibility: $e');
    }
  }

  Future<void> toggleProjectFeatured(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(featured: !project.featured);
      await _firebaseService.updateProject(project.id, updatedProject);
    } catch (e) {
      throw Exception('Failed to toggle featured:  $e');
    }
  }

  /// ADMIN OPERATIONS - CONTACT INFO CRUD
  Future<void> updateContactInfo(ContactModel contact) async {
    try {
      await _firebaseService.updateContactInfo(contact);
    } catch (e) {
      throw Exception('Failed to update contact info: $e');
    }
  }

  Future<void> addExperience(ProfessionalExperienceModel item) async {
    try {
      await _firebaseService.addExperience(item);
    } catch (e) {
      throw Exception('Failed to add experience: $e');
    }
  }

  Future<void> updateExperience(String id, ProfessionalExperienceModel item) async {
    try {
      await _firebaseService.updateExperience(id, item);
    } catch (e) {
      throw Exception('Failed to update experience: $e');
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _firebaseService.deleteExperience(id);
    } catch (e) {
      throw Exception('Failed to delete experience: $e');
    }
  }

  Future<void> addEducation(EducationModel item) async {
    try {
      await _firebaseService.addEducation(item);
    } catch (e) {
      throw Exception('Failed to add education: $e');
    }
  }

  Future<void> updateEducation(String id, EducationModel item) async {
    try {
      await _firebaseService.updateEducation(id, item);
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await _firebaseService.deleteEducation(id);
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }

  Future<void> addCertification(CertificationModel item) async {
    try {
      await _firebaseService.addCertification(item);
    } catch (e) {
      throw Exception('Failed to add certification: $e');
    }
  }

  Future<void> updateCertification(String id, CertificationModel item) async {
    try {
      await _firebaseService.updateCertification(id, item);
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  Future<void> deleteCertification(String id) async {
    try {
      await _firebaseService.deleteCertification(id);
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }

  @override
  void dispose() {
    _skillsSub?.cancel();
    _projectsSub?.cancel();
    _contactSub?.cancel();
    _allSkillsSub?.cancel();
    _allProjectsSub?.cancel();
    _experiencesSub?.cancel();
    _educationSub?.cancel();
    _certificationsSub?.cancel();
    super.dispose();
  }
}
