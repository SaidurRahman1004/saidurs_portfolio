import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/analytics/analytics_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey herokey;
  final GlobalKey aboutkey;
  final GlobalKey experiencekey;
  final GlobalKey skillskey;
  final GlobalKey projectskey;
  final GlobalKey educationkey;
  final GlobalKey contactkey;

  const CustomAppBar({
    super.key,
    required this.herokey,
    required this.aboutkey,
    required this.experiencekey,
    required this.skillskey,
    required this.projectskey,
    required this.educationkey,
    required this.contactkey,
  });

  void _scrollToSection(GlobalKey key, String sectionName) {
    AnalyticsService.instance.logNavClick(
      itemTitle: sectionName,
      destination: sectionName.toLowerCase(),
      source: 'desktop_navbar',
    );
    AnalyticsService.instance.logSectionView(
      sectionId: sectionName.toLowerCase(),
      sectionName: sectionName,
      source: 'nav_click',
    );

    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 16,
          tablet: 32,
          desktop: 64,
        ),
      ),
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor.withAlpha(242)
            : Colors.white.withAlpha(245),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.getBorderColor(context).withAlpha(isDark ? 50 : 160),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Theme.of(context).shadowColor.withAlpha(127)
                : const Color(0xFF0F172A).withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => (isDark
                        ? AppTheme.primaryGradient
                        : AppTheme.lightPrimaryGradient)
                    .createShader(bounds),
                child: Text(
                  '<SR/>',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (ResponsiveWrapper.isDesktop(context)) ...[
                Row(
                  children: [
                    _NavButton(
                      text: 'Home',
                      onTap: () => _scrollToSection(herokey, 'Home'),
                    ),
                    _NavButton(
                      text: 'About',
                      onTap: () => _scrollToSection(aboutkey, 'About'),
                    ),
                    _NavButton(
                      text: 'Experience',
                      onTap: () => _scrollToSection(experiencekey, 'Experience'),
                    ),
                    _NavButton(
                      text: 'Skills',
                      onTap: () => _scrollToSection(skillskey, 'Skills'),
                    ),
                    _NavButton(
                      text: 'Projects',
                      onTap: () => _scrollToSection(projectskey, 'Projects'),
                    ),
                    _NavButton(
                      text: 'Education',
                      onTap: () => _scrollToSection(educationkey, 'Education'),
                    ),
                    _NavButton(
                      text: 'Contact',
                      onTap: () => _scrollToSection(contactkey, 'Contact'),
                    ),
                  ],
                ),
              ] else ...[
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
                      AnalyticsService.instance.logMobileMenu(
                        isOpen: true,
                        source: 'app_bar_hamburger',
                      );
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu,
                        color: Theme.of(context).colorScheme.primary),
                    tooltip: 'Menu',
                  ),
                ),
              ],
              const SizedBox(width: 16),
              // Theme Switcher
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Theme.of(context).cardColor : Colors.white,
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                  boxShadow: AppTheme.getCardShadow(context),
                ),
                child: IconButton(
                  onPressed: () {
                    final nextDark = !isDark;
                    context.read<ThemeProvider>().toggleTheme();
                    AnalyticsService.instance.logThemeToggle(isDark: nextDark);
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(isDark),
                      color: isDark ? Colors.amber : const Color(0xFF4F46E5),
                    ),
                  ),
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _NavButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _NavButton({required this.text, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _isHovered
                ? primary.withAlpha(isDark ? 28 : 18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: widget.onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              foregroundColor: _isHovered
                  ? primary
                  : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

