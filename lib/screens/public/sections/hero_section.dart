import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        // 1. Open to work badge — first to appear
        if (isOpenToWork)
          Builder(
            builder: (context) {
              final isDark = AppTheme.isDark(context);
              final emeraldColor = isDark ? const Color(0xFF22C55E) : const Color(0xFF047857);
              final emeraldBg = isDark ? const Color(0xFF22C55E).withAlpha(25) : const Color(0xFF059669).withAlpha(20);
              final emeraldBorder = isDark ? const Color(0xFF22C55E).withAlpha(120) : const Color(0xFF059669).withAlpha(80);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: emeraldBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: emeraldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: emeraldColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: emeraldColor.withAlpha(isDark ? 255 : 180),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    )
                    // Pulse animation on the green dot
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      duration: 900.ms,
                      curve: Curves.easeInOut,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      openToWorkText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: emeraldColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 600.ms)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutBack);
            },
          ),

        // 2. "Hi, I'm" label
        Text(
          'Hi, I\'m',
          style: txtTheme.headlineMedium?.copyWith(
            color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
            fontSize: isMobile ? 22 : 28,
          ),
        )
        .animate(delay: 150.ms)
        .fade(duration: 500.ms)
        .slideX(begin: -0.05, end: 0, duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 8),

        // 3. Name with gradient
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
        )
        .animate(delay: 250.ms)
        .fade(duration: 700.ms)
        .slideX(begin: -0.06, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),

        const SizedBox(height: 16),

        // 4. Role typewriter
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
        )
        .animate(delay: 400.ms)
        .fade(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // 5. Description text
        Text(
          description,
          style: txtTheme.bodyLarge?.copyWith(
            fontSize: isMobile ? 14 : 16,
            height: 1.5,
          ),
          maxLines: 5,
        )
        .animate(delay: 550.ms)
        .fade(duration: 600.ms)
        .slideY(begin: 0.08, end: 0, duration: 600.ms, curve: Curves.easeOut),

        const SizedBox(height: 36),

        // 6. Buttons — staggered
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
            )
            .animate(delay: 700.ms)
            .fade(duration: 500.ms)
            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutBack),

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
            )
            .animate(delay: 800.ms)
            .fade(duration: 500.ms)
            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutBack),

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
            )
            .animate(delay: 900.ms)
            .fade(duration: 500.ms)
            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
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

            final isDark = AppTheme.isDark(context);
            final primary = Theme.of(context).colorScheme.primary;

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing ring — pulses gently
                  Container(
                    height: glowH,
                    width: glowW,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: primary.withAlpha(isDark ? 25 : 40),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withAlpha(isDark ? 20 : 18),
                          blurRadius: 50,
                          spreadRadius: isDark ? 10 : 6,
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.02, 1.02),
                    duration: 3000.ms,
                    curve: Curves.easeInOut,
                  ),

                  // Card — entrance animation + continuous float
                  _FloatingCard(
                    child: Container(
                      height: cardH,
                      width: cardW,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: isDark ? Colors.white.withAlpha(7) : Colors.white,
                        border: Border.all(
                          color: isDark ? Colors.white.withAlpha(15) : AppTheme.getBorderColor(context),
                          width: 1.2,
                        ),
                        boxShadow: AppTheme.getCardShadow(context),
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
                                  color: primary.withAlpha(isDark ? 25 : 12),
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
                    )
                    .animate(delay: 300.ms)
                    .fade(duration: 800.ms)
                    .slideX(
                      begin: 0.08,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutCubic,
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

/// A widget that perpetually floats its child up and down.
class _FloatingCard extends StatefulWidget {
  final Widget child;
  const _FloatingCard({required this.child});

  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -8 * _anim.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
