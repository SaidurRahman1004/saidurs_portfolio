import 'package:flutter/material.dart';

import '../../config/theme.dart';

class GradientButton extends StatefulWidget {
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
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.getPrimaryColor(context);
    final gradient = AppTheme.getPrimaryGradient(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.isOutlined
              ? (_isHovered ? primaryColor.withAlpha(25) : null) != null
                  ? LinearGradient(colors: [primaryColor.withAlpha(20), primaryColor.withAlpha(10)])
                  : null
              : gradient,
          borderRadius: BorderRadius.circular(14),
          border: widget.isOutlined
              ? Border.all(
                  color: _isHovered ? primaryColor : primaryColor.withAlpha(180),
                  width: 1.8,
                )
              : null,
          boxShadow: [
            if (!widget.isOutlined)
              BoxShadow(
                color: primaryColor.withAlpha(_isHovered ? 90 : 50),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 6 : 3),
              )
            else if (_isHovered)
              BoxShadow(
                color: primaryColor.withAlpha(35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 19,
                      color: widget.isOutlined ? primaryColor : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: widget.isOutlined
                              ? primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
