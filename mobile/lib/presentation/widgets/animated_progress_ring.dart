import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedProgressRing extends StatelessWidget {
  final double progress;
  final Duration duration;
  final Color? color;
  final double strokeWidth;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    required this.duration,
    this.color,
    this.strokeWidth = 8.0,
  }) : assert(progress >= 0 && progress <= 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = color ?? theme.colorScheme.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Anel de fundo
            CustomPaint(
              size: const Size.fromRadius(40),
              painter: _ProgressRingPainter(
                progress: 1.0,
                color: theme.colorScheme.surfaceVariant,
                strokeWidth: strokeWidth,
              ),
            ),
            // Anel de progresso animado
            CustomPaint(
              size: const Size.fromRadius(40),
              painter: _ProgressRingPainter(
                progress: value,
                color: ringColor,
                strokeWidth: strokeWidth,
              ),
            ),
            // Texto de porcentagem
            Center(
              child: Text(
                '${(value * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Começa do topo
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
