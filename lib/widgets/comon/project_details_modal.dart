import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/project_model.dart';
import '../../services/analytics/analytics_constants.dart';
import '../../services/analytics/analytics_service.dart';

class ProjectDetailsModal extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsModal({super.key, required this.project});

  @override
  State<ProjectDetailsModal> createState() => _ProjectDetailsModalState();
}

class _ProjectDetailsModalState extends State<ProjectDetailsModal> {
  int _activeScreenshotIndex = 0;

  String get _slug =>
      widget.project.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _hasUrl(String? value) => value != null && value.trim().isNotEmpty;
  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  bool get _hasAnyAction =>
      _hasUrl(widget.project.githubUrl) ||
      _hasUrl(widget.project.liveUrl) ||
      _hasUrl(widget.project.playStoreUrl) ||
      _hasUrl(widget.project.appStoreUrl) ||
      _hasUrl(widget.project.otherUrl);

  @override
  void initState() {
    super.initState();
    final screenshots = widget.project.screenshots
        .where((url) => url.trim().isNotEmpty)
        .toList();
    if (screenshots.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AnalyticsService.instance.logProjectGalleryOpen(
          projectId: widget.project.id,
          projectSlug: _slug,
          imageCount: screenshots.length,
          sourceSection: 'details_modal',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final isDesktop = width >= 820;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.getPrimaryColor(context);

    final dialogBg = isDark ? const Color(0xFF0F1426) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263150) : const Color(0xFFCBD5E1);

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 12,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1040,
          maxHeight: size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isDark, primary),
            const Divider(height: 1, thickness: 1),
            Flexible(
              child: isDesktop
                  ? _buildDesktopSplitLayout(context, isDark, primary)
                  : _buildMobileStackedLayout(context, isDark, primary),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with Title, Badges, and Action Icons
  Widget _buildHeader(BuildContext context, bool isDark, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category / Type icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withAlpha(isDark ? 50 : 35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProjectTypeIcon(widget.project.displayProjectType),
              color: primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (widget.project.displayProjectType.isNotEmpty)
                      _badge(
                        widget.project.displayProjectType,
                        color: primary,
                        isDark: isDark,
                      ),
                    if (_hasText(widget.project.category))
                      _badge(
                        widget.project.category!,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                        isDark: isDark,
                      ),
                    if (_hasText(widget.project.status))
                      _badge(
                        widget.project.status!,
                        color: Colors.greenAccent,
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy Project Link',
            icon: const Icon(Icons.link, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'https://saidurs.me/#project-${widget.project.id}',
              ));
              AnalyticsService.instance.logProjectCopyLink(
                projectId: widget.project.id,
                projectSlug: _slug,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Project',
            icon: const Icon(Icons.share_outlined, size: 19),
            onPressed: () {
              AnalyticsService.instance.logProjectShare(
                projectId: widget.project.id,
                projectSlug: _slug,
                method: 'clipboard_share',
              );
              Clipboard.setData(ClipboardData(
                text: 'Check out ${widget.project.title}: https://saidurs.me/#project-${widget.project.id}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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

  /// Desktop Split View: Left Media & Actions, Right Details
  Widget _buildDesktopSplitLayout(BuildContext context, bool isDark, Color primary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT COLUMN (Media, Screenshots & Quick Actions)
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13192F) : const Color(0xFFF8FAFC),
              border: Border(
                right: BorderSide(
                  color: isDark ? const Color(0xFF263150) : const Color(0xFFCBD5E1),
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(context, isDark, height: 260),
                  if (widget.project.screenshots.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildGalleryThumbnails(context, isDark, primary),
                  ],
                  if (_hasAnyAction) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Explore & Launch',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActions(context, isDark, primary, isDesktop: true),
                  ],
                ],
              ),
            ),
          ),
        ),

        // RIGHT COLUMN (Scrollable Details)
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasText(widget.project.shortDescription)) ...[
                  _buildOverviewCard(context, isDark, primary),
                  const SizedBox(height: 24),
                ],
                if (_hasText(widget.project.fullDescription) &&
                    widget.project.fullDescription != widget.project.shortDescription) ...[
                  _section(context, isDark, 'Full Overview & Architecture', widget.project.fullDescription),
                  const SizedBox(height: 24),
                ],
                if (_hasText(widget.project.role)) ...[
                  _infoBlock(context, isDark, 'My Contribution & Role', widget.project.role!),
                  const SizedBox(height: 24),
                ],
                if (_hasText(widget.project.challenges)) ...[
                  _infoBlock(context, isDark, 'Technical Challenges Solved', widget.project.challenges!),
                  const SizedBox(height: 24),
                ],
                if (widget.project.technologies.isNotEmpty || widget.project.techStack.isNotEmpty) ...[
                  _buildTechnologies(context, isDark, primary),
                  const SizedBox(height: 24),
                ],
                if (widget.project.keyFeatures.isNotEmpty) ...[
                  _buildKeyFeatures(context, isDark, primary),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile Stacked Layout (Scrolls smoothly without overflow)
  Widget _buildMobileStackedLayout(BuildContext context, bool isDark, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(context, isDark, height: 210),
          if (widget.project.screenshots.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildGalleryThumbnails(context, isDark, primary),
          ],
          if (_hasText(widget.project.shortDescription)) ...[
            const SizedBox(height: 20),
            _buildOverviewCard(context, isDark, primary),
          ],
          if (_hasText(widget.project.fullDescription) &&
              widget.project.fullDescription != widget.project.shortDescription) ...[
            const SizedBox(height: 20),
            _section(context, isDark, 'Description', widget.project.fullDescription),
          ],
          if (_hasText(widget.project.role)) ...[
            const SizedBox(height: 20),
            _infoBlock(context, isDark, 'My Role', widget.project.role!),
          ],
          if (_hasText(widget.project.challenges)) ...[
            const SizedBox(height: 20),
            _infoBlock(context, isDark, 'Technical Highlights', widget.project.challenges!),
          ],
          if (widget.project.technologies.isNotEmpty || widget.project.techStack.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildTechnologies(context, isDark, primary),
          ],
          if (widget.project.keyFeatures.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildKeyFeatures(context, isDark, primary),
          ],
          if (_hasAnyAction) ...[
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 18),
            _buildActions(context, isDark, primary, isDesktop: false),
          ],
        ],
      ),
    );
  }

  /// Hero Image with clean rounded styling & zoom preview
  Widget _buildHeroImage(BuildContext context, bool isDark, {required double height}) {
    final screenshots = widget.project.screenshots
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final activeImage = (screenshots.isNotEmpty && _activeScreenshotIndex < screenshots.length)
        ? screenshots[_activeScreenshotIndex]
        : widget.project.imageUrl;

    if (!_hasUrl(activeImage)) {
      return _buildFallbackBanner(context, isDark, height: height);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: activeImage!,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: height,
            color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) =>
              _buildFallbackBanner(context, isDark, height: height),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner(BuildContext context, bool isDark, {required double height}) {
    final primary = AppTheme.getPrimaryColor(context);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192038) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF263150) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getProjectTypeIcon(widget.project.displayProjectType),
              size: 48,
              color: primary.withAlpha(160),
            ),
            const SizedBox(height: 8),
            Text(
              widget.project.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.project.displayProjectType.isNotEmpty
                  ? widget.project.displayProjectType
                  : 'Project Showcase',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Screenshots Thumbnails Row
  Widget _buildGalleryThumbnails(BuildContext context, bool isDark, Color primary) {
    final screenshots = widget.project.screenshots
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (screenshots.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: screenshots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _activeScreenshotIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _activeScreenshotIndex = index;
              });
              AnalyticsService.instance.logProjectGalleryImageView(
                projectId: widget.project.id,
                projectSlug: _slug,
                imageIndex: index,
                sourceSection: 'details_modal',
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primary : (isDark ? const Color(0xFF263150) : const Color(0xFFCBD5E1)),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: screenshots[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E38) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3860) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.project.shortDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, bool isDark, String title, String body) =>
      _infoBlock(context, isDark, title, body);

  Widget _infoBlock(BuildContext context, bool isDark, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnologies(BuildContext context, bool isDark, Color primary) {
    final list = widget.project.technologies.isNotEmpty
        ? widget.project.technologies
        : widget.project.techStack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technologies & Frameworks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2640) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                tech,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(BuildContext context, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features & Deliverables',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ...widget.project.keyFeatures
            .where((item) => item.trim().isNotEmpty)
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.check_circle_outline, size: 16, color: primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _badge(String value, {required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 40 : 25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  IconData _getProjectTypeIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('app') || lower.contains('mobile')) {
      return Icons.phone_android;
    } else if (lower.contains('web')) {
      return Icons.language;
    } else if (lower.contains('cms')) {
      return Icons.dashboard_customize;
    } else if (lower.contains('crm')) {
      return Icons.people_alt;
    }
    return Icons.code;
  }

  /// Action Buttons (Live, Play Store, App Store, GitHub, Other)
  Widget _buildActions(BuildContext context, bool isDark, Color primary, {required bool isDesktop}) {
    final p = widget.project;
    final buttons = <Widget>[];

    if (_hasUrl(p.playStoreUrl)) {
      buttons.add(_actionButton(
        context: context,
        label: 'Google Play',
        icon: Icons.shop,
        url: p.playStoreUrl!,
        linkType: AnalyticsLinkTypes.googlePlay,
        color: const Color(0xFF00C853),
        isDesktop: isDesktop,
      ));
    }

    if (_hasUrl(p.appStoreUrl)) {
      buttons.add(_actionButton(
        context: context,
        label: 'App Store',
        icon: Icons.apple,
        url: p.appStoreUrl!,
        linkType: AnalyticsLinkTypes.appStore,
        color: isDark ? Colors.white : Colors.black87,
        isDesktop: isDesktop,
      ));
    }

    if (_hasUrl(p.liveUrl)) {
      buttons.add(_actionButton(
        context: context,
        label: 'Live Demo',
        icon: Icons.rocket_launch,
        url: p.liveUrl!,
        linkType: AnalyticsLinkTypes.liveDemo,
        color: primary,
        isDesktop: isDesktop,
      ));
    }

    if (_hasUrl(p.githubUrl)) {
      buttons.add(_actionButton(
        context: context,
        label: 'Source Code',
        icon: Icons.code,
        url: p.githubUrl!,
        linkType: AnalyticsLinkTypes.github,
        color: const Color(0xFF6C63FF),
        isDesktop: isDesktop,
      ));
    }

    if (_hasUrl(p.otherUrl)) {
      buttons.add(_actionButton(
        context: context,
        label: _hasText(p.otherUrlLabel) ? p.otherUrlLabel! : 'External Link',
        icon: Icons.open_in_new,
        url: p.otherUrl!,
        linkType: 'other_url',
        color: const Color(0xFFFF6584),
        isDesktop: isDesktop,
      ));
    }

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((b) => Padding(padding: const EdgeInsets.only(bottom: 8), child: b)).toList(),
      );
    } else {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: buttons,
      );
    }
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String url,
    required String linkType,
    required Color color,
    required bool isDesktop,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        AnalyticsService.instance.logProjectLinkClick(
          projectId: widget.project.id,
          linkType: linkType,
          url: url,
          projectTitle: widget.project.title,
          projectSlug: _slug,
          category: widget.project.category,
          sourceSection: 'details_modal',
        );
        _launchUrl(url);
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}
