import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/project_model.dart';

class ProjectDetailsModal extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsModal({super.key, required this.project});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _hasUrl(String? value) => value != null && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    return Dialog(
      backgroundColor: AppTheme.darkBackground,
      insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 32,
                  0,
                  isMobile ? 20 : 32,
                  isMobile ? 20 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(context),
                    if (_hasText(project.shortDescription)) ...[
                      const SizedBox(height: 24),
                      _section(context, 'Overview', project.shortDescription),
                    ],
                    if (_hasText(project.fullDescription)) ...[
                      const SizedBox(height: 24),
                      _section(context, 'Full Description', project.fullDescription),
                    ],
                    if (_hasText(project.role)) ...[
                      const SizedBox(height: 24),
                      _infoBlock(context, 'My Role', project.role!),
                    ],
                    if (_hasText(project.challenges)) ...[
                      const SizedBox(height: 24),
                      _infoBlock(context, 'Challenges & Technical Highlights', project.challenges!),
                    ],
                    if (project.technologies.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildTechnologies(context),
                    ],
                    if (project.keyFeatures.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildBulletSection(context, 'Key Features', project.keyFeatures),
                    ],
                    if (project.screenshots.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildGallery(context),
                    ],
                    if (_hasAnyAction) ...[
                      const SizedBox(height: 28),
                      _buildActions(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasAnyAction =>
      _hasUrl(project.githubUrl) ||
      _hasUrl(project.liveUrl) ||
      _hasUrl(project.playStoreUrl) ||
      _hasUrl(project.appStoreUrl);

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_hasText(project.category)) _badge(project.category!),
                    if (_hasText(project.status)) _badge(project.status!),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _badge(String value) => Chip(
        label: Text(value),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppTheme.surfaceColor,
        labelStyle: const TextStyle(color: AppTheme.primaryColor),
        side: BorderSide.none,
      );

  Widget _buildHeroImage(BuildContext context) {
    if (!_hasUrl(project.imageUrl)) {
      return _imagePlaceholder(height: 220, label: 'No project image available');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        project.imageUrl!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : _imagePlaceholder(height: 220, label: 'Loading project image...'),
        errorBuilder: (_, _, _) =>
            _imagePlaceholder(height: 220, label: 'Project image unavailable'),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) =>
      _infoBlock(context, title, body);

  Widget _infoBlock(BuildContext context, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildTechnologies(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Technologies', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.technologies.map(_badge).toList(),
        ),
      ],
    );
  }

  Widget _buildBulletSection(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...items.where((item) => item.trim().isNotEmpty).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(Icons.circle, size: 6, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge)),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildGallery(BuildContext context) {
    final images = project.screenshots.where((url) => url.trim().isNotEmpty).toList();
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Screenshots', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 600 ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.6 : 1.45,
              ),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : _imagePlaceholder(label: 'Loading screenshot...'),
                  errorBuilder: (_, _, _) =>
                      _imagePlaceholder(label: 'Screenshot unavailable'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _imagePlaceholder({double height = 160, required String label}) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppTheme.surfaceColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 40, color: AppTheme.textHint),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textHint)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (_hasUrl(project.githubUrl))
          _action(context, 'GitHub', Icons.code, project.githubUrl!),
        if (_hasUrl(project.liveUrl))
          _action(context, 'Live Demo', Icons.open_in_browser, project.liveUrl!),
        if (_hasUrl(project.playStoreUrl))
          _action(context, 'Google Play', Icons.shop, project.playStoreUrl!),
        if (_hasUrl(project.appStoreUrl))
          _action(context, 'App Store', Icons.apple, project.appStoreUrl!),
      ],
    );
  }

  Widget _action(BuildContext context, String label, IconData icon, String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
