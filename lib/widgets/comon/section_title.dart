import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centered;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        //Line upper of Text
        if (centered) ...[
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(2),
            ),
          )
          .animate()
          .fade(duration: 400.ms)
          .scaleX(
            begin: 0,
            end: 1,
            duration: 600.ms,
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 16),
          //Text
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.getPrimaryGradient(context).createShader(bounds),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: centered ? TextAlign.center : TextAlign.left,
            ),
          )
          .animate(delay: 150.ms)
          .fade(duration: 600.ms)
          .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],

        if(subtitle != null)...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: centered ? TextAlign.center : TextAlign.left,
          )
          .animate(delay: 280.ms)
          .fade(duration: 500.ms)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
        ]
      ],
    );
  }
}
