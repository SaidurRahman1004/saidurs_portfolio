import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/analytics_report_models.dart';
import '../../../models/project_model.dart';

/// Interactive table displaying content and portfolio project engagement.
/// Integrates Phase 2 project tracking with Phase 6 GA4 reports.
class ProjectAnalyticsTable extends StatelessWidget {
  final List<ProjectModel> projects;
  final ContentInteractionsModel contentInteractions;
  final List<AnalyticsBreakdownItem> pages;
  final List<AnalyticsBreakdownItem> events;

  const ProjectAnalyticsTable({
    super.key,
    required this.projects,
    required this.contentInteractions,
    required this.pages,
    required this.events,
  });

  int _getEventCount(String eventName) {
    for (final ev in events) {
      if (ev.label == eventName) return ev.count;
    }
    return 0;
  }

  /// Calculates approximate views for a project based on pagePath breakdown.
  int _getProjectViews(ProjectModel project) {
    final slug = project.slug.isNotEmpty ? project.slug.toLowerCase() : project.id.toLowerCase();
    int count = 0;
    for (final page in pages) {
      final path = page.label.toLowerCase();
      if (path.contains(slug) || (project.title.isNotEmpty && path.contains(project.title.toLowerCase()))) {
        count += page.count;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    final projectMetrics = contentInteractions.projects;
    final totalShares = _getEventCount('project_share') + _getEventCount('project_copy_link');

    // Determine most viewed project
    ProjectModel? mostViewedProject;
    int maxViews = -1;
    for (final p in projects) {
      final views = _getProjectViews(p);
      if (views > maxViews) {
        maxViews = views;
        mostViewedProject = p;
      }
    }
    if (mostViewedProject == null && projects.isNotEmpty) {
      mostViewedProject = projects.firstWhere((p) => p.isFeatured, orElse: () => projects.first);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and aggregate pills
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 780;
              final titleWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.layers_rounded, color: primaryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Analytics: Projects',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Interactions, code links, live demos, and store clicks',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final pillsWidget = Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildPill(context, 'Details Opens: ${projectMetrics.detailsOpened}', Icons.visibility_rounded, primaryColor),
                  _buildPill(context, 'External Clicks: ${projectMetrics.totalExternalClicks}', Icons.open_in_new_rounded, const Color(0xFF10B981)),
                ],
              );

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: 12),
                        pillsWidget,
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: titleWidget),
                        const SizedBox(width: 16),
                        pillsWidget,
                      ],
                    );
            },
          ),

          const SizedBox(height: 20),

          // Most Viewed Project Highlight Banner
          if (mostViewedProject != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.12),
                    (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'MOST POPULAR PROJECT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: primaryColor,
                              ),
                            ),
                            if (mostViewedProject.isFeatured) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Featured',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mostViewedProject.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        if (mostViewedProject.category != null)
                          Text(
                            mostViewedProject.category!,
                            style: TextStyle(fontSize: 11, color: textSecondary),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        maxViews > 0 ? '$maxViews views' : '${projectMetrics.detailsOpened} opens',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${projectMetrics.totalExternalClicks} total outbound',
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Project List/Table
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No portfolio projects found in database.',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 750;

                if (isMobile) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final views = _getProjectViews(project);

                      return _buildMobileProjectCard(
                        context,
                        project: project,
                        views: views,
                        projectMetrics: projectMetrics,
                        totalShares: totalShares,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      );
                    },
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      ),
                      horizontalMargin: 12,
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Views / Opens', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('GitHub Clicks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Live Demo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Play Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('App Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Shares', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: projects.map((project) {
                        final views = _getProjectViews(project);
                        final hasGithub = project.githubUrl != null && project.githubUrl!.isNotEmpty;
                        final hasDemo = project.liveUrl != null && project.liveUrl!.isNotEmpty;
                        final hasPlayStore = project.playStoreUrl != null && project.playStoreUrl!.isNotEmpty;
                        final hasAppStore = project.appStoreUrl != null && project.appStoreUrl!.isNotEmpty;

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.code_rounded, color: primaryColor, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        project.title,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPrimary),
                                      ),
                                      Text(
                                        project.category ?? 'App',
                                        style: TextStyle(fontSize: 10, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                views > 0 ? '$views' : '${projectMetrics.detailsOpened}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: textPrimary),
                              ),
                            ),
                            DataCell(
                              _buildMetricCell(hasGithub, projectMetrics.githubClicks, textPrimary, textSecondary),
                            ),
                            DataCell(
                              _buildMetricCell(hasDemo, projectMetrics.liveDemoClicks, textPrimary, textSecondary),
                            ),
                            DataCell(
                              _buildMetricCell(hasPlayStore, projectMetrics.googlePlayClicks, textPrimary, textSecondary),
                            ),
                            DataCell(
                              _buildMetricCell(hasAppStore, projectMetrics.appStoreClicks, textPrimary, textSecondary),
                            ),
                            DataCell(
                              Text(
                                '$totalShares',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCell(bool available, int globalCount, Color textPrimary, Color textSecondary) {
    if (!available) {
      return Text('—', style: TextStyle(color: textSecondary.withOpacity(0.5), fontSize: 12));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$globalCount',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
        ),
      ],
    );
  }

  Widget _buildMobileProjectCard(
    BuildContext context, {
    required ProjectModel project,
    required int views,
    required ProjectEngagementMetrics projectMetrics,
    required int totalShares,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.code_rounded, color: primaryColor, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                    ),
                    Text(
                      project.category ?? 'App',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  views > 0 ? '$views views' : '${projectMetrics.detailsOpened} opens',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMiniPill('GitHub: ${projectMetrics.githubClicks}', Icons.code_rounded, project.githubUrl != null),
              _buildMiniPill('Demo: ${projectMetrics.liveDemoClicks}', Icons.open_in_browser_rounded, project.liveUrl != null),
              _buildMiniPill('Play: ${projectMetrics.googlePlayClicks}', Icons.shop_rounded, project.playStoreUrl != null),
              _buildMiniPill('App Store: ${projectMetrics.appStoreClicks}', Icons.apple_rounded, project.appStoreUrl != null),
              _buildMiniPill('Shares: $totalShares', Icons.share_rounded, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPill(String text, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: active ? Colors.grey.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: active ? Colors.blueGrey : Colors.grey.withOpacity(0.4)),
          const SizedBox(width: 4),
          Text(
            active ? text : '—',
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.blueGrey : Colors.grey.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
