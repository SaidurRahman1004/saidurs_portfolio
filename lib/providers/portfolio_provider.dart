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

  ///Loading states
  bool _isLoadingSkills = true;
  bool _isLoadingProjects = true;
  bool _isLoadingContact = true;

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
    return _projects.where((project)=>project.isFeatured).toList();
  }
}
