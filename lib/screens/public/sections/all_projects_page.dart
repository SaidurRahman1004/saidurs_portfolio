import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../models/project_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/analytics/analytics_constants.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import '../../../widgets/comon/project_details_modal.dart';

class AllProjectsPage extends StatefulWidget {
  const AllProjectsPage({super.key});

  @override
  State<AllProjectsPage> createState() => _AllProjectsPageState();
}

class _AllProjectsPageState extends State<AllProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _viewedProjectIds = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logPageView(
      screenName: 'All Projects Page',
      screenClass: 'AllProjectsPage',
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, int resultCount) {
    setState(() {
      _searchQuery = value.trim();
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery.isNotEmpty) {
        AnalyticsService.instance.logProjectSearch(
          searchTerm: _searchQuery,
          resultCount: resultCount,
          sourceSection: 'all_projects_page',
        );
      }
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      AnalyticsService.instance.logProjectFilterApply(
        category: category,
        sourceSection: 'all_projects_page',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.isDark(context)
                        ? const Color(0xFF1E293B).withAlpha(200)
                        : Colors.white.withAlpha(220),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: BackButton(
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'All Projects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withAlpha(AppTheme.isDark(context) ? 60 : 35),
                        Theme.of(context).colorScheme.secondary.withAlpha(AppTheme.isDark(context) ? 40 : 20),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.getPrimaryGradient(context),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withAlpha(80),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.layers_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PORTFOLIO ARCHIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Search & Filter Header
            SliverToBoxAdapter(
              child: Consumer<PortfolioProvider>(
                builder: (context, provider, _) {
                  final categories = <String>{'All'};
                  for (final p in provider.projects) {
                    if (p.category != null && p.category!.trim().isNotEmpty) {
                      categories.add(p.category!.trim());
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: () {
                        final width = MediaQuery.of(context).size.width;
                        if (width > 1200) {
                          return (width - 1200) / 2 + 24;
                        } else if (width > 800) {
                          return 24.0;
                        } else {
                          return 16.0;
                        }
                      }(),
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search projects by name, description, or tech...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.isDark(context)
                                ? const Color(0xFF0F172A).withAlpha(120)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
                            ),
                          ),
                          onChanged: (val) {
                            final count = provider.projects.where((p) {
                              final matchesCat = _selectedCategory == 'All' ||
                                  p.category?.toLowerCase() == _selectedCategory.toLowerCase();
                              final q = val.toLowerCase().trim();
                              final matchesQuery = q.isEmpty ||
                                  p.name.toLowerCase().contains(q) ||
                                  p.description.toLowerCase().contains(q);
                              return matchesCat && matchesQuery;
                            }).length;
                            _onSearchChanged(val, count);
                          },
                        ),
                        if (categories.length > 1) ...[
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    onSelected: (_) => _onCategorySelected(cat),
                                    selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                                    checkmarkColor: Theme.of(context).colorScheme.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : AppTheme.getTextSecondary(context),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Projects Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: () {
                  final width = MediaQuery.of(context).size.width;
                  if (width > 1200) {
                    return (width - 1200) / 2 + 24;
                  } else if (width > 800) {
                    return 24.0;
                  } else {
                    return 16.0;
                  }
                }(),
                vertical: 12,
              ),
              sliver: Consumer<PortfolioProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingProjects) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.errorProjects != null) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(provider.errorProjects!),
                            const SizedBox(height: 16),
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

                  final filtered = provider.projects.where((p) {
                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category?.toLowerCase() == _selectedCategory.toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch = query.isEmpty ||
                        p.name.toLowerCase().contains(query) ||
                        p.description.toLowerCase().contains(query) ||
                        p.techStack.any((t) => t.toLowerCase().contains(query));
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No matching projects found'),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 10),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveWrapper.isMobile(context)
                            ? 1
                            : ResponsiveWrapper.isTablet(context)
                                ? 2
                                : 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: ResponsiveWrapper.isMobile(context)
                            ? 480
                            : 460,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildProjectCard(context, filtered[index], index);
                      }, childCount: filtered.length),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel project, int position) {
    final slug = project.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewedProjectIds.add(project.id)) {
        AnalyticsService.instance.logProjectCardView(
          projectId: project.id,
          projectTitle: project.name,
          projectSlug: slug,
          category: project.category,
          sourceSection: 'all_projects_page',
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            AnalyticsService.instance.logProjectDetailsOpen(
              projectId: project.id,
              projectTitle: project.name,
              projectSlug: slug,
              category: project.category,
              sourceSection: 'all_projects_page',
              position: position,
            );
            showDialog(
              context: context,
              builder: (context) => ProjectDetailsModal(project: project),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Image and Badge
          Stack(
            children: [
              if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      _buildFallbackBanner(context, project),
                      CachedNetworkImage(
                        imageUrl: project.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),
                    ],
                  ),
                )
              else
                _buildFallbackBanner(context, project),
              if (project.isFeatured)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getPrimaryGradient(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        const Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (project.displayProjectType.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.displayProjectType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (project.category != null && project.category!.isNotEmpty)
                      Container(
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.techStack.take(4).map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tech,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 11,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AnalyticsService.instance.logProjectDetailsOpen(
                        projectId: project.id,
                        projectTitle: project.name,
                        projectSlug: slug,
                        category: project.category,
                        sourceSection: 'all_projects_page',
                        position: position,
                      );
                      showDialog(
                        context: context,
                        builder: (context) => ProjectDetailsModal(project: project),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
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
                        projectSlug: slug,
                        category: project.category,
                        sourceSection: 'all_projects_page',
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
                        projectSlug: slug,
                        category: project.category,
                        sourceSection: 'all_projects_page',
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
                        projectSlug: slug,
                        category: project.category,
                        sourceSection: 'all_projects_page',
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
                        projectSlug: slug,
                        category: project.category,
                        sourceSection: 'all_projects_page',
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
    ),
  ),
);
}

  Widget _buildFallbackBanner(BuildContext context, ProjectModel project) {
    final isDark = AppTheme.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    final cat = (project.category ?? '').toLowerCase();
    final type = project.displayProjectType.toLowerCase();
    final IconData bannerIcon;
    final String techTag;

    if (cat.contains('mobile') || type.contains('app') || cat.contains('android') || cat.contains('flutter')) {
      bannerIcon = Icons.phone_android_rounded;
      techTag = 'MOBILE APP';
    } else if (cat.contains('web')) {
      bannerIcon = Icons.language_rounded;
      techTag = 'WEB APP';
    } else if (cat.contains('backend') || cat.contains('cloud') || cat.contains('api') || cat.contains('django')) {
      bannerIcon = Icons.dns_rounded;
      techTag = 'BACKEND';
    } else {
      bannerIcon = Icons.devices_rounded;
      techTag = 'SOFTWARE';
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  primary.withAlpha(50),
                  const Color(0xFF0F172A),
                ]
              : [
                  primary.withAlpha(35),
                  secondary.withAlpha(20),
                  const Color(0xFFF1F5F9),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Background subtle code watermark
          Positioned(
            right: -10,
            bottom: -15,
            child: Text(
              '</>',
              style: TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.w900,
                color: (isDark ? Colors.white : primary).withAlpha(15),
                letterSpacing: -2,
              ),
            ),
          ),

          // Ambient glowing circle
          Positioned(
            left: 20,
            top: 15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withAlpha(isDark ? 40 : 25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Centered tech badge
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withAlpha(160)
                        : Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withAlpha(isDark ? 80 : 120),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withAlpha(isDark ? 50 : 25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    bannerIcon,
                    size: 32,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    techTag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
