import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/analytics_report_models.dart';

/// Interactive, GPU-accelerated timeseries chart for traffic metrics over time.
/// Supports switching between Active Users, Page Views, and Sessions.
class AnalyticsTimeseriesChart extends StatefulWidget {
  final List<AnalyticsTimeseriesPoint> points;
  final String activeMetric; // 'activeUsers', 'screenPageViews', 'sessions'
  final Function(String) onMetricChanged;
  final int newUsers;
  final int totalActiveUsers;

  const AnalyticsTimeseriesChart({
    super.key,
    required this.points,
    required this.activeMetric,
    required this.onMetricChanged,
    this.newUsers = 0,
    this.totalActiveUsers = 0,
  });

  @override
  State<AnalyticsTimeseriesChart> createState() => _AnalyticsTimeseriesChartState();
}

class _AnalyticsTimeseriesChartState extends State<AnalyticsTimeseriesChart> {
  int? _hoveredIndex;

  int _getValue(AnalyticsTimeseriesPoint point) {
    switch (widget.activeMetric) {
      case 'screenPageViews':
        return point.screenPageViews;
      case 'sessions':
        return point.sessions;
      case 'activeUsers':
      default:
        return point.activeUsers;
    }
  }

  String _getMetricTitle() {
    switch (widget.activeMetric) {
      case 'screenPageViews':
        return 'Screen Page Views';
      case 'sessions':
        return 'Total Sessions';
      case 'activeUsers':
      default:
        return 'Active Users (GA4)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    final values = widget.points.map(_getValue).toList();
    final maxValue = values.isEmpty ? 10 : math.max(values.reduce(math.max), 5);
    final totalMetricSum = values.fold<int>(0, (a, b) => a + b);

    final returningUsers = math.max(0, widget.totalActiveUsers - widget.newUsers);
    final newPercent = widget.totalActiveUsers > 0
        ? ((widget.newUsers / widget.totalActiveUsers) * 100).round()
        : 0;
    final returnPercent = widget.totalActiveUsers > 0 ? 100 - newPercent : 0;

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
          // Header & Metric Switcher
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Traffic Over Time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total ${_getMetricTitle()}: $totalMetricSum',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                ],
              );

              final buttonsWidget = Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildMetricButton(
                    context,
                    label: 'Users',
                    metricKey: 'activeUsers',
                    icon: Icons.people_outline_rounded,
                    primaryColor: primaryColor,
                  ),
                  _buildMetricButton(
                    context,
                    label: 'Page Views',
                    metricKey: 'screenPageViews',
                    icon: Icons.visibility_outlined,
                    primaryColor: primaryColor,
                  ),
                  _buildMetricButton(
                    context,
                    label: 'Sessions',
                    metricKey: 'sessions',
                    icon: Icons.play_circle_outline_rounded,
                    primaryColor: primaryColor,
                  ),
                ],
              );

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: 12),
                        buttonsWidget,
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: titleWidget),
                        buttonsWidget,
                      ],
                    );
            },
          ),

          const SizedBox(height: 16),

          // User Loyalty Segment Indicator (New vs Returning)
          if (widget.totalActiveUsers > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New Users: ${widget.newUsers} ($newPercent%)  •  Returning Users: $returningUsers ($returnPercent%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Chart Canvas
          if (widget.points.isEmpty)
            Container(
              height: 220,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart_outlined_rounded, size: 40, color: textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'No traffic datapoints recorded for this time window.',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 240,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    onHover: (event) {
                      final width = constraints.maxWidth - 50; // account for left axis
                      final step = width / math.max(1, widget.points.length - 1);
                      final localX = (event.localPosition.dx - 40).clamp(0.0, width);
                      final index = (localX / step).round().clamp(0, widget.points.length - 1);
                      if (_hoveredIndex != index) {
                        setState(() => _hoveredIndex = index);
                      }
                    },
                    onExit: (_) {
                      setState(() => _hoveredIndex = null);
                    },
                    child: GestureDetector(
                      onTapDown: (details) {
                        final width = constraints.maxWidth - 50;
                        final step = width / math.max(1, widget.points.length - 1);
                        final localX = (details.localPosition.dx - 40).clamp(0.0, width);
                        final index = (localX / step).round().clamp(0, widget.points.length - 1);
                        setState(() => _hoveredIndex = index);
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, 240),
                        painter: _TimeseriesChartPainter(
                          points: widget.points,
                          values: values,
                          maxValue: maxValue,
                          hoveredIndex: _hoveredIndex,
                          primaryColor: primaryColor,
                          textSecondary: textSecondary,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Hovered Data readout tooltip pill
          if (_hoveredIndex != null && _hoveredIndex! < widget.points.length)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      widget.points[_hoveredIndex!].formattedDate,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_getMetricTitle()}: ${_getValue(widget.points[_hoveredIndex!])}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: textPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricButton(
    BuildContext context, {
    required String label,
    required String metricKey,
    required IconData icon,
    required Color primaryColor,
  }) {
    final isSelected = widget.activeMetric == metricKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: () => widget.onMetricChanged(metricKey),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black87 : AppTheme.getTextSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black87 : AppTheme.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeseriesChartPainter extends CustomPainter {
  final List<AnalyticsTimeseriesPoint> points;
  final List<int> values;
  final int maxValue;
  final int? hoveredIndex;
  final Color primaryColor;
  final Color textSecondary;
  final Color borderColor;
  final bool isDark;

  _TimeseriesChartPainter({
    required this.points,
    required this.values,
    required this.maxValue,
    required this.hoveredIndex,
    required this.primaryColor,
    required this.textSecondary,
    required this.borderColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 42.0;
    const bottomPadding = 26.0;
    const topPadding = 16.0;
    final chartWidth = size.width - leftPadding - 16;
    final chartHeight = size.height - bottomPadding - topPadding;

    // Draw Y-axis horizontal grid lines & labels (3 levels: 0, max/2, max)
    final gridPaint = Paint()
      ..color = borderColor.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final levels = [0, (maxValue / 2).round(), maxValue];
    for (final level in levels) {
      final y = topPadding + chartHeight - ((level / maxValue) * chartHeight);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - 16, y),
        gridPaint,
      );

      final textSpan = TextSpan(
        text: '$level',
        style: TextStyle(
          color: textSecondary.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - (tp.height / 2)));
    }

    // Calculate (x, y) coordinates for all points
    final count = points.length;
    final stepX = count <= 1 ? 0.0 : chartWidth / (count - 1);
    final coords = <Offset>[];

    for (int i = 0; i < count; i++) {
      final x = count <= 1 ? leftPadding + (chartWidth / 2) : leftPadding + (i * stepX);
      final val = values[i];
      final y = topPadding + chartHeight - ((val / maxValue) * chartHeight);
      coords.add(Offset(x, y));
    }

    // Build gradient fill path under the line
    if (coords.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(coords.first.dx, topPadding + chartHeight);
      fillPath.lineTo(coords.first.dx, coords.first.dy);

      for (int i = 1; i < coords.length; i++) {
        final p0 = coords[i - 1];
        final p1 = coords[i];
        final midX = (p0.dx + p1.dx) / 2;
        fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(coords.last.dx, topPadding + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.35),
            primaryColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw main stroke line
    final strokePath = Path();
    if (coords.isNotEmpty) {
      strokePath.moveTo(coords.first.dx, coords.first.dy);
      for (int i = 1; i < coords.length; i++) {
        final p0 = coords[i - 1];
        final p1 = coords[i];
        final midX = (p0.dx + p1.dx) / 2;
        strokePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      final strokePaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(strokePath, strokePaint);
    }

    // Draw X-axis date labels (sample every few points to avoid crowding)
    final labelInterval = math.max(1, (count / 6).ceil());
    for (int i = 0; i < count; i += labelInterval) {
      final pt = points[i];
      final coord = coords[i];
      final textSpan = TextSpan(
        text: pt.formattedDate,
        style: TextStyle(
          color: textSecondary.withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(coord.dx - (tp.width / 2), size.height - bottomPadding + 6));
    }

    // Draw Hover Highlight vertical line and marker circle
    if (hoveredIndex != null && hoveredIndex! < coords.length) {
      final hCoord = coords[hoveredIndex!];

      // Vertical guide line
      final hoverLinePaint = Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hCoord.dx, topPadding),
        Offset(hCoord.dx, topPadding + chartHeight),
        hoverLinePaint,
      );

      // Outer halo
      final haloPaint = Paint()
        ..color = primaryColor.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hCoord, 7.0, haloPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hCoord, 4.0, dotPaint);

      final centerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hCoord, 2.0, centerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _TimeseriesChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.primaryColor != primaryColor;
  }
}
