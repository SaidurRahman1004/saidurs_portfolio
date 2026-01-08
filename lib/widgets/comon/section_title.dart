import 'package:flutter/material.dart';
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
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          //Text
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge ?.copyWith(
                color: Colors.white,
              ),
              textAlign: centered ? TextAlign.center : TextAlign.left,
            ),
          ),
        ],

        if(subtitle != null)...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: centered ? TextAlign.center : TextAlign.left,
          ),

        ]
      ],
    );
  }
}
