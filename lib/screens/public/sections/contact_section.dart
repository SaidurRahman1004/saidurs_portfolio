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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Profiles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        _buildSocialButton(
          context,
          icon: const FaIcon(
            FontAwesomeIcons.github,
            color: Colors.white,
            size: 18,
          ),
          label: 'GitHub Profile',
          color: const Color(0xFF181717),
          onTap: () {
            AnalyticsService.instance.logGithubClick(
              source: 'contact_section',
              ctaLocation: 'social_profiles',
            );
            _launchURL(contact.githubUrl);
          },
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          context,
          icon: const FaIcon(
            FontAwesomeIcons.linkedin,
            color: Color(0xFF0A66C2),
            size: 18,
          ),
          label: 'LinkedIn Profile',
          color: const Color(0xFF0A66C2),
          onTap: contact.linkedinUrl != null && contact.linkedinUrl!.isNotEmpty
              ? () {
                  AnalyticsService.instance.logLinkedinClick(
                    source: 'contact_section',
                    ctaLocation: 'social_profiles',
                  );
                  _launchURL(contact.linkedinUrl!);
                }
              : null,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          context,
          icon: const Icon(Icons.description_outlined, size: 20),
          label: 'View / Download CV',
          color: Theme.of(context).colorScheme.primary,
          onTap: contact.resumeUrl != null && contact.resumeUrl!.isNotEmpty
              ? () {
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
                  _launchURL(contact.resumeUrl!);
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resume not available yet')),
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

  Widget _buildSocialButton(
    BuildContext context, {
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    final isDark = AppTheme.isDark(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDisabled
                ? AppTheme.getTextHint(context)
                : AppTheme.getTextPrimary(context),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          side: BorderSide(
            color: AppTheme.getBorderColor(context),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
