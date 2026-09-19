import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/comon/custom_app_bar.dart';
import 'sections/hero_section.dart';
import 'sections/highlights_section.dart';
import 'sections/about_section.dart';
import 'sections/experience_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/education_section.dart';
import 'sections/certifications_section.dart';
import 'sections/contact_section.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/analytics/analytics_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey experienceKey = GlobalKey();
  final GlobalKey skillsKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey educationKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounceTimer;
  String? _lastActiveSection;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastActiveSection = 'hero';
      AnalyticsService.instance.logSectionView(
        sectionId: 'hero',
        sectionName: 'Home',
        source: 'initial_load',
      );
    });
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 400), _checkActiveSection);
  }

  void _checkActiveSection() {
    if (!mounted) return;

    final sections = [
      (id: 'hero', name: 'Home', key: heroKey),
      (id: 'about', name: 'About', key: aboutKey),
      (id: 'experience', name: 'Experience', key: experienceKey),
      (id: 'skills', name: 'Skills', key: skillsKey),
      (id: 'projects', name: 'Projects', key: projectsKey),
      (id: 'education', name: 'Education', key: educationKey),
      (id: 'contact', name: 'Contact', key: contactKey),
    ];

    String? currentVisibleSection;
    String? currentVisibleName;

    for (final section in sections) {
      final ctx = section.key.currentContext;
      if (ctx != null) {
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final position = renderBox.localToGlobal(Offset.zero);
          // When top of section is near the upper third of screen
          if (position.dy <= 280 && position.dy + renderBox.size.height > 100) {
            currentVisibleSection = section.id;
            currentVisibleName = section.name;
          }
        }
      }
    }

    if (currentVisibleSection != null && currentVisibleSection != _lastActiveSection) {
      _lastActiveSection = currentVisibleSection;
      AnalyticsService.instance.logSectionView(
        sectionId: currentVisibleSection,
        sectionName: currentVisibleName,
        source: 'scroll',
      );
    }
  }

  void _scrollToSection(GlobalKey key, {String? sectionId, String? sectionName}) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    }

    if (sectionId != null) {
      _lastActiveSection = sectionId;
      AnalyticsService.instance.logNavClick(
        itemTitle: sectionName ?? sectionId,
        destination: sectionId,
        source: 'navigation',
      );
      AnalyticsService.instance.logSectionView(
        sectionId: sectionId,
        sectionName: sectionName,
        source: 'nav_click',
      );
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final gradient = isDark ? AppTheme.primaryGradient : AppTheme.lightPrimaryGradient;

    return SelectionArea(
      child: Scaffold(
        onDrawerChanged: (isOpen) {
          AnalyticsService.instance.logMobileMenu(isOpen: isOpen, source: 'home_drawer');
        },
        appBar: CustomAppBar(
          herokey: heroKey,
          aboutkey: aboutKey,
          experiencekey: experienceKey,
          skillskey: skillsKey,
          projectskey: projectsKey,
          educationkey: educationKey,
          contactkey: contactKey,
        ),
        drawer: Drawer(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: gradient.scale(0.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => gradient.createShader(bounds),
                      child: Text(
                        '<SR/>',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Flutter Developer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.home,
                title: 'Home',
                onTap: () => _scrollToSection(heroKey, sectionId: 'hero', sectionName: 'Home'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.person,
                title: 'About',
                onTap: () => _scrollToSection(aboutKey, sectionId: 'about', sectionName: 'About'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.work,
                title: 'Experience',
                onTap: () => _scrollToSection(experienceKey, sectionId: 'experience', sectionName: 'Experience'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.code,
                title: 'Skills',
                onTap: () => _scrollToSection(skillsKey, sectionId: 'skills', sectionName: 'Skills'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.layers,
                title: 'Projects',
                onTap: () => _scrollToSection(projectsKey, sectionId: 'projects', sectionName: 'Projects'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.school,
                title: 'Education',
                onTap: () => _scrollToSection(educationKey, sectionId: 'education', sectionName: 'Education'),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.mail,
                title: 'Contact',
                onTap: () => _scrollToSection(contactKey, sectionId: 'contact', sectionName: 'Contact'),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  isDark ? 'Light Mode' : 'Dark Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  final nextDark = !isDark;
                  context.read<ThemeProvider>().toggleTheme();
                  AnalyticsService.instance.logThemeToggle(isDark: nextDark);
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                key: heroKey,
                child: HeroSection(
                  onProjectClick: () => _scrollToSection(projectsKey, sectionId: 'projects', sectionName: 'Projects'),
                  onContentClick: () => _scrollToSection(contactKey, sectionId: 'contact', sectionName: 'Contact'),
                ),
              ),
              const HighlightsSection(),
              Container(key: aboutKey, child: const AboutSection()),
              Container(key: experienceKey, child: const ExperienceSection()),
              Container(key: skillsKey, child: const SkillsSection()),
              Container(key: projectsKey, child: const ProjectsSection()),
              Container(key: educationKey, child: const EducationSection()),
              const CertificationsSection(),
              Container(key: contactKey, child: const ContactSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
      hoverColor: Theme.of(context).colorScheme.primary.withAlpha(25),
    );
  }
}