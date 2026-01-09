import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

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
          ResponsiveWrapper(
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),

          const SizedBox(height: 60),

          _buildFooter(context),
        ],
      ),
    );
  }


//Contact Dektop laout
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildContactInfo(context)),
        const SizedBox(width: 60),
        Expanded(child: _buildSocialLinks(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildContactInfo(context),
        const SizedBox(height: 40),
        _buildSocialLinks(context),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge,
          ),
          const SizedBox(height: 32),
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            value: AppConstants.email,
            onTap: () => _launchEmail(),
          ),
          const SizedBox(height: 20),

          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            title: 'WhatsApp',
            value: AppConstants.phone,
            onTap: () => _launchWhatsApp(),
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            context,
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: 'Bangladesh',
            onTap: null,
          ),


        ]
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect With Me',
          style: Theme
              .of(context)
              .textTheme
              .headlineMedium,
        ),

        const SizedBox(height: 32),
        _buildSocialButton(
          context,
          icon: Icons.code,
          label: 'GitHub',
          color: Colors.white,
          onTap: () => _launchURL(AppConstants.github),
        ),

        const SizedBox(height: 16),

        _buildSocialButton(
          context,
          icon: Icons.work_outline,
          label: 'LinkedIn',
          color: const Color(0xFF0A66C2),
          onTap: () {
            // Add LinkedIn when available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('LinkedIn coming soon!')),
            );
          },
        ),

        const SizedBox(height: 16),

         _buildSocialButton(
          context,
          icon: Icons.picture_as_pdf,
          label: 'Download Resume',
          color: AppTheme.accentColor,
          onTap: () => _launchURL(AppConstants.resumeUrl),
        ),

      ],
    );
  }

  //Contact Contents
  Widget _buildContactItem(BuildContext context, {
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
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
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
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ]
            ),),
            if(onTap != null)
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

  Widget _buildSocialButton(BuildContext context,
      {required IconData icon,
        required String label, required Color color, required onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label),
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
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: AppTheme.textHint,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Made with ❤️ in Bangladesh',
          style: Theme
              .of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }

  //Lanch Url
  void _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.email,
      query: 'subject=Portfolio Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/${AppConstants.phone.replaceAll('+', '')}');
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
