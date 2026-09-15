import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  void _scrollToSection(GlobalKey key) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final gradient = isDark ? AppTheme.primaryGradient : AppTheme.lightPrimaryGradient;

    return Scaffold(
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Junior Flutter Developer',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () => _scrollToSection(heroKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_outline,
              title: 'About',
              onTap: () => _scrollToSection(aboutKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.work_history_outlined,
              title: 'Experience',
              onTap: () => _scrollToSection(experienceKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Skills',
              onTap: () => _scrollToSection(skillsKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.work_outline,
              title: 'Projects',
              onTap: () => _scrollToSection(projectsKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.school_outlined,
              title: 'Education',
              onTap: () => _scrollToSection(educationKey),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.contact_mail_outlined,
              title: 'Contact',
              onTap: () => _scrollToSection(contactKey),
            ),
            Divider(color: Theme.of(context).cardColor),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© ${DateTime.now().year} Saidur Rahman',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              key: heroKey,
              child: HeroSection(
                onProjectClick: () => _scrollToSection(projectsKey),
                onContentClick: () => _scrollToSection(contactKey),
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
          ]
              .animate(interval: 200.ms)
              .fade(duration: 800.ms)
              .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
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