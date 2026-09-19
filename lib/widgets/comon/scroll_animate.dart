import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that triggers flutter_animate entrance animations the first time
/// it becomes visible in the viewport. Uses a GlobalKey + post-frame callback
/// approach to detect initial visibility, and a NotificationListener for
/// subsequent scroll-triggered visibility.
class ScrollAnimate extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double slideY;
  final Duration duration;
  final Curve curve;
  final double slideX;
  final double? fromScale;

  const ScrollAnimate({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideY = 0.08,
    this.slideX = 0.0,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.fromScale,
  });

  @override
  State<ScrollAnimate> createState() => _ScrollAnimateState();
}

class _ScrollAnimateState extends State<ScrollAnimate> {
  bool _visible = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_visible || !mounted) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH + 100) {
      if (mounted) setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_visible) _checkVisibility();
        return false;
      },
      child: Builder(
        key: _key,
        builder: (context) {
          if (!_visible) {
            return Opacity(opacity: 0, child: widget.child);
          }
          var animated = widget.child
              .animate(delay: widget.delay)
              .fade(duration: widget.duration, curve: widget.curve)
              .slideY(
                begin: widget.slideY,
                end: 0,
                duration: widget.duration,
                curve: widget.curve,
              );
          if (widget.slideX != 0.0) {
            animated = animated.slideX(
              begin: widget.slideX,
              end: 0,
              duration: widget.duration,
              curve: widget.curve,
            );
          }
          if (widget.fromScale != null) {
            animated = animated.scale(
              begin: Offset(widget.fromScale!, widget.fromScale!),
              end: const Offset(1, 1),
              duration: widget.duration,
              curve: widget.curve,
            );
          }
          return animated;
        },
      ),
    );
  }
}
