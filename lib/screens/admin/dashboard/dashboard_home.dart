import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/project_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../screens/public/home_screen.dart';
import 'projects/add_project_screen.dart';
import 'projects/edit_project_screen.dart';
import 'skills/add_skill_dialog.dart';

class DashboardHome extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardHome({super.key, this.onNavigate});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      provider.loadAllSkills();
      provider.loadAllProjects();
      provider.loadExperiences(includeHidden: true);
      provider.loadEducation(includeHidden: true);
      provider.loadCertifications(includeHidden: true);
      provider.loadContactInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final contentPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackground(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(contentPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Hero Banner
                _buildWelcomeHero(context),

                const SizedBox(height: 28),

                // Live Dynamic Metrics Grid
                _buildMetricsGrid(context),

                const SizedBox(height: 32),

                // Quick Action Command Hub
                _buildQuickActions(context),

                const SizedBox(height: 32),

                // Responsive 2-Column: Recent Projects Feed & System Health
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 960) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildRecentProjectsSection(context),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _buildSystemHealthCard(context),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildRecentProjectsSection(context),
                          const SizedBox(height: 24),
                          _buildSystemHealthCard(context),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Welcome Hero Banner
  Widget _buildWelcomeHero(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 8),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppTheme.primaryGradient
                      : AppTheme.lightPrimaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(isDark ? 80 : 50),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👋', style: TextStyle(fontSize: 26)),
                ),
              ),

              const SizedBox(width: 20),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Welcome back, ${adminProvider.userDisplayName}!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF10B981).withAlpha(70),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Live',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your portfolio data, track real-time content, and update public details.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
      },
    );
  }

  // Live Metrics Grid
  Widget _buildMetricsGrid(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        final totalSkills = provider.allSkills.isNotEmpty
            ? provider.allSkills.length
            : provider.skills.length;
        final visibleSkills = provider.skills.length;

        final totalProjects = provider.allProjects.isNotEmpty
            ? provider.allProjects.length
            : provider.projects.length;
        final featuredProjects = (provider.allProjects.isNotEmpty
                ? provider.allProjects
                : provider.projects)
            .where((p) => p.isFeatured)
            .length;

        final experiencesCount = provider.experiences.length;
        final educationCount = provider.education.length;
        final certificationsCount = provider.certifications.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            int columns = 4;
            if (constraints.maxWidth < 640) {
              columns = 1;
            } else if (constraints.maxWidth < 1080) {
              columns = 2;
            }

            final cards = [
              _buildMetricCard(
                context,
                title: 'Total Skills',
                value: '$totalSkills',
                subtitle: '$visibleSkills visible on site',
                icon: Icons.bolt_rounded,
                accentColor: const Color(0xFF2563EB),
                tag: 'Skills',
                onTap: () => widget.onNavigate?.call(4),
              ),
              _buildMetricCard(
                context,
                title: 'Total Projects',
                value: '$totalProjects',
                subtitle: '$featuredProjects featured showcases',
                icon: Icons.layers_rounded,
                accentColor: const Color(0xFF7C3AED),
                tag: 'Projects',
                onTap: () => widget.onNavigate?.call(3),
              ),
              _buildMetricCard(
                context,
                title: 'Experience & Edu',
                value: '${experiencesCount + educationCount}',
                subtitle: '$experiencesCount roles • $educationCount degrees',
                icon: Icons.work_rounded,
                accentColor: const Color(0xFF0EA5E9),
                tag: 'Career',
                onTap: () => widget.onNavigate?.call(2),
              ),
              _buildMetricCard(
                context,
                title: 'Certifications',
                value: '$certificationsCount',
                subtitle: 'Verified credentials',
                icon: Icons.military_tech_rounded,
                accentColor: const Color(0xFFF59E0B),
                tag: 'Honors',
                onTap: () => widget.onNavigate?.call(6),
              ),
            ];

            if (columns == 1) {
              return Column(
                children: cards
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: c,
                        ))
                    .toList(),
              );
            }

            final rows = <Widget>[];
            for (var i = 0; i < cards.length; i += columns) {
              final rowCards = <Widget>[];
              for (var j = 0; j < columns; j++) {
                if (i + j < cards.length) {
                  rowCards.add(Expanded(child: cards[i + j]));
                  if (j < columns - 1 && i + j + 1 < cards.length) {
                    rowCards.add(const SizedBox(width: 16));
                  }
                } else {
                  rowCards.add(const Expanded(child: SizedBox()));
                }
              }
              rows.add(Row(children: rowCards));
              if (i + columns < cards.length) {
                rows.add(const SizedBox(height: 16));
              }
            }

            return Column(children: rows);
          },
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String tag,
    VoidCallback? onTap,
  }) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(isDark ? 30 : 15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // Quick Action Command Hub
  Widget _buildQuickActions(BuildContext context) {
    final textPrimary = AppTheme.getTextPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              size: 20,
              color: AppTheme.getPrimaryColor(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _buildActionChip(
                  context,
                  title: 'Add New Project',
                  subtitle: 'Showcase work on site',
                  icon: Icons.add_circle_outline_rounded,
                  color: const Color(0xFF2563EB),
                  width: isNarrow ? double.infinity : 280,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddProjectDialog(),
                    );
                  },
                ),
                _buildActionChip(
                  context,
                  title: 'Add New Skill',
                  subtitle: 'Add tech or tool',
                  icon: Icons.add_task_rounded,
                  color: const Color(0xFF7C3AED),
                  width: isNarrow ? double.infinity : 280,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddSkillDialog(),
                    );
                  },
                ),
                _buildActionChip(
                  context,
                  title: 'Edit Profile & Media',
                  subtitle: 'Photos, phone, socials',
                  icon: Icons.badge_outlined,
                  color: const Color(0xFF0EA5E9),
                  width: isNarrow ? double.infinity : 280,
                  onTap: () => widget.onNavigate?.call(1),
                ),
                _buildActionChip(
                  context,
                  title: 'Manage Experience',
                  subtitle: 'Roles & career history',
                  icon: Icons.work_history_outlined,
                  color: const Color(0xFF10B981),
                  width: isNarrow ? double.infinity : 280,
                  onTap: () => widget.onNavigate?.call(2),
                ),
                _buildActionChip(
                  context,
                  title: 'Sync Resume Data',
                  subtitle: 'Seed latest CV to Firestore',
                  icon: Icons.cloud_sync_rounded,
                  color: const Color(0xFFF59E0B),
                  width: isNarrow ? double.infinity : 280,
                  onTap: () => _confirmSeedResumeData(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmSeedResumeData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Sync Latest Resume Data?'),
          ],
        ),
        content: const Text(
          'This will populate your Firestore database with your latest resume data:\n\n'
          '• Current Role: SM Technology — A Betopia Group Company\n'
          '• Projects: EzyDash, ChugChain, PocketVault, TravelSnap\n'
          '• Education: Dhaka Polytechnic Institute, Ali Ahmed School & College\n'
          '• Certifications: Ostad (Flutter), Bohubrihi (Web)\n'
          '• Skills: 34 categorized skills with tech stacks\n'
          '• Contact: Updated phone, email, and social links\n\n'
          'Existing custom documents will not be deleted. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () => Navigator.pop(dialogCtx, true),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Sync to Firestore'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Syncing resume data to Firestore...'),
              ],
            ),
            duration: Duration(seconds: 4),
          ),
        );

        await context.read<PortfolioProvider>().seedResumeData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF10B981),
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Resume data successfully synced to Firestore!'),
                ],
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to sync: $e'),
            ),
          );
        }
      }
    }
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 40 : 25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // Recent Projects Feed from Firebase
  Widget _buildRecentProjectsSection(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        final projects = provider.allProjects.isNotEmpty
            ? provider.allProjects
            : provider.projects;

        final recentProjects = projects.take(4).toList();

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 25 : 6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Projects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onNavigate?.call(3),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.isLoadingAllProjects && projects.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (recentProjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.layers_clear_rounded,
                        size: 44,
                        color: AppTheme.getTextHint(context),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No projects published yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddProjectDialog(),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Your First Project'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentProjects.map(
                  (project) => _buildProjectRowItem(context, project),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectRowItem(BuildContext context, ProjectModel project) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Project Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: project.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: primaryColor.withAlpha(30),
                        child: Icon(Icons.image, color: primaryColor, size: 24),
                      ),
                    )
                  : Container(
                      color: primaryColor.withAlpha(30),
                      child: Icon(
                        Icons.layers_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // Project Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project.isFeatured) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 10, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  project.shortDescription.isNotEmpty
                      ? project.shortDescription
                      : project.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Edit Action Button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditProjectDialog(project: project),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: primaryColor,
            tooltip: 'Edit Project',
          ),
        ],
      ),
    );
  }

  // System Health & Profile Completeness Card
  Widget _buildSystemHealthCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        final contact = provider.contactInfo;
        int completedSteps = 0;
        if (contact != null) {
          if (contact.email.isNotEmpty) completedSteps++;
          if (contact.phone.isNotEmpty) completedSteps++;
          if (contact.githubUrl.isNotEmpty) completedSteps++;
          if (contact.profileImageUrl != null &&
              contact.profileImageUrl!.isNotEmpty) {
            completedSteps++;
          }
          if (contact.resumeUrl != null && contact.resumeUrl!.isNotEmpty) {
            completedSteps++;
          }
        }
        final double completeness = completedSteps / 5.0;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 25 : 6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: 20,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Portfolio Health',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Profile completion meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Completeness',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '${(completeness * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: completeness,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completeness >= 0.8
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Status checklist
              _buildHealthRow(
                context,
                icon: Icons.cloud_done_rounded,
                title: 'Firebase Firestore',
                subtitle: 'Real-time database connected',
                status: 'Active',
                statusColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              _buildHealthRow(
                context,
                icon: Icons.language_rounded,
                title: 'Public Web App',
                subtitle: 'Production build ready',
                status: 'Ready',
                statusColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),
              _buildHealthRow(
                context,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Resume CV',
                subtitle: contact?.resumeUrl != null &&
                        contact!.resumeUrl!.isNotEmpty
                    ? 'Cloud document linked'
                    : 'Not attached yet',
                status: contact?.resumeUrl != null &&
                        contact!.resumeUrl!.isNotEmpty
                    ? 'Linked'
                    : 'Missing',
                statusColor: contact?.resumeUrl != null &&
                        contact!.resumeUrl!.isNotEmpty
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),

              const SizedBox(height: 20),

              // View Public Site Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open Public Portfolio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

