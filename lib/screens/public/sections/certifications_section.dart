import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/certification_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Certifications', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              'Credentials and learning milestones that support my work.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCertifications) {
                  return const Center(child: CircularProgressIndicator());
                }
                final certifications = provider.certifications;
                if (certifications.isEmpty) {
                  return _EmptyCertifications();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 620
                        ? 1
                        : constraints.maxWidth < 1020
                            ? 2
                            : 3;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: columns == 1 ? 330 : 300,
                      ),
                      itemCount: certifications.length,
                      itemBuilder: (context, index) => _CertificationCard(
                        certification: certifications[index],
                      ),
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

class _EmptyCertifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_outlined, size: 42, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Certifications will appear here.', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final CertificationModel certification;

  const _CertificationCard({required this.certification});

  bool get _hasImage => certification.imageUrl?.trim().isNotEmpty == true;
  bool get _hasCredential => certification.credentialUrl?.trim().isNotEmpty == true;

  Future<void> _openCredential(BuildContext context) async {
    final rawUrl = certification.credentialUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) return;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credential link is unavailable')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showCertificate(BuildContext context) {
    if (!_hasImage) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(certification.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(certification.issuingOrganization),
                trailing: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close),
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: certification.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) => const _CertificateUnavailable(),
                  ),
                ),
              ),
              if (_hasCredential)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: FilledButton.icon(
                    onPressed: () => _openCredential(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open official credential'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('MMM yyyy').format(certification.issueDate);
    final primary = theme.colorScheme.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: InkWell(
          onTap: _hasImage ? () => _showCertificate(context) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 122,
                width: double.infinity,
                child: _hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'certificate-${certification.id}',
                            child: CachedNetworkImage(
                              imageUrl: certification.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (_, _, _) => const _CertificateUnavailable(compact: true),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.62), borderRadius: BorderRadius.circular(20)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.zoom_in, size: 16, color: Colors.white), SizedBox(width: 5), Text('View certificate', style: TextStyle(color: Colors.white, fontSize: 12))]),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: primary.withValues(alpha: 0.08),
                        child: Center(child: Icon(Icons.workspace_premium_rounded, size: 48, color: primary)),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(certification.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                          Text(date, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(certification.issuingOrganization, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (_hasCredential)
                        TextButton.icon(
                          onPressed: () => _openCredential(context),
                          icon: const Icon(Icons.verified_outlined, size: 17),
                          label: const Text('Verify credential'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                        )
                      else if (_hasImage)
                        TextButton.icon(
                          onPressed: () => _showCertificate(context),
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          label: const Text('View certificate'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                        )
                      else
                        Text('Certificate details available', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificateUnavailable extends StatelessWidget {
  final bool compact;

  const _CertificateUnavailable({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: compact ? 32 : 48),
          if (!compact) ...[
            const SizedBox(height: 8),
            const Text('Certificate image unavailable'),
          ],
        ],
      ),
    );
  }
}
