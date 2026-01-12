import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveWrapper.isMobile(context) ? 16 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Welcome Section
          _buildWelcomeSection(context),

          const SizedBox(height: 32),

          /// Statistics Cards
          _buildStatisticsSection(context),

          const SizedBox(height: 32),

          /// Quick Actions
          _buildQuickActions(context),

          const SizedBox(height: 32),

          /// Recent Activity (placeholder)
           _buildRecentActivity(context),

        ],
      ),
    );
  }

  //Welcom Section
  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient.scale(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [

              /// Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient.scale(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waving_hand,
                  size: 32,
                  color: Colors.amber,
                ),
              ),

              const SizedBox(width: 20),

              /// Welcome text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${adminProvider.userDisplayName}!',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your portfolio content from here',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //Statistics Section

  Widget _buildStatisticsSection(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        return ResponsiveWrapper(
          mobile: _buildStatsGridMobile(context, portfolioProvider),
          desktop: _buildStatsGridDesktop(context, portfolioProvider),
        );
      },
    );
  }

  // Desktop stats grid (3 columns)
  Widget _buildStatsGridDesktop(BuildContext context,
      PortfolioProvider portfolioProvider) {
    return Row(
      children: [
      ],
    );
  }

  // Individual stat card
  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border. all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.trending_up, color: Colors.green, size: 20),
            ],
          ),

          const SizedBox(height:  16),

          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
              fontWeight:  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Mobile stats grid (1 column)
  Widget _buildStatsGridMobile(BuildContext context,
      PortfolioProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height:  16),

        ResponsiveWrapper(
          mobile:  _buildQuickActionsMobile(context),
          desktop: _buildQuickActionsDesktop(context),
        ),
      ],
    );

  }
  //Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height:  16),

        ResponsiveWrapper(
          mobile:  _buildQuickActionsMobile(context),
          desktop: _buildQuickActionsDesktop(context),
        ),
      ],
    );
  }

  Widget _buildQuickActionsDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_circle_outline,
            title: 'Add New Skill',
            subtitle: 'Add a new skill to your portfolio',
            color: AppTheme.primaryColor,
            onTap: () {
              // Navigate to skills tab
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.work_outline,
            title: 'Add New Project',
            subtitle: 'Showcase your latest work',
            color: AppTheme.secondaryColor,
            onTap: () {
              // Navigate to projects tab
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsMobile(BuildContext context) {
    return Column(
      children:  [
        _buildActionCard(
          context,
          icon:  Icons.add_circle_outline,
          title: 'Add New Skill',
          subtitle: 'Add a new skill to your portfolio',
          color: AppTheme.primaryColor,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          icon: Icons. work_outline,
          title:  'Add New Project',
          subtitle: 'Showcase your latest work',
          color: AppTheme.secondaryColor,
          onTap: () {},
        ),
      ],
    );
  }

  //Action Card
  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets. all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border. all(
            color: color. withOpacity(0.3),
          ),
        ),
        child: Row(
          children:  [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width:  16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  Text(
                    title,
                    style: Theme. of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme. of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme. textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }





  //Recent Activites

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme. primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height:  16),

          Text(
            'Activity tracking coming soon...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
