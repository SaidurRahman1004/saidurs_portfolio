import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/certification_model.dart';
import '../../../models/education_model.dart';
import '../../../models/professional_experience_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import '../forms/mobile_certification_form_sheet.dart';
import '../forms/mobile_education_form_sheet.dart';
import '../forms/mobile_experience_form_sheet.dart';

class MobileResumeTab extends StatefulWidget {
  const MobileResumeTab({super.key});

  @override
  State<MobileResumeTab> createState() => _MobileResumeTabState();
}

class _MobileResumeTabState extends State<MobileResumeTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<PortfolioProvider>(context, listen: false);
      p.loadExperiences(includeHidden: true);
      p.loadEducation(includeHidden: true);
      p.loadCertifications(includeHidden: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteItem({
    required String title,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await onConfirm();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "$title"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);

    final experiences = portfolioProvider.experiences;
    final education = portfolioProvider.education;
    final certifications = portfolioProvider.certifications;

    return Column(
      children: [
        // Tab Header Container
        Container(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'Experience (${experiences.length})'),
                  Tab(text: 'Education (${education.length})'),
                  Tab(text: 'Certs (${certifications.length})'),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Experience Tab View
              _buildExperienceList(context, experiences, isDark),

              // Education Tab View
              _buildEducationList(context, education, isDark),

              // Certifications Tab View
              _buildCertificationsList(context, certifications, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceList(BuildContext context, List<ProfessionalExperienceModel> list, bool isDark) {
    final df = DateFormat('MMM yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MobileExperienceFormSheet.show(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Experience'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<PortfolioProvider>(context, listen: false).loadExperiences(includeHidden: true),
        child: list.isEmpty
            ? _buildEmptyState(isDark, 'No professional experience entries found.', () => MobileExperienceFormSheet.show(context))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final exp = list[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.work_outline_rounded, color: AppTheme.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exp.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    exp.company,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryColor),
                              onPressed: () => MobileExperienceFormSheet.show(context, experience: exp),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                              onPressed: () => _deleteItem(
                                title: '${exp.title} at ${exp.company}',
                                onConfirm: () => FirebaseService.instance.deleteExperience(exp.id),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 13, color: isDark ? Colors.white38 : Colors.black38),
                            const SizedBox(width: 4),
                            Text(
                              '${df.format(exp.startDate)} — ${exp.isCurrentRole ? "Present" : (exp.endDate != null ? df.format(exp.endDate!) : "Present")}',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: exp.isVisible ? const Color(0xFF10B981).withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                exp.isVisible ? 'VISIBLE' : 'HIDDEN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: exp.isVisible ? const Color(0xFF10B981) : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEducationList(BuildContext context, List<EducationModel> list, bool isDark) {
    final df = DateFormat('yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MobileEducationFormSheet.show(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Education'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<PortfolioProvider>(context, listen: false).loadEducation(includeHidden: true),
        child: list.isEmpty
            ? _buildEmptyState(isDark, 'No education records found.', () => MobileEducationFormSheet.show(context))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final edu = list[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school_outlined, color: Color(0xFF3B82F6), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                edu.degree,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                edu.institution,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                '${df.format(edu.startDate)} — ${edu.isCurrent ? "Present" : (edu.endDate != null ? df.format(edu.endDate!) : "Present")}',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryColor),
                          onPressed: () => MobileEducationFormSheet.show(context, education: edu),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () => _deleteItem(
                            title: edu.degree,
                            onConfirm: () => FirebaseService.instance.deleteEducation(edu.id),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCertificationsList(BuildContext context, List<CertificationModel> list, bool isDark) {
    final df = DateFormat('MMM yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MobileCertificationFormSheet.show(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Certification'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<PortfolioProvider>(context, listen: false).loadCertifications(includeHidden: true),
        child: list.isEmpty
            ? _buildEmptyState(isDark, 'No certifications added yet.', () => MobileCertificationFormSheet.show(context))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final cert = list[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            image: cert.imageUrl != null && cert.imageUrl!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(cert.imageUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (cert.imageUrl == null || cert.imageUrl!.isEmpty)
                              ? const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cert.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                cert.issuingOrganization,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                df.format(cert.issueDate),
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryColor),
                          onPressed: () => MobileCertificationFormSheet.show(context, certification: cert),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () => _deleteItem(
                            title: cert.name,
                            onConfirm: () => FirebaseService.instance.deleteCertification(cert.id),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message, VoidCallback onAdd) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }
}
