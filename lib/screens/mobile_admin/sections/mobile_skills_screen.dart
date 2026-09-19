import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/skill_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/comon/material_icon_mapper.dart';
import '../forms/mobile_skill_form_sheet.dart';

class MobileSkillsScreen extends StatefulWidget {
  const MobileSkillsScreen({super.key});

  @override
  State<MobileSkillsScreen> createState() => _MobileSkillsScreenState();
}

class _MobileSkillsScreenState extends State<MobileSkillsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Mobile',
    'Frontend',
    'Backend',
    'Database',
    'DevOps & Cloud',
    'Tools & Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(context, listen: false).loadAllSkills();
    });
  }

  Future<void> _deleteSkill(BuildContext context, SkillModel skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Delete "${skill.name}" from skills list?'),
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
      await FirebaseService.instance.deleteSkill(skill.id);
      if (context.mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadAllSkills();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${skill.name}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final allSkills = portfolioProvider.allSkills;

    final filtered = _selectedCategory == 'All'
        ? allSkills
        : allSkills.where((s) => s.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Skills Management'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MobileSkillFormSheet.show(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Skill'),
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 48,
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Skills List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => portfolioProvider.loadAllSkills(),
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No skills found in $_selectedCategory.',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final skill = filtered[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                MaterialIconMapper.fromCode(skill.iconCode),
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              skill.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: Text(
                              '${skill.category} • Order: ${skill.order}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryColor),
                                  onPressed: () => MobileSkillFormSheet.show(context, skill: skill),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                  onPressed: () => _deleteSkill(context, skill),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
