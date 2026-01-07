import 'package:flutter/material.dart';

import '../../config/theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isOutlined ? null : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        border: isOutlined
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isOutlined
                        ? AppTheme.primaryColor
                        : AppTheme.darkBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
