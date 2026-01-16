import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/config/constants.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';

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
          ResponsiveWrapper(
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
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
//Avatar Image
  Widget _buildAvatar(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final profileImageUrl = provider.contactInfo?.profileImageUrl;
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Container(
          constraints: BoxConstraints(
            maxHeight: isMobile ? 300 : 400,
            maxWidth: isMobile ? 300 : 400,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient.scale(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              Center(
                child: Container(
                  width: isMobile ? 280 : 380,
                  height: isMobile ? 280 : 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
                            fit:
                                BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackAvatar();
                            },
                          )
                        : _buildFallbackAvatar(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // fallback Avatar
  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: 100,
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
