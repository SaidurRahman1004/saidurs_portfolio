import 'package:flutter/cupertino.dart';

import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/contact_model.dart';
import '../services/firebase_service.dart';

class PortfolioProvider with ChangeNotifier {
  final FirebaseService _firebaseService =
      FirebaseService.instance; //instance of firebase service class
  ///Store All Logics
  List<SkillModel> _skills = [];
  List<ProjectModel> _projects = [];
  ContactModel? _contactInfo;

  //For Admin
  List<SkillModel> _allSkills = [];
  List<ProjectModel> _allProjects = [];

  //getter
  List<SkillModel> get skills => _skills;

  List<ProjectModel> get projects => _projects;

  ContactModel? get contactInfo => _contactInfo;

  //Admin gretter
  List<SkillModel> get allSkills => _allSkills;

  List<ProjectModel> get allProjects => _allProjects;

  ///Loading states
  bool _isLoadingSkills = true;
  bool _isLoadingProjects = true;
  bool _isLoadingContact = true;

  //Admin Loaders
  bool _isLoadingAllSkills = false;
  bool _isLoadingAllProjects = false;

  //get Admin loaders
  bool get isLoadingAllSkills => _isLoadingAllSkills;

  bool get isLoadingAllProjects => _isLoadingAllProjects;

  bool get isLoadingSkills => _isLoadingSkills;

  bool get isLoadingProjects => _isLoadingProjects;

  bool get isLoadingContact => _isLoadingContact;

  //All Data Loading State
  bool get isLoading =>
      _isLoadingSkills || _isLoadingProjects || _isLoadingContact;

  ///Error States
  String? _errorSkills;
  String? _errorProjects;
  String? _errorContact;

  //  Admin error states
  String? _errorAllSkills;
  String? _errorAllProjects;

  // Admin error getters
  String? get errorAllSkills => _errorAllSkills;

  String? get errorAllProjects => _errorAllProjects;

  String? get errorSkills => _errorSkills;

  String? get errorProjects => _errorProjects;

  String? get errorContact => _errorContact;

  ///Loads Data
  //Load Skill
  Future<void> loadSkills() async {
    try {
      _isLoadingSkills = true;
      _errorSkills = null;
      notifyListeners();
      await _firebaseService.getSkills().listen(
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

  //Load All Skills For Admin
  Future<void> loadAllSkills() async {
    try {
      _isLoadingAllSkills = true;
      _errorAllSkills = null;
      notifyListeners();

      _firebaseService.getAllSkills().listen(
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

  //Load All Project
  Future<void> loadProjects() async {
    try {
      _isLoadingProjects = true;
      _errorProjects = null;
      notifyListeners();

      _firebaseService.getProjects().listen(
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

  //Load All Projects For Admin
  Future<void> loadAllProjects() async {
    try {
      _isLoadingAllProjects = true;
      _errorAllProjects = null;
      notifyListeners();

      _firebaseService.getAllProjects().listen(
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

  //Load Contact Info
  Future<void> loadContactInfo() async {
    try {
      _isLoadingContact = true;
      _errorContact = null;
      notifyListeners();
      _firebaseService.getContactInfo().listen(
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

  //All Data Load Initial Loading,call in main.dart
  Future<void> loadAllData() async {
    await Future.wait([loadSkills(), loadProjects(), loadContactInfo()]);
  }

  //Pull To Refresh
  Future<void> refresh() async {
    await loadAllData();
  }

  //  FILTERED DATA
  //Show Catagorywise Skills
  Map<String, List<SkillModel>> get skillsByCategory {
    final Map<String, List<SkillModel>> grouped = {}; //uses for sorting
    for (var skill in _skills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]?.add(skill);
    }
    return grouped;
  }

  /// Show Featured Projects highlight in Publicly from Firebase
  List<ProjectModel> get featuredProjects {
    return _projects.where((project) => project.isFeatured).toList();
  }

  /// ADMIN OPERATIONS - SKILLS CRUD
  // Add New Skill
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _firebaseService.addSkill(skill);
    } catch (e) {
      throw Exception('Failed to add skill: $e');
    }
  }

  //Update Skill
  Future<void> updateSkill(String skillId, SkillModel skill) async {
    try {
      await _firebaseService.updateSkill(skillId, skill);
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  //DEllet Screen
  Future<void> deleteSkill(String skillId) async {
    try {
      await _firebaseService.deleteSkill(skillId);
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  //Skill visibility toggle
  Future<void> toggleSkillVisibility(SkillModel skill) async {
    try {
      //cheak Current Visiability
      final updateSkill = skill.copyWith(isVisible: !skill.isVisible);
      await _firebaseService.updateSkill(skill.id, updateSkill);
    } catch (e) {
      throw Exception('Failed to toggle skill visibility: $e');
    }
  }

  /// ADMIN OPERATIONS - PROJECTS CRUD
  // Project add
  Future<void> addProject(ProjectModel project) async {
    try {
      await _firebaseService.addProject(project);
    } catch (e) {
      throw Exception('Failed to add project:  $e');
    }
  }

  //Project update
  Future<void> updateProject(String projectId, ProjectModel project) async {
    try {
      await _firebaseService.updateProject(projectId, project);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  //Project delete
  Future<void> deleteProject(String projectId) async {
    try {
      await _firebaseService.deleteProject(projectId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  //Project visibility toggle
  Future<void> toggleProjectVisibility(ProjectModel project) async {
    try {
      final updateProject = project.copyWith(isVisible: !project.isVisible);
      await _firebaseService.updateProject(project.id, updateProject);
    } catch (e) {
      throw Exception('Failed to toggle project visibility: $e');
    }
  }

  // Toggle featured status
  Future<void> toggleProjectFeatured(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(isFeatured: !project.isFeatured);

      await _firebaseService.updateProject(project.id, updatedProject);
    } catch (e) {
      throw Exception('Failed to toggle featured:  $e');
    }
  }

  /// ADMIN OPERATIONS - CONTACT INFO CRUD
  //Update Contact Info
  Future<void> updateContactInfo(ContactModel contact) async {
    try {
      await _firebaseService.updateContactInfo(contact);
    } catch (e) {
      throw Exception('Failed to update contact info: $e');
    }
  }
}
