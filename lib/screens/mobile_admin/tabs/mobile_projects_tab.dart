import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../models/project_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../forms/mobile_project_form_sheet.dart';

class MobileProjectsTab extends StatefulWidget {
  const MobileProjectsTab({super.key});

  @override
  State<MobileProjectsTab> createState() => _MobileProjectsTabState();
}

class _MobileProjectsTabState extends State<MobileProjectsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'App', 'Web', 'CMS', 'CRM', 'Featured', 'Hidden'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectModel> _getFilteredProjects(List<ProjectModel> all) {
    var list = all;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.shortDescription.toLowerCase().contains(q) ||
            p.technologies.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    if (_selectedFilter == 'Featured') {
      list = list.where((p) => p.isFeatured).toList();
    } else if (_selectedFilter == 'Hidden') {
      list = list.where((p) => !p.isVisible).toList();
    } else if (_selectedFilter != 'All') {
      list = list.where((p) => (p.projectType ?? '').toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    return list;
  }

  Future<void> _deleteProject(BuildContext context, ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.title}"? This cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<PortfolioProvider>(context, listen: false).deleteProject(project.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Project "${project.title}" deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<void> _toggleVisibility(BuildContext context, ProjectModel project) async {
    try {
      final updated = project.copyWith(isVisible: !project.isVisible);
      await Provider.of<PortfolioProvider>(context, listen: false).updateProject(project.id, updated);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating visibility: $e')),
        );
      }
    }
  }

  Future<void> _launchExternalUrl(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    try {
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final allProjects = portfolioProvider.allProjects;
    final filtered = _getFilteredProjects(allProjects);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MobileProjectFormSheet.show(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search projects by title, tech...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips List
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final f = _filters[i];
                      final isSelected = _selectedFilter == f;

                      return FilterChip(
                        label: Text(f, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedFilter = f);
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Projects List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => portfolioProvider.loadAllProjects(),
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 48,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No projects match "$_searchQuery"' : 'No projects found in this category',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final proj = filtered[i];
                        return _buildProjectCard(context, proj, isDark);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectModel proj, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          // Banner Image & Badges
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
                  image: proj.imageUrl != null && proj.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(proj.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (proj.imageUrl == null || proj.imageUrl!.isEmpty)
                    ? const Center(child: Icon(Icons.code_rounded, size: 40, color: Colors.grey))
                    : null,
              ),

              // Badges overlay
              Positioned(
                top: 10,
                left: 10,
                child: Wrap(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        proj.projectType ?? 'App',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (proj.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              // Visibility status chip
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: proj.isVisible ? const Color(0xFF10B981) : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    proj.isVisible ? 'VISIBLE' : 'HIDDEN',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proj.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proj.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),

                // Technologies chips
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: proj.technologies.take(4).map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Card Actions Footer
                Row(
                  children: [
                    // External Link Buttons
                    if (proj.liveUrl != null && proj.liveUrl!.isNotEmpty)
                      IconButton(
                        tooltip: 'Open Live Demo',
                        icon: const Icon(Icons.language_rounded, size: 18),
                        onPressed: () => _launchExternalUrl(proj.liveUrl),
                      ),
                    if (proj.githubUrl != null && proj.githubUrl!.isNotEmpty)
                      IconButton(
                        tooltip: 'Open GitHub',
                        icon: const Icon(Icons.code_rounded, size: 18),
                        onPressed: () => _launchExternalUrl(proj.githubUrl),
                      ),
                    if (proj.playStoreUrl != null && proj.playStoreUrl!.isNotEmpty)
                      IconButton(
                        tooltip: 'Google Play Store',
                        icon: const Icon(Icons.shop_rounded, size: 18),
                        onPressed: () => _launchExternalUrl(proj.playStoreUrl),
                      ),

                    const Spacer(),

                    // Visibility Toggle
                    IconButton(
                      tooltip: proj.isVisible ? 'Hide from public' : 'Show publicly',
                      icon: Icon(
                        proj.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        size: 20,
                        color: proj.isVisible ? const Color(0xFF10B981) : Colors.grey,
                      ),
                      onPressed: () => _toggleVisibility(context, proj),
                    ),

                    // Edit Button
                    IconButton(
                      tooltip: 'Edit Project',
                      icon: Icon(Icons.edit_rounded, size: 20, color: AppTheme.primaryColor),
                      onPressed: () => MobileProjectFormSheet.show(context, project: proj),
                    ),

                    // Delete Button
                    IconButton(
                      tooltip: 'Delete Project',
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                      onPressed: () => _deleteProject(context, proj),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
