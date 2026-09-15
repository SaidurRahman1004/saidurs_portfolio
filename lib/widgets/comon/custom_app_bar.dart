import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

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

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
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
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(242),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(isDark ? 127 : 20),
            blurRadius: 10,
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
                      onTap: () => _scrollToSection(herokey),
                    ),
                    _NavButton(
                      text: 'About',
                      onTap: () => _scrollToSection(aboutkey),
                    ),
                    _NavButton(
                      text: 'Experience',
                      onTap: () => _scrollToSection(experiencekey),
                    ),
                    _NavButton(
                      text: 'Skills',
                      onTap: () => _scrollToSection(skillskey),
                    ),
                    _NavButton(
                      text: 'Projects',
                      onTap: () => _scrollToSection(projectskey),
                    ),
                    _NavButton(
                      text: 'Education',
                      onTap: () => _scrollToSection(educationkey),
                    ),
                    _NavButton(
                      text: 'Contact',
                      onTap: () => _scrollToSection(contactkey),
                    ),
                  ],
                ),
              ] else ...[
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
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
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withAlpha(isDark ? 50 : 20),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: IconButton(
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(isDark),
                      color: isDark ? Colors.amber : Colors.blueGrey,
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

class _NavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NavButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

