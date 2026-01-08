import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:futter_portfileo_website/widgets/comon/custom_button.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

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
      constraints: const BoxConstraints(minHeight: 600),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 24,
          tablet: 64,
          desktop: 120,
        ),
        // Adjust the horizontal padding as needed using Responsive layout
        vertical: 80, // Adjust the vertical padding as needed
      ),
      child: ResponsiveWrapper(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  //_buildMobileLayout for mobile View

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      children: [
        _buildContent(context),
        const SizedBox(width: 40),
        _buildIllustration(),
      ],
    );
  }

  //_buildDesktopLayout for desktop View
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildContent(context)),
        const SizedBox(width: 80),
        Expanded(child: _buildIllustration()),
      ],
    );
  }

  //Widget For Main HEro Content and Button
  Widget _buildContent(BuildContext context) {
    final TxtTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hi, I\'m',
          style: TxtTheme.headlineMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            AppConstants.name,
            style: TxtTheme.displayLarge?.copyWith(
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
        Row(
          children: [
            Text('A', style: TxtTheme.headlineMedium),
            //Animated Textkit
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Flutter Developer',
                  textStyle: TxtTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Problem Solver',
                  textStyle: TxtTheme.headlineMedium?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'Django Developer',
                  textStyle: TxtTheme.headlineMedium?.copyWith(
                    color: AppTheme.secondaryColor,
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
          style: TxtTheme.bodyLarge,
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
              text: 'ViewProject',
              icon: Icons.work_outline,
            ),
            GradientButton(
              text:  'Contact Me',
              icon: Icons.email_outlined,
              isOutlined: true,
              onPressed: onContentClick,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient.scale(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Image.network(
          AppConstants.imgUrl,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),

    );
  }
}
