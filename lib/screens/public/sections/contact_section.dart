import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../models/contact_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/analytics/analytics_service.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(76),
      ),
      child: ResponsiveContainer(
        child: Column(
          children: [
            SectionTitle(
              title: 'Get In Touch',
              subtitle: "Have a project in mind or an opportunity? Let's talk!",
            ),
            const SizedBox(height: 60),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                // loading State
                if (provider.isLoadingContact) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // Error State
                if (provider.errorContact != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Failed to load contact information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorContact!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => provider.loadContactInfo(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Null State
                if (provider.contactInfo == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        'Contact information not available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                final contact = provider.contactInfo!;
                return Column(
                  children: [
                    ResponsiveWrapper(
                      mobile: _buildMobileLayout(context, contact),
                      desktop: _buildDesktopLayout(context, contact),
                    ),
                    const SizedBox(height: 60),
                    _buildFooter(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ContactModel contact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactInfo(context, contact),
              const SizedBox(height: 32),
              _buildSocialLinks(context, contact),
            ],
          ),
        ),
        const SizedBox(width: 48),
        const Expanded(
          flex: 6,
          child: _DirectMessageForm(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ContactModel contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContactInfo(context, contact),
        const SizedBox(height: 32),
        _buildSocialLinks(context, contact),
        const SizedBox(height: 48),
        const _DirectMessageForm(),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, ContactModel contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct Contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Feel free to connect directly via email or WhatsApp',
          style: TextStyle(
            color: AppTheme.getTextHint(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        _buildContactItem(
          context,
          icon: Icons.email_outlined,
          title: 'Email',
          value: contact.email,
          onTap: () => _launchEmail(contact.email),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Copy Email',
                icon: const Icon(Icons.copy_rounded, size: 16),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: contact.email));
                  AnalyticsService.instance.logCopyEmail(
                    source: 'contact_section',
                    ctaLocation: 'direct_contact_card',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email address copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          icon: Icons.phone_outlined,
          title: 'WhatsApp / Phone',
          value: contact.whatsappNumber,
          onTap: () => _launchWhatsApp(contact.whatsappNumber),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: contact.location,
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context, ContactModel contact) {
    final isDark = AppTheme.isDark(context);
    final theme = Theme.of(context);

    // Build the dynamic list of social & professional profile entries
    final entries = <_ProfileEntry>[];

    // 1. GitHub Profile
    if (contact.githubUrl.isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'GitHub',
          subtitle: 'Code & Open Source',
          url: contact.githubUrl,
          brandColor: isDark ? const Color(0xFF38434F) : const Color(0xFF181717),
          iconWidget: const FaIcon(
            FontAwesomeIcons.github,
            color: Colors.white,
            size: 19,
          ),
          badge: 'Dev',
          onTap: () {
            AnalyticsService.instance.logGithubClick(
              source: 'contact_section',
              ctaLocation: 'social_profiles',
            );
            _launchURL(contact.githubUrl);
          },
        ),
      );
    }

    // 2. LinkedIn Profile
    final linkedin = (contact.linkedinUrl != null && contact.linkedinUrl!.trim().isNotEmpty)
        ? contact.linkedinUrl!
        : 'https://www.linkedin.com/in/saidur1004/';
    entries.add(
      _ProfileEntry(
        title: 'LinkedIn',
        subtitle: 'Professional Network',
        url: linkedin,
        brandColor: const Color(0xFF0A66C2),
        iconWidget: const FaIcon(
          FontAwesomeIcons.linkedinIn,
          color: Colors.white,
          size: 19,
        ),
        badge: 'Connect',
        onTap: () {
          AnalyticsService.instance.logLinkedinClick(
            source: 'contact_section',
            ctaLocation: 'social_profiles',
          );
          _launchURL(linkedin);
        },
      ),
    );

    // 3. Facebook Profile (uses contact.facebookUrl if set, or default fallback unless explicitly cleared "")
    final fbUrl = contact.facebookUrl ?? 'https://facebook.com/SaidurRahman1004';
    if (fbUrl.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'Facebook',
          subtitle: 'Social & Community',
          url: fbUrl,
          brandColor: const Color(0xFF1877F2),
          iconWidget: const FaIcon(
            FontAwesomeIcons.facebookF,
            color: Colors.white,
            size: 19,
          ),
          badge: 'Follow',
          onTap: () {
            AnalyticsService.instance.logExternalLinkClick(
              destinationDomain: 'facebook.com',
              source: 'contact_section',
            );
            _launchURL(fbUrl);
          },
        ),
      );
    }

    // 4. Twitter / X Profile (if configured)
    if (contact.twitterUrl != null && contact.twitterUrl!.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'Twitter / X',
          subtitle: 'Tech & Updates',
          url: contact.twitterUrl!,
          brandColor: const Color(0xFF1DA1F2),
          iconWidget: const FaIcon(
            FontAwesomeIcons.twitter,
            color: Colors.white,
            size: 18,
          ),
          badge: 'Posts',
          onTap: () => _launchURL(contact.twitterUrl!),
        ),
      );
    }

    // 5. YouTube Channel (if configured)
    if (contact.youtubeUrl != null && contact.youtubeUrl!.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'YouTube',
          subtitle: 'Tech & App Demos',
          url: contact.youtubeUrl!,
          brandColor: const Color(0xFFFF0000),
          iconWidget: const FaIcon(
            FontAwesomeIcons.youtube,
            color: Colors.white,
            size: 18,
          ),
          badge: 'Videos',
          onTap: () => _launchURL(contact.youtubeUrl!),
        ),
      );
    }

    // 6. Instagram (if configured)
    if (contact.instagramUrl != null && contact.instagramUrl!.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'Instagram',
          subtitle: 'Personal & Stories',
          url: contact.instagramUrl!,
          brandColor: const Color(0xFFE4405F),
          iconWidget: const FaIcon(
            FontAwesomeIcons.instagram,
            color: Colors.white,
            size: 19,
          ),
          badge: 'Life',
          onTap: () => _launchURL(contact.instagramUrl!),
        ),
      );
    }

    // 7. LeetCode / Coding (if configured)
    if (contact.leetcodeUrl != null && contact.leetcodeUrl!.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'LeetCode',
          subtitle: 'Problem Solving & DSA',
          url: contact.leetcodeUrl!,
          brandColor: const Color(0xFFFFA116),
          iconWidget: const Icon(
            Icons.terminal_rounded,
            color: Colors.white,
            size: 20,
          ),
          badge: 'DSA',
          onTap: () => _launchURL(contact.leetcodeUrl!),
        ),
      );
    }

    // 8. Medium (if configured)
    if (contact.mediumUrl != null && contact.mediumUrl!.trim().isNotEmpty) {
      entries.add(
        _ProfileEntry(
          title: 'Medium',
          subtitle: 'Articles & Write-ups',
          url: contact.mediumUrl!,
          brandColor: const Color(0xFF00AB6C),
          iconWidget: const Icon(
            Icons.article_rounded,
            color: Colors.white,
            size: 20,
          ),
          badge: 'Blog',
          onTap: () => _launchURL(contact.mediumUrl!),
        ),
      );
    }

    // 9. View / Download CV (Core CTA)
    final resumeUrl = contact.resumeUrl ?? AppConstants.resumeUrl;
    entries.add(
      _ProfileEntry(
        title: 'View / Download CV',
        subtitle: 'Curriculum Vitae & PDF',
        url: resumeUrl,
        brandColor: theme.colorScheme.primary,
        iconWidget: const Icon(
          Icons.description_rounded,
          color: Colors.white,
          size: 20,
        ),
        badge: 'PDF',
        onTap: () {
          if (resumeUrl.isNotEmpty) {
            AnalyticsService.instance.logResumeView(
              source: 'contact',
              ctaLocation: 'social_profiles',
              fileType: 'pdf',
            );
            AnalyticsService.instance.logResumeDownload(
              source: 'contact',
              ctaLocation: 'social_profiles',
              fileType: 'pdf',
            );
            _launchURL(resumeUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume not available yet')),
            );
          }
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.hub_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Professional Profiles',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Connect across developer platforms and professional networks',
          style: TextStyle(
            color: AppTheme.getTextHint(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTwoCol = width >= 440;
            final cardWidth = isTwoCol ? (width - 12) / 2 : width;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: entries
                  .map(
                    (entry) => SizedBox(
                      width: cardWidth,
                      child: _SocialProfileCard(entry: entry),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryGradient(context).scale(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getTextHint(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }



  Widget _buildFooter(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Column(
      children: [
        Divider(color: AppTheme.getBorderColor(context), thickness: 1),
        const SizedBox(height: 32),
        Text(
          '© $currentYear Saidur Rahman. All rights reserved.',
          style: TextStyle(
            color: AppTheme.getTextSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Crafted with ',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getTextHint(context),
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.getPrimaryGradient(context).createShader(bounds),
              child: const Icon(Icons.favorite, size: 16, color: Colors.white),
            ),
            Text(
              ' using Flutter & Firebase',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getTextHint(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dhaka, Bangladesh',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.getTextHint(context),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _launchEmail(String email) async {
    AnalyticsService.instance.logEmailClick(
      source: 'contact_section',
      ctaLocation: 'direct_contact',
    );
    final uri = Uri(
      scheme: 'mailto',
      path: email.isNotEmpty ? email : AppConstants.email,
      query: 'subject=Portfolio Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String phone) async {
    AnalyticsService.instance.logWhatsappClick(
      source: 'contact_section',
      ctaLocation: 'direct_contact',
    );
    AnalyticsService.instance.logPhoneClick(
      source: 'contact_section',
      ctaLocation: 'direct_contact',
    );
    final rawNumber = (phone.isNotEmpty ? phone : AppConstants.phone)
        .replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$rawNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (uri.host.isNotEmpty) {
        AnalyticsService.instance.logExternalLinkClick(
          destinationDomain: uri.host,
          source: 'contact_section',
        );
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

class _ProfileEntry {
  final String title;
  final String subtitle;
  final String url;
  final Color brandColor;
  final Widget iconWidget;
  final String? badge;
  final VoidCallback onTap;

  _ProfileEntry({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.brandColor,
    required this.iconWidget,
    this.badge,
    required this.onTap,
  });
}

class _SocialProfileCard extends StatefulWidget {
  final _ProfileEntry entry;

  const _SocialProfileCard({required this.entry});

  @override
  State<_SocialProfileCard> createState() => _SocialProfileCardState();
}

class _SocialProfileCardState extends State<_SocialProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final brandColor = widget.entry.brandColor;

    final borderColor = _isHovered
        ? brandColor.withOpacity(0.55)
        : AppTheme.getBorderColor(context);

    final cardBg = _isHovered
        ? (isDark
            ? brandColor.withOpacity(0.14)
            : brandColor.withOpacity(0.06))
        : (isDark
            ? const Color(0xFF1E2640)
            : Colors.white);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: brandColor.withOpacity(isDark ? 0.28 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.entry.onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: brandColor.withOpacity(0.14),
            highlightColor: brandColor.withOpacity(0.07),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // High-contrast branded icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: brandColor,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: widget.entry.iconWidget,
                  ),
                  const SizedBox(width: 12),
                  // Title, subtitle and badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.entry.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.getTextPrimary(context),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.entry.badge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: brandColor.withOpacity(0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  widget.entry.badge!,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: brandColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.entry.subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.getTextHint(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action indicator icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? brandColor.withOpacity(0.18)
                          : (isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04)),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 15,
                      color: _isHovered
                          ? brandColor
                          : AppTheme.getTextHint(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive Direct Message Form
class _DirectMessageForm extends StatefulWidget {
  const _DirectMessageForm();

  @override
  State<_DirectMessageForm> createState() => _DirectMessageFormState();
}

class _DirectMessageFormState extends State<_DirectMessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedType = 'Job Opportunity';
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _formStarted = false;

  final List<String> _projectTypes = [
    'Job Opportunity',
    'Mobile App Development',
    'Full-Stack Project',
    'Consultation / Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldTouched);
    _emailController.addListener(_onFieldTouched);
    _subjectController.addListener(_onFieldTouched);
    _messageController.addListener(_onFieldTouched);
  }

  void _onFieldTouched() {
    if (!_formStarted) {
      _formStarted = true;
      AnalyticsService.instance.logContactFormStart(sourceSection: 'contact_section');
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldTouched);
    _emailController.removeListener(_onFieldTouched);
    _subjectController.removeListener(_onFieldTouched);
    _messageController.removeListener(_onFieldTouched);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AnalyticsService.instance.logContactFormFailure(
        projectType: _selectedType,
        errorType: 'validation_error',
      );
      return;
    }

    AnalyticsService.instance.logContactFormSubmit(
      projectType: _selectedType,
      hasPhone: _phoneController.text.trim().isNotEmpty,
    );

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<PortfolioProvider>();
    final success = await provider.submitInquiry(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      projectType: _selectedType,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      AnalyticsService.instance.logContactFormSuccess(
        projectType: _selectedType,
      );
      _formStarted = false;
      setState(() {
        _isSuccess = true;
      });
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
    } else {
      AnalyticsService.instance.logContactFormFailure(
        projectType: _selectedType,
        errorType: 'submission_error',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try WhatsApp or email.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final primary = AppTheme.getPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(60) : Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _isSuccess ? _buildSuccessView(context) : _buildFormView(context, primary, borderColor),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 38,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Message Received!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Thank you for reaching out. I have received your message and will get back to you shortly.',
          style: TextStyle(
            color: AppTheme.getTextSecondary(context),
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _isSuccess = false;
            });
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Send Another Message'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(BuildContext context, Color primary, Color borderColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(context).scale(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.send_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Send a Direct Message',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recruiters & clients: Leave a note and I will get back to you within 24 hours.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.getTextHint(context),
            ),
          ),
          const SizedBox(height: 24),

          // Project/Inquiry Type Dropdown
          Text(
            'Inquiry Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: _inputDecoration('Select Type', borderColor),
            items: _projectTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedType = val);
              }
            },
          ),
          const SizedBox(height: 16),

          // Name and Email
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return Row(
                  children: [
                    Expanded(child: _buildNameField(borderColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildEmailField(borderColor)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildNameField(borderColor),
                  const SizedBox(height: 16),
                  _buildEmailField(borderColor),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Subject Field
          TextFormField(
            controller: _subjectController,
            decoration: _inputDecoration('Subject / Opportunity Title', borderColor),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Subject is required';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Message Field
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: _inputDecoration('Your message or project scope...', borderColor),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Message cannot be empty';
              if (val.trim().length < 10) return 'Please write at least 10 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Send Message',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(Color borderColor) {
    return TextFormField(
      controller: _nameController,
      decoration: _inputDecoration('Your Name', borderColor),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Name is required';
        return null;
      },
    );
  }

  Widget _buildEmailField(Color borderColor) {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Email Address', borderColor),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(val.trim())) return 'Enter a valid email';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hint, Color borderColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: AppTheme.getTextHint(context)),
      filled: true,
      fillColor: AppTheme.isDark(context)
          ? const Color(0xFF0F172A).withAlpha(120)
          : const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.getPrimaryColor(context),
          width: 1.5,
        ),
      ),
    );
  }
}
