import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/responsive_wrapper.dart';
import '../../config/theme.dart';

class CustomAppBar extends StatelessWidget {
  final GlobalKey herokey;
  final GlobalKey aboutkey;
  final GlobalKey skillskey;
  final GlobalKey projectskey;
  final GlobalKey contactkey;

  const CustomAppBar({
    super.key,
    required this.herokey,
    required this.aboutkey,
    required this.skillskey,
    required this.projectskey,
    required this.contactkey,
  });

  //scrollable
  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        color: AppTheme.darkBackground.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBackground.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          //Logo
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              '<SR/>',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          //NAVIGATION manue
          if (ResponsiveWrapper.isDesktop(context)) ...[
            Row(
              children: [
                //All Of NAbigation
                _NavButton(text: 'Home', onTap: ()=>_scrollToSection(herokey)),
                _NavButton(text: 'About', onTap: ()=>_scrollToSection(aboutkey)),
                _NavButton(text: 'Skills', onTap: ()=>_scrollToSection(skillskey)),
                _NavButton(text: 'Projects', onTap: ()=>_scrollToSection(projectskey)),
                _NavButton(text: 'Contact', onTap: ()=>_scrollToSection(contactkey)),
              ],
            ),
          ] else ...[
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
//_NavButton Used For show button For All Navigations..and shroll effect _scrollToSection
class _NavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NavButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
