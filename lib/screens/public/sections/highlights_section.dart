import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class HighlightsSection extends StatelessWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final experienceDuration =
        context.watch<PortfolioProvider>().experienceDuration;
    final isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : const Color(0xFFF8FAFC),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.getBorderColor(context).withAlpha(140),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: ResponsiveContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int crossAxisCount;
            if (width < 360) {
              crossAxisCount = 1;
            } else if (width < 900) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 4;
            }

            final items = [
              _HighlightCard(
                title: experienceDuration,
                subtitle: 'Professional Experience',
                icon: Icons.work_outline,
              ),
              const _HighlightCard(
                title: 'Production',
                subtitle: 'App Experience',
                icon: Icons.verified_user_outlined,
              ),
              const _HighlightCard(
                title: 'Stores',
                subtitle: 'Play Store & App Store',
                icon: Icons.store_outlined,
              ),
              const _HighlightCard(
                title: 'Flutter',
                subtitle: 'Primary Specialization',
                icon: Icons.code_outlined,
              ),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 155,
              ),
              itemBuilder: (context, index) => items[index],
            );
          },
        ),
      ),
    );
  }
}

class _HighlightCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HighlightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovered
              ? (isDark ? primary.withAlpha(20) : Colors.white)
              : (isDark ? Theme.of(context).cardColor : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? primary.withAlpha(isDark ? 140 : 180)
                : AppTheme.getBorderColor(context),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: primary.withAlpha(isDark ? 40 : 30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppTheme.getCardShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withAlpha(isDark ? 25 : 18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: primary, size: 26),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

