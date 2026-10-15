import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A crisp, vector-rendered Brazilian flag icon.
class BrazilFlagIcon extends StatelessWidget {
  const BrazilFlagIcon({
    super.key,
    this.width = 20,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.5),
      child: CustomPaint(
        size: Size(width, height),
        painter: _BrazilFlagPainter(),
      ),
    );
  }
}

class _BrazilFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Green background
    final greenPaint = Paint()..color = const Color(0xFF009B3A);
    canvas.drawRect(Offset.zero & size, greenPaint);

    // 2. Yellow diamond (rhombus)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFEDF00)
      ..style = PaintingStyle.fill;
    final diamondPath = Path()
      ..moveTo(size.width / 2, size.height * 0.12)
      ..lineTo(size.width * 0.88, size.height / 2)
      ..lineTo(size.width / 2, size.height * 0.88)
      ..lineTo(size.width * 0.12, size.height / 2)
      ..close();
    canvas.drawPath(diamondPath, yellowPaint);

    // 3. Blue celestial globe
    final bluePaint = Paint()..color = const Color(0xFF002776);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * 0.25;
    canvas.drawCircle(center, radius, bluePaint);

    // 4. White curved band
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.055;
    final bandPath = Path();
    bandPath.addArc(
      Rect.fromCircle(
        center: Offset(center.dx - radius * 0.15, center.dy + radius * 0.45),
        radius: radius * 1.05,
      ),
      -math.pi * 0.72,
      math.pi * 0.44,
    );
    canvas.drawPath(bandPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A crisp, vector-rendered United States flag icon.
class UsaFlagIcon extends StatelessWidget {
  const UsaFlagIcon({
    super.key,
    this.width = 20,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.5),
      child: CustomPaint(
        size: Size(width, height),
        painter: _UsaFlagPainter(),
      ),
    );
  }
}

class _UsaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Red background
    final redPaint = Paint()..color = const Color(0xFFB22234);
    canvas.drawRect(Offset.zero & size, redPaint);

    // 2. White stripes (7 red, 6 white = 13 stripes total)
    final whitePaint = Paint()..color = Colors.white;
    final stripeHeight = size.height / 13;
    for (var i = 1; i < 13; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        whitePaint,
      );
    }

    // 3. Blue canton (covers 7 stripes, 42% width)
    final bluePaint = Paint()..color = const Color(0xFF3C3B6E);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.42, stripeHeight * 7),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
