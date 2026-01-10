import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../models/contact_model.dart';
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

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
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.3),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: 'Get In Touch',
            subtitle: "Have a project in mind? Let's collaborate!",
          ),
          const SizedBox(height: 60),
          Consumer<PortfolioProvider>(
            builder: (context, provider, child) {
              //loading State
              if (provider.isLoadingContact) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              //Error State
              if (provider.errorContact != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.accentColor,
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
              //Null State
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
              ); //data loaded success
            },
          ),
        ],
      ),
    );
  }

  //Contact Dektop laout
  Widget _buildDesktopLayout(BuildContext context, ContactModel contact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildContactInfo(context, contact)),
        const SizedBox(width: 60),
        Expanded(child: _buildSocialLinks(context, contact)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ContactModel contact) {
    return Column(
      children: [
        _buildContactInfo(context, contact),
        const SizedBox(height: 40),
        _buildSocialLinks(context, contact),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, ContactModel contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),
        _buildContactItem(
          context,
          icon: Icons.email_outlined,
          title: 'Email',
          value: contact.email,
          onTap: () => _launchEmail(contact.email),
        ),
        const SizedBox(height: 20),

        _buildContactItem(
          context,
          icon: Icons.phone_outlined,
          title: 'WhatsApp',
          value: contact.whatsappNumber,
          onTap: () => _launchWhatsApp(contact.whatsappNumber),
        ),

        const SizedBox(height: 20),

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
          'Connect With Me',
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        const SizedBox(height: 32),
        _buildSocialButton(
          context,
          icon: Icons.code,
          label: 'GitHub',
          color: Colors.white,
          onTap: () => _launchURL(contact.githubUrl),
        ),

        const SizedBox(height: 16),

        _buildSocialButton(
          context,
          icon: Icons.work_outline,
          label: 'LinkedIn',
          color: const Color(0xFF0A66C2),
          onTap: contact.linkedinUrl != null
              ? () => _launchURL(contact.linkedinUrl!)
              : null,
        ),

        const SizedBox(height: 16),

        _buildSocialButton(
          context,
          icon: Icons.picture_as_pdf,
          label: 'Download Resume',
          color: AppTheme.accentColor,
          onTap: contact.resumeUrl != null
              ? () => _launchURL(contact.resumeUrl!)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resume not available yet')),
                  );
                },
        ),
      ],
    );
  }

  //Contact Contents
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient.scale(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
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
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textHint),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required onTap,
  }) {
    final isDisabled = onTap == null; //Disible State HAndling
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Row(
          children: [
            Text(label),
            if (isDisabled) ...[
              const SizedBox(width: 8),
              Text(
                '(Coming soon)',
                style: Theme.of(context).textTheme.bodySmall?. copyWith(
                  color:  AppTheme.textHint,
                ),
              ),
            ],
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  //Footer Sections
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppTheme.surfaceColor),
        const SizedBox(height: 24),

        Text(
          '© 2026 ${AppConstants.name}. All rights reserved. 💙',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textHint),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Made with ❤️ in Bangladesh',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
        ),
      ],
    );
  }

  //Lanch Url
  void _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.email,
      query: 'subject=Portfolio Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String phone) async {
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.phone.replaceAll('+', '')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
