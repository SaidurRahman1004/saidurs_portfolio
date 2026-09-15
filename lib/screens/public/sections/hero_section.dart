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
        const SizedBox(width: 40),
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

  //Widget For Main HEro Content and Button
  Widget _buildContent(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hi, I\'m',
          style: txtTheme.headlineMedium?.copyWith(
            color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.getPrimaryGradient(context).createShader(bounds),
          child: Text(
            AppConstants.name,
            style: txtTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: Responsive.value(
                context: context,
                mobile: 36,
                tablet: 48,
                desktop: 56,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('A', style: txtTheme.headlineMedium),
            const SizedBox(width: 8),
            //Animated Textkit
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Flutter Developer',
                  textStyle: txtTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Problem Solver',
                  textStyle: txtTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Django Developer',
                  textStyle: txtTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
            ),
          ],
        ),
        //Description
        Text(
          AppConstants.heroDescription,
          style: txtTheme.bodyLarge,
          maxLines: 4,
        ),
        const SizedBox(height: 40),
        //Butons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            GradientButton(
              onPressed: onProjectClick,
              text: 'View Project',
              icon: Icons.work_outline,
            ),
            GradientButton(
              text: 'Contact Me',
              icon: Icons.email_outlined,
              isOutlined: true,
              onPressed: onContentClick,
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
                      ? () => _launchURL(resumeUrl)
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

  //  Dynamic Hero Image from Firebase

  Widget _buildIllustration(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final firebaseUrl = provider.contactInfo?.heroImageUrl;
        final String finalImageUrl =
            (firebaseUrl != null && firebaseUrl.isNotEmpty)
            ? firebaseUrl
            : AppConstants.imgUrl2;

        final bool isMobile = ResponsiveWrapper.isMobile(context);

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //glowing
              Container(
                height: isMobile ? 300 : 420,
                width: isMobile ? 320 : 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    width: 2,
                  ),
                  // Effect
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
                height: isMobile ? 280 : 380,
                width: isMobile ? 300 : 520,
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

  //  Launch URL helper
  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}




