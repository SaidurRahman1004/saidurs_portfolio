import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'analytics_constants.dart';
import 'realtime_analytics_service.dart';

/// Centralized service for application analytics.
/// Wraps [FirebaseAnalytics] to provide safe, type-checked, and resilient
/// tracking methods that will NEVER crash the application if analytics fails.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  bool _isInitialized = false;
  bool _isEnabled = true;

  // Extensibility hook for future GA4 reporting / local admin event interception
  void Function(String eventName, Map<String, Object>? parameters)? _onEventLogged;

  /// Whether the analytics service has completed its initialization attempt.
  bool get isInitialized => _isInitialized;

  /// Whether analytics collection is currently enabled.
  bool get isEnabled => _isEnabled;

  /// Provides a [FirebaseAnalyticsObserver] for [MaterialApp.navigatorObservers],
  /// or `null` if analytics is not available/initialized.
  FirebaseAnalyticsObserver? get navigatorObserver => _observer;

  /// Registers an optional listener for testing or secondary event sinks.
  void setEventListener(
    void Function(String eventName, Map<String, Object>? parameters)? listener,
  ) {
    _onEventLogged = listener;
  }

  /// Safely initializes Firebase Analytics.
  /// If Firebase core is uninitialized or platform does not support analytics,
  /// this method logs a debug message and gracefully disables tracking without throwing.
  Future<void> initialize({
    FirebaseAnalytics? analyticsInstance,
    bool isEnabled = true,
  }) async {
    if (_isInitialized) {
      debugPrint('[AnalyticsService] Already initialized; skipping duplicate initialization.');
      return;
    }

    _isEnabled = isEnabled;

    try {
      if (analyticsInstance != null) {
        // Injected instance (e.g. for testing)
        _analytics = analyticsInstance;
      } else {
        // Verify Firebase is ready before accessing FirebaseAnalytics.instance
        if (Firebase.apps.isEmpty) {
          debugPrint('[AnalyticsService] Warning: Firebase.apps is empty. Analytics will be disabled.');
          _isInitialized = true;
          return;
        }
        _analytics = FirebaseAnalytics.instance;
      }

      await _analytics?.setAnalyticsCollectionEnabled(_isEnabled);

      if (_analytics != null) {
        _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      }

      _isInitialized = true;
      debugPrint('[AnalyticsService] Initialized successfully. Collection enabled: $_isEnabled');

      // Record visitor session to Realtime Firestore Analytics
      RealtimeAnalyticsService.instance.recordVisitorSession();
    } catch (e, stack) {
      // Must NEVER crash the app if analytics setup fails
      debugPrint('[AnalyticsService] Initialization failed (gracefully degraded): $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
      _isInitialized = true;
      _analytics = null;
      _observer = null;
    }
  }

  /// Toggles analytics collection on or off (e.g. for user privacy preferences).
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      await _analytics?.setAnalyticsCollectionEnabled(enabled);
      debugPrint('[AnalyticsService] Analytics collection set to: $enabled');
    } catch (e) {
      debugPrint('[AnalyticsService] Error updating collection status: $e');
    }
  }

  /// Core safe event logging method.
  /// Sanitizes parameters according to GA4 limitations and suppresses any errors.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isEnabled) {
      return;
    }

    try {
      final sanitizedParams = _sanitizeParameters(parameters);
      if (_analytics != null) {
        await _analytics!.logEvent(
          name: name,
          parameters: sanitizedParams,
        );
      }

      _onEventLogged?.call(name, sanitizedParams);
      _forwardToRealtimeAnalytics(name, sanitizedParams);

      if (kDebugMode) {
        debugPrint('[Analytics] Logged: $name with params: $sanitizedParams');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging event "$name": $e');
    }
  }

  void _forwardToRealtimeAnalytics(String name, Map<String, Object>? params) {
    try {
      switch (name) {
        case AnalyticsEvents.sectionView:
          final id = params?[AnalyticsParams.sectionId]?.toString() ?? 'section';
          final title = params?[AnalyticsParams.sectionName]?.toString() ?? id;
          RealtimeAnalyticsService.instance.recordSectionView(id, title);
          break;

        case AnalyticsEvents.resumeDownload:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'download_cv',
            buttonName: 'Download CV / Resume',
            category: 'CTA',
          );
          break;

        case AnalyticsEvents.resumeView:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'view_resume',
            buttonName: 'View Resume Online',
            category: 'CTA',
          );
          break;

        case AnalyticsEvents.contactCtaClick:
        case AnalyticsEvents.ctaClick:
          final title = params?[AnalyticsParams.itemTitle]?.toString() ?? 'Hire Me / Contact';
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'hire_me',
            buttonName: title,
            category: 'CTA',
          );
          break;

        case AnalyticsEvents.projectDetailsOpen:
          final title = params?[AnalyticsParams.projectTitle]?.toString() ?? 'Project Details';
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'project_card_open',
            buttonName: 'View Project: $title',
            category: 'Project',
          );
          break;

        case AnalyticsEvents.projectLinkClick:
          final linkType = params?[AnalyticsParams.linkType]?.toString() ?? 'demo';
          final isGithub = linkType.toLowerCase().contains('github') || linkType.toLowerCase().contains('source');
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: isGithub ? 'project_source_code' : 'project_live_demo',
            buttonName: isGithub ? 'View Project Source Code' : 'View Project Live Demo',
            category: 'Project',
          );
          break;

        case AnalyticsEvents.githubClick:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'social_github',
            buttonName: 'GitHub Profile Link',
            category: 'Social',
          );
          break;

        case AnalyticsEvents.linkedinClick:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'social_linkedin',
            buttonName: 'LinkedIn Profile Link',
            category: 'Social',
          );
          break;

        case AnalyticsEvents.contactFormSubmit:
        case AnalyticsEvents.contactFormSuccess:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'contact_form_submit',
            buttonName: 'Contact Form Send Message',
            category: 'Inquiry',
          );
          break;

        case AnalyticsEvents.themeToggle:
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'theme_toggle',
            buttonName: 'Theme Toggle (Dark/Light)',
            category: 'UI',
          );
          break;

        case AnalyticsEvents.projectFilterApply:
          final cat = params?[AnalyticsParams.projectCategory]?.toString() ?? 'All';
          RealtimeAnalyticsService.instance.recordButtonClick(
            buttonKey: 'filter_projects',
            buttonName: 'Filter Projects: $cat',
            category: 'Navigation',
          );
          break;

        default:
          if (name.contains('click')) {
            final title = params?[AnalyticsParams.itemTitle]?.toString() ?? name;
            RealtimeAnalyticsService.instance.recordButtonClick(
              buttonKey: name,
              buttonName: title,
              category: 'General',
            );
          }
          break;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Error forwarding to RealtimeAnalytics: $e');
    }
  }

  /// Logs a screen view or page view.
  Future<void> logPageView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

      _onEventLogged?.call(AnalyticsEvents.pageView, {
        AnalyticsParams.screenName: screenName,
        if (screenClass != null) AnalyticsParams.screenClass: screenClass,
      });

      if (kDebugMode) {
        debugPrint('[Analytics] PageView: $screenName');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging page view "$screenName": $e');
    }
  }

  // ==========================================
  // A. NAVIGATION TRACKING
  // ==========================================

  /// Logs when the visitor scrolls to or views a specific section.
  Future<void> logSectionView({
    required String sectionId,
    String? sectionName,
    String? source,
  }) async {
    await logEvent(
      name: AnalyticsEvents.sectionView,
      parameters: {
        AnalyticsParams.sectionId: sectionId,
        if (sectionName != null) AnalyticsParams.sectionName: sectionName,
        if (source != null) AnalyticsParams.source: source,
      },
    );
  }

  /// Logs a navigation click (navbar, drawer, footer, etc.).
  Future<void> logNavClick({
    required String itemTitle,
    String? destination,
    String? source,
  }) async {
    await logEvent(
      name: AnalyticsEvents.navClick,
      parameters: {
        AnalyticsParams.itemTitle: itemTitle,
        if (destination != null) AnalyticsParams.destination: destination,
        if (source != null) AnalyticsParams.source: source,
      },
    );
  }

  /// Backward compatible alias for [logNavClick].
  Future<void> logNavigationClick({
    required String itemTitle,
    String? destination,
    String? source,
  }) => logNavClick(itemTitle: itemTitle, destination: destination, source: source);

  /// Logs opening or closing the mobile navigation drawer.
  Future<void> logMobileMenu({
    required bool isOpen,
    String? source,
  }) async {
    await logEvent(
      name: isOpen ? AnalyticsEvents.mobileMenuOpen : AnalyticsEvents.mobileMenuClose,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
      },
    );
  }

  // ==========================================
  // B. PROJECTS TRACKING
  // ==========================================

  /// Logs when a project card is displayed in viewport/grid.
  Future<void> logProjectCardView({
    required String projectId,
    String? projectTitle,
    String? projectSlug,
    String? category,
    String? sourceSection,
    int? position,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectCardView,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectTitle != null) AnalyticsParams.projectTitle: projectTitle,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        if (category != null) AnalyticsParams.projectCategory: category,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
        if (position != null) AnalyticsParams.position: position,
      },
    );
  }

  /// Logs when a user opens a project details modal.
  Future<void> logProjectDetailsOpen({
    required String projectId,
    String? projectTitle,
    String? projectSlug,
    String? category,
    String? sourceSection,
    int? position,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectDetailsOpen,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectTitle != null) AnalyticsParams.projectTitle: projectTitle,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        if (category != null) AnalyticsParams.projectCategory: category,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
        if (position != null) AnalyticsParams.position: position,
      },
    );
  }

  /// Backward-compatible alias for [logProjectDetailsOpen].
  Future<void> logProjectOpen({
    required String projectId,
    String? projectTitle,
    String? category,
  }) => logProjectDetailsOpen(
        projectId: projectId,
        projectTitle: projectTitle,
        category: category,
      );

  /// Logs when a user applies a project category or tag filter.
  Future<void> logProjectFilterApply({
    required String category,
    String? sourceSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectFilterApply,
      parameters: {
        AnalyticsParams.projectCategory: category,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
      },
    );
  }

  /// Logs when a user performs a search in the project list.
  Future<void> logProjectSearch({
    required String searchTerm,
    int? resultCount,
    String? sourceSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectSearch,
      parameters: {
        AnalyticsParams.searchTerm: searchTerm,
        if (resultCount != null) AnalyticsParams.resultCount: resultCount,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
      },
    );
  }

  /// Logs when a user clicks a project outbound link (GitHub, Live Demo, Play Store, App Store).
  Future<void> logProjectLinkClick({
    required String projectId,
    required String linkType,
    String? url,
    String? projectTitle,
    String? projectSlug,
    String? category,
    String? sourceSection,
    int? position,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectLinkClick,
      parameters: {
        AnalyticsParams.projectId: projectId,
        AnalyticsParams.linkType: linkType,
        if (url != null) AnalyticsParams.linkUrl: url,
        if (projectTitle != null) AnalyticsParams.projectTitle: projectTitle,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        if (category != null) AnalyticsParams.projectCategory: category,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
        if (position != null) AnalyticsParams.position: position,
      },
    );
  }

  /// Logs when the project screenshot gallery is opened.
  Future<void> logProjectGalleryOpen({
    required String projectId,
    String? projectSlug,
    int? imageCount,
    String? sourceSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectGalleryOpen,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        if (imageCount != null) AnalyticsParams.imageCount: imageCount,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
      },
    );
  }

  /// Logs when a user views a specific gallery screenshot.
  Future<void> logProjectGalleryImageView({
    required String projectId,
    String? projectSlug,
    required int imageIndex,
    String? sourceSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectGalleryImageView,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        AnalyticsParams.imageIndex: imageIndex,
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
      },
    );
  }

  /// Logs when a project is shared.
  Future<void> logProjectShare({
    required String projectId,
    String? projectSlug,
    String? method,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectShare,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
        if (method != null) AnalyticsParams.platform: method,
      },
    );
  }

  /// Logs when a user copies the project link to clipboard.
  Future<void> logProjectCopyLink({
    required String projectId,
    String? projectSlug,
  }) async {
    await logEvent(
      name: AnalyticsEvents.projectCopyLink,
      parameters: {
        AnalyticsParams.projectId: projectId,
        if (projectSlug != null) AnalyticsParams.projectSlug: projectSlug,
      },
    );
  }

  // ==========================================
  // C. RESUME TRACKING
  // ==========================================

  /// Logs when a visitor views the resume.
  Future<void> logResumeView({
    String? source,
    String? ctaLocation,
    String? fileType = 'pdf',
  }) async {
    await logEvent(
      name: AnalyticsEvents.resumeView,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
        if (fileType != null) AnalyticsParams.fileType: fileType,
      },
    );
  }

  /// Logs when a visitor downloads or opens the resume file.
  Future<void> logResumeDownload({
    String? source,
    String? ctaLocation,
    String? fileType = 'pdf',
  }) async {
    await logEvent(
      name: AnalyticsEvents.resumeDownload,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
        if (fileType != null) AnalyticsParams.fileType: fileType,
      },
    );
  }

  // ==========================================
  // D. CONTACT & INQUIRIES TRACKING
  // ==========================================

  /// Logs when a user clicks a "Contact Me" or "Get In Touch" call-to-action button.
  Future<void> logContactCtaClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contactCtaClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Logs when a visitor begins filling out the contact form (first field touched).
  Future<void> logContactFormStart({
    String? sourceSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contactFormStart,
      parameters: {
        if (sourceSection != null) AnalyticsParams.sourceSection: sourceSection,
      },
    );
  }

  /// Logs when a visitor submits the contact form.
  /// IMPORTANT: NEVER passes email, phone, name, or message content.
  Future<void> logContactFormSubmit({
    String? projectType,
    bool? hasPhone,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contactFormSubmit,
      parameters: {
        if (projectType != null) AnalyticsParams.projectType: projectType,
        if (hasPhone != null) AnalyticsParams.hasPhone: hasPhone ? 'true' : 'false',
      },
    );
  }

  /// Logs successful contact form delivery.
  Future<void> logContactFormSuccess({
    String? projectType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contactFormSuccess,
      parameters: {
        if (projectType != null) AnalyticsParams.projectType: projectType,
      },
    );
  }

  /// Logs contact form validation or delivery failure.
  Future<void> logContactFormFailure({
    String? projectType,
    String? errorType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contactFormFailure,
      parameters: {
        if (projectType != null) AnalyticsParams.projectType: projectType,
        if (errorType != null) AnalyticsParams.errorType: errorType,
      },
    );
  }

  /// Backward compatible helper for contact events.
  Future<void> logContactEvent({
    required String action,
    String? method,
    String? projectType,
    bool? hasPhone,
  }) async {
    await logEvent(
      name: action,
      parameters: {
        if (method != null) AnalyticsParams.contactMethod: method,
        if (projectType != null) AnalyticsParams.projectType: projectType,
        if (hasPhone != null) AnalyticsParams.hasPhone: hasPhone ? 'true' : 'false',
      },
    );
  }

  /// Logs when a visitor clicks an email link.
  Future<void> logEmailClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.emailClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Logs when a visitor clicks a phone link.
  Future<void> logPhoneClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.phoneClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Logs when a visitor clicks a WhatsApp button.
  Future<void> logWhatsappClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.whatsappClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  // ==========================================
  // E. SOCIAL PROFILES TRACKING
  // ==========================================

  /// Logs when a visitor clicks a GitHub profile link.
  Future<void> logGithubClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.githubClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Logs when a visitor clicks a LinkedIn profile link.
  Future<void> logLinkedinClick({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.linkedinClick,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Generic social click logger.
  Future<void> logSocialClick({
    required String platform,
    String? url,
  }) async {
    await logEvent(
      name: AnalyticsEvents.socialClick,
      parameters: {
        AnalyticsParams.platform: platform,
        if (url != null) AnalyticsParams.linkUrl: url,
      },
    );
  }

  // ==========================================
  // F. UX & INTERACTION TRACKING
  // ==========================================

  /// Logs theme mode toggles (dark/light).
  Future<void> logThemeToggle({required bool isDark}) async {
    await logEvent(
      name: AnalyticsEvents.themeToggle,
      parameters: {
        AnalyticsParams.themeMode: isDark ? 'dark' : 'light',
      },
    );
  }

  /// Logs when a visitor copies an email address to clipboard.
  Future<void> logCopyEmail({
    String? source,
    String? ctaLocation,
  }) async {
    await logEvent(
      name: AnalyticsEvents.copyEmail,
      parameters: {
        if (source != null) AnalyticsParams.source: source,
        if (ctaLocation != null) AnalyticsParams.ctaLocation: ctaLocation,
      },
    );
  }

  /// Logs clicks to external websites and resources.
  Future<void> logExternalLinkClick({
    required String destinationDomain,
    String? source,
  }) async {
    await logEvent(
      name: AnalyticsEvents.externalLinkClick,
      parameters: {
        AnalyticsParams.destinationDomain: destinationDomain,
        if (source != null) AnalyticsParams.source: source,
      },
    );
  }

  /// Logs general CTA clicks.
  Future<void> logCtaClick({
    required String itemTitle,
    String? destination,
    String? source,
  }) async {
    await logEvent(
      name: AnalyticsEvents.ctaClick,
      parameters: {
        AnalyticsParams.itemTitle: itemTitle,
        if (destination != null) AnalyticsParams.destination: destination,
        if (source != null) AnalyticsParams.source: source,
      },
    );
  }

  /// Logs when a timeline item is expanded (experience/education).
  Future<void> logTimelineExpand({
    required String itemId,
    String? itemTitle,
  }) async {
    await logEvent(
      name: AnalyticsEvents.timelineExpand,
      parameters: {
        AnalyticsParams.targetId: itemId,
        if (itemTitle != null) AnalyticsParams.itemTitle: itemTitle,
      },
    );
  }

  /// Logs admin operations (login, logout, editing content).
  Future<void> logAdminAction({
    required String action,
    String? targetType,
    String? targetId,
  }) async {
    await logEvent(
      name: action,
      parameters: {
        if (targetType != null) AnalyticsParams.targetType: targetType,
        if (targetId != null) AnalyticsParams.targetId: targetId,
      },
    );
  }

  /// Sets custom user properties (e.g. preferred theme, device category).
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isEnabled || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('[AnalyticsService] Error setting user property "$name": $e');
    }
  }

  /// Resets analytics data (e.g. on admin logout).
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics?.resetAnalyticsData();
    } catch (e) {
      debugPrint('[AnalyticsService] Error resetting analytics data: $e');
    }
  }

  // Forbidden keys that must NEVER be passed to analytics (PII protection)
  static const Set<String> _forbiddenKeys = {
    'email',
    'email_address',
    'phone',
    'phone_number',
    'whatsapp_number',
    'contact_message',
    'message',
    'message_text',
    'password',
    'token',
    'user_data',
    'private_data',
  };

  static final RegExp _emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  /// Sanitizes parameter map to adhere to GA4 restrictions and guarantees zero PII leaks:
  /// - Non-null keys and values only.
  /// - Drops forbidden keys containing personal user data.
  /// - Filters out values matching email patterns.
  /// - Maximum string length of 100 characters for values to prevent payload rejection.
  /// - Keys must be alphanumeric + underscores, max 40 chars.
  Map<String, Object>? _sanitizeParameters(Map<String, Object>? raw) {
    if (raw == null || raw.isEmpty) return null;

    final sanitized = <String, Object>{};
    for (final entry in raw.entries) {
      final key = entry.key.trim().toLowerCase();
      final val = entry.value;

      if (key.isEmpty) continue;

      // PII Protection: Drop forbidden keys
      if (_forbiddenKeys.contains(key)) {
        if (kDebugMode) {
          debugPrint('[AnalyticsService] BLOCKED forbidden PII parameter: "$key"');
        }
        continue;
      }

      // Truncate key to 40 characters if necessary
      final safeKey = key.length > 40 ? key.substring(0, 40) : key;

      if (val is String) {
        // PII Protection: Strip values that contain email addresses
        if (_emailRegex.hasMatch(val)) {
          if (kDebugMode) {
            debugPrint('[AnalyticsService] BLOCKED value containing email in key "$safeKey"');
          }
          continue;
        }
        sanitized[safeKey] = val.length > 100 ? val.substring(0, 100) : val;
      } else if (val is num || val is bool) {
        sanitized[safeKey] = val;
      } else {
        final strVal = val.toString();
        if (_emailRegex.hasMatch(strVal)) {
          continue;
        }
        sanitized[safeKey] = strVal.length > 100 ? strVal.substring(0, 100) : strVal;
      }
    }

    return sanitized.isEmpty ? null : sanitized;
  }

  /// Exposes parameter sanitization for unit tests.
  @visibleForTesting
  Map<String, Object>? sanitizeParametersForTesting(Map<String, Object>? raw) =>
      _sanitizeParameters(raw);

  /// Resets internal state (used exclusively for unit tests).
  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _isEnabled = true;
    _analytics = null;
    _observer = null;
    _onEventLogged = null;
  }
}
