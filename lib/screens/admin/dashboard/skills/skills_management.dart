import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/skill_model.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';
import 'add_skill_dialog.dart';
import 'edit_skill_dialog.dart';

class SkillsManagement extends StatefulWidget {
  const SkillsManagement({super.key});

  @override
  State<SkillsManagement> createState() => _SkillsManagementState();
}

class _SkillsManagementState extends State<SkillsManagement> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  //Selected category filter
  String _selectedCategory = 'All';

  //Filter skills based on search and category
  List<SkillModel> _filteredSkills(List<SkillModel> skills) {
    var filtered = skills;
    //Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((skill) {
        return skill.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            skill.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    //Catagory Filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((skill) {
        return skill.category == _selectedCategory;
      }).toList();
    }
    return filtered;
  }

  /// Get unique categories
  List<String> _getCategories(List<SkillModel> skills) {
    final categories = skills.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        // Loading State
        if (portfolioProvider.isLoadingSkills) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading skills... '),
              ],
            ),
          );
        }

        //Error State
        if (portfolioProvider.errorSkills != null) {
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
                  'Failed to load skills',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(portfolioProvider.errorSkills!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => portfolioProvider.loadSkills(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        //Seccess
        final allSkills = portfolioProvider.skills;
        final filteredSkills = _filteredSkills(allSkills);
        final categories = _getCategories(allSkills);
        return SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveWrapper.isMobile(context) ? 16 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///Header Section
              _buildHeader(context, allSkills.length),

              const SizedBox(height: 24),

              // Search & Filter Section
              _buildSearchAndFilter(categories),

              const SizedBox(height: 24),

              // Skills List Table
              if (filteredSkills.isEmpty)
                _buildEmptyState()
              else
                _buildSkillsList(context, filteredSkills),
            ],
          ),
        );
      },
    );
  }

  // Header with Add button
  Widget _buildHeader(BuildContext context, int totalCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount total skills',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),

        // Add Skill Button
        ElevatedButton.icon(
          onPressed: () => _showAddSkillDialog(context),
          icon: const Icon(Icons.add),
          label: Text(
            ResponsiveWrapper.isMobile(context) ? 'Add' : 'Add Skill',
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

  // Search and Filter Section
  Widget _buildSearchAndFilter(List<String> categories) {
    return ResponsiveWrapper(
      mobile: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildCategoryFilter(categories),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(flex: 2, child: _buildSearchField()),
          const SizedBox(width: 16),
          Expanded(child: _buildCategoryFilter(categories)),
        ],
      ),
    );
  }

  /// Search field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search skills...',
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

  // Category filter dropdown
  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ),
    );
  }

  // Skills List
  Widget _buildSkillsList(BuildContext context, List<SkillModel> skills) {
    return ResponsiveWrapper(
      mobile: _buildSkillsCards(skills),
      desktop: _buildSkillsTable(skills),
    );
  }

  /// Desktop:  Table view
  Widget _buildSkillsTable(List<SkillModel> skills) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 50), // Icon space
                Expanded(flex: 2, child: _tableHeader('Skill Name')),
                Expanded(flex: 2, child: _tableHeader('Category')),
                Expanded(child: _tableHeader('Order')),
                Expanded(child: _tableHeader('Status')),
                const SizedBox(width: 120), // Actions space
              ],
            ),
          ),

          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return _buildTableRow(context, skills[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, SkillModel skill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              IconData(skill.iconCode, fontFamily: 'MaterialIcons'),
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          // Skill Name
          Expanded(
            flex: 2,
            child: Text(
              skill.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: Text(
              skill.category,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ),

          // Order
          Expanded(
            child: Text(
              skill.order.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          // Visibility Status
          Expanded(child: _buildVisibilityChip(skill.isVisible)),

          // Actions
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Toggle Visibility
                IconButton(
                  icon: Icon(
                    skill.isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  tooltip: skill.isVisible ? 'Hide' : 'Show',
                  onPressed: () => _toggleVisibility(context, skill),
                ),

                // Edit
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                  onPressed: () => _showEditSkillDialog(context, skill),
                ),

                // Delete
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppTheme.accentColor,
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, skill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile: Card view
  Widget _buildSkillsCards(List<SkillModel> skills) {
    return Column(
      children: skills.map((skill) => _buildSkillCard(context, skill)).toList(),
    );
  }

  Widget _buildSkillCard(BuildContext context, SkillModel skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconData(skill.iconCode, fontFamily: 'MaterialIcons'),
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              // Name & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skill.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Visibility Status
              _buildVisibilityChip(skill.isVisible),
            ],
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleVisibility(context, skill),
                  icon: Icon(
                    skill.isVisible ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  label: Text(skill.isVisible ? 'Hide' : 'Show'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditSkillDialog(context, skill),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _confirmDelete(context, skill),
                icon: const Icon(Icons.delete),
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Visibility status chip
  Widget _buildVisibilityChip(bool isVisible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVisible
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isVisible ? 'Visible' : 'Hidden',
        style: TextStyle(
          fontSize: 12,
          color: isVisible ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(
              'No skills found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Click "Add Skill" to create your first skill',
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

  // ACTION METHODS

  /// Show Add Skill Dialog
  void _showAddSkillDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddSkillDialog());
  }

  /// Show Edit Skill Dialog
  void _showEditSkillDialog(BuildContext context, SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => EditSkillDialog(skill: skill),
    );
  }

  /// Toggle visibility
  Future<void> _toggleVisibility(BuildContext context, SkillModel skill) async {
    try {
      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.toggleSkillVisibility(skill);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              skill.isVisible
                  ? 'Skill hidden from public view'
                  : 'Skill now visible on public site',
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

  /// Confirm delete
  void _confirmDelete(BuildContext context, SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.accentColor),
            const SizedBox(width: 12),
            const Text('Delete Skill? '),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${skill.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSkill(context, skill);
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

  /// Delete skill
  Future<void> _deleteSkill(BuildContext context, SkillModel skill) async {
    try {
      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.deleteSkill(skill.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting skill: $e'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    }
  }
}
