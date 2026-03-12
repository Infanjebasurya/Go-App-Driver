import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class FaceOverlay extends StatelessWidget {
  const FaceOverlay({
    super.key,
    required this.guidanceText,
    required this.isAutoCapturing,
  });

  final String guidanceText;
  final bool isAutoCapturing;

  static const double _aspect = 3.5 / 4.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;
        final Rect guideRect = _guideRectFor(size);

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _FaceOverlayPainter(guideRect: guideRect),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 28,
              child: _OverlayLabel(
                title: guidanceText,
                subtitle: isAutoCapturing ? 'Auto capturing…' : 'Auto capture when aligned',
              ),
            ),
          ],
        );
      },
    );
  }

  Rect _guideRectFor(Size size) {
    final double w = size.width;
    final double h = size.height;

    double guideW = w * 0.70;
    double guideH = guideW / _aspect;

    final double maxH = h * 0.74;
    if (guideH > maxH) {
      guideH = maxH;
      guideW = guideH * _aspect;
    }

    return Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: guideW,
      height: guideH,
    );
  }
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.black60,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.white70),
          ),
        ],
      ),
    );
  }
}

class _FaceOverlayPainter extends CustomPainter {
  _FaceOverlayPainter({required this.guideRect});

  final Rect guideRect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint scrim = Paint()..color = AppColors.overlayScrim;
    final Paint border = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Rect full = Offset.zero & size;
    final Path hole = Path()..addOval(guideRect);
    final Path overlay = Path()..addRect(full);
    final Path masked = Path.combine(PathOperation.difference, overlay, hole);
    canvas.drawPath(masked, scrim);
    canvas.drawOval(guideRect, border);
  }

  @override
  bool shouldRepaint(covariant _FaceOverlayPainter oldDelegate) {
    return oldDelegate.guideRect != guideRect;
  }
}

