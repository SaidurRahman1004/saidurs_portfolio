import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets. all(
        ResponsiveWrapper.isMobile(context) ? 16 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildContentStats(context),
          const SizedBox(height: 24),
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Portfolio content statistics and insights',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContentStats(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final visibleSkills = provider.allSkills.where((s) => s.isVisible).length;
        final hiddenSkills = provider.allSkills.length - visibleSkills;

        final visibleProjects = provider.allProjects.where((p) => p.isVisible).length;
        final hiddenProjects = provider. allProjects.length - visibleProjects;
        final featuredProjects = provider.allProjects.where((p) => p.isFeatured).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Skills Stats
            _buildStatCard(
              context,
              title: 'Skills Statistics',
              items: [
                _StatItem('Total Skills', provider.allSkills.length.toString(), AppTheme.primaryColor),
                _StatItem('Visible', visibleSkills.toString(), Colors.green),
                _StatItem('Hidden', hiddenSkills. toString(), Colors.orange),
              ],
            ),

            const SizedBox(height: 16),

            // Projects Stats
            _buildStatCard(
              context,
              title: 'Projects Statistics',
              items:  [
                _StatItem('Total Projects', provider.allProjects. length.toString(), AppTheme.secondaryColor),
                _StatItem('Visible', visibleProjects.toString(), Colors.green),
                _StatItem('Hidden', hiddenProjects.toString(), Colors.orange),
                _StatItem('Featured', featuredProjects.toString(), Colors.amber),
              ],
            ),

            const SizedBox(height: 16),

            // Categories
            _buildCategoriesCard(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required List<_StatItem> items,
      }) {
    return Container(
      padding: const EdgeInsets. all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border. all(color: AppTheme. primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?. copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: items. map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: item.color. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.color.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: Theme. of(context).textTheme.headlineSmall?.copyWith(
                        color: item.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item. label,
                      style: Theme. of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context, PortfolioProvider provider) {
    final categories = provider.allSkills.map((s) => s.category).toSet().toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme. cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final count = provider.allSkills.where((s) => s.category == category).length;
              return Chip(
                label: Text('$category ($count)'),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(color: AppTheme.primaryColor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.secondaryColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Analytics Coming Soon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visitor tracking, page views, and detailed analytics will be added in future updates.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem(this.label, this.value, this.color);
}