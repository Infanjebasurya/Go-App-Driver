import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class FaceGuideOverlay extends StatelessWidget {
  const FaceGuideOverlay({
    super.key,
    required this.showDebugBox,
    required this.normalizedDebugBox,
    required this.statusText,
    required this.progress,
  });

  final bool showDebugBox;
  final Rect? normalizedDebugBox;
  final String statusText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _FaceGuidePainter())),
          if (showDebugBox && normalizedDebugBox != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _DebugBoxPainter(normalizedBox: normalizedDebugBox!),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 28,
            child: _StatusPill(text: statusText, progress: progress),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.progress});

  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: progress <= 0 ? null : progress,
                  strokeWidth: 2.5,
                  color: AppColors.emerald,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  static const double _aspect = 3.5 / 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint scrim = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final Rect full = Offset.zero & size;

    final double guideWidth = size.width * 0.68;
    final double guideHeight = guideWidth / _aspect;
    final Rect guide = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: guideWidth,
      height: guideHeight,
    );

    final RRect oval = RRect.fromRectAndRadius(
      guide,
      Radius.circular(guideWidth),
    );

    final Path mask = Path()
      ..addRect(full)
      ..addRRect(oval)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(mask, scrim);

    final Paint border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = Colors.white.withValues(alpha: 0.85);

    canvas.drawRRect(oval, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DebugBoxPainter extends CustomPainter {
  _DebugBoxPainter({required this.normalizedBox});

  final Rect normalizedBox;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(
      normalizedBox.left * size.width,
      normalizedBox.top * size.height,
      normalizedBox.right * size.width,
      normalizedBox.bottom * size.height,
    );
    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.redAccent.withValues(alpha: 0.9);
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _DebugBoxPainter oldDelegate) {
    return oldDelegate.normalizedBox != normalizedBox;
  }
}
