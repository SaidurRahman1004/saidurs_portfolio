import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/contact_model.dart';
import '../models/professional_experience_model.dart';
import '../models/education_model.dart';
import '../models/certification_model.dart';
import '../models/career_config_model.dart';
import '../models/inquiry_model.dart';
import '../models/error_report_model.dart';
import '../services/firebase_service.dart';
import '../services/portfolio_seed_data.dart';
import '../services/security/audit_service.dart';


class PortfolioProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  PortfolioProvider() {
    loadCareerConfig();
  }

  /// Store All Logics
  List<SkillModel> _skills = [];
  List<ProjectModel> _projects = [];
  ContactModel? _contactInfo;
  
  List<ProfessionalExperienceModel> _experiences = [];
  List<EducationModel> _education = [];
  List<CertificationModel> _certifications = [];
  CareerConfigModel _careerConfig = CareerConfigModel.defaultConfig();
  List<InquiryModel> _inquiries = [];
  List<ErrorReportModel> _errorReports = [];

  StreamSubscription? _skillsSub;
  StreamSubscription? _projectsSub;
  StreamSubscription? _contactSub;
  StreamSubscription? _allSkillsSub;
  StreamSubscription? _allProjectsSub;
  
  StreamSubscription? _experiencesSub;
  StreamSubscription? _educationSub;
  StreamSubscription? _certificationsSub;
  StreamSubscription? _careerConfigSub;
  StreamSubscription? _inquiriesSub;
  StreamSubscription? _errorReportsSub;

  // For Admin
  List<SkillModel> _allSkills = [];
  List<ProjectModel> _allProjects = [];

  // getter
  List<SkillModel> get skills => _skills.isNotEmpty ? _skills : PortfolioSeedData.skills;
  List<ProjectModel> get projects => _projects.isNotEmpty ? _projects : PortfolioSeedData.projects;
  ContactModel? get contactInfo => _contactInfo ?? PortfolioSeedData.contactInfo;
  List<ProfessionalExperienceModel> get experiences => _experiences.isNotEmpty ? _experiences : PortfolioSeedData.experiences;
  List<EducationModel> get education => _education.isNotEmpty ? _education : PortfolioSeedData.educations;
  List<CertificationModel> get certifications => _certifications.isNotEmpty ? _certifications : PortfolioSeedData.certifications;
  CareerConfigModel get careerConfig => _careerConfig;
  String get experienceDuration => _careerConfig.formattedDuration;

  // Admin getter
  List<SkillModel> get allSkills => _allSkills.isNotEmpty ? _allSkills : (_skills.isNotEmpty ? _skills : PortfolioSeedData.skills);
  List<ProjectModel> get allProjects => _allProjects.isNotEmpty ? _allProjects : (_projects.isNotEmpty ? _projects : PortfolioSeedData.projects);
  List<InquiryModel> get inquiries => _inquiries;
  int get unreadInquiriesCount => _inquiries.where((i) => !i.isRead).length;

  // Error reports getters
  List<ErrorReportModel> get errorReports => _errorReports;
  bool get isLoadingErrorReports => _isLoadingErrorReports;
  String? get errorReportsError => _errorReportsError;

  int get totalErrorsCount => _errorReports.length;
  int get openErrorsCount => _errorReports.where((e) => e.isOpen).length;
  int get investigatingErrorsCount => _errorReports.where((e) => e.isInvestigating).length;
  int get resolvedErrorsCount => _errorReports.where((e) => e.isResolved).length;
  int get ignoredErrorsCount => _errorReports.where((e) => e.isIgnored).length;
  int get criticalErrorsCount => _errorReports.where((e) => e.isCritical).length;
  int get last24HoursErrorsCount => _errorReports.where((e) => e.isLast24Hours).length;


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
  bool _isLoadingInquiries = false;
  bool _isLoadingErrorReports = false;
  String? _errorReportsError;

  // get Admin loaders
  bool get isLoadingAllSkills => _isLoadingAllSkills;
  bool get isLoadingAllProjects => _isLoadingAllProjects;

  bool get isLoadingSkills => _isLoadingSkills;
  bool get isLoadingProjects => _isLoadingProjects;
  bool get isLoadingContact => _isLoadingContact;
  bool get isLoadingExperiences => _isLoadingExperiences;
  bool get isLoadingEducation => _isLoadingEducation;
  bool get isLoadingCertifications => _isLoadingCertifications;
  bool get isLoadingInquiries => _isLoadingInquiries;

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
  String? get errorInquiries => _errorInquiries;

  String? _errorInquiries;

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
  
  bool _isExperienceFromFirestore = false;
  bool get isExperienceFromFirestore => _isExperienceFromFirestore;

  bool _isEducationFromFirestore = false;
  bool get isEducationFromFirestore => _isEducationFromFirestore;

  bool _isCertificationFromFirestore = false;
  bool get isCertificationFromFirestore => _isCertificationFromFirestore;

  Future<void> syncDefaultExperiencesToFirestore() async {
    _isLoadingExperiences = true;
    _errorExperiences = null;
    notifyListeners();
    try {
      for (final exp in PortfolioSeedData.experiences) {
        await _firebaseService.addExperience(exp);
      }
      _isLoadingExperiences = false;
      notifyListeners();
    } catch (e) {
      _isLoadingExperiences = false;
      _errorExperiences = 'Failed to sync experience: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> syncDefaultEducationToFirestore() async {
    _isLoadingEducation = true;
    _errorEducation = null;
    notifyListeners();
    try {
      for (final edu in PortfolioSeedData.educations) {
        await _firebaseService.addEducation(edu);
      }
      _isLoadingEducation = false;
      notifyListeners();
    } catch (e) {
      _isLoadingEducation = false;
      _errorEducation = 'Failed to sync education: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> syncDefaultCertificationsToFirestore() async {
    _isLoadingCertifications = true;
    _errorCertifications = null;
    notifyListeners();
    try {
      for (final cert in PortfolioSeedData.certifications) {
        await _firebaseService.addCertification(cert);
      }
      _isLoadingCertifications = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCertifications = false;
      _errorCertifications = 'Failed to sync certifications: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadExperiences({bool includeHidden = false}) async {
    try {
      _isLoadingExperiences = true;
      _errorExperiences = null;
      notifyListeners();
      _experiencesSub?.cancel();
      _experiencesSub = _firebaseService.getExperiences(includeHidden: includeHidden).listen(
        (list) {
          if (list.isEmpty) {
            _experiences = PortfolioSeedData.experiences;
            _isExperienceFromFirestore = false;
          } else {
            _experiences = list;
            _isExperienceFromFirestore = true;
          }
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

  Future<void> loadEducation({bool includeHidden = false}) async {
    try {
      _isLoadingEducation = true;
      _errorEducation = null;
      notifyListeners();
      _educationSub?.cancel();
      _educationSub = _firebaseService.getEducation(includeHidden: includeHidden).listen(
        (list) {
          if (list.isEmpty) {
            _education = PortfolioSeedData.educations;
            _isEducationFromFirestore = false;
          } else {
            _education = list;
            _isEducationFromFirestore = true;
          }
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

  Future<void> loadCertifications({bool includeHidden = false}) async {
    try {
      _isLoadingCertifications = true;
      _errorCertifications = null;
      notifyListeners();
      _certificationsSub?.cancel();
      _certificationsSub = _firebaseService.getCertifications(includeHidden: includeHidden).listen(
        (list) {
          if (list.isEmpty) {
            _certifications = PortfolioSeedData.certifications;
            _isCertificationFromFirestore = false;
          } else {
            _certifications = list;
            _isCertificationFromFirestore = true;
          }
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
      loadAllSkills(),
      loadAllProjects(),
      loadContactInfo(),
      loadExperiences(),
      loadEducation(),
      loadCertifications(),
    ]);
  }

  Future<void> refresh() async {
    await loadAllData();
  }

  // FILTERED DATA
  Map<String, List<SkillModel>> get skillsByCategory {
    final Map<String, List<SkillModel>> grouped = {};
    for (var skill in skills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]?.add(skill);
    }
    return grouped;
  }

  List<ProjectModel> get featuredProjects {
    return projects.where((project) => project.isFeatured).toList();
  }


  /// ADMIN OPERATIONS - SKILLS CRUD
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _firebaseService.addSkill(skill);
      AuditService.instance.logAction(
        action: 'skill_create',
        resourceType: 'skill',
        resourceId: skill.name,
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'skill_create',
        resourceType: 'skill',
        resourceId: skill.name,
        result: 'failure',
      );
      throw Exception('Failed to add skill: $e');
    }
  }

  Future<void> updateSkill(String skillId, SkillModel skill) async {
    try {
      await _firebaseService.updateSkill(skillId, skill);
      AuditService.instance.logAction(
        action: 'skill_update',
        resourceType: 'skill',
        resourceId: skillId,
        metadata: {'name': skill.name},
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'skill_update',
        resourceType: 'skill',
        resourceId: skillId,
        result: 'failure',
      );
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      await _firebaseService.deleteSkill(skillId);
      AuditService.instance.logAction(
        action: 'skill_delete',
        resourceType: 'skill',
        resourceId: skillId,
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'skill_delete',
        resourceType: 'skill',
        resourceId: skillId,
        result: 'failure',
      );
      throw Exception('Failed to delete skill: $e');
    }
  }

  Future<void> toggleSkillVisibility(SkillModel skill) async {
    try {
      final updateSkill = skill.copyWith(isVisible: !skill.isVisible);
      await _firebaseService.updateSkill(skill.id, updateSkill);
      AuditService.instance.logAction(
        action: 'visibility_toggle',
        resourceType: 'skill',
        resourceId: skill.id,
        metadata: {'newVisibility': updateSkill.isVisible},
      );
    } catch (e) {
      throw Exception('Failed to toggle skill visibility: $e');
    }
  }

  /// ADMIN OPERATIONS - PROJECTS CRUD
  Future<void> addProject(ProjectModel project) async {
    try {
      await _firebaseService.addProject(project);
      AuditService.instance.logAction(
        action: 'project_create',
        resourceType: 'project',
        resourceId: project.title,
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'project_create',
        resourceType: 'project',
        resourceId: project.title,
        result: 'failure',
      );
      throw Exception('Failed to add project:  $e');
    }
  }

  Future<void> updateProject(String projectId, ProjectModel project) async {
    try {
      await _firebaseService.updateProject(projectId, project);
      AuditService.instance.logAction(
        action: 'project_update',
        resourceType: 'project',
        resourceId: projectId,
        metadata: {'title': project.title},
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'project_update',
        resourceType: 'project',
        resourceId: projectId,
        result: 'failure',
      );
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firebaseService.deleteProject(projectId);
      AuditService.instance.logAction(
        action: 'project_delete',
        resourceType: 'project',
        resourceId: projectId,
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'project_delete',
        resourceType: 'project',
        resourceId: projectId,
        result: 'failure',
      );
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<void> toggleProjectVisibility(ProjectModel project) async {
    try {
      final updateProject = project.copyWith(isVisible: !project.isVisible);
      await _firebaseService.updateProject(project.id, updateProject);
      AuditService.instance.logAction(
        action: 'visibility_toggle',
        resourceType: 'project',
        resourceId: project.id,
        metadata: {'newVisibility': updateProject.isVisible},
      );
    } catch (e) {
      throw Exception('Failed to toggle project visibility: $e');
    }
  }

  Future<void> toggleProjectFeatured(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(featured: !project.featured);
      await _firebaseService.updateProject(project.id, updatedProject);
      AuditService.instance.logAction(
        action: 'featured_toggle',
        resourceType: 'project',
        resourceId: project.id,
        metadata: {'newFeatured': updatedProject.featured},
      );
    } catch (e) {
      throw Exception('Failed to toggle featured:  $e');
    }
  }

  /// ADMIN OPERATIONS - CONTACT INFO CRUD
  Future<void> updateContactInfo(ContactModel contact) async {
    try {
      await _firebaseService.updateContactInfo(contact);
      AuditService.instance.logAction(
        action: 'contact_update',
        resourceType: 'contact',
        resourceId: contact.id,
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'contact_update',
        resourceType: 'contact',
        resourceId: contact.id,
        result: 'failure',
      );
      throw Exception('Failed to update contact info: $e');
    }
  }

  Future<void> addExperience(ProfessionalExperienceModel item) async {
    try {
      await _firebaseService.addExperience(item);
      AuditService.instance.logAction(
        action: 'experience_update',
        resourceType: 'experience',
        resourceId: item.company,
        metadata: {'operation': 'add', 'title': item.title},
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'experience_update',
        resourceType: 'experience',
        resourceId: item.company,
        result: 'failure',
      );
      throw Exception('Failed to add experience: $e');
    }
  }

  Future<void> updateExperience(String id, ProfessionalExperienceModel item) async {
    try {
      await _firebaseService.updateExperience(id, item);
      AuditService.instance.logAction(
        action: 'experience_update',
        resourceType: 'experience',
        resourceId: id,
        metadata: {'operation': 'update', 'company': item.company},
      );
    } catch (e) {
      AuditService.instance.logAction(
        action: 'experience_update',
        resourceType: 'experience',
        resourceId: id,
        result: 'failure',
      );
      throw Exception('Failed to update experience: $e');
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _firebaseService.deleteExperience(id);
      AuditService.instance.logAction(
        action: 'experience_update',
        resourceType: 'experience',
        resourceId: id,
        metadata: {'operation': 'delete'},
      );
    } catch (e) {
      throw Exception('Failed to delete experience: $e');
    }
  }

  Future<void> addEducation(EducationModel item) async {
    try {
      await _firebaseService.addEducation(item);
      AuditService.instance.logAction(
        action: 'education_update',
        resourceType: 'education',
        resourceId: item.institution,
        metadata: {'operation': 'add', 'degree': item.degree},
      );
    } catch (e) {
      throw Exception('Failed to add education: $e');
    }
  }

  Future<void> updateEducation(String id, EducationModel item) async {
    try {
      await _firebaseService.updateEducation(id, item);
      AuditService.instance.logAction(
        action: 'education_update',
        resourceType: 'education',
        resourceId: id,
        metadata: {'operation': 'update', 'institution': item.institution},
      );
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await _firebaseService.deleteEducation(id);
      AuditService.instance.logAction(
        action: 'education_update',
        resourceType: 'education',
        resourceId: id,
        metadata: {'operation': 'delete'},
      );
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }

  Future<void> addCertification(CertificationModel item) async {
    try {
      await _firebaseService.addCertification(item);
      AuditService.instance.logAction(
        action: 'certification_update',
        resourceType: 'certification',
        resourceId: item.name,
        metadata: {'operation': 'add', 'issuer': item.issuingOrganization},
      );
    } catch (e) {
      throw Exception('Failed to add certification: $e');
    }
  }

  Future<void> updateCertification(String id, CertificationModel item) async {
    try {
      await _firebaseService.updateCertification(id, item);
      AuditService.instance.logAction(
        action: 'certification_update',
        resourceType: 'certification',
        resourceId: id,
        metadata: {'operation': 'update', 'name': item.name},
      );
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  Future<void> deleteCertification(String id) async {
    try {
      await _firebaseService.deleteCertification(id);
      AuditService.instance.logAction(
        action: 'certification_update',
        resourceType: 'certification',
        resourceId: id,
        metadata: {'operation': 'delete'},
      );
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }

  /// Career Config Operations (Start Date & Duration)
  Future<void> loadCareerConfig() async {
    try {
      _careerConfigSub?.cancel();
      _careerConfigSub = _firebaseService.getCareerConfig().listen(
        (config) {
          _careerConfig = config;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('Error loading career config: $e');
        },
      );
    } catch (e) {
      debugPrint('Unexpected error in loadCareerConfig: $e');
    }
  }

  Future<void> updateCareerConfig(CareerConfigModel config) async {
    try {
      await _firebaseService.updateCareerConfig(config);
      _careerConfig = config;
      AuditService.instance.logAction(
        action: 'settings_update',
        resourceType: 'settings',
        resourceId: 'career_config',
        metadata: {'useAutoCalculation': config.useAutoCalculation},
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating career config: $e');
      rethrow;
    }
  }

  /// Bulk Seed Resume & Portfolio Data
  Future<void> seedResumeData() async {
    await _firebaseService.seedResumeData();
    notifyListeners();
  }

  /// Inquiries Operations
  void loadInquiries() {
    _isLoadingInquiries = true;
    _errorInquiries = null;
    notifyListeners();

    _inquiriesSub?.cancel();
    _inquiriesSub = _firebaseService.getInquiries().listen(
      (data) {
        _inquiries = data;
        _isLoadingInquiries = false;
        _errorInquiries = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoadingInquiries = false;
        _errorInquiries = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> submitInquiry({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String message,
    String projectType = 'General Inquiry',
  }) async {
    try {
      final inquiry = InquiryModel(
        id: '',
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        message: message,
        projectType: projectType,
        createdAt: DateTime.now(),
      );
      await _firebaseService.submitInquiry(inquiry);
      return true;
    } catch (e) {
      debugPrint('Failed to submit inquiry: $e');
      return false;
    }
  }

  Future<void> markInquiryAsRead(String id, bool isRead) async {
    try {
      await _firebaseService.markInquiryAsRead(id, isRead);
    } catch (e) {
      debugPrint('Failed to mark inquiry as read: $e');
    }
  }

  Future<void> toggleInquiryStar(String id, bool isStarred) async {
    try {
      await _firebaseService.toggleInquiryStar(id, isStarred);
    } catch (e) {
      debugPrint('Failed to toggle inquiry star: $e');
    }
  }

  Future<void> deleteInquiry(String id) async {
    try {
      await _firebaseService.deleteInquiry(id);
      AuditService.instance.logAction(
        action: 'inquiry_delete',
        resourceType: 'inquiry',
        resourceId: id,
      );
    } catch (e) {
      debugPrint('Failed to delete inquiry: $e');
    }
  }

  /// Error Monitoring Operations
  void loadErrorReports() {
    _isLoadingErrorReports = true;
    _errorReportsError = null;
    notifyListeners();

    _errorReportsSub?.cancel();
    _errorReportsSub = _firebaseService.getErrorReports().listen(
      (data) {
        _errorReports = data;
        _isLoadingErrorReports = false;
        _errorReportsError = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoadingErrorReports = false;
        _errorReportsError = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> updateErrorStatus(String fingerprint, String status) async {
    try {
      await _firebaseService.updateErrorStatus(fingerprint, status);
      AuditService.instance.logAction(
        action: 'error_status_update',
        resourceType: 'error_report',
        resourceId: fingerprint,
        metadata: {'status': status},
      );
      final index = _errorReports.indexWhere((e) => e.fingerprint == fingerprint);
      if (index != -1) {
        _errorReports[index] = _errorReports[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update error status: $e');
      rethrow;
    }
  }

  Future<void> addErrorNote(String fingerprint, String note) async {
    try {
      await _firebaseService.addErrorNote(fingerprint, note);
      final index = _errorReports.indexWhere((e) => e.fingerprint == fingerprint);
      if (index != -1) {
        final currentNotes = List<String>.from(_errorReports[index].notes)..add(note);
        _errorReports[index] = _errorReports[index].copyWith(notes: currentNotes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to add error note: $e');
      rethrow;
    }
  }

  Future<void> deleteErrorReport(String fingerprint) async {
    try {
      await _firebaseService.deleteErrorReport(fingerprint);
      AuditService.instance.logAction(
        action: 'error_report_delete',
        resourceType: 'error_report',
        resourceId: fingerprint,
      );
      _errorReports.removeWhere((e) => e.fingerprint == fingerprint);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete error report: $e');
      rethrow;
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
    _careerConfigSub?.cancel();
    _inquiriesSub?.cancel();
    _errorReportsSub?.cancel();
    super.dispose();
  }
}
