import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

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
            title: 'About Me',
            subtitle: 'Learn more about my journey and expertise',
          ),
          const SizedBox(height: 60),
          _buildSkillsGrid(context),
        ],
      ),
    );
  }

  //Skill Cards Grids
  _buildSkillsGrid(BuildContext context) {
    //List Of Skills
    final skillCategories = [
      {
        'category': 'Mobile Development',
        'icon': Icons.phone_android,
        'skills': ['Flutter', 'Dart', 'Kotlin (Basic)', 'Android'],
      },
      {
        'category': 'Backend & APIs',
        'icon': Icons.dns_outlined,
        'skills': ['Django (Learning)', 'REST API', 'Firebase', 'JWT Auth'],
      },
      {
        'category': 'State Management',
        'icon': Icons.settings_outlined,
        'skills': ['Provider', 'GetX', 'Riverpod', 'Cubit'],
      },
      {
        'category': 'Database',
        'icon': Icons.storage_outlined,
        'skills': ['Firestore', 'Hive', 'Shared Preferences', 'SQLite'],
      },
      {
        'category': 'Programming',
        'icon': Icons.code,
        'skills': ['Python', 'Java', 'JavaScript', 'HTML/CSS'],
      },
      {
        'category': 'Tools & Others',
        'icon': Icons.build_outlined,
        'skills': ['Git/GitHub', 'VS Code', 'Android Studio', 'Postman'],
      },
    ];
    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, skillCategories),
      tablet: _buildTabletGrid(context, skillCategories),
      desktop: _buildDesktopGrid(context, skillCategories),
    );
  }

  //Mobile Card show
  Widget _buildMobileGrid(
    BuildContext context,
    List<Map<String, dynamic>> categories,
  ) {
    return Column(
      children: categories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSkillCard(context, cat),
            ),
          )
          .toList(),
    );
  }

  //tablet Card show
  Widget? _buildTabletGrid(
    BuildContext context,
    List<Map<String, dynamic>> categories,
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
      itemBuilder: (context, index) =>
          _buildSkillCard(context, categories[index]),
    );
  }

  Widget? _buildDesktopGrid(
    BuildContext context,
    List<Map<String, dynamic>> categories,
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
      itemBuilder: (context, index) =>
          _buildSkillCard(context, categories[index]),
    );
  }

  Widget _buildSkillCard(BuildContext context, Map<String, dynamic> category) {
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
                  category['icon'] as IconData,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category['category'] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: (category['skills'] as List<String>).map((skill) {
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
