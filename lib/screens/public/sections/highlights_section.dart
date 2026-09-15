import 'package:flutter/material.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class HighlightsSection extends StatelessWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = MediaQuery.of(context).size.width < 600;
            int crossAxisCount = isMobile ? 2 : 4;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.2 : 1.5,
              children: const [
                _HighlightCard(
                  title: '6+ Months',
                  subtitle: 'Professional Experience',
                  icon: Icons.work_outline,
                ),
                _HighlightCard(
                  title: 'Production',
                  subtitle: 'App Experience',
                  icon: Icons.verified_user_outlined,
                ),
                _HighlightCard(
                  title: 'Stores',
                  subtitle: 'Play Store & App Store',
                  icon: Icons.store_outlined,
                ),
                _HighlightCard(
                  title: 'Flutter',
                  subtitle: 'Primary Specialization',
                  icon: Icons.code_outlined,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HighlightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

