import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class HighlightsSection extends StatelessWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final experienceDuration =
        context.watch<PortfolioProvider>().experienceDuration;

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 60),
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
    final primary = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered
              ? primary.withAlpha(20)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? primary.withAlpha(120)
                : primary.withAlpha(51),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: primary.withAlpha(35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: primary, size: 26),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                fontSize: 12,
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

