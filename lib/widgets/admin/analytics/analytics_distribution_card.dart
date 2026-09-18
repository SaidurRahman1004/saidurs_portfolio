import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/analytics_report_models.dart';

/// Reusable card displaying distribution breakdowns (Devices, Browsers, Geography, Sources)
/// using clean proportional horizontal progress bars and percentages.
class AnalyticsDistributionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<AnalyticsBreakdownItem> items;
  final String emptyMessage;
  final Color? accentColor;
  final int maxItems;

  const AnalyticsDistributionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.emptyMessage = 'No distribution data available for this range.',
    this.accentColor,
    this.maxItems = 6,
  });

  IconData _getLeadingIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('desktop')) return Icons.computer_rounded;
    if (lower.contains('mobile')) return Icons.phone_android_rounded;
    if (lower.contains('tablet')) return Icons.tablet_mac_rounded;
    if (lower.contains('chrome')) return Icons.public_rounded;
    if (lower.contains('safari')) return Icons.explore_rounded;
    if (lower.contains('firefox')) return Icons.local_fire_department_rounded;
    if (lower.contains('edge')) return Icons.language_rounded;
    if (lower.contains('direct')) return Icons.input_rounded;
    if (lower.contains('organic') || lower.contains('google')) return Icons.search_rounded;
    if (lower.contains('social') || lower.contains('linkedin') || lower.contains('github')) {
      return Icons.share_rounded;
    }
    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primary = accentColor ?? AppTheme.getPrimaryColor(context);

    final displayItems = items.take(maxItems).toList();
    final totalCount = displayItems.fold<int>(0, (sum, item) => sum + item.count);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (totalCount > 0)
                Text(
                  '$totalCount total',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (displayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final percent = item.percentage.clamp(0.0, 100.0);
                final itemIcon = _getLeadingIcon(item.label);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(itemIcon, size: 14, color: textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.label.isEmpty ? 'Unknown' : item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.count}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 44,
                          child: Text(
                            item.formattedPercentage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: borderColor.withOpacity(0.4),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          index == 0
                              ? primary
                              : primary.withOpacity(0.55 + ((displayItems.length - index) * 0.08).clamp(0.0, 0.45)),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
