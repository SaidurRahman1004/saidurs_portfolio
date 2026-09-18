import '../models/certification_model.dart';
import '../models/contact_model.dart';
import '../models/education_model.dart';
import '../models/professional_experience_model.dart';
import '../models/project_model.dart';
import '../models/skill_model.dart';

class PortfolioSeedData {
  // Contact Info
  static ContactModel get contactInfo => ContactModel(
        id: 'primary_contact',
        email: 'saidurrahman1004@gmail.com',
        phone: '+880 1795 664122',
        whatsappNumber: '+880 1795 664122',
        location: 'Dhaka, Bangladesh',
        githubUrl: 'https://github.com/SaidurRahman1004',
        linkedinUrl: 'https://www.linkedin.com/in/saidur1004/',
        resumeUrl:
            'https://drive.google.com/file/d/1944Q6bXgFM46TTJZP7z4lfXqpokdBWV6/view?usp=sharing',
        profileImageUrl:
            'https://i.postimg.cc/d3yXKM4r/profile-pic-(4).png',
        heroImageUrl: 'https://i.postimg.cc/TYRmdvH5/hiropic.png',
        updatedAt: DateTime.now(),
      );

  // Projects
  static List<ProjectModel> get projects => [
        ProjectModel(
          id: 'ezydash',
          title: 'EzyDash — Student Marketplace',
          slug: 'ezydash-student-marketplace',
          shortDescription:
              'Production student marketplace and community mobile application live on Google Play Store and Apple App Store.',
          fullDescription:
              'Developed and maintained a production mobile application published on Google Play Store and Apple App Store. Built student-focused marketplace services with 6+ categories (Accommodation, Events, Services, Jobs, Marketplace, Giveaways), real-time user messaging using Socket.IO, integrated Airtel Money & MTN Mobile Money payments, QR-based ticketing, promo codes, and location-based discovery with Google Maps.',
          role: 'Junior Flutter Developer',
          category: 'Mobile Development',
          featured: true,
          status: 'Production',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.ezydash&hl=en',
          appStoreUrl:
              'https://apps.apple.com/in/app/ezydash-student-marketplace/id6749002165',
          imageUrl:
              'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=800',
          technologies: [
            'Flutter',
            'Dart',
            'Firebase',
            'REST APIs',
            'Socket.IO',
            'Google Maps',
            'Airtel Money',
            'MTN Money',
          ],
          keyFeatures: [
            'Published on Google Play Store & Apple App Store',
            '6+ marketplace categories (Accommodation, Events, Services, Jobs, Marketplace, Giveaways)',
            'Real-time user-to-user messaging with Socket.IO',
            'Integrated Airtel Money & MTN Mobile Money payments',
            'QR-based ticketing & promo code system',
            'Google Maps integration & location-based search & pagination',
            'Firebase Authentication, FCM, Analytics & Crashlytics',
          ],
          sortOrder: 1,
          isVisible: true,
          createdAt: DateTime(2026, 3, 1),
        ),
        ProjectModel(
          id: 'chugchain',
          title: 'ChugChain — Social Video Sharing Platform',
          slug: 'chugchain-video-platform',
          shortDescription:
              'TikTok-style cross-platform social video sharing platform with high-performance video streaming and in-app monetization.',
          fullDescription:
              'A TikTok-style social video sharing application featuring interactive video feeds, controlled video preloading, auto-looping playback, lazy loading, and visibility-based performance optimizations. Implemented camera capture, video compression, multipart video uploads, thumbnail generation, in-app purchases, subscription management, and Google Mobile Ads.',
          role: 'Mobile App Developer',
          category: 'Mobile Development',
          featured: true,
          status: 'In Development',
          imageUrl:
              'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?q=80&w=800',
          technologies: [
            'Flutter',
            'Dart',
            'GetX',
            'REST APIs',
            'Video Streaming',
            'Firebase',
            'Google Mobile Ads',
            'In-App Purchases',
          ],
          keyFeatures: [
            'Interactive video feed with preloading, auto-looping & lazy loading',
            'Custom camera capture, video compression & multipart upload',
            'Friend discovery, profile feeds, likes & content reporting',
            'In-app purchases & recurring subscription management',
            'Google Mobile Ads & ad-free premium tiers',
            'Firebase Push Notifications, Analytics & Crashlytics',
          ],
          sortOrder: 2,
          isVisible: true,
          createdAt: DateTime(2026, 2, 1),
        ),
        ProjectModel(
          id: 'pocketvault',
          title: 'PocketVault — Full-Stack Productivity App',
          slug: 'pocketvault-productivity',
          shortDescription:
              'Full-stack productivity application with Flutter frontend and Django REST Framework backend.',
          fullDescription:
              'Built a multi-feature productivity application with Flutter and a custom Django REST Framework backend. Designed structured full-stack architecture with JWT authentication, user-specific data isolation, offline-first SQLite local storage, synchronized workflows, Clean Architecture, and Provider state management.',
          role: 'Full-Stack Developer',
          category: 'Full-Stack Mobile',
          featured: false,
          status: 'Completed',
          githubUrl: 'https://github.com/SaidurRahman1004/pocketvault',
          imageUrl:
              'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?q=80&w=800',
          technologies: [
            'Flutter',
            'Django',
            'Django REST Framework',
            'JWT Auth',
            'SQLite',
            'Provider',
            'Clean Architecture',
          ],
          keyFeatures: [
            'Custom Django REST Framework backend with JWT authentication',
            'Offline-first local caching using SQLite & sqflite',
            'Synchronized data workflows between client and server',
            'Clean Architecture with Repository Pattern and Provider',
          ],
          sortOrder: 3,
          isVisible: true,
          createdAt: DateTime(2025, 11, 1),
        ),
        ProjectModel(
          id: 'travelsnap',
          title: 'TravelSnap — Social Travel Platform',
          slug: 'travelsnap-social-travel',
          shortDescription:
              'Social travel platform for sharing GPS-tagged trips with Google Maps and Firebase.',
          fullDescription:
              'Social travel platform built with Flutter and Firebase. Features public and private GPS-tagged trips, community engagement feeds, Cloud Firestore with offline caching, Google Maps integration, Geolocator with automatic reverse geocoding address resolution, ImgBB REST API image uploads, and GoRouter declarative navigation.',
          role: 'Flutter Developer',
          category: 'Mobile Development',
          featured: false,
          status: 'Completed',
          githubUrl: 'https://github.com/SaidurRahman1004/my_trips',
          imageUrl:
              'https://images.unsplash.com/photo-1488646953014-85cb44e25828?q=80&w=800',
          technologies: [
            'Flutter',
            'Firebase',
            'Google Maps',
            'Geolocator',
            'GoRouter',
            'ImgBB API',
          ],
          keyFeatures: [
            'Public and private GPS-tagged travel logs and interactive map feed',
            'Cloud Firestore real-time database with offline persistence',
            'Automatic address resolution via Geolocator & reverse geocoding',
            'Declarative navigation using GoRouter',
            'Firebase Authentication and Cloud Messaging push notifications',
          ],
          sortOrder: 4,
          isVisible: true,
          createdAt: DateTime(2025, 9, 1),
        ),
      ];

  // Professional Experience
  static List<ProfessionalExperienceModel> get experiences => [
        ProfessionalExperienceModel(
          id: 'sm_technology_exp',
          title: 'Junior Executive, Mobile App',
          company: 'SM Technology — A Betopia Group Company',
          companyUrl: 'https://smtech24.com/',
          parentCompany: 'Betopia Group',
          parentCompanyUrl: 'https://betopiagroup.com/',
          location: 'Dhaka, Bangladesh',
          employmentType: 'Full-time • On-site',
          startDate: DateTime(2026, 3, 1),
          endDate: null,
          isCurrentRole: true,
          description:
              'Developing and maintaining production mobile applications using Flutter and Dart. Following structured, scalable coding practices, working with REST APIs, Firebase, and backend services. Handling Google Play Store and Apple App Store publishing, in-app purchases, release management, and cross-functional team coordination.',
          responsibilities: [
            'Developing and maintaining production mobile applications using Flutter and Dart.',
            'Following structured, scalable, and maintainable coding practices.',
            'Working with REST APIs, Firebase, and backend services.',
            'Integrating application features and managing data-driven workflows.',
            'Handling Google Play Store and Apple App Store publishing.',
            'Preparing application releases and managing versioning.',
            'Managing mobile application deployment processes.',
            'Working with in-app purchasing workflows and application integration requirements.',
            'Gaining practical experience with cloud-based production environments.',
            'Participating in release lifecycle management.',
            'Collaborating within a professional development team.',
            'Coordinating tasks and feature planning with cross-functional teams.',
            'Participating in client communication and requirement gathering.',
            'Tracking progress and coordinating project delivery.',
          ],
          skills: [
            'Flutter',
            'Dart',
            'REST APIs',
            'Firebase',
            'Google Play Publishing',
            'Apple App Store Publishing',
            'In-App Purchases',
            'State Management',
            'Release Management',
          ],
          promotions: const [
            ExperiencePromotionModel(
              title: 'Junior Executive, Mobile App',
              period: 'March 2026 — Present',
              type: 'Promoted Role • Current',
              note:
                  'Promoted to Junior Executive handling production application lifecycles, Google Play Store and Apple App Store publishing, in-app purchase workflows, release management, and cross-functional team coordination.',
            ),
            ExperiencePromotionModel(
              title: 'Junior Flutter Developer',
              period: 'October 2025 — February 2026',
              type: 'Initial Position',
              note:
                  'Contributed to core Flutter architecture, REST API integrations, Firebase services, bug fixes, UI/UX polish, and maintaining clean code standards across active production projects.',
            ),
          ],
          order: 1,
          isVisible: true,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];

  // Education
  static List<EducationModel> get education => [
        EducationModel(
          id: 'dpi_edu',
          degree: 'Diploma in Computer Engineering',
          field: 'Computer Science & Technology',
          institution: 'Dhaka Polytechnic Institute',
          institutionUrl: 'https://dhaka.polytech.gov.bd/',
          location: 'Dhaka, Bangladesh',
          startDate: DateTime(2022, 1, 1),
          endDate: DateTime(2026, 6, 30),
          isCurrent: true,
          description:
              'Studying core computer science disciplines including Software Engineering, Mobile Application Development, Data Structures, Algorithms, Object-Oriented Programming, and Database Systems.',
          order: 1,
          isVisible: true,
          createdAt: DateTime(2022, 1, 1),
        ),
        EducationModel(
          id: 'aasac_edu',
          degree: 'Secondary School Certificate (SSC)',
          field: 'Science',
          institution: 'Ali Ahmed School and College',
          institutionUrl: 'http://aasac.edu.bd/',
          location: 'Dhaka, Bangladesh',
          startDate: DateTime(2019, 1, 1),
          endDate: DateTime(2021, 12, 31),
          isCurrent: false,
          description:
              'Completed Secondary School Certificate in Science group with strong academic foundation in Mathematics, Physics, and Chemistry.',
          order: 2,
          isVisible: true,
          createdAt: DateTime(2021, 12, 31),
        ),
      ];

  static List<EducationModel> get educations => education;

  // Certifications
  static List<CertificationModel> get certifications => [
        CertificationModel(
          id: 'ostad_flutter_cert',
          name: 'Flutter and Dart App Development',
          issuingOrganization: 'Ostad',
          issueDate: DateTime(2023, 11, 1),
          credentialUrl:
              'https://ostad.app/share/certificate/c43942-md-saidur-rahman-bhuyan',
          order: 1,
          isVisible: true,
          createdAt: DateTime(2023, 11, 1),
        ),
        CertificationModel(
          id: 'bohubrihi_web_cert',
          name: 'Web Development',
          issuingOrganization: 'Bohubrihi',
          issueDate: DateTime(2023, 5, 1),
          credentialUrl:
              'https://www.linkedin.com/in/saidur1004/overlay/Certifications/132641588/treasury/?profileId=ACoAAFvw44EBd0KjHnbL5Xfk4zXY-laSdkRnl2E',
          order: 2,
          isVisible: true,
          createdAt: DateTime(2023, 5, 1),
        ),
      ];

  // Technical Skills
  static List<SkillModel> get skills => [
        // Mobile Development
        SkillModel(id: 's_flutter', name: 'Flutter', category: 'Mobile Development', iconCode: 58240, order: 1, isVisible: true),
        SkillModel(id: 's_dart', name: 'Dart', category: 'Mobile Development', iconCode: 57704, order: 2, isVisible: true),
        SkillModel(id: 's_responsive_ui', name: 'Responsive UI', category: 'Mobile Development', iconCode: 57777, order: 3, isVisible: true),
        SkillModel(id: 's_rest_api', name: 'REST API Integration', category: 'Mobile Development', iconCode: 58835, order: 4, isVisible: true),
        SkillModel(id: 's_animations', name: 'Animations', category: 'Mobile Development', iconCode: 59568, order: 5, isVisible: true),

        // State Management
        SkillModel(id: 's_provider', name: 'Provider', category: 'State Management', iconCode: 59576, order: 6, isVisible: true),
        SkillModel(id: 's_riverpod', name: 'Riverpod', category: 'State Management', iconCode: 59576, order: 7, isVisible: true),
        SkillModel(id: 's_getx', name: 'GetX', category: 'State Management', iconCode: 59576, order: 8, isVisible: true),

        // Backend & APIs
        SkillModel(id: 's_django', name: 'Django', category: 'Backend & APIs', iconCode: 58062, order: 9, isVisible: true),
        SkillModel(id: 's_drf', name: 'Django REST Framework', category: 'Backend & APIs', iconCode: 58835, order: 10, isVisible: true),
        SkillModel(id: 's_jwt', name: 'JWT Authentication', category: 'Backend & APIs', iconCode: 59591, order: 11, isVisible: true),
        SkillModel(id: 's_websocket', name: 'WebSocket / Socket.IO', category: 'Backend & APIs', iconCode: 59616, order: 12, isVisible: true),

        // Firebase & Cloud
        SkillModel(id: 's_fb_auth', name: 'Firebase Authentication', category: 'Firebase & Cloud', iconCode: 58045, order: 13, isVisible: true),
        SkillModel(id: 's_firestore', name: 'Cloud Firestore', category: 'Firebase & Cloud', iconCode: 58829, order: 14, isVisible: true),
        SkillModel(id: 's_fcm', name: 'FCM Push Notifications', category: 'Firebase & Cloud', iconCode: 58045, order: 15, isVisible: true),
        SkillModel(id: 's_crashlytics', name: 'Firebase Crashlytics', category: 'Firebase & Cloud', iconCode: 58045, order: 16, isVisible: true),

        // Databases & Storage
        SkillModel(id: 's_sqlite', name: 'SQLite / sqflite', category: 'Databases & Storage', iconCode: 58829, order: 17, isVisible: true),
        SkillModel(id: 's_hive', name: 'Hive Storage', category: 'Databases & Storage', iconCode: 58062, order: 18, isVisible: true),
        SkillModel(id: 's_shared_prefs', name: 'SharedPreferences', category: 'Databases & Storage', iconCode: 58062, order: 19, isVisible: true),

        // Architecture & Design
        SkillModel(id: 's_clean_arch', name: 'Clean Architecture', category: 'Architecture & Design', iconCode: 59591, order: 20, isVisible: true),
        SkillModel(id: 's_mvvm', name: 'MVVM Pattern', category: 'Architecture & Design', iconCode: 59591, order: 21, isVisible: true),
        SkillModel(id: 's_repo_pattern', name: 'Repository Pattern', category: 'Architecture & Design', iconCode: 59591, order: 22, isVisible: true),

        // Deployment & Monetization
        SkillModel(id: 's_play_store', name: 'Google Play Publishing', category: 'Deployment & Monetization', iconCode: 60120, order: 23, isVisible: true),
        SkillModel(id: 's_app_store', name: 'Apple App Store Publishing', category: 'Deployment & Monetization', iconCode: 60120, order: 24, isVisible: true),
        SkillModel(id: 's_iap', name: 'In-App Purchases', category: 'Deployment & Monetization', iconCode: 59448, order: 25, isVisible: true),
        SkillModel(id: 's_admob', name: 'Google Mobile Ads (AdMob)', category: 'Deployment & Monetization', iconCode: 59568, order: 26, isVisible: true),

        // Programming Languages
        SkillModel(id: 's_lang_dart', name: 'Dart', category: 'Programming Languages', iconCode: 57704, order: 27, isVisible: true),
        SkillModel(id: 's_lang_python', name: 'Python', category: 'Programming Languages', iconCode: 57704, order: 28, isVisible: true),
        SkillModel(id: 's_lang_js', name: 'JavaScript', category: 'Programming Languages', iconCode: 57704, order: 29, isVisible: true),
        SkillModel(id: 's_lang_kotlin', name: 'Kotlin', category: 'Programming Languages', iconCode: 58240, order: 30, isVisible: true),

        // Tools & AI
        SkillModel(id: 's_tool_git', name: 'Git & GitHub', category: 'Tools & AI', iconCode: 60399, order: 31, isVisible: true),
        SkillModel(id: 's_tool_postman', name: 'Postman', category: 'Tools & AI', iconCode: 58835, order: 32, isVisible: true),
        SkillModel(id: 's_tool_gemini', name: 'Google Gemini API', category: 'Tools & AI', iconCode: 59568, order: 33, isVisible: true),
        SkillModel(id: 's_tool_ai', name: 'AI-Assisted Development', category: 'Tools & AI', iconCode: 59568, order: 34, isVisible: true),
      ];
}
