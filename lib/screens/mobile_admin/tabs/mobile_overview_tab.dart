import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import '../forms/mobile_project_form_sheet.dart';
import '../forms/mobile_skill_form_sheet.dart';
import 'mobile_inquiry_detail_sheet.dart';

class MobileOverviewTab extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;

  const MobileOverviewTab({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final projects = portfolioProvider.allProjects;
    final skills = portfolioProvider.allSkills;
    final inquiries = portfolioProvider.inquiries;
    final experiences = portfolioProvider.experiences;

    final unreadInquiries = inquiries.where((i) => !i.isRead).length;
    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        portfolioProvider.loadAllProjects();
        portfolioProvider.loadAllSkills();
        portfolioProvider.loadInquiries();
        portfolioProvider.loadExperiences(includeHidden: true);
        portfolioProvider.loadEducation(includeHidden: true);
        portfolioProvider.loadCertifications(includeHidden: true);
        portfolioProvider.loadContactInfo();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [AppTheme.primaryColor.withOpacity(0.08), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          adminProvider.userInitials,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hello, ${adminProvider.userDisplayName} 👋',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Production Database Connected',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Live Metrics Grid
            Text(
              'LIVE METRICS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildKpiCard(
                  context,
                  title: 'Projects',
                  value: projects.length.toString(),
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => onNavigateTab?.call(1),
                ),
                _buildKpiCard(
                  context,
                  title: 'Inquiries',
                  value: inquiries.length.toString(),
                  badgeText: unreadInquiries > 0 ? '$unreadInquiries new' : null,
                  icon: Icons.mark_email_unread_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () => onNavigateTab?.call(2),
                ),
                _buildKpiCard(
                  context,
                  title: 'Skills',
                  value: skills.length.toString(),
                  icon: Icons.code_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => onNavigateTab?.call(4),
                ),
                _buildKpiCard(
                  context,
                  title: 'Experience',
                  value: experiences.length.toString(),
                  icon: Icons.work_outline_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => onNavigateTab?.call(3),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Quick Action Hub
            Text(
              'QUICK COMMANDS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionChip(
                    context,
                    label: '+ Add Project',
                    icon: Icons.add_box_rounded,
                    color: AppTheme.primaryColor,
                    onTap: () => MobileProjectFormSheet.show(context),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    context,
                    label: '+ Add Skill',
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => MobileSkillFormSheet.show(context),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    context,
                    label: 'Sync Resume',
                    icon: Icons.sync_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Seed & Sync Resume'),
                          content: const Text('Sync default resume experience, education, certifications, and skills into Firestore?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sync Now')),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        try {
                          await FirebaseService.instance.seedResumeData();
                          if (context.mounted) {
                            portfolioProvider.loadAllData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Resume data synced successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sync error: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    context,
                    label: 'View Messages',
                    icon: Icons.mail_outline_rounded,
                    color: const Color(0xFFEC4899),
                    onTap: () => onNavigateTab?.call(2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Recent Inquiries Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT INQUIRIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab?.call(2),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('See All'),
                ),
              ],
            ),

            if (inquiries.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No messages received yet.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inquiries.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final inq = inquiries[idx];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: inq.isRead
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : AppTheme.primaryColor.withOpacity(0.5),
                        width: inq.isRead ? 1 : 1.5,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => MobileInquiryDetailSheet.show(context, inq),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                        child: Text(
                          inq.name.isNotEmpty ? inq.name[0].toUpperCase() : 'U',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                      title: Text(
                        inq.name,
                        style: TextStyle(
                          fontWeight: inq.isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        inq.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: inq.isRead
                          ? null
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Section: Recent Projects Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT PROJECTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab?.call(1),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('Manage All'),
                ),
              ],
            ),

            if (projects.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No projects added yet.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final proj = projects[idx];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => MobileProjectFormSheet.show(context, project: proj),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          image: proj.imageUrl != null && proj.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(proj.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (proj.imageUrl == null || proj.imageUrl!.isEmpty)
                            ? const Icon(Icons.code_rounded, size: 20)
                            : null,
                      ),
                      title: Text(
                        proj.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        proj.category ?? (proj.projectType ?? 'Project'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      side: BorderSide(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
