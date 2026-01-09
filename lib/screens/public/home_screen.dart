import 'package:flutter/material.dart';
import '../../widgets/comon/custom_app_bar.dart';
import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/contact_section.dart';

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
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
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
}
