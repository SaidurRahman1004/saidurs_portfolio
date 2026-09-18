/// Centralized event names for Firebase Analytics.
/// Follows Google Analytics 4 (GA4) recommended naming conventions (snake_case, <= 40 characters).
class AnalyticsEvents {
  // Prevent instantiation
  AnalyticsEvents._();

  // Navigation & Page Views
  static const String pageView = 'page_view';
  static const String sectionView = 'section_view';
  static const String navClick = 'nav_click';
  static const String mobileMenuOpen = 'mobile_menu_open';
  static const String mobileMenuClose = 'mobile_menu_close';

  // Projects
  static const String projectCardView = 'project_card_view';
  static const String projectDetailsOpen = 'project_details_open';
  static const String projectFilterApply = 'project_filter_apply';
  static const String projectSearch = 'project_search';
  static const String projectLinkClick = 'project_link_click';
  static const String projectGalleryOpen = 'project_gallery_open';
  static const String projectGalleryImageView = 'project_gallery_image_view';
  static const String projectShare = 'project_share';
  static const String projectCopyLink = 'project_copy_link';

  // Resume
  static const String resumeView = 'resume_view';
  static const String resumeDownload = 'resume_download';

  // Contact & Inquiries
  static const String contactCtaClick = 'contact_cta_click';
  static const String contactFormStart = 'contact_form_start';
  static const String contactFormSubmit = 'contact_form_submit';
  static const String contactFormSuccess = 'contact_form_success';
  static const String contactFormFailure = 'contact_form_failure';
  static const String emailClick = 'email_click';
  static const String phoneClick = 'phone_click';
  static const String whatsappClick = 'whatsapp_click';

  // Social
  static const String githubClick = 'github_click';
  static const String linkedinClick = 'linkedin_click';

  // UX & Engagement
  static const String themeToggle = 'theme_toggle';
  static const String externalLinkClick = 'external_link_click';
  static const String copyEmail = 'copy_email';
  static const String ctaClick = 'cta_click';
  static const String timelineExpand = 'timeline_expand';

  // Admin Actions
  static const String adminLogin = 'admin_login';
  static const String adminLogout = 'admin_logout';
  static const String adminContentEdit = 'admin_content_edit';

  // Backward compatibility aliases
  static const String navigationClick = navClick;
  static const String projectOpen = projectDetailsOpen;
  static const String projectFilter = projectFilterApply;
  static const String contactInquiryStart = contactFormStart;
  static const String contactInquirySubmit = contactFormSubmit;
  static const String directContactClick = emailClick;
  static const String socialClick = githubClick;
}

/// Centralized parameter keys for Firebase Analytics.
/// Parameters are reusable across multiple events to ensure consistent dimensions.
class AnalyticsParams {
  AnalyticsParams._();

  // Navigation / Section Parameters
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String sectionId = 'section_id';
  static const String sectionName = 'section_name';
  static const String itemTitle = 'item_title';
  static const String destination = 'destination';
  static const String source = 'source';
  static const String sourceSection = 'source_section';
  static const String ctaLocation = 'cta_location';

  // Project Parameters
  static const String projectId = 'project_id';
  static const String projectTitle = 'project_title';
  static const String projectSlug = 'project_slug';
  static const String projectCategory = 'project_category';
  static const String linkType = 'link_type';
  static const String linkUrl = 'link_url';
  static const String position = 'position';
  static const String searchTerm = 'search_term';
  static const String resultCount = 'result_count';
  static const String imageIndex = 'image_index';
  static const String imageCount = 'image_count';

  // Resume Parameters
  static const String fileType = 'file_type';

  // Contact / Social Parameters
  static const String platform = 'platform';
  static const String contactMethod = 'contact_method';
  static const String projectType = 'project_type';
  static const String hasPhone = 'has_phone';
  static const String errorType = 'error_type';

  // System & Preference Parameters
  static const String themeMode = 'theme_mode';
  static const String deviceType = 'device_type';
  static const String action = 'action';
  static const String targetType = 'target_type';
  static const String targetId = 'target_id';
  static const String status = 'status';
  static const String destinationDomain = 'destination_domain';
}

/// Standardized project link types.
class AnalyticsLinkTypes {
  AnalyticsLinkTypes._();

  static const String github = 'github';
  static const String liveDemo = 'live_demo';
  static const String googlePlay = 'google_play';
  static const String appStore = 'app_store';
  static const String other = 'other';
}
