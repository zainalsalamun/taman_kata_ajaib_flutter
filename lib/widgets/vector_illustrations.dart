import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 1. MASCOT "MIKO" VECTOR WIDGET
class MascotWidget extends StatelessWidget {
  final double size;
  const MascotWidget({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MascotPainter(),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = const Color(0xFFD84315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;

    final earPaint = Paint()
      ..color = const Color(0xFFFF8A65)
      ..style = PaintingStyle.fill;

    final innerEarPaint = Paint()
      ..color = const Color(0xFFFFCCBC)
      ..style = PaintingStyle.fill;

    // Left Ear
    final leftEar = Path()..moveTo(16, 38)..lineTo(24, 10)..lineTo(44, 28)..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(leftEar, strokePaint);
    final leftInner = Path()..moveTo(22, 32)..lineTo(28, 18)..lineTo(38, 26)..close();
    canvas.drawPath(leftInner, innerEarPaint);

    // Right Ear
    final rightEar = Path()..moveTo(84, 38)..lineTo(76, 10)..lineTo(56, 28)..close();
    canvas.drawPath(rightEar, earPaint);
    canvas.drawPath(rightEar, strokePaint);
    final rightInner = Path()..moveTo(78, 32)..lineTo(72, 18)..lineTo(62, 26)..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // Head Base
    final headPaint = Paint()..color = const Color(0xFFFFA726);
    canvas.drawOval(const Rect.fromLTWH(12, 22, 76, 68), headPaint);
    canvas.drawOval(const Rect.fromLTWH(12, 22, 76, 68), Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5);

    // White Muzzle
    final muzzlePaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawOval(const Rect.fromLTWH(30, 49, 40, 32), muzzlePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF263238);
    final eyeSparkle = Paint()..color = Colors.white;
    canvas.drawOval(const Rect.fromLTWH(30, 42, 12, 16), eyePaint);
    canvas.drawCircle(const Offset(34, 47), 2.5, eyeSparkle);
    canvas.drawOval(const Rect.fromLTWH(58, 42, 12, 16), eyePaint);
    canvas.drawCircle(const Offset(62, 47), 2.5, eyeSparkle);

    // Nose & Mouth
    final nosePath = Path()..moveTo(46, 60)..lineTo(54, 60)..lineTo(50, 65)..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFFF7043));
    final mouthPaint = Paint()
      ..color = const Color(0xFFD84315)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(44, 68)
      ..quadraticBezierTo(50, 73, 50, 66)
      ..quadraticBezierTo(50, 73, 56, 68);
    canvas.drawPath(mouthPath, mouthPaint);

    // Blush Cheeks
    final blushPaint = Paint()..color = const Color(0x99FF8A80);
    canvas.drawCircle(const Offset(26, 60), 5.5, blushPaint);
    canvas.drawCircle(const Offset(74, 60), 5.5, blushPaint);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xFFBF360C)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14, 56), const Offset(28, 58), whiskerPaint);
    canvas.drawLine(const Offset(14, 64), const Offset(28, 63), whiskerPaint);
    canvas.drawLine(const Offset(86, 56), const Offset(72, 58), whiskerPaint);
    canvas.drawLine(const Offset(86, 64), const Offset(72, 63), whiskerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// 2. LEARNING OBJECT ILLUSTRATION WIDGET
class ObjectIllustrationWidget extends StatelessWidget {
  final String illustrationKey;
  final double size;

  const ObjectIllustrationWidget({
    super.key,
    required this.illustrationKey,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ObjectPainter(illustrationKey),
      ),
    );
  }
}

typedef VectorIllustrationWidget = ObjectIllustrationWidget;

class _ObjectPainter extends CustomPainter {
  final String key;
  _ObjectPainter(this.key);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    switch (key.toLowerCase()) {
      case 'apel':
        _drawApple(canvas);
        break;
      case 'balon':
        _drawBalloon(canvas);
        break;
      case 'ceri':
        _drawCherry(canvas);
        break;
      case 'domba':
        _drawSheep(canvas);
        break;
      case 'bola':
        _drawSoccerBall(canvas);
        break;
      case 'buku':
        _drawBook(canvas);
        break;
      case 'roti':
        _drawBread(canvas);
        break;
      case 'kucing':
        _drawKitten(canvas);
        break;
      case 'mobil':
        _drawCar(canvas);
        break;
      case 'kuda':
        _drawHorse(canvas);
        break;
      case 'mata':
        _drawEyes(canvas);
        break;
      case 'pisang':
        _drawBanana(canvas);
        break;
      case 'rumah':
        _drawHouse(canvas);
        break;
      case 'ikan':
        _drawFish(canvas);
        break;
      case 'jeruk':
        _drawOrange(canvas);
        break;
      case 'topi':
        _drawHat(canvas);
        break;
      case 'sepatu':
        _drawShoe(canvas);
        break;
      case 'pesawat':
        _drawPlane(canvas);
        break;
      case 'sepeda':
        _drawBicycle(canvas);
        break;
      default:
        _drawSmartBadge(canvas, key);
    }

    canvas.restore();
  }

  void _drawApple(Canvas canvas) {
    final twig = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 4.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 28), const Offset(60, 10), twig);
    final leaf = Path()..moveTo(54, 18)..quadraticBezierTo(76, 14, 78, 24)..quadraticBezierTo(62, 26, 54, 18);
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF4CAF50));

    final apple = Path()
      ..moveTo(50, 32)
      ..cubicTo(38, 24, 20, 28, 16, 46)
      ..cubicTo(12, 68, 28, 90, 48, 90)
      ..cubicTo(50, 90, 52, 87, 50, 87)
      ..cubicTo(48, 87, 50, 90, 52, 90)
      ..cubicTo(72, 90, 88, 68, 84, 46)
      ..cubicTo(80, 28, 62, 24, 50, 32);
    canvas.drawPath(apple, Paint()..color = const Color(0xFFE53935));
    canvas.drawPath(apple, Paint()..color = const Color(0xFFB71C1C)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    canvas.save();
    canvas.translate(32, 46);
    canvas.rotate(-20 * math.pi / 180);
    canvas.drawOval(const Rect.fromLTWH(-6, -12, 12, 24), Paint()..color = const Color(0x66FFFFFF));
    canvas.restore();
  }

  void _drawBalloon(Canvas canvas) {
    final balPaint = Paint()..color = const Color(0xFFFF4081);
    canvas.drawOval(const Rect.fromLTWH(20, 6, 60, 72), balPaint);
    canvas.drawOval(const Rect.fromLTWH(20, 6, 60, 72), Paint()..color = const Color(0xFFC2185B)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    final stringPath = Path()..moveTo(50, 83)..quadraticBezierTo(45, 90, 52, 96);
    canvas.drawPath(stringPath, Paint()..color = const Color(0xFF78909C)..strokeWidth = 2.5..style = PaintingStyle.stroke);

    canvas.save();
    canvas.translate(35, 30);
    canvas.rotate(-25 * math.pi / 180);
    canvas.drawOval(const Rect.fromLTWH(-5, -10, 10, 20), Paint()..color = const Color(0x88FFFFFF));
    canvas.restore();
  }

  void _drawCherry(Canvas canvas) {
    final stem = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(34, 65), const Offset(66, 12), stem);
    canvas.drawLine(const Offset(68, 70), const Offset(66, 12), stem);

    final leaf = Path()..moveTo(66, 12)..quadraticBezierTo(86, 16, 84, 28)..quadraticBezierTo(70, 26, 66, 12);
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF4CAF50));

    canvas.drawCircle(const Offset(34, 65), 18, Paint()..color = const Color(0xFFD32F2F));
    canvas.drawCircle(const Offset(34, 65), 18, Paint()..color = const Color(0xFFB71C1C)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(const Offset(28, 59), 4.5, Paint()..color = const Color(0x88FFFFFF));

    canvas.drawCircle(const Offset(68, 70), 18, Paint()..color = const Color(0xFFC2185B));
    canvas.drawCircle(const Offset(68, 70), 18, Paint()..color = const Color(0xFF880E4F)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(const Offset(62, 64), 4.5, Paint()..color = const Color(0x88FFFFFF));
  }

  void _drawSheep(Canvas canvas) {
    final legPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 70, 8, 18), const Radius.circular(4)), legPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(62, 70, 8, 18), const Radius.circular(4)), legPaint);

    final wool = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawCircle(const Offset(34, 54), 16, wool);
    canvas.drawCircle(const Offset(64, 54), 16, wool);
    canvas.drawCircle(const Offset(48, 42), 18, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(48, 62), 18, wool);

    canvas.drawOval(const Rect.fromLTWH(34, 36, 28, 24), Paint()..color = const Color(0xFFFFE0B2));
    canvas.drawCircle(const Offset(43, 47), 2.5, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(const Offset(53, 47), 2.5, Paint()..color = const Color(0xFF263238));
  }

  void _drawSoccerBall(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 50), 38, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(50, 50), 38, Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 4);

    final poly = Path()..moveTo(50, 34)..lineTo(60, 42)..lineTo(56, 54)..lineTo(44, 54)..lineTo(40, 42)..close();
    canvas.drawPath(poly, Paint()..color = const Color(0xFF263238));

    final lineP = Paint()..color = const Color(0xFF263238)..strokeWidth = 3;
    canvas.drawLine(const Offset(50, 34), const Offset(50, 14), lineP);
    canvas.drawLine(const Offset(60, 42), const Offset(78, 34), lineP);
    canvas.drawLine(const Offset(56, 54), const Offset(72, 70), lineP);
    canvas.drawLine(const Offset(44, 54), const Offset(28, 70), lineP);
    canvas.drawLine(const Offset(40, 42), const Offset(22, 34), lineP);
  }

  void _drawBook(Canvas canvas) {
    final bookCover = Path()
      ..moveTo(12, 28)..cubicTo(30, 24, 48, 30, 50, 36)..cubicTo(52, 30, 70, 24, 88, 28)
      ..lineTo(88, 78)..cubicTo(70, 74, 52, 80, 50, 86)..cubicTo(48, 80, 30, 74, 12, 78)..close();
    canvas.drawPath(bookCover, Paint()..color = const Color(0xFF42A5F5));
    canvas.drawPath(bookCover, Paint()..color = const Color(0xFF1565C0)..style = PaintingStyle.stroke..strokeWidth = 4);

    final leftPage = Path()..moveTo(15, 32)..cubicTo(32, 28, 47, 33, 50, 38)..lineTo(50, 82)..cubicTo(47, 77, 32, 72, 15, 75)..close();
    canvas.drawPath(leftPage, Paint()..color = Colors.white);
    final rightPage = Path()..moveTo(85, 32)..cubicTo(68, 28, 53, 33, 50, 38)..lineTo(50, 82)..cubicTo(53, 77, 68, 72, 85, 75)..close();
    canvas.drawPath(rightPage, Paint()..color = const Color(0xFFFFFDF0));
  }

  void _drawBread(Canvas canvas) {
    final loaf = Path()
      ..moveTo(22, 46)..cubicTo(22, 30, 34, 22, 50, 22)..cubicTo(66, 22, 78, 30, 78, 46)
      ..cubicTo(84, 48, 86, 56, 86, 70)..cubicTo(86, 80, 78, 84, 68, 84)..lineTo(32, 84)
      ..cubicTo(22, 84, 14, 80, 14, 70)..cubicTo(14, 56, 16, 48, 22, 46)..close();
    canvas.drawPath(loaf, Paint()..color = const Color(0xFFFFA726));
    canvas.drawPath(loaf, Paint()..color = const Color(0xFFE65100)..style = PaintingStyle.stroke..strokeWidth = 4);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 46, 16, 12), const Radius.circular(3)), Paint()..color = const Color(0xFFFFF59D));
  }

  void _drawKitten(Canvas canvas) {
    canvas.drawOval(const Rect.fromLTWH(16, 28, 68, 60), Paint()..color = const Color(0xFFFFA726));
    canvas.drawOval(const Rect.fromLTWH(16, 28, 68, 60), Paint()..color = const Color(0xFFE65100)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(38, 54), 5, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(const Offset(62, 54), 5, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(const Offset(28, 62), 4, Paint()..color = const Color(0x99FF8A80));
    canvas.drawCircle(const Offset(72, 62), 4, Paint()..color = const Color(0x99FF8A80));
  }

  void _drawCar(Canvas canvas) {
    final body = Path()
      ..moveTo(12, 56)..lineTo(24, 38)..cubicTo(28, 32, 36, 30, 46, 30)..lineTo(66, 30)
      ..cubicTo(76, 30, 84, 36, 88, 44)..lineTo(92, 56)..cubicTo(96, 58, 96, 66, 94, 70)
      ..lineTo(86, 74)..lineTo(14, 74)..cubicTo(6, 66, 6, 58, 12, 56)..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawPath(body, Paint()..color = const Color(0xFF0288D1)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    canvas.drawCircle(const Offset(28, 74), 10, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(const Offset(72, 74), 10, Paint()..color = const Color(0xFF37474F));
  }

  void _drawHorse(Canvas canvas) {
    final head = Path()
      ..moveTo(36, 48)..lineTo(46, 22)..cubicTo(48, 18, 56, 16, 66, 22)..lineTo(76, 34)
      ..cubicTo(82, 40, 80, 48, 72, 50)..lineTo(58, 50)..lineTo(52, 74)..lineTo(32, 72)..close();
    canvas.drawPath(head, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawPath(head, Paint()..color = const Color(0xFF4E342E)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(62, 34), 4, Paint()..color = const Color(0xFF212121));
  }

  void _drawEyes(Canvas canvas) {
    canvas.drawOval(const Rect.fromLTWH(14, 26, 36, 48), Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(14, 26, 36, 48), Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(34, 50), 10, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawCircle(const Offset(34, 50), 6, Paint()..color = const Color(0xFF212121));

    canvas.drawOval(const Rect.fromLTWH(50, 26, 36, 48), Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(50, 26, 36, 48), Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(66, 50), 10, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawCircle(const Offset(66, 50), 6, Paint()..color = const Color(0xFF212121));
  }

  void _drawBanana(Canvas canvas) {
    final b1 = Path()..moveTo(22, 72)..cubicTo(36, 84, 66, 84, 82, 52)..cubicTo(62, 64, 38, 66, 22, 72);
    canvas.drawPath(b1, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawPath(b1, Paint()..color = const Color(0xFFF57F17)..style = PaintingStyle.stroke..strokeWidth = 3);
    final b2 = Path()..moveTo(18, 64)..cubicTo(32, 78, 68, 76, 84, 38)..cubicTo(58, 56, 34, 56, 18, 64);
    canvas.drawPath(b2, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawPath(b2, Paint()..color = const Color(0xFFF57F17)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawHouse(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(22, 48, 56, 40), const Radius.circular(4)), Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(22, 48, 56, 40), const Radius.circular(4)), Paint()..color = const Color(0xFFFBC02D)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    final roof = Path()..moveTo(50, 16)..lineTo(12, 48)..lineTo(88, 48)..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFEF5350));
    canvas.drawPath(roof, Paint()..color = const Color(0xFFC62828)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 60, 16, 28), const Radius.circular(3)), Paint()..color = const Color(0xFF8D6E63));
  }

  void _drawFish(Canvas canvas) {
    // Fish Body
    final body = Path()
      ..moveTo(82, 50)
      ..quadraticBezierTo(52, 22, 24, 50)
      ..quadraticBezierTo(52, 78, 82, 50);
    canvas.drawPath(body, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawPath(body, Paint()..color = const Color(0xFF0284C7)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    // Tail Fin
    final tail = Path()
      ..moveTo(24, 50)
      ..lineTo(10, 32)
      ..quadraticBezierTo(16, 50, 10, 68)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFF0284C7));

    // Eye
    canvas.drawCircle(const Offset(68, 44), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(70, 44), 2.5, Paint()..color = const Color(0xFF0F172A));
  }

  void _drawOrange(Canvas canvas) {
    // Leaf & Stem
    canvas.drawLine(const Offset(50, 24), const Offset(50, 12), Paint()..color = const Color(0xFF78350F)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    final leaf = Path()..moveTo(50, 18)..quadraticBezierTo(68, 12, 70, 22)..quadraticBezierTo(58, 26, 50, 18);
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF22C55E));

    // Orange Sphere
    canvas.drawCircle(const Offset(50, 56), 34, Paint()..color = const Color(0xFFFB923C));
    canvas.drawCircle(const Offset(50, 56), 34, Paint()..color = const Color(0xFFEA580C)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.drawCircle(const Offset(38, 44), 6, Paint()..color = const Color(0x66FFFFFF));
  }

  void _drawHat(Canvas canvas) {
    // Cap Dome
    final dome = Path()
      ..moveTo(22, 60)
      ..cubicTo(24, 28, 76, 28, 78, 60)
      ..close();
    canvas.drawPath(dome, Paint()..color = const Color(0xFF6366F1));
    canvas.drawPath(dome, Paint()..color = const Color(0xFF4338CA)..style = PaintingStyle.stroke..strokeWidth = 3.5);

    // Visor / Brim
    final visor = Path()
      ..moveTo(20, 60)
      ..quadraticBezierTo(50, 65, 88, 56)
      ..quadraticBezierTo(86, 68, 20, 64)
      ..close();
    canvas.drawPath(visor, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawPath(visor, Paint()..color = const Color(0xFFD97706)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Button on top
    canvas.drawCircle(const Offset(50, 28), 4, Paint()..color = const Color(0xFFFBBF24));
  }

  void _drawShoe(Canvas canvas) {
    // Sneaker Sole
    final sole = Path()
      ..moveTo(14, 68)..lineTo(86, 68)..quadraticBezierTo(88, 76, 84, 78)..lineTo(16, 78)..close();
    canvas.drawPath(sole, Paint()..color = Colors.white);
    canvas.drawPath(sole, Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Shoe Upper
    final upper = Path()
      ..moveTo(18, 68)
      ..lineTo(22, 42)
      ..quadraticBezierTo(40, 42, 52, 54)
      ..lineTo(84, 60)
      ..lineTo(84, 68)
      ..close();
    canvas.drawPath(upper, Paint()..color = const Color(0xFFEF4444));
    canvas.drawPath(upper, Paint()..color = const Color(0xFFB91C1C)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawPlane(Canvas canvas) {
    // Fuselage
    final body = Path()
      ..moveTo(14, 52)..lineTo(76, 36)..quadraticBezierTo(88, 38, 86, 48)..lineTo(14, 60)..close();
    canvas.drawPath(body, Paint()..color = Colors.white);
    canvas.drawPath(body, Paint()..color = const Color(0xFF0284C7)..style = PaintingStyle.stroke..strokeWidth = 3);

    // Wings
    final wing = Path()..moveTo(42, 45)..lineTo(32, 20)..lineTo(48, 22)..lineTo(62, 43)..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFF38BDF8));

    // Tail
    final tail = Path()..moveTo(16, 52)..lineTo(10, 32)..lineTo(22, 34)..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFF0284C7));
  }

  void _drawBicycle(Canvas canvas) {
    final wheelPaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4;
    // Wheels
    canvas.drawCircle(const Offset(28, 62), 16, wheelPaint);
    canvas.drawCircle(const Offset(72, 62), 16, wheelPaint);

    // Frame
    final framePaint = Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    canvas.drawLine(const Offset(28, 62), const Offset(46, 44), framePaint);
    canvas.drawLine(const Offset(46, 44), const Offset(70, 44), framePaint);
    canvas.drawLine(const Offset(70, 44), const Offset(72, 62), framePaint);
    canvas.drawLine(const Offset(28, 62), const Offset(54, 62), framePaint);
    canvas.drawLine(const Offset(54, 62), const Offset(46, 44), framePaint);

    // Seat & Handle
    canvas.drawLine(const Offset(42, 38), const Offset(50, 38), Paint()..color = const Color(0xFF0F172A)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(68, 36), const Offset(74, 36), Paint()..color = const Color(0xFF0F172A)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
  }

  void _drawSmartBadge(Canvas canvas, String rawKey) {
    final keyLower = rawKey.toLowerCase();
    // Choose emoji or icon matching common words
    String symbol = '⭐';
    Color bg1 = const Color(0xFFFEF08A);
    Color bg2 = const Color(0xFFFDE047);
    Color border = const Color(0xFFEAB308);

    if (keyLower.contains('elang')) {
      symbol = '🦅';
      bg1 = const Color(0xFFE0E7FF);
      bg2 = const Color(0xFFC7D2FE);
      border = const Color(0xFF6366F1);
    } else if (keyLower.contains('dino')) {
      symbol = '🦖';
      bg1 = const Color(0xFFDCFCE7);
      bg2 = const Color(0xFFBBF7D0);
      border = const Color(0xFF16A34A);
    } else if (keyLower.contains('gajah')) {
      symbol = '🐘';
      bg1 = const Color(0xFFF1F5F9);
      bg2 = const Color(0xFFE2E8F0);
      border = const Color(0xFF64748B);
    } else if (keyLower.contains('harimau')) {
      symbol = '🐯';
      bg1 = const Color(0xFFFFEDD5);
      bg2 = const Color(0xFFFED7AA);
      border = const Color(0xFFF97316);
    } else if (keyLower.contains('zebra')) {
      symbol = '🦓';
      bg1 = const Color(0xFFF8FAFC);
      bg2 = const Color(0xFFE2E8F0);
      border = const Color(0xFF334155);
    } else if (keyLower.contains('sapi')) {
      symbol = '🐮';
      bg1 = const Color(0xFFDCFCE7);
      bg2 = const Color(0xFFBBF7D0);
      border = const Color(0xFF22C55E);
    } else if (keyLower.contains('wortel')) {
      symbol = '🥕';
      bg1 = const Color(0xFFFFEDD5);
      bg2 = const Color(0xFFFDBA74);
      border = const Color(0xFFEA580C);
    } else if (keyLower.contains('udang')) {
      symbol = '🦐';
      bg1 = const Color(0xFFFFE4E6);
      bg2 = const Color(0xFFFECDD3);
      border = const Color(0xFFF43F5E);
    } else if (keyLower.contains('lemon')) {
      symbol = '🍋';
      bg1 = const Color(0xFFFEF9C3);
      bg2 = const Color(0xFFFDE047);
      border = const Color(0xFFCA8A04);
    } else if (keyLower.contains('nanas')) {
      symbol = '🍍';
      bg1 = const Color(0xFFFEF3C7);
      bg2 = const Color(0xFFFDE68A);
      border = const Color(0xFFD97706);
    } else if (keyLower.contains('jus')) {
      symbol = '🧃';
      bg1 = const Color(0xFFFEF08A);
      bg2 = const Color(0xFFFDE047);
      border = const Color(0xFFF59E0B);
    } else if (keyLower.contains('obat')) {
      symbol = '💊';
      bg1 = const Color(0xFFE0F2FE);
      bg2 = const Color(0xFFBAE6FD);
      border = const Color(0xFF0284C7);
    } else if (keyLower.contains('foto')) {
      symbol = '📸';
      bg1 = const Color(0xFFF3E8FF);
      bg2 = const Color(0xFFE9D5FF);
      border = const Color(0xFFA855F7);
    } else if (keyLower.contains('vas')) {
      symbol = '🏺';
      bg1 = const Color(0xFFEDE9FE);
      bg2 = const Color(0xFFDDD6FE);
      border = const Color(0xFF7C3AED);
    } else if (keyLower.contains('yoyo')) {
      symbol = '🪀';
      bg1 = const Color(0xFFFCE7F3);
      bg2 = const Color(0xFFFBCFE8);
      border = const Color(0xFFEC4899);
    } else if (keyLower.contains('xilofon')) {
      symbol = '🎵';
      bg1 = const Color(0xFFCCFBF1);
      bg2 = const Color(0xFF99F6E4);
      border = const Color(0xFF0D9488);
    } else if (keyLower.contains('burung')) {
      symbol = '🐦';
      bg1 = const Color(0xFFBAE6FD);
      bg2 = const Color(0xFF7DD3FC);
      border = const Color(0xFF0284C7);
    } else if (keyLower.contains('kereta')) {
      symbol = '🚂';
      bg1 = const Color(0xFFFEE2E2);
      bg2 = const Color(0xFFFECACA);
      border = const Color(0xFFEF4444);
    } else if (keyLower.contains('bunga')) {
      symbol = '🌸';
      bg1 = const Color(0xFFFCE7F3);
      bg2 = const Color(0xFFFBCFE8);
      border = const Color(0xFFEC4899);
    } else if (keyLower.contains('matahari')) {
      symbol = '☀️';
      bg1 = const Color(0xFFFEF08A);
      bg2 = const Color(0xFFFDE047);
      border = const Color(0xFFEAB308);
    } else if (keyLower.contains('kupu')) {
      symbol = '🦋';
      bg1 = const Color(0xFFEDE9FE);
      bg2 = const Color(0xFFDDD6FE);
      border = const Color(0xFF8B5CF6);
    } else if (keyLower.contains('awan')) {
      symbol = '☁️';
      bg1 = const Color(0xFFF0F9FF);
      bg2 = const Color(0xFFE0F2FE);
      border = const Color(0xFF38BDF8);
    } else if (keyLower.contains('pelangi')) {
      symbol = '🌈';
      bg1 = const Color(0xFFFDF4FF);
      bg2 = const Color(0xFFF5D0FE);
      border = const Color(0xFFD946EF);
    } else if (keyLower.contains('rusa')) {
      symbol = '🦌';
      bg1 = const Color(0xFFFEF3C7);
      bg2 = const Color(0xFFFDE68A);
      border = const Color(0xFFD97706);
    } else if (keyLower.contains('pohon')) {
      symbol = '🌳';
      bg1 = const Color(0xFFDCFCE7);
      bg2 = const Color(0xFFBBF7D0);
      border = const Color(0xFF22C55E);
    } else if (keyLower.contains('hati')) {
      symbol = '💖';
      bg1 = const Color(0xFFFFE4E6);
      bg2 = const Color(0xFFFECDD3);
      border = const Color(0xFFF43F5E);
    } else if (keyLower.contains('ikan')) {
      symbol = '🐟';
      bg1 = const Color(0xFFE0F2FE);
      bg2 = const Color(0xFFBAE6FD);
      border = const Color(0xFF0284C7);
    } else if (keyLower.contains('buku')) {
      symbol = '📖';
      bg1 = const Color(0xFFFEF3C7);
      bg2 = const Color(0xFFFDE68A);
      border = const Color(0xFFD97706);
    } else {
      symbol = rawKey.isNotEmpty ? rawKey.substring(0, 1).toUpperCase() : '✨';
    }

    // Badge Background
    final rrect = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 80, 80), const Radius.circular(22));
    final bgPaint = Paint()
      ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bg1, bg2])
          .createShader(const Rect.fromLTWH(10, 10, 80, 80));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = 3.5);

    // Draw Emoji / Icon
    final tp = TextPainter(
      text: TextSpan(
        text: symbol,
        style: const TextStyle(fontSize: 42),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(50 - tp.width / 2, 50 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// 3. UI VECTOR ICONS
class VectorIconWidget extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;

  const VectorIconWidget({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VectorIconPainter(icon, color ?? const Color(0xFF334155)),
      ),
    );
  }
}

class _VectorIconPainter extends CustomPainter {
  final String icon;
  final Color color;

  _VectorIconPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final p = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (icon) {
      case 'star':
        final starPath = Path()
          ..moveTo(12, 2)..lineTo(15, 8.5)..lineTo(22, 9.5)..lineTo(17, 14.5)
          ..lineTo(18.5, 21.5)..lineTo(12, 18)..lineTo(5.5, 21.5)..lineTo(7, 14.5)
          ..lineTo(2, 9.5)..lineTo(9, 8.5)..close();
        canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFD54F));
        canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFA000)..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
      case 'home':
        final homePath = Path()
          ..moveTo(3, 10.5)..lineTo(12, 3)..lineTo(21, 10.5)..lineTo(21, 20)
          ..lineTo(3, 20)..close();
        canvas.drawPath(homePath, p);
        canvas.drawLine(const Offset(9, 20), const Offset(9, 13), p);
        canvas.drawLine(const Offset(9, 13), const Offset(15, 13), p);
        canvas.drawLine(const Offset(15, 13), const Offset(15, 20), p);
        break;
      case 'soundOn':
        final speaker = Path()..moveTo(11, 5)..lineTo(6, 9)..lineTo(2, 9)..lineTo(2, 15)..lineTo(6, 15)..lineTo(11, 19)..close();
        canvas.drawPath(speaker, p);
        canvas.drawArc(const Rect.fromLTWH(11, 8, 8, 8), -math.pi / 3, 2 * math.pi / 3, false, p);
        break;
      case 'soundOff':
        final speaker = Path()..moveTo(11, 5)..lineTo(6, 9)..lineTo(2, 9)..lineTo(2, 15)..lineTo(6, 15)..lineTo(11, 19)..close();
        canvas.drawPath(speaker, p);
        canvas.drawLine(const Offset(17, 9), const Offset(23, 15), p);
        canvas.drawLine(const Offset(23, 9), const Offset(17, 15), p);
        break;
      case 'musicOn':
        final noteHead = Path()..addOval(const Rect.fromLTWH(5, 13, 6, 5));
        canvas.drawPath(noteHead, Paint()..color = color);
        canvas.drawLine(const Offset(10.5, 15), const Offset(10.5, 5), p);
        final flag = Path()..moveTo(10.5, 5)..quadraticBezierTo(16, 7, 16, 11);
        canvas.drawPath(flag, p);
        break;
      case 'musicOff':
        final noteHeadOff = Path()..addOval(const Rect.fromLTWH(5, 13, 6, 5));
        canvas.drawPath(noteHeadOff, Paint()..color = color);
        canvas.drawLine(const Offset(10.5, 15), const Offset(10.5, 5), p);
        final flagOff = Path()..moveTo(10.5, 5)..quadraticBezierTo(16, 7, 16, 11);
        canvas.drawPath(flagOff, p);
        canvas.drawLine(const Offset(4, 4), const Offset(20, 20), Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 2);
        break;

      case 'stickers':
        final book = Path()..moveTo(4, 4)..lineTo(20, 4)..lineTo(20, 20)..lineTo(4, 20)..close();
        canvas.drawPath(book, p);
        canvas.drawLine(const Offset(7, 8), const Offset(17, 8), p);
        canvas.drawLine(const Offset(7, 12), const Offset(17, 12), p);
        break;
      case 'parental':
        final shield = Path()..moveTo(12, 2)..lineTo(20, 5)..lineTo(20, 12)..cubicTo(20, 18, 12, 22, 12, 22)..cubicTo(12, 22, 4, 18, 4, 12)..lineTo(4, 5)..close();
        canvas.drawPath(shield, p);
        canvas.drawCircle(const Offset(12, 11), 2.5, Paint()..color = color);
        break;
      case 'speaker':
        final spk = Path()..moveTo(11, 5)..lineTo(6, 9)..lineTo(2, 9)..lineTo(2, 15)..lineTo(6, 15)..lineTo(11, 19)..close();
        canvas.drawPath(spk, Paint()..color = color);
        canvas.drawArc(const Rect.fromLTWH(11, 8, 8, 8), -math.pi / 3, 2 * math.pi / 3, false, p);
        break;
      case 'reload':
        canvas.drawArc(const Rect.fromLTWH(3, 3, 18, 18), -math.pi / 4, 1.5 * math.pi, false, p);
        final arrow = Path()..moveTo(14, 2)..lineTo(18, 5)..lineTo(14, 8);
        canvas.drawPath(arrow, p);
        break;
      case 'gift':
        final box = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 9, 16, 12), const Radius.circular(2)));
        canvas.drawPath(box, Paint()..color = color.withAlpha(50));
        canvas.drawPath(box, p);
        final lid = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 7, 18, 4), const Radius.circular(1.5)));
        canvas.drawPath(lid, Paint()..color = color);
        canvas.drawLine(const Offset(12, 7), const Offset(12, 21), Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 2);
        final bowLeft = Path()..addOval(const Rect.fromLTWH(7, 3, 5, 4));
        final bowRight = Path()..addOval(const Rect.fromLTWH(12, 3, 5, 4));
        canvas.drawPath(bowLeft, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawPath(bowRight, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
