import 'package:flutter/material.dart';
import '../../widgets/comon/custom_app_bar.dart';
import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/contact_section.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey skillsKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        herokey: heroKey,
        aboutkey: aboutKey,
        skillskey: skillsKey,
        projectskey: projectsKey,
        contactkey: contactKey,
      ),
      //Drawer for mobile
      drawer: Drawer(
        backgroundColor: AppTheme.darkBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient.scale(0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
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
                    'Flutter Developer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
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
              icon: Icons.contact_mail_outlined,
              title: 'Contact',
              onTap: () => _scrollToSection(contactKey),
            ),

            const Divider(color: AppTheme.surfaceColor),

            // Footer in drawer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© ${DateTime.now().year} Saidur Rahman',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              key: heroKey,
              child: HeroSection(
                onProjectClick: () {
                  return _scrollToSection(projectsKey);
                },
                onContentClick: () {
                  return _scrollToSection(contactKey);
                },
              ),
            ),
            // About Section
            Container(key: aboutKey, child: const AboutSection()),
            // Skills Section
            Container(key: skillsKey, child: const SkillsSection()),
            // Projects Section
            Container(key: projectsKey, child: const ProjectsSection()),

            // Contact Section
            Container(key: contactKey, child: const ContactSection()),
          ],
        ),
      ),
    );
  }

  //Drawer Item Builder
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
      hoverColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }
}
