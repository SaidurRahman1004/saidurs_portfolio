import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/analytics/analytics_service.dart';
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
        drawer: _buildModernDrawer(context, isDark, gradient),
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

  Widget _buildModernDrawer(BuildContext context, bool isDark, Gradient gradient) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, _) {
          final contact = portfolioProvider.contactInfo;
          final primary = Theme.of(context).colorScheme.primary;
          final cardBg = AppTheme.getCardBackground(context);
          final borderColor = AppTheme.getBorderColor(context);

          return Column(
            children: [
              // Rich Interactive Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withAlpha(isDark ? 55 : 35),
                      Theme.of(context).colorScheme.secondary.withAlpha(isDark ? 35 : 20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with glowing ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: gradient,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withAlpha(80),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            child: ClipOval(
                              child: (contact?.profileImageUrl != null && contact!.profileImageUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: contact.profileImageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/icons/app_icon.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/icons/app_icon.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        '<SR/>',
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Tech branding tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(isDark ? 40 : 25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primary.withAlpha(isDark ? 80 : 120)),
                          ),
                          child: Text(
                            '<SR/>',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      contact?.fullName.isNotEmpty == true ? contact!.fullName : AppConstants.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Role
                    Text(
                      contact?.title.isNotEmpty == true ? contact!.title : AppConstants.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Live Status Pill
                    if (contact?.isOpenToWork ?? true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withAlpha(isDark ? 90 : 120),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF10B981),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              contact?.openToWorkText.isNotEmpty == true
                                  ? contact!.openToWorkText
                                  : 'Available for Opportunities',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Nav Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  children: [
                    _buildModernNavItem(
                      context,
                      icon: Icons.home_rounded,
                      title: 'Home',
                      onTap: () => _scrollToSection(heroKey, sectionId: 'hero', sectionName: 'Home'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.person_rounded,
                      title: 'About',
                      onTap: () => _scrollToSection(aboutKey, sectionId: 'about', sectionName: 'About'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.work_rounded,
                      title: 'Experience',
                      onTap: () => _scrollToSection(experienceKey, sectionId: 'experience', sectionName: 'Experience'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.code_rounded,
                      title: 'Skills',
                      onTap: () => _scrollToSection(skillsKey, sectionId: 'skills', sectionName: 'Skills'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.layers_rounded,
                      title: 'Projects',
                      onTap: () => _scrollToSection(projectsKey, sectionId: 'projects', sectionName: 'Projects'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Education',
                      onTap: () => _scrollToSection(educationKey, sectionId: 'education', sectionName: 'Education'),
                    ),
                    _buildModernNavItem(
                      context,
                      icon: Icons.mail_rounded,
                      title: 'Contact',
                      onTap: () => _scrollToSection(contactKey, sectionId: 'contact', sectionName: 'Contact'),
                    ),
                  ],
                ),
              ),

              // Bottom Section: Theme Switcher + Socials + Footer
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Theme Switcher Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.amber : primary).withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: isDark ? Colors.amber : primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isDark ? 'Light Mode' : 'Dark Mode',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (val) {
                              context.read<ThemeProvider>().toggleTheme();
                              AnalyticsService.instance.logThemeToggle(isDark: val);
                            },
                            activeColor: primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Social Quick Links Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDrawerSocialIcon(
                          icon: FontAwesomeIcons.github,
                          tooltip: 'GitHub',
                          color: isDark ? Colors.white : const Color(0xFF181717),
                          onTap: () => _launchDrawerUrl(contact?.githubUrl ?? AppConstants.github),
                        ),
                        if (contact?.linkedinUrl != null && contact!.linkedinUrl!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          _buildDrawerSocialIcon(
                            icon: FontAwesomeIcons.linkedinIn,
                            tooltip: 'LinkedIn',
                            color: const Color(0xFF0A66C2),
                            onTap: () => _launchDrawerUrl(contact.linkedinUrl!),
                          ),
                        ],
                        if (contact?.facebookUrl != null && contact!.facebookUrl!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          _buildDrawerSocialIcon(
                            icon: FontAwesomeIcons.facebookF,
                            tooltip: 'Facebook',
                            color: const Color(0xFF1877F2),
                            onTap: () => _launchDrawerUrl(contact.facebookUrl!),
                          ),
                        ],
                        if (contact?.email.isNotEmpty == true) ...[
                          const SizedBox(width: 10),
                          _buildDrawerSocialIcon(
                            icon: Icons.mail_outline_rounded,
                            tooltip: 'Email',
                            color: primary,
                            onTap: () => _launchDrawerUrl('mailto:${contact!.email}'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Copyright caption
                    Text(
                      '© ${DateTime.now().year} Saidur Rahman • Flutter Dev',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.getTextHint(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = AppTheme.isDark(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor: primary.withAlpha(isDark ? 30 : 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(isDark ? 30 : 15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.getTextHint(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerSocialIcon({
    required dynamic icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: icon is IconData ? Icon(icon, size: 16, color: color) : FaIcon(icon, size: 15, color: color),
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(25),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Future<void> _launchDrawerUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}