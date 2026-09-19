# PHASE 2: Public Website Analytics Tracking Report

**Project:** Saidur Rahman Portfolio (Flutter Web)  
**Date:** September 18, 2026  
**Status:** ✅ Successfully Implemented & Verified  
**Author:** Antigravity AI Assistant

---

## 1. Executive Summary

Phase 2 builds directly upon the Phase 1 Analytics Foundation to implement visitor behavior tracking across the public-facing portfolio website. All analytics events strictly route through the centralized `AnalyticsService`, ensuring that `FirebaseAnalytics.instance.logEvent()` is **never** directly invoked within UI components.

A core tenet of Phase 2 is **Zero PII (Personally Identifiable Information)** collection and **Zero UI Interference**:
- Visitor emails, phone numbers, contact messages, passwords, and tokens are categorically stripped both at call sites and via an automated regex and keyword-based sanitizer in `AnalyticsService`.
- Section and card impressions are deduplicated and debounced to prevent phantom tracking events caused by Flutter widget rebuilds or rapid scrolling.
- All analytics operations degrade gracefully to safe no-ops if Firebase is uninitialized or network fails.

---

## 2. Event Inventory & Taxonomy

All event names follow GA4 `snake_case` conventions and adhere to GA4 string length limits ($\le 40$ chars).

| Event Name | Category | Description | Primary Parameters |
| :--- | :--- | :--- | :--- |
| `page_view` | Navigation | Triggered on route or sub-page view | `screen_name`, `screen_class` |
| `section_view` | Navigation | Triggered when a section enters viewport | `section_id`, `section_name`, `source` |
| `nav_click` | Navigation | Triggered on navbar/drawer menu item tap | `item_title`, `destination`, `source` |
| `mobile_menu_open` | Navigation | Triggered when mobile navigation drawer opens | `source` |
| `mobile_menu_close` | Navigation | Triggered when mobile navigation drawer closes | `source` |
| `project_card_view` | Projects | Triggered once per project card impression in viewport | `project_id`, `project_title`, `project_slug`, `project_category`, `source_section`, `position` |
| `project_details_open` | Projects | Triggered when user opens project details modal | `project_id`, `project_title`, `project_slug`, `project_category`, `source_section`, `position` |
| `project_filter_apply` | Projects | Triggered when user filters projects by category | `project_category`, `source_section` |
| `project_search` | Projects | Triggered when user searches projects (debounced 500ms) | `search_term`, `result_count`, `source_section` |
| `project_link_click` | Projects | Triggered on external project link click | `project_id`, `project_slug`, `project_category`, `link_type`, `position`, `source_section` |
| `project_gallery_open` | Projects | Triggered when screenshots gallery loads | `project_id`, `image_count`, `source_section` |
| `project_gallery_image_view` | Projects | Triggered when a screenshot is selected or viewed | `project_id`, `project_slug`, `image_index`, `source_section` |
| `project_share` | Projects | Triggered when user shares a project (Web Share API) | `project_id`, `project_slug`, `platform` |
| `project_copy_link` | Projects | Triggered when user copies project URL to clipboard | `project_id`, `project_slug` |
| `resume_view` | Resume | Triggered when resume modal or preview opens | `source`, `cta_location`, `file_type` |
| `resume_download` | Resume | Triggered when visitor clicks resume download/view | `source`, `cta_location`, `file_type` |
| `contact_cta_click` | Contact | Triggered when visitor clicks a contact CTA button | `source`, `cta_location` |
| `contact_form_start` | Contact | Triggered on first form field interaction/focus | `source_section` |
| `contact_form_submit` | Contact | Triggered when contact form is submitted | `project_type`, `has_phone` |
| `contact_form_success` | Contact | Triggered upon successful inquiry dispatch to Firestore | *(none - strictly zero PII)* |
| `contact_form_failure` | Contact | Triggered when inquiry dispatch fails | `error_type` *(sanitized)* |
| `email_click` | Social/Contact | Triggered on mailto link click | `source`, `cta_location` |
| `phone_click` | Social/Contact | Triggered on tel link click | `source`, `cta_location` |
| `whatsapp_click` | Social/Contact | Triggered on WhatsApp button click | `source`, `cta_location` |
| `github_click` | Social | Triggered on GitHub profile button click | `source`, `cta_location` |
| `linkedin_click` | Social | Triggered on LinkedIn profile button click | `source`, `cta_location` |
| `copy_email` | UX | Triggered when visitor copies email to clipboard | `source`, `cta_location` |
| `theme_toggle` | UX | Triggered when visitor toggles dark/light theme | `theme_mode` |
| `external_link_click` | UX | Triggered on arbitrary external links | `destination_domain`, `source` |

---

## 3. Event-to-UI Mapping

### A. Navigation & Shell
- **[custom_app_bar.dart](file:///e:/MyWeb/saidurs_portfolio/lib/widgets/comon/custom_app_bar.dart)**:
  - Desktop Navigation Buttons $\rightarrow$ `nav_click` (`source: 'navbar'`, `item_title: item.title`, `destination: item.id`) + `section_view` (`source: 'nav_click'`).
  - Mobile Menu Hamburger $\rightarrow$ `mobile_menu_open` (`source: 'app_bar_hamburger'`).
  - Theme Mode Toggle $\rightarrow$ `theme_toggle` (`theme_mode: 'dark' | 'light'`).
- **[home_screen.dart](file:///e:/MyWeb/saidurs_portfolio/lib/screens/public/home_screen.dart)**:
  - Initial Post-Frame Load $\rightarrow$ `section_view` (`section_id: 'hero'`, `section_name: 'Home'`, `source: 'initial_load'`).
  - Scroll Listener $\rightarrow$ Viewport bounding box tracking debounced by 400ms $\rightarrow$ `section_view` (`source: 'scroll'`).
  - Drawer `onDrawerChanged` $\rightarrow$ `mobile_menu_open` / `mobile_menu_close` (`source: 'scaffold_drawer'`).
  - Mobile Drawer Navigation Items $\rightarrow$ `nav_click` (`source: 'mobile_drawer'`).

### B. Hero Section
- **[hero_section.dart](file:///e:/MyWeb/saidurs_portfolio/lib/screens/public/sections/hero_section.dart)**:
  - "View Project" CTA $\rightarrow$ `cta_click` (`item_title: 'View Project'`, `destination: 'projects'`, `source: 'hero'`).
  - "Contact Me" CTA $\rightarrow$ `contact_cta_click` (`source: 'hero'`, `cta_location: 'hero_primary_cta'`).
  - "View Resume" CTA $\rightarrow$ `resume_view` + `resume_download` (`source: 'hero'`, `cta_location: 'hero_resume_button'`, `file_type: 'pdf'`).

### C. Projects Section (Home & All Projects)
- **[projects_section.dart](file:///e:/MyWeb/saidurs_portfolio/lib/screens/public/sections/projects_section.dart)**:
  - Project Cards $\rightarrow$ Converted to `StatefulWidget` with local `Set<String> _viewedProjectIds` tracking impressions via post-frame callback $\rightarrow$ `project_card_view`.
  - "View All Projects" CTA $\rightarrow$ `nav_click` (`item_title: 'View All Projects'`, `destination: '/projects'`, `source: 'projects_section'`).
  - "Details" Button $\rightarrow$ `project_details_open` (`source_section: 'featured_projects'`).
  - Play Store / App Store / GitHub / Live Demo Buttons $\rightarrow$ `project_link_click` with standardized `link_type` (`google_play`, `app_store`, `github`, `live_demo`).
- **[all_projects_page.dart](file:///e:/MyWeb/saidurs_portfolio/lib/screens/public/sections/all_projects_page.dart)**:
  - Page Entry $\rightarrow$ `page_view` (`screen_name: 'All Projects'`).
  - Search Input $\rightarrow$ Debounced (500ms) timer $\rightarrow$ `project_search` (`search_term`, `result_count`, `source_section: 'all_projects'`).
  - Category Filter Chips $\rightarrow$ `project_filter_apply` (`project_category`, `source_section: 'all_projects'`).
  - Grid Cards $\rightarrow$ Viewport impression deduplicated via `_viewedProjectIds` $\rightarrow$ `project_card_view`.
  - Details Modal & External Link clicks $\rightarrow$ `project_details_open`, `project_link_click`.
- **[project_details_modal.dart](file:///e:/MyWeb/saidurs_portfolio/lib/widgets/comon/project_details_modal.dart)**:
  - Screenshots Gallery $\rightarrow$ `project_gallery_open` (`image_count`, `source_section: 'project_details_modal'`).
  - Gallery Thumbnail Tap $\rightarrow$ `project_gallery_image_view` (`image_index`, `source_section: 'project_details_modal'`).
  - Header Action "Copy Link" $\rightarrow$ `project_copy_link` (`project_id`, `project_slug`) + SnackBar confirmation.
  - Header Action "Share" $\rightarrow$ `project_share` (Web Share API invocation with clipboard fallback).
  - External Link Action Buttons $\rightarrow$ `project_link_click` (`link_type`: `github`, `live_demo`, `google_play`, `app_store`).

### D. Contact Section
- **[contact_section.dart](file:///e:/MyWeb/saidurs_portfolio/lib/screens/public/sections/contact_section.dart)**:
  - Direct Contact Options:
    - Email Tap $\rightarrow$ `email_click` (`source: 'contact_section'`).
    - Copy Email Icon Tap $\rightarrow$ `copy_email` (`source: 'contact_section'`) + SnackBar confirmation.
    - Phone Tap $\rightarrow$ `phone_click` (`source: 'contact_section'`).
    - WhatsApp Tap $\rightarrow$ `whatsapp_click` (`source: 'contact_section'`).
    - Resume CV Button $\rightarrow$ `resume_view` + `resume_download` (`source: 'contact_section'`, `file_type: 'pdf'`).
    - Social Media Links $\rightarrow$ `github_click`, `linkedin_click`, `external_link_click`.
  - Direct Message Form Lifecycle:
    - First Field Interaction $\rightarrow$ `contact_form_start` (`source_section: 'contact_section'`).
    - Form Submission $\rightarrow$ `contact_form_submit` (`project_type`, `has_phone`).
    - Submission Success $\rightarrow$ `contact_form_success` (*strictly zero PII*).
    - Submission Failure $\rightarrow$ `contact_form_failure` (`error_type: 'unknown'`).

---

## 4. Parameter Standards & Standardized Link Types

### Standardized `link_type` Values
As defined in `AnalyticsLinkTypes`:
- `github`
- `live_demo`
- `google_play`
- `app_store`
- `other`

### Common Parameters
- `project_id`, `project_slug`, `project_category`
- `source_section`, `source`, `cta_location`, `position`
- `destination`, `destination_domain`, `file_type`
- `search_term`, `result_count`, `image_index`, `image_count`

---

## 5. Duplicate-Event Prevention & Performance Strategy

Flutter's declarative rebuild model can easily cause repetitive analytics events if not managed carefully. Phase 2 implements a multi-tiered deduplication strategy:

1. **Section View Deduplication & Debounce:**
   - In `HomeScreen`, the `ScrollController` listener is debounced with a 400ms timer (`_scrollDebounceTimer`).
   - The visible section calculation compares viewport bounding boxes and only logs `section_view` if the currently visible section differs from `_lastActiveSection`.
   - Continuous scrolling or rebuilds while hovering over the same section fire zero duplicate events.
2. **Project Card View Deduplication:**
   - Both `ProjectsSection` and `AllProjectsPage` maintain a `Set<String> _viewedProjectIds`.
   - Each project card only logs `project_card_view` once during a browsing session, even if the parent widget rebuilds or the user scrolls back and forth over the card.
3. **Search Query Debounce:**
   - In `AllProjectsPage`, search input is debounced with a 500ms timer (`_searchDebounceTimer`). Only settled queries log `project_search`, avoiding logging on every keystroke.
4. **Zero UI Blocking:**
   - All analytics helper methods are asynchronous and fire-and-forget (`unawaited` where called from synchronous callbacks).
   - Any internal analytics exceptions are caught and swallowed with `debugPrint` so the user interface never freezes or stumbles.

---

## 6. Ironclad PII Protection Architecture

To ensure strict GDPR/privacy compliance, Phase 2 implements a two-layer PII firewall:

1. **Call-Site Guard:**
   - UI code explicitly excludes user input fields (name, email, phone number, message text) from the parameter payload when logging `contact_form_submit`, `contact_form_success`, or direct contact taps.
2. **Centralized Service-Level Sanitizer (`_sanitizeParameters`):**
   - **Forbidden Keys:** Drops any parameter named `email`, `email_address`, `phone`, `phone_number`, `whatsapp_number`, `contact_message`, `message`, `message_text`, `password`, `token`, `user_data`, or `private_data`.
   - **Regex Email Scanner:** Even if a user embeds an email inside a permitted key (e.g. `item_title: 'Contact me at test@example.com'`), the regex `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` detects it and discards the entire value.
   - **String Length Limits:** Truncates string values to 100 characters and parameter keys to 40 characters to conform to GA4 constraints.

---

## 7. Files Modified

| File | Changes Made |
| :--- | :--- |
| `lib/services/analytics/analytics_constants.dart` | Added all Phase 2 event constants, parameter keys, and standardized `AnalyticsLinkTypes`. |
| `lib/services/analytics/analytics_service.dart` | Added typed helper methods for all Phase 2 events, `_forbiddenKeys` and `_emailRegex` PII sanitizer, `sanitizeParametersForTesting`, and `logTimelineExpand`. |
| `lib/widgets/comon/custom_app_bar.dart` | Added `nav_click`, `section_view`, `theme_toggle`, and `mobile_menu_open` tracking. |
| `lib/screens/public/home_screen.dart` | Added debounced scroll section detection, initial hero view, mobile drawer open/close, and drawer nav item tracking. |
| `lib/screens/public/sections/hero_section.dart` | Added `cta_click`, `contact_cta_click`, and `resume_view`/`resume_download` tracking. |
| `lib/screens/public/sections/projects_section.dart` | Converted to `StatefulWidget`, added `_viewedProjectIds` deduplication, `project_card_view`, `project_details_open`, `project_link_click` with standardized link types, and "View All Projects" `nav_click`. |
| `lib/screens/public/sections/all_projects_page.dart` | Converted to `StatefulWidget`, added search debouncing (`project_search`), category filter chips (`project_filter_apply`), `project_card_view` deduplication, `project_details_open`, and `project_link_click`. |
| `lib/widgets/comon/project_details_modal.dart` | Added `project_gallery_open`, `project_gallery_image_view`, `project_copy_link`, `project_share`, and `project_link_click`. |
| `lib/screens/public/sections/contact_section.dart` | Added direct contact clicks (`email_click`, `copy_email`, `phone_click`, `whatsapp_click`, `github_click`, `linkedin_click`, `resume_view`, `resume_download`, `external_link_click`), and complete form lifecycle tracking (`contact_form_start`, `contact_form_submit`, `contact_form_success`, `contact_form_failure`) with zero PII. |
| `test/services/analytics_service_test.dart` | Added unit tests for all Phase 2 events, parameters, link types, PII sanitization filters, and safe no-op degradation. |

---

## 8. Verification & Testing Results

1. **`flutter test`:**
   - Total Tests: **38**
   - Result: **38 passed, 0 failed**
   - Confirmed PII filters block forbidden keys and embedded emails.
   - Confirmed all tracking methods execute without throwing when Firebase is uninitialized.
2. **`flutter analyze`:**
   - Result: **No issues found! (0 warnings, 0 errors)**
3. **`flutter build web`:**
   - Clean compilation succeeded with zero errors.
4. **Hot Reload / DTD:**
   - Successfully hot-reloaded to the running Flutter web process without interruptions.

---

## 9. Bugs Found & Fixed During Phase 2

1. **Null Check Risk in `HomeScreen` Viewport Calculation:**
   - *Issue:* Calling `key.currentContext!` directly could throw if a section widget had not mounted or was disposed.
   - *Fix:* Added null-safe checks `final context = key.currentContext; if (context == null) continue;`.
2. **Missing Search & Filter Tracking in All Projects Page:**
   - *Issue:* `AllProjectsPage` was a simple `StatelessWidget` without search or filter UI, making it impossible to satisfy `project_filter_apply` and `project_search` tracking.
   - *Fix:* Converted to `StatefulWidget`, added modern search bar with 500ms debounce and responsive filter chips matching the portfolio design language, and integrated full tracking.
3. **Potential Re-impression Flooding on Rebuilds:**
   - *Issue:* Every time `ProjectsSection` rebuilds (e.g. on window resize or theme switch), project cards would re-fire `project_card_view`.
   - *Fix:* Added `Set<String> _viewedProjectIds` deduplication set ensuring each card is only logged once per session.
4. **Accidental PII Ingestion Risk:**
   - *Issue:* If future developers pass raw form data to `logEvent`, visitor contact details could leak to GA4.
   - *Fix:* Centralized regex and forbidden-key firewall in `AnalyticsService._sanitizeParameters` that drops sensitive parameters even if mistakenly provided.

---

## 10. Remaining Tasks (Phase 3+)

The following features were intentionally excluded from Phase 2 per user requirements:
- **Admin Analytics Dashboard:** Viewing analytics metrics inside the Admin panel (`AnalyticsScreen`).
- **GA4 Data API Integration:** Fetching aggregated visitor stats from Google Analytics 4 for dashboard display.
- **Advanced Funnel & Conversion Reports:** Real-time visitor breakdowns.

Phase 2 Public Website Analytics Tracking is **100% complete and fully verified**.
