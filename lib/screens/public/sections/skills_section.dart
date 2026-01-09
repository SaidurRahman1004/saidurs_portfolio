import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 24,
          tablet: 64,
          desktop: 120,
        ),
        vertical: 80,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.3),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: 'My Skills',
            subtitle: 'Technical expertise and tools I use',
          ),
          const SizedBox(height: 60),
          Consumer<PortfolioProvider>(
            builder: (context, provider, child) {
              //loading
              if (provider.isLoadingSkills) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              //error state
              if (provider.errorSkills != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorSkills!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadSkills(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Empty State
              if (provider.skillsByCategory.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'No skills available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              return _buildSkillsGrid(context, provider.skillsByCategory);
            },
          ),
        ],
      ),
    );
  }

  //Skill Cards Grids
  _buildSkillsGrid(
    BuildContext context,
    Map<String, List<dynamic>> skillsByCategory,
  ) {
    //List Of Skills
    final categories = skillsByCategory.entries.toList();
    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, categories),
      tablet: _buildTabletGrid(context, categories),
      desktop: _buildDesktopGrid(context, categories),
    );
  }

  //Mobile Card show
  Widget _buildMobileGrid(
      BuildContext context, List<MapEntry<String, List<dynamic>>> categories
  ) {
    return Column(
      children: categories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSkillCard(context,cat.key, cat.value),
            ),
          )
          .toList(),
    );
  }

  //tablet Card show
  Widget? _buildTabletGrid(
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
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index){
        final category = categories[index];
        return _buildSkillCard(context, category.key, category.value);
      }

    );
  }

  Widget? _buildDesktopGrid(
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
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildSkillCard(context, category.key, category.value);
      }

    );
  }

  Widget _buildSkillCard(BuildContext context, String categoryName, List<dynamic> skills) {
    final firstSkill = skills.first;
    final iconCode = firstSkill.iconCode;
    final icon = IconData(iconCode, fontFamily:  'MaterialIcons');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Icon And Cat
          //Icon and Catagory
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient.scale(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          //Expended
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
