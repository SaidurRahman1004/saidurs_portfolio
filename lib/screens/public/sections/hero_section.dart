import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:futter_portfileo_website/widgets/comon/custom_button.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/analytics/analytics_service.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onProjectClick;
  final VoidCallback onContentClick;

  const HeroSection({
    super.key,
    required this.onProjectClick,
    required this.onContentClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 600),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: ResponsiveWrapper(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  //_buildMobileLayout for mobile View
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildIllustration(context),
        const SizedBox(height: 40),
        _buildContent(context),
      ],
    );
  }

  //_buildDesktopLayout for desktop View
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildContent(context)),
        const SizedBox(width: 80),
        Expanded(child: _buildIllustration(context)),
      ],
    );
  }

  //Widget For Main Hero Content and Button
  Widget _buildContent(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveWrapper.isMobile(context);
    final provider = context.watch<PortfolioProvider>();
    final contact = provider.contactInfo;

    final displayName = contact?.fullName.isNotEmpty == true
        ? contact!.fullName
        : AppConstants.name;
    final roles = (contact != null && contact.animatedRoles.isNotEmpty)
        ? contact.animatedRoles
        : [
            'Junior Executive, Mobile App',
            'Junior Flutter Developer',
            'Production Mobile Engineer',
          ];
    final description = contact?.heroDescription.isNotEmpty == true
        ? contact!.heroDescription
        : AppConstants.heroDescription;
    final isOpenToWork = contact?.isOpenToWork ?? true;
    final openToWorkText = contact?.openToWorkText.isNotEmpty == true
        ? contact!.openToWorkText
        : 'Available for Opportunities';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isOpenToWork)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withAlpha(120)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF22C55E),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  openToWorkText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF22C55E),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Hi, I\'m',
          style: txtTheme.headlineMedium?.copyWith(
            color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
            fontSize: isMobile ? 22 : 28,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.getPrimaryGradient(context).createShader(bounds),
            child: Text(
              displayName,
              style: txtTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: Responsive.value(
                  context: context,
                  mobile: 34,
                  tablet: 46,
                  desktop: 54,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'A ',
              style: txtTheme.headlineMedium?.copyWith(
                fontSize: isMobile ? 18 : 24,
              ),
            ),
            AnimatedTextKit(
              key: ValueKey(roles.join('|')),
              repeatForever: true,
              animatedTexts: roles.asMap().entries.map((entry) {
                final isOdd = entry.key % 2 == 1;
                return TypewriterAnimatedText(
                  entry.value,
                  textStyle: txtTheme.headlineMedium?.copyWith(
                    color: isOdd
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 24,
                  ),
                  speed: const Duration(milliseconds: 100),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: txtTheme.bodyLarge?.copyWith(
            fontSize: isMobile ? 14 : 16,
            height: 1.5,
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 36),
        //Buttons
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            GradientButton(
              onPressed: () {
                AnalyticsService.instance.logCtaClick(
                  itemTitle: 'View Project',
                  destination: 'projects',
                  source: 'hero_section',
                );
                onProjectClick();
              },
              text: 'View Project',
              icon: Icons.work_outline,
            ),
            GradientButton(
              text: 'Contact Me',
              icon: Icons.email_outlined,
              isOutlined: true,
              onPressed: () {
                AnalyticsService.instance.logContactCtaClick(
                  source: 'hero',
                  ctaLocation: 'hero_section',
                );
                onContentClick();
              },
            ),
            //Resume Button
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                final resumeUrl = provider.contactInfo?.resumeUrl;

                return GradientButton(
                  text: 'View Resume',
                  icon: Icons.description_outlined,
                  isOutlined: true,
                  onPressed: resumeUrl != null && resumeUrl.isNotEmpty
                      ? () {
                          AnalyticsService.instance.logResumeView(
                            source: 'hero',
                            ctaLocation: 'hero_section',
                            fileType: 'pdf',
                          );
                          AnalyticsService.instance.logResumeDownload(
                            source: 'hero',
                            ctaLocation: 'hero_section',
                            fileType: 'pdf',
                          );
                          _launchURL(resumeUrl);
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Resume not available yet'),
                            ),
                          );
                        },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Dynamic Hero Image from Firebase
  Widget _buildIllustration(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final firebaseUrl = provider.contactInfo?.heroImageUrl;
        final String finalImageUrl =
            (firebaseUrl != null && firebaseUrl.isNotEmpty)
                ? firebaseUrl
                : AppConstants.imgUrl2;

        final bool isMobile = ResponsiveWrapper.isMobile(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final double cardW = isMobile
                ? (maxW * 0.94).clamp(240.0, 360.0)
                : 500.0;
            final double cardH = isMobile
                ? (cardW * 0.85).clamp(220.0, 300.0)
                : 380.0;
            final double glowW = cardW + (isMobile ? 16 : 30);
            final double glowH = cardH + (isMobile ? 16 : 40);

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing
                  Container(
                    height: glowH,
                    width: glowW,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withAlpha(25),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Background
                  Container(
                    height: cardH,
                    width: cardW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Colors.white.withAlpha(7),
                  border: Border.all(
                    color: Colors.white.withAlpha(12),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withAlpha(25),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CachedNetworkImage(
                            imageUrl: finalImageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildFallbackImage(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            size: 60,
            color: Theme.of(context).colorScheme.primary.withAlpha(76),
          ),
          const SizedBox(height: 10),
          Text(
            "Ready to Launch",
            style: TextStyle(
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey).withAlpha(127),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Launch URL helper
  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
