import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

class SurgeMapWidget extends StatelessWidget {
  const SurgeMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(painter: _MapPainter(), child: Container()),
        const Positioned(
          top: 60,
          left: 60,
          child: _SurgeBlob(size: 180, opacity: 0.18),
        ),
        const Positioned(
          top: 30,
          right: 40,
          child: _SurgeBlob(size: 120, opacity: 0.12),
        ),
        const Positioned(top: 130, left: 90, child: _SurgeDot()),
        const Positioned(top: 170, left: 180, child: _SurgeDot()),
        const Positioned(top: 90, right: 80, child: _SurgeDot()),
        const Positioned(top: 170, right: 30, child: _SurgeDot()),
        const Positioned(top: 200, right: 100, child: _SurgeDot()),
        Positioned(
          right: 12,
          bottom: 70,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: Color(0xFF555555),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SurgeBlob extends StatelessWidget {
  const _SurgeBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthUiColors.brandGreen.withValues(alpha: opacity),
      ),
    );
  }
}

class _SurgeDot extends StatelessWidget {
  const _SurgeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AuthUiColors.brandGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final rng = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final path = Path();
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      path.moveTo(sx, sy);
      final ex = sx + (rng.nextDouble() - 0.4) * 200;
      final ey = sy + (rng.nextDouble() - 0.4) * 200;
      final cx = (sx + ex) / 2 + (rng.nextDouble() - 0.5) * 60;
      final cy = (sy + ey) / 2 + (rng.nextDouble() - 0.5) * 60;
      path.quadraticBezierTo(cx, cy, ex, ey);
      paint.strokeWidth = rng.nextDouble() < 0.3 ? 3.0 : 1.5;
      canvas.drawPath(path, paint);
    }

    final blockPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..style = PaintingStyle.fill;
    final rng2 = math.Random(7);
    for (int i = 0; i < 12; i++) {
      final x = rng2.nextDouble() * size.width;
      final y = rng2.nextDouble() * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            y,
            20 + rng2.nextDouble() * 35,
            15 + rng2.nextDouble() * 25,
          ),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
