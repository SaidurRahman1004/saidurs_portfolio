import 'package:flutter/material.dart';
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
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSkillCard(context, cat.key, cat.value),
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
        return _buildSkillCard(context, category.key, category.value);
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
        return _buildSkillCard(context, category.key, category.value);
      }
    );
  }

  Widget _buildSkillCard(BuildContext context, String categoryName, List<dynamic> skills) {
    final firstSkill = skills.first as SkillModel;
    final icon = MaterialIconMapper.fromCode(firstSkill.iconCode);
    final isDark = AppTheme.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? primary.withAlpha(40)
              : AppTheme.getBorderColor(context),
        ),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withAlpha(isDark ? 25 : 18),
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
                  categoryName,
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
            children: skills.map((skill) {
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
    );
  }
}
