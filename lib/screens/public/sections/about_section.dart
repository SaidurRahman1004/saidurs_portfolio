import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/config/constants.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 24,
          tablet: 64,
          desktop: 120,
        ),
        vertical: 80,
      ),
      child: Column(
        children: [
          SectionTitle(
            title: 'About Me',
            subtitle: 'Learn more about my journey and expertise',
          ),
          const SizedBox(height: 60),
          ResponsiveWrapper(mobile: _buildMobileLayout(context),desktop: _buildDesktopLayout(context),),
        ],
      ),
    );
  }

  //Desktop Layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //image Left
        Expanded(flex: 2, child: _buildAvatar(context)),
        const SizedBox(width: 60),
        //Description Right
        Expanded(flex: 3, child: _buildContent(context)),
      ],
    );
  }

  //Mobile LAyout
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildAvatar(context),
        const SizedBox(height: 40),
        _buildContent(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: 120,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  //About Content
  Widget _buildContent(BuildContext context) {
    final TxtTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.aboutMe,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
        ),
        const SizedBox(height: 32),
        // Quick Facts
        _buildFactItem(
          context,
          icon: Icons.school_outlined,
          title: 'Education',
          value: 'Diploma in CST - Dhaka Polytechnic Institute',
        ),
        const SizedBox(height: 16),
        _buildFactItem(
          context,
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: 'Bangladesh',
        ),
        const SizedBox(height: 16),

        _buildFactItem(
          context,
          icon: Icons.code_outlined,
          title: 'Focus',
          value: 'Flutter + Firebase + Django',
        ),
        const SizedBox(height: 16),

        _buildFactItem(
          context,
          icon: Icons.emoji_events_outlined,
          title: 'Goal',
          value: 'Full-Stack Mobile Developer',
        ),
      ],
    );
  }

  Widget _buildFactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient.scale(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.textHint),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
