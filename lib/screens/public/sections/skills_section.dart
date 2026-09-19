import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:futter_portfileo_website/models/skill_model.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import '../../../widgets/comon/material_icon_mapper.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          children: [
            SectionTitle(
              title: 'My Skills',
              subtitle: 'Technical expertise and tools I use',
            ),
            const SizedBox(height: 60),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingSkills) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (provider.errorSkills != null) {
                  return Center(
                    child: Text(
                      'Failed to load skills',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                if (provider.skills.isEmpty) {
                  return Center(
                    child: Text(
                      'No skills available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return _buildSkillsGrid(context, provider.skillsByCategory);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(
    BuildContext context,
    Map<String, List<dynamic>> skillsByCategory,
  ) {
    final categories = skillsByCategory.entries.toList();
    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, categories),
      tablet: _buildTabletGrid(context, categories),
      desktop: _buildDesktopGrid(context, categories),
    );
  }

  Widget _buildMobileGrid(
      BuildContext context, List<MapEntry<String, List<dynamic>>> categories
  ) {
    return Column(
      children: categories
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSkillCard(context, entry.value.key, entry.value.value, entry.key),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<MapEntry<String, List<dynamic>>> categories,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 280,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index){
        final category = categories[index];
        return _buildSkillCard(context, category.key, category.value, index);
      }
    );
  }

  Widget _buildDesktopGrid(
    BuildContext context,
    List<MapEntry<String, List<dynamic>>> categories,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 265,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildSkillCard(context, category.key, category.value, index);
      }
    );
  }

  Widget _buildSkillCard(BuildContext context, String categoryName, List<dynamic> skills, [int index = 0]) {
    return _SkillCard(categoryName: categoryName, skills: skills, index: index);
  }
}

class _SkillCard extends StatefulWidget {
  final String categoryName;
  final List<dynamic> skills;
  final int index;

  const _SkillCard({
    required this.categoryName,
    required this.skills,
    required this.index,
  });

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final firstSkill = widget.skills.first as SkillModel;
    final icon = MaterialIconMapper.fromCode(firstSkill.iconCode);
    final isDark = AppTheme.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? primary.withAlpha(isDark ? 160 : 200)
                : (isDark
                    ? primary.withAlpha(40)
                    : AppTheme.getBorderColor(context)),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: primary.withAlpha(isDark ? 50 : 35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  )
                ]
              : AppTheme.getCardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _hovered
                        ? primary.withAlpha(isDark ? 50 : 35)
                        : primary.withAlpha(isDark ? 25 : 18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : AppTheme.getBorderColor(context).withAlpha(120),
                    ),
                  ),
                  child: Text(
                    (skill as SkillModel).name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      )
      .animate(delay: Duration(milliseconds: 100 + widget.index * 80))
      .fade(duration: 600.ms)
      .scale(
        begin: const Offset(0.93, 0.93),
        end: const Offset(1, 1),
        duration: 600.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
