import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:intl/intl.dart';

class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certifications',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCertifications) {
                  return const Center(child: CircularProgressIndicator());
                }

                final certs = provider.certifications;

                if (certs.isEmpty) {
                  return const Text('No certifications found.');
                }

                final isMobile = MediaQuery.of(context).size.width < 600;
                final isTablet = MediaQuery.of(context).size.width >= 600 &&
                    MediaQuery.of(context).size.width < 1000;
                int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 180,
                  ),
                  itemCount: certs.length,
                  itemBuilder: (context, index) {
                    final cert = certs[index];
                    final issueDateStr =
                        DateFormat('MMM yyyy').format(cert.issueDate);

                    return _CertificationCard(
                      name: cert.name,
                      organization: cert.issuingOrganization,
                      date: issueDateStr,
                      credentialUrl: cert.credentialUrl,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final String name;
  final String organization;
  final String date;
  final String? credentialUrl;

  const _CertificationCard({
    required this.name,
    required this.organization,
    required this.date,
    this.credentialUrl,
  });

  Future<void> _launchUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.secondary, size: 32),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  organization,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Issued $date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (credentialUrl != null && credentialUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _launchUrl(credentialUrl),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Show Credential'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

