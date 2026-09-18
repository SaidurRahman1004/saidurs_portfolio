import 'package:flutter_test/flutter_test.dart';
import 'package:futter_portfileo_website/services/analytics/analytics_constants.dart';
import 'package:futter_portfileo_website/services/analytics/analytics_service.dart';

void main() {
  group('AnalyticsConstants Tests', () {
    test('all GA4 event names follow valid snake_case conventions', () {
      final events = [
        AnalyticsEvents.pageView,
        AnalyticsEvents.sectionView,
        AnalyticsEvents.navClick,
        AnalyticsEvents.navigationClick,
        AnalyticsEvents.mobileMenuOpen,
        AnalyticsEvents.mobileMenuClose,
        AnalyticsEvents.themeToggle,
        AnalyticsEvents.projectOpen,
        AnalyticsEvents.projectCardView,
        AnalyticsEvents.projectDetailsOpen,
        AnalyticsEvents.projectFilterApply,
        AnalyticsEvents.projectFilter,
        AnalyticsEvents.projectSearch,
        AnalyticsEvents.projectLinkClick,
        AnalyticsEvents.projectGalleryOpen,
        AnalyticsEvents.projectGalleryImageView,
        AnalyticsEvents.projectShare,
        AnalyticsEvents.projectCopyLink,
        AnalyticsEvents.resumeDownload,
        AnalyticsEvents.resumeView,
        AnalyticsEvents.contactCtaClick,
        AnalyticsEvents.contactFormStart,
        AnalyticsEvents.contactFormSubmit,
        AnalyticsEvents.contactFormSuccess,
        AnalyticsEvents.contactFormFailure,
        AnalyticsEvents.contactInquiryStart,
        AnalyticsEvents.contactInquirySubmit,
        AnalyticsEvents.directContactClick,
        AnalyticsEvents.emailClick,
        AnalyticsEvents.phoneClick,
        AnalyticsEvents.whatsappClick,
        AnalyticsEvents.githubClick,
        AnalyticsEvents.linkedinClick,
        AnalyticsEvents.copyEmail,
        AnalyticsEvents.socialClick,
        AnalyticsEvents.externalLinkClick,
        AnalyticsEvents.ctaClick,
        AnalyticsEvents.timelineExpand,
        AnalyticsEvents.adminLogin,
        AnalyticsEvents.adminLogout,
        AnalyticsEvents.adminContentEdit,
      ];

      for (final event in events) {
        expect(event.length, lessThanOrEqualTo(40),
            reason: '$event exceeds 40 characters');
        expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(event), isTrue,
            reason: '$event is not valid snake_case');
      }
    });

    test('parameter keys follow GA4 length and format rules', () {
      final params = [
        AnalyticsParams.screenName,
        AnalyticsParams.screenClass,
        AnalyticsParams.sectionId,
        AnalyticsParams.sectionName,
        AnalyticsParams.itemTitle,
        AnalyticsParams.destination,
        AnalyticsParams.destinationDomain,
        AnalyticsParams.source,
        AnalyticsParams.sourceSection,
        AnalyticsParams.ctaLocation,
        AnalyticsParams.projectId,
        AnalyticsParams.projectTitle,
        AnalyticsParams.projectSlug,
        AnalyticsParams.projectCategory,
        AnalyticsParams.position,
        AnalyticsParams.searchTerm,
        AnalyticsParams.resultCount,
        AnalyticsParams.imageIndex,
        AnalyticsParams.imageCount,
        AnalyticsParams.fileType,
        AnalyticsParams.errorType,
        AnalyticsParams.linkType,
        AnalyticsParams.linkUrl,
        AnalyticsParams.platform,
        AnalyticsParams.contactMethod,
        AnalyticsParams.projectType,
        AnalyticsParams.hasPhone,
        AnalyticsParams.themeMode,
        AnalyticsParams.deviceType,
        AnalyticsParams.action,
        AnalyticsParams.targetType,
        AnalyticsParams.targetId,
        AnalyticsParams.status,
      ];

      for (final param in params) {
        expect(param.length, lessThanOrEqualTo(40),
            reason: '$param exceeds 40 characters');
        expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(param), isTrue,
            reason: '$param is not valid snake_case parameter key');
      }
    });

    test('link types are standardized snake_case values', () {
      final linkTypes = [
        AnalyticsLinkTypes.github,
        AnalyticsLinkTypes.liveDemo,
        AnalyticsLinkTypes.googlePlay,
        AnalyticsLinkTypes.appStore,
        AnalyticsLinkTypes.other,
      ];

      for (final type in linkTypes) {
        expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(type), isTrue,
            reason: '$type is not valid snake_case link type');
      }
    });
  });

  group('Analytics PII Sanitization & Safety Tests', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService.instance;
    });

    test('returns null for null or empty parameter maps', () {
      expect(service.sanitizeParametersForTesting(null), isNull);
      expect(service.sanitizeParametersForTesting({}), isNull);
    });

    test('blocks all forbidden PII parameter keys', () {
      final dirtyParams = <String, Object>{
        'email': 'user@gmail.com',
        'email_address': 'test@example.com',
        'phone': '+1234567890',
        'phone_number': '01700000000',
        'whatsapp_number': '+8801700000000',
        'message': 'Hello, here is my secret',
        'contact_message': 'Please build me an app',
        'password': 'supersecretpassword123',
        'token': 'secret_auth_token',
        'user_data': 'private info',
        'section_id': 'contact', // valid key
        'position': 1, // valid key
      };

      final sanitized = service.sanitizeParametersForTesting(dirtyParams);

      expect(sanitized, isNotNull);
      expect(sanitized!.containsKey('email'), isFalse);
      expect(sanitized.containsKey('email_address'), isFalse);
      expect(sanitized.containsKey('phone'), isFalse);
      expect(sanitized.containsKey('phone_number'), isFalse);
      expect(sanitized.containsKey('whatsapp_number'), isFalse);
      expect(sanitized.containsKey('message'), isFalse);
      expect(sanitized.containsKey('contact_message'), isFalse);
      expect(sanitized.containsKey('password'), isFalse);
      expect(sanitized.containsKey('token'), isFalse);
      expect(sanitized.containsKey('user_data'), isFalse);
      // Safe parameters must be retained
      expect(sanitized['section_id'], equals('contact'));
      expect(sanitized['position'], equals(1));
    });

    test('blocks string values containing email addresses even under safe keys', () {
      final paramsWithEmbeddedEmail = <String, Object>{
        'item_title': 'Contact via user@domain.com',
        'destination': 'mailto:test.person@sub.example.co.uk',
        'source_section': 'projects',
      };

      final sanitized = service.sanitizeParametersForTesting(paramsWithEmbeddedEmail);

      expect(sanitized, isNotNull);
      expect(sanitized!.containsKey('item_title'), isFalse);
      expect(sanitized.containsKey('destination'), isFalse);
      expect(sanitized['source_section'], equals('projects'));
    });

    test('truncates strings longer than 100 characters', () {
      final longString = 'a' * 150;
      final params = <String, Object>{
        'item_title': longString,
      };

      final sanitized = service.sanitizeParametersForTesting(params);

      expect(sanitized, isNotNull);
      expect((sanitized!['item_title'] as String).length, equals(100));
    });

    test('preserves valid primitive types (int, double, bool, clean string)', () {
      final validParams = <String, Object>{
        'section_id': 'hero',
        'position': 2,
        'result_count': 10,
        'has_phone': false,
      };

      final sanitized = service.sanitizeParametersForTesting(validParams);

      expect(sanitized, isNotNull);
      expect(sanitized!['section_id'], equals('hero'));
      expect(sanitized['position'], equals(2));
      expect(sanitized['result_count'], equals(10));
      expect(sanitized['has_phone'], equals(false));
    });
  });

  group('AnalyticsService Safe Fallback & Execution Tests', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService.instance;
      service.resetForTesting();
    });

    test('is a singleton instance', () {
      final s1 = AnalyticsService();
      final s2 = AnalyticsService.instance;
      expect(identical(s1, s2), isTrue);
    });

    test('initializes safely when Firebase apps is empty without crashing', () async {
      expect(service.isInitialized, isFalse);

      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(service.navigatorObserver, isNull);
    });

    test('ignores duplicate initialize calls', () async {
      await service.initialize();
      expect(service.isInitialized, isTrue);

      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    test('all Phase 2 tracking methods execute safely without throwing when uninitialized', () async {
      service.resetForTesting();

      // Navigation
      await service.logPageView(screenName: 'AllProjects');
      await service.logSectionView(sectionId: 'projects', sectionName: 'Projects', source: 'scroll');
      await service.logNavClick(itemTitle: 'Projects', destination: 'projects', source: 'navbar');
      await service.logMobileMenu(isOpen: true, source: 'app_bar');
      await service.logMobileMenu(isOpen: false, source: 'drawer');

      // Projects
      await service.logProjectCardView(
        projectId: 'p1',
        projectTitle: 'Portfolio',
        projectSlug: 'portfolio',
        category: 'Flutter Web',
        sourceSection: 'projects_grid',
        position: 0,
      );
      await service.logProjectDetailsOpen(
        projectId: 'p1',
        projectTitle: 'Portfolio',
        projectSlug: 'portfolio',
        category: 'Flutter Web',
        sourceSection: 'home',
        position: 0,
      );
      await service.logProjectFilterApply(category: 'Flutter', sourceSection: 'all_projects');
      await service.logProjectSearch(searchTerm: 'crypto', resultCount: 2, sourceSection: 'all_projects');
      await service.logProjectLinkClick(
        projectId: 'p1',
        projectSlug: 'portfolio',
        category: 'Flutter Web',
        linkType: AnalyticsLinkTypes.github,
        url: 'https://github.com/example/repo',
        position: 0,
        sourceSection: 'modal',
      );
      await service.logProjectGalleryOpen(
        projectId: 'p1',
        imageCount: 4,
        sourceSection: 'modal',
      );
      await service.logProjectGalleryImageView(
        projectId: 'p1',
        imageIndex: 2,
        sourceSection: 'modal',
      );
      await service.logProjectShare(
        projectId: 'p1',
        projectSlug: 'portfolio',
        method: 'web_share',
      );
      await service.logProjectCopyLink(
        projectId: 'p1',
        projectSlug: 'portfolio',
      );

      // Resume
      await service.logResumeView(source: 'hero', ctaLocation: 'hero_buttons');
      await service.logResumeDownload(source: 'contact', ctaLocation: 'contact_section', fileType: 'pdf');

      // Contact
      await service.logContactCtaClick(source: 'hero', ctaLocation: 'hero_cta');
      await service.logContactFormStart(sourceSection: 'contact_section');
      await service.logContactFormSubmit(projectType: 'Mobile App', hasPhone: false);
      await service.logContactFormSuccess();
      await service.logContactFormFailure(errorType: 'network');
      await service.logEmailClick(source: 'contact_section');
      await service.logPhoneClick(source: 'contact_section');
      await service.logWhatsappClick(source: 'contact_section');

      // Social
      await service.logGithubClick(source: 'footer');
      await service.logLinkedinClick(source: 'contact');

      // UX
      await service.logThemeToggle(isDark: true);
      await service.logCopyEmail(source: 'contact_card');
      await service.logExternalLinkClick(destinationDomain: 'flutter.dev', source: 'about');
      await service.logCtaClick(itemTitle: 'hire_me', destination: 'contact');
      await service.logTimelineExpand(itemId: 'exp_1', itemTitle: 'Flutter Dev');

      // Admin & properties
      await service.logAdminAction(action: 'edit_project', targetType: 'project', targetId: 'p1');
      await service.setUserProperty(name: 'user_role', value: 'guest');
      await service.resetAnalyticsData();
    });

    test('event listener is not called when service collection is disabled or uninitialized', () async {
      await service.initialize();
      await service.setAnalyticsCollectionEnabled(false);

      String? capturedEvent;
      Map<String, Object>? capturedParams;

      service.setEventListener((event, params) {
        capturedEvent = event;
        capturedParams = params;
      });

      await service.logSectionView(
        sectionId: 'hero',
        sectionName: 'Hero Section',
      );

      // Since collection is disabled, logEvent returns safely before triggering listener
      expect(capturedEvent, isNull);
      expect(capturedParams, isNull);
    });

    test('disabling analytics collection updates isEnabled flag', () async {
      await service.initialize();
      expect(service.isEnabled, isTrue);

      await service.setAnalyticsCollectionEnabled(false);
      expect(service.isEnabled, isFalse);

      await service.setAnalyticsCollectionEnabled(true);
      expect(service.isEnabled, isTrue);
    });
  });
}
