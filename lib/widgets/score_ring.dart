import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/responsive.dart';

/// Animated circular score visual. The arc colour reflects performance and
/// the number is always shown in text, so meaning never relies on colour alone.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.caption = 'dari 100',
    this.diameter,
  });

  final int score;
  final String caption;
  final double? diameter;

  @override
  Widget build(BuildContext context) {
    final size =
        diameter ??
        (context.rw(0.56)).clamp(context.rs(150), context.rs(240));
    final normalized = score.clamp(0, 100) / 100;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    final colors = switch (score) {
      >= 80 => <Color>[palette.success, const Color(0xFF29B6A0)],
      >= 60 => <Color>[scheme.secondary, const Color(0xFFF28A0F)],
      _ => <Color>[scheme.error, const Color(0xFFF08A6C)],
    };

    return Semantics(
      label: 'Skor $score dari 100',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: normalized),
        duration: const Duration(milliseconds: 1050),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          return SizedBox.square(
            dimension: size,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  progress: progress,
                  trackColor: palette.softPrimary,
                  colors: colors,
                  strokeWidth: size * 0.075,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$score',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: size * 0.27,
                              color: colors.first,
                              height: 1,
                            ),
                      ),
                      SizedBox(height: context.rs(4)),
                      Text(
                        caption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.colors,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Compact metric tile used on the result page and history summary.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final color = accent ?? scheme.primary;

    return Container(
      padding: EdgeInsets.all(context.rs(14)),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.rs(18)),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: context.rs(38),
            height: context.rs(38),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(context.rs(12)),
            ),
            child: Icon(icon, size: context.rs(19), color: color),
          ),
          SizedBox(width: context.rs(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  caption ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
