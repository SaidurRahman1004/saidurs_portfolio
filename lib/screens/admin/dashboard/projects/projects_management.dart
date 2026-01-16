import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../models/project_model.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';
import 'add_project_screen.dart';
import 'edit_project_screen.dart';

class ProjectsManagement extends StatefulWidget {
  const ProjectsManagement({Key? key}) : super(key: key);

  @override
  State<ProjectsManagement> createState() => _ProjectsManagementState();
}

class _ProjectsManagementState extends State<ProjectsManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All'; // All, Featured, Hidden

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter projects
  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    var filtered = projects;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        return project.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            project.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Type filter
    switch (_filterType) {
      case 'Featured':
        filtered = filtered.where((p) => p.isFeatured).toList();
        break;
      case 'Hidden':
        filtered = filtered.where((p) => !p.isVisible).toList();
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(context, listen: false).loadAllProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        if (portfolioProvider.isLoadingAllProjects) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading projects... '),
              ],
            ),
          );
        }

        if (portfolioProvider.errorAllProjects != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load projects',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(portfolioProvider.errorProjects!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => portfolioProvider.loadAllProjects(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allProjects = portfolioProvider.allProjects;
        final filteredProjects = _filterProjects(allProjects);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveWrapper.isMobile(context) ? 16 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, allProjects.length),
              const SizedBox(height: 24),
              _buildSearchAndFilter(),
              const SizedBox(height: 24),
              if (filteredProjects.isEmpty)
                _buildEmptyState()
              else
                _buildProjectsGrid(context, filteredProjects),
            ],
          ),
        );
      },
    );
  }

  /// Header
  Widget _buildHeader(BuildContext context, int totalCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount total projects',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddProjectDialog(context),
          icon: const Icon(Icons.add),
          label: Text(
            ResponsiveWrapper.isMobile(context) ? 'Add' : 'Add Project',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  /// Search & Filter
  Widget _buildSearchAndFilter() {
    return ResponsiveWrapper(
      mobile: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildFilterButtons(),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(flex: 2, child: _buildSearchField()),
          const SizedBox(width: 16),
          _buildFilterButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search projects.. .',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: ['All', 'Featured', 'Hidden'].map((filter) {
        final isSelected = _filterType == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filterType = filter;
              });
            },
            backgroundColor: AppTheme.cardBackground,
            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
            checkmarkColor: AppTheme.primaryColor,
          ),
        );
      }).toList(),
    );
  }

  /// Projects Grid
  Widget _buildProjectsGrid(BuildContext context, List<ProjectModel> projects) {
    return ResponsiveWrapper(
      mobile: _buildProjectsList(projects),
      desktop: _buildProjectsGridView(projects),
    );
  }

  Widget _buildProjectsList(List<ProjectModel> projects) {
    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProjectCard(context, project),
            ),
          )
          .toList(),
    );
  }

  /// Project Card
  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    bool isMobile = ResponsiveWrapper.isMobile(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: 400,
        maxHeight: isMobile ? 500 : 450,
      ), // Desktop: no constraint
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: project.isFeatured
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(0.2),
          width: project.isFeatured ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Section
          if (project.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                project.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppTheme.surfaceColor,
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppTheme.textHint,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: AppTheme.textHint,
                ),
              ),
            ),

          // Badges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (project.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: project.isVisible
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.isVisible ? 'VISIBLE' : 'HIDDEN',
                    style: TextStyle(
                      fontSize: 10,
                      color: project.isVisible ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  project.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 60,
                  child: Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.techStack.take(4).map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tech,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.surfaceColor.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditProjectDialog(context, project),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _toggleVisibility(context, project),
                  icon: Icon(
                    project.isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  tooltip: project.isVisible ? 'Hide' : 'Show',
                ),
                IconButton(
                  onPressed: () => _toggleFeatured(context, project),
                  icon: Icon(
                    project.isFeatured ? Icons.star : Icons.star_outline,
                    size: 20,
                  ),
                  color: project.isFeatured ? Colors.amber : null,
                  tooltip: project.isFeatured ? 'Unfeature' : 'Feature',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, project),
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppTheme.accentColor,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsGridView(List<ProjectModel> projects) {
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          _buildProjectCard(context, projects[index]),
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(Icons.work_off, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Click "Add Project" to create your first project',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => EditProjectDialog(project: project),
    );
  }

  Future<void> _toggleVisibility(
    BuildContext context,
    ProjectModel project,
  ) async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.toggleProjectVisibility(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              project.isVisible
                  ? 'Project hidden from public view'
                  : 'Project now visible on public site',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error:  $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  Future<void> _toggleFeatured(
    BuildContext context,
    ProjectModel project,
  ) async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.toggleProjectFeatured(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              project.isFeatured
                  ? 'Project removed from featured'
                  : 'Project marked as featured',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.accentColor),
            const SizedBox(width: 12),
            const Text('Delete Project? '),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProject(context, project);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(
    BuildContext context,
    ProjectModel project,
  ) async {
    try {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);
      await provider.deleteProject(project.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }
}
