import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:futter_portfileo_website/models/project_model.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';
import 'all_projects_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/analytics/analytics_constants.dart';
import '../../../services/analytics/analytics_service.dart';

import '../../../widgets/comon/project_details_modal.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  final Set<String> _viewedProjectIds = {};

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
              title: 'Featured Projects',
              subtitle: 'Showcasing my best work and achievements',
            ),
            const SizedBox(height: 60),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                // loading State
                if (provider.isLoadingProjects) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading projects... '),
                        ],
                      ),
                    ),
                  );
                }
                // Error State
                if (provider.errorProjects != null) {
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
                            'Failed to load projects',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorProjects!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => provider.loadProjects(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Only Featured Projects
                final featuredProjects = provider.projects
                    .where((project) => project.isFeatured)
                    .toList();

                // Empty State
                if (featuredProjects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No featured projects yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Featured Projects will appear here once added',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    _buildProjectsGrid(context, featuredProjects),
                    if (provider.projects.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      _buildViewAllButton(context, provider.projects.length),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // View All Projects Button
  Widget _buildViewAllButton(BuildContext context, int totalProjects) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          AnalyticsService.instance.logNavClick(
            itemTitle: 'View All Projects',
            destination: 'all_projects_page',
            source: 'featured_projects',
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllProjectsPage()),
          );
        },
        icon: const Icon(Icons.grid_view),
        label: Text('View All Projects ($totalProjects)'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          foregroundColor: Theme.of(context).colorScheme.primary,
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, List<ProjectModel> projects) {
    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, projects),
      tablet: _buildTabletGrid(context, projects),
      desktop: _buildDesktopGrid(context, projects),
    );
  }

  // Phone Grid
  Widget _buildMobileGrid(BuildContext context, List<ProjectModel> projects) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildProjectCard(context, projects[index], index),
        );
      },
    );
  }

  // Tablet Grid
  Widget _buildTabletGrid(BuildContext context, List<ProjectModel> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 470,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          _buildProjectCard(context, projects[index], index),
    );
  }

  // Desktop Grid
  Widget _buildDesktopGrid(BuildContext context, List<ProjectModel> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 470,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          _buildProjectCard(context, projects[index], index),
    );
  }

  // Projects Card
  Widget _buildProjectCard(BuildContext context, ProjectModel project, int position) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewedProjectIds.add(project.id)) {
        AnalyticsService.instance.logProjectCardView(
          projectId: project.id,
          projectTitle: project.name,
          projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
          category: project.category,
          sourceSection: 'featured_projects',
          position: position,
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGradient(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: project.isFeatured
              ? Theme.of(context).colorScheme.primary.withAlpha(127)
              : Theme.of(context).colorScheme.primary.withAlpha(51),
          width: project.isFeatured ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Badges
          Stack(
            children: [
              if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: project.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildFallbackBanner(context, project),
                  ),
                )
              else
                _buildFallbackBanner(context, project),

              // Featured Badge
              if (project.isFeatured)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getPrimaryGradient(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'FEATURED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Category Badge
              if (project.category != null && project.category!.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withAlpha(76),
                      ),
                    ),
                    child: Text(
                      project.category!,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  project.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                SizedBox(
                  height: 40,
                  child: Text(
                    project.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),

                // Tech Stack
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.techStack.take(3).map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(35),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withAlpha(60),
                        ),
                      ),
                      child: Text(
                        tech,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          if (!isMobile) const Spacer() else const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AnalyticsService.instance.logProjectDetailsOpen(
                        projectId: project.id,
                        projectTitle: project.name,
                        projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                        category: project.category,
                        sourceSection: 'featured_projects',
                        position: position,
                      );
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ProjectDetailsModal(project: project),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 15),
                    label: Text(
                      'Details',
                      style: TextStyle(fontSize: isMobile ? 12 : 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (project.playStoreUrl != null && project.playStoreUrl!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      AnalyticsService.instance.logProjectLinkClick(
                        projectId: project.id,
                        linkType: AnalyticsLinkTypes.googlePlay,
                        url: project.playStoreUrl,
                        projectTitle: project.name,
                        projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                        category: project.category,
                        sourceSection: 'featured_projects',
                        position: position,
                      );
                      _launchURL(project.playStoreUrl!);
                    },
                    icon: const Icon(Icons.shop, size: 18),
                    tooltip: 'Google Play Store',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                if (project.appStoreUrl != null && project.appStoreUrl!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      AnalyticsService.instance.logProjectLinkClick(
                        projectId: project.id,
                        linkType: AnalyticsLinkTypes.appStore,
                        url: project.appStoreUrl,
                        projectTitle: project.name,
                        projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                        category: project.category,
                        sourceSection: 'featured_projects',
                        position: position,
                      );
                      _launchURL(project.appStoreUrl!);
                    },
                    icon: const Icon(Icons.apple, size: 18),
                    tooltip: 'Apple App Store',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                    ),
                  ),
                ],
                if (project.githubUrl != null && project.githubUrl!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      AnalyticsService.instance.logProjectLinkClick(
                        projectId: project.id,
                        linkType: AnalyticsLinkTypes.github,
                        url: project.githubUrl,
                        projectTitle: project.name,
                        projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                        category: project.category,
                        sourceSection: 'featured_projects',
                        position: position,
                      );
                      _launchURL(project.githubUrl!);
                    },
                    icon: const Icon(Icons.code, size: 18),
                    tooltip: 'GitHub Repository',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                    ),
                  ),
                ],
                if (project.liveUrl != null && project.liveUrl!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      AnalyticsService.instance.logProjectLinkClick(
                        projectId: project.id,
                        linkType: AnalyticsLinkTypes.liveDemo,
                        url: project.liveUrl,
                        projectTitle: project.name,
                        projectSlug: project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                        category: project.category,
                        sourceSection: 'featured_projects',
                        position: position,
                      );
                      _launchURL(project.liveUrl!);
                    },
                    icon: const Icon(Icons.launch, size: 18),
                    tooltip: 'Live Demo',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(40),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner(BuildContext context, ProjectModel project) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(50),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.devices_outlined,
          size: 44,
          color: Theme.of(context).colorScheme.primary.withAlpha(150),
        ),
      ),
    );
  }

  //LaunchUrl Functions
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
