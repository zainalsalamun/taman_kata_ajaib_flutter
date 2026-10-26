import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'achievement_certificate_dialog.dart';

class ChildAvatar {
  final String id;
  final String name;
  final String title;
  final String emoji;
  final String personality;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final String greeting;

  const ChildAvatar({
    required this.id,
    required this.name,
    required this.title,
    required this.emoji,
    required this.personality,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.greeting,
  });
}

class ChildAvatarData {
  static const List<ChildAvatar> allAvatars = [
    ChildAvatar(
      id: 'miko',
      name: 'Miko si Kucing',
      title: 'Kucing Penjelajah Ajaib',
      emoji: '🐱',
      personality: 'Ceria & Suka Bertualang',
      primaryColor: Color(0xFFFEF3C7),
      secondaryColor: Color(0xFFFDE68A),
      borderColor: Color(0xFFF59E0B),
      greeting: 'Meong! Aku Miko si Kucing Ajaib, siap membantumu membaca kata-kata seru!',
    ),
    ChildAvatar(
      id: 'cici',
      name: 'Cici si Kelinci',
      title: 'Kelinci Pengeja Cerdik',
      emoji: '🐰',
      personality: 'Lincah & Teliti Mengeja',
      primaryColor: Color(0xFFFDF2F8),
      secondaryColor: Color(0xFFFCE7F3),
      borderColor: Color(0xFFEC4899),
      greeting: 'Hai! Aku Cici si Kelinci cerdik, ayo melompat riang merangkai huruf dan suku kata!',
    ),
    ChildAvatar(
      id: 'kiki',
      name: 'Kiki si Beruang',
      title: 'Beruang Penyuka Dongeng',
      emoji: '🐻',
      personality: 'Hangat & Penyabar',
      primaryColor: Color(0xFFFEF3C7),
      secondaryColor: Color(0xFFFED7AA),
      borderColor: Color(0xFFD97706),
      greeting: 'Halo sahabat! Aku Kiki si Beruang baik hati, senang sekali membaca buku dongeng bersamamu!',
    ),
    ChildAvatar(
      id: 'leo',
      name: 'Leo si Singa',
      title: 'Singa Juara Pemberani',
      emoji: '🦁',
      personality: 'Semangat & Percaya Diri',
      primaryColor: Color(0xFFFFFBEB),
      secondaryColor: Color(0xFFFEF08A),
      borderColor: Color(0xFFEAB308),
      greeting: 'Rawrr ceria! Aku Leo si Singa pemberani, selalu semangat dan pantang menyerah belajar!',
    ),
    ChildAvatar(
      id: 'piko',
      name: 'Piko si Panda',
      title: 'Panda Ceria Bersahabat',
      emoji: '🐼',
      personality: 'Tenang & Sahabat Asyik',
      primaryColor: Color(0xFFF0FDF4),
      secondaryColor: Color(0xFFDCFCE7),
      borderColor: Color(0xFF10B981),
      greeting: 'Hai teman baru! Aku Piko si Panda pintar, ayo santai belajar dan kumpulkan banyak bintang!',
    ),
    ChildAvatar(
      id: 'rino',
      name: 'Rino si Rubah',
      title: 'Rubah Cerdik Logika',
      emoji: '🦊',
      personality: 'Pintar & Cepat Tanggap',
      primaryColor: Color(0xFFFFF7ED),
      secondaryColor: Color(0xFFFFEDD5),
      borderColor: Color(0xFFF97316),
      greeting: 'Hore! Aku Rino si Rubah cerdik, siap menemanimu memecahkan teka-teki logika kata!',
    ),
  ];

  static ChildAvatar getAvatar(String id) {
    return allAvatars.firstWhere(
      (a) => a.id == id,
      orElse: () => allAvatars.first,
    );
  }
}

/// A scalable vector character avatar widget for the child profile
class ChildAvatarWidget extends StatelessWidget {
  final String avatarId;
  final double size;
  final bool showBorder;
  final bool showGlow;
  final VoidCallback? onTap;

  const ChildAvatarWidget({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.showBorder = true,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = ChildAvatarData.getAvatar(avatarId);

    Widget avatarGraphic = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _getAvatarPainter(avatarId),
      ),
    );

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [avatar.primaryColor, avatar.secondaryColor],
        ),
        border: showBorder
            ? Border.all(color: avatar.borderColor, width: math.max(1.5, size * 0.05))
            : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: avatar.borderColor.withAlpha(90),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Center(child: avatarGraphic),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  CustomPainter _getAvatarPainter(String id) {
    switch (id) {
      case 'cici':
        return _RabbitPainter();
      case 'kiki':
        return _BearPainter();
      case 'leo':
        return _LionPainter();
      case 'piko':
        return _PandaPainter();
      case 'rino':
        return _FoxPainter();
      case 'miko':
      default:
        return _CatPainter();
    }
  }
}

/// 1. Miko the Cat Painter
class _CatPainter extends CustomPainter {
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

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Cici the Rabbit Painter
class _RabbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final earOutline = Paint()
      ..color = const Color(0xFFDB2777)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Long Bunny Ears
    final earFill = Paint()..color = const Color(0xFFFFF1F2);
    final earInner = Paint()..color = const Color(0xFFF472B6);

    // Left Ear
    final leftEar = Path()
      ..moveTo(32, 42)
      ..cubicTo(24, 25, 22, 6, 33, 5)
      ..cubicTo(43, 6, 42, 25, 42, 42)
      ..close();
    canvas.drawPath(leftEar, earFill);
    canvas.drawPath(leftEar, earOutline);
    final leftInner = Path()
      ..moveTo(33, 36)
      ..cubicTo(28, 24, 26, 12, 33, 10)
      ..cubicTo(39, 12, 38, 24, 38, 36)
      ..close();
    canvas.drawPath(leftInner, earInner);

    // Right Ear (slightly playful tilt)
    final rightEar = Path()
      ..moveTo(58, 42)
      ..cubicTo(58, 25, 57, 6, 67, 5)
      ..cubicTo(78, 6, 76, 25, 68, 42)
      ..close();
    canvas.drawPath(rightEar, earFill);
    canvas.drawPath(rightEar, earOutline);
    final rightInner = Path()
      ..moveTo(62, 36)
      ..cubicTo(62, 24, 61, 12, 67, 10)
      ..cubicTo(72, 12, 71, 24, 67, 36)
      ..close();
    canvas.drawPath(rightInner, earInner);

    // Head Base
    final headRect = const Rect.fromLTWH(15, 28, 70, 62);
    canvas.drawOval(headRect, Paint()..color = const Color(0xFFFFFBFB));
    canvas.drawOval(headRect, Paint()
      ..color = const Color(0xFFF472B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2);

    // Cute Cheeks
    canvas.drawCircle(const Offset(27, 62), 6, Paint()..color = const Color(0x80F472B6));
    canvas.drawCircle(const Offset(73, 62), 6, Paint()..color = const Color(0x80F472B6));

    // Big Sparkle Eyes
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawOval(const Rect.fromLTWH(31, 46, 11, 14), eyePaint);
    canvas.drawCircle(const Offset(34, 50), 2.5, Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(58, 46, 11, 14), eyePaint);
    canvas.drawCircle(const Offset(61, 50), 2.5, Paint()..color = Colors.white);

    // Pink Nose
    final nose = Path()..moveTo(47, 63)..lineTo(53, 63)..lineTo(50, 67)..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFE11D48));

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFFBE185D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(45, 70)
      ..quadraticBezierTo(50, 74, 50, 68)
      ..quadraticBezierTo(50, 74, 55, 70);
    canvas.drawPath(mouth, mouthPaint);

    // Bunny Teeth
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(48, 71, 4, 5), const Radius.circular(1.5)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(48, 71, 4, 5), const Radius.circular(1.5)),
      Paint()
        ..color = const Color(0xFFF43F5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Kiki the Bear Painter
class _BearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final bearColor = const Color(0xFFB45309);
    final bearOutline = const Color(0xFF78350F);

    // Round Ears
    canvas.drawCircle(const Offset(26, 26), 14, Paint()..color = bearColor);
    canvas.drawCircle(const Offset(26, 26), 14, Paint()
      ..color = bearOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0);
    canvas.drawCircle(const Offset(26, 26), 8, Paint()..color = const Color(0xFFFDE68A));

    canvas.drawCircle(const Offset(74, 26), 14, Paint()..color = bearColor);
    canvas.drawCircle(const Offset(74, 26), 14, Paint()
      ..color = bearOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0);
    canvas.drawCircle(const Offset(74, 26), 8, Paint()..color = const Color(0xFFFDE68A));

    // Head
    final headRect = const Rect.fromLTWH(14, 24, 72, 66);
    canvas.drawOval(headRect, Paint()..color = bearColor);
    canvas.drawOval(headRect, Paint()
      ..color = bearOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2);

    // Warm Snout
    final snoutRect = const Rect.fromLTWH(32, 50, 36, 30);
    canvas.drawOval(snoutRect, Paint()..color = const Color(0xFFFEF3C7));

    // Bear Nose
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(42, 55, 16, 11), const Radius.circular(5)),
      Paint()..color = const Color(0xFF451A03),
    );

    // Bear Mouth Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(43, 69)
      ..quadraticBezierTo(50, 74, 50, 66)
      ..quadraticBezierTo(50, 74, 57, 69);
    canvas.drawPath(mouth, mouthPaint);

    // Warm Eyes
    canvas.drawOval(const Rect.fromLTWH(31, 41, 10, 13), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(34, 44), 2.5, Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(59, 41, 10, 13), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(62, 44), 2.5, Paint()..color = Colors.white);

    // Cheeks
    canvas.drawCircle(const Offset(25, 59), 5.5, Paint()..color = const Color(0x60F59E0B));
    canvas.drawCircle(const Offset(75, 59), 5.5, Paint()..color = const Color(0x60F59E0B));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Leo the Lion Painter
class _LionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Fluffy Golden Mane
    final manePaint = Paint()..color = const Color(0xFFEA580C);
    final maneOffsets = [
      const Offset(50, 14), const Offset(66, 18), const Offset(80, 28),
      const Offset(88, 44), const Offset(88, 62), const Offset(78, 76),
      const Offset(64, 86), const Offset(50, 88), const Offset(36, 86),
      const Offset(22, 76), const Offset(12, 62), const Offset(12, 44),
      const Offset(20, 28), const Offset(34, 18),
    ];
    for (var off in maneOffsets) {
      canvas.drawCircle(off, 14, manePaint);
    }

    // Mane Center Fill
    canvas.drawCircle(const Offset(50, 52), 40, manePaint);

    // Head Base
    final headRect = const Rect.fromLTWH(22, 26, 56, 54);
    canvas.drawOval(headRect, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawOval(headRect, Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0);

    // Round Lion Ears
    canvas.drawCircle(const Offset(28, 28), 8, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(const Offset(28, 28), 5, Paint()..color = const Color(0xFFFEF3C7));
    canvas.drawCircle(const Offset(72, 28), 8, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(const Offset(72, 28), 5, Paint()..color = const Color(0xFFFEF3C7));

    // Muzzle
    final muzzleRect = const Rect.fromLTWH(34, 50, 32, 24);
    canvas.drawOval(muzzleRect, Paint()..color = const Color(0xFFFFFBEB));

    // Brown Nose
    final nose = Path()..moveTo(45, 54)..lineTo(55, 54)..lineTo(50, 60)..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFF78350F));

    // Proud Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(44, 66)
      ..quadraticBezierTo(50, 71, 50, 63)
      ..quadraticBezierTo(50, 71, 56, 66);
    canvas.drawPath(mouth, mouthPaint);

    // Sparkle Eyes
    canvas.drawOval(const Rect.fromLTWH(34, 40, 9, 13), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(37, 43), 2.2, Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(57, 40, 9, 13), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(60, 43), 2.2, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 5. Piko the Panda Painter
class _PandaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Black Round Ears
    canvas.drawCircle(const Offset(24, 22), 13, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(76, 22), 13, Paint()..color = const Color(0xFF1E293B));

    // White Head Base
    final headRect = const Rect.fromLTWH(15, 22, 70, 68);
    canvas.drawOval(headRect, Paint()..color = Colors.white);
    canvas.drawOval(headRect, Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2);

    // Characteristic Black Eye Patches (Angled Ovals)
    canvas.save();
    canvas.translate(33, 48);
    canvas.rotate(-math.pi / 12);
    canvas.drawOval(const Rect.fromLTWH(-9, -12, 18, 24), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(-1, -2), 3.2, Paint()..color = Colors.white);
    canvas.restore();

    canvas.save();
    canvas.translate(67, 48);
    canvas.rotate(math.pi / 12);
    canvas.drawOval(const Rect.fromLTWH(-9, -12, 18, 24), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(1, -2), 3.2, Paint()..color = Colors.white);
    canvas.restore();

    // Pink Blush Under Eye Patches
    canvas.drawCircle(const Offset(24, 64), 5.5, Paint()..color = const Color(0x60F472B6));
    canvas.drawCircle(const Offset(76, 64), 5.5, Paint()..color = const Color(0x60F472B6));

    // Black Button Nose
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(45, 59, 10, 7), const Radius.circular(3.5)),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Cute Panda Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(44, 71)
      ..quadraticBezierTo(50, 75, 50, 68)
      ..quadraticBezierTo(50, 75, 56, 71);
    canvas.drawPath(mouth, mouthPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 6. Rino the Fox Painter
class _FoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final foxOrange = const Color(0xFFEA580C);
    final foxDark = const Color(0xFF7C2D12);

    // Pointed Ears with Dark Tips
    final leftEar = Path()..moveTo(18, 38)..lineTo(18, 8)..lineTo(44, 26)..close();
    canvas.drawPath(leftEar, Paint()..color = foxOrange);
    canvas.drawPath(leftEar, Paint()
      ..color = foxDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8);

    // Left Ear Tip (Dark)
    final leftTip = Path()..moveTo(18, 20)..lineTo(18, 8)..lineTo(28, 15)..close();
    canvas.drawPath(leftTip, Paint()..color = const Color(0xFF431407));
    // Inner ear cream
    final leftInner = Path()..moveTo(22, 32)..lineTo(24, 16)..lineTo(38, 26)..close();
    canvas.drawPath(leftInner, Paint()..color = const Color(0xFFFEF3C7));

    // Right Ear with Dark Tip
    final rightEar = Path()..moveTo(82, 38)..lineTo(82, 8)..lineTo(56, 26)..close();
    canvas.drawPath(rightEar, Paint()..color = foxOrange);
    canvas.drawPath(rightEar, Paint()
      ..color = foxDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8);

    // Right Ear Tip (Dark)
    final rightTip = Path()..moveTo(82, 20)..lineTo(82, 8)..lineTo(72, 15)..close();
    canvas.drawPath(rightTip, Paint()..color = const Color(0xFF431407));
    // Inner ear cream
    final rightInner = Path()..moveTo(78, 32)..lineTo(76, 16)..lineTo(62, 26)..close();
    canvas.drawPath(rightInner, Paint()..color = const Color(0xFFFEF3C7));

    // Fox Head Base
    final headRect = const Rect.fromLTWH(14, 22, 72, 68);
    canvas.drawOval(headRect, Paint()..color = foxOrange);
    canvas.drawOval(headRect, Paint()
      ..color = foxDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0);

    // White Cheeks / Muzzle Tufts
    final whiteCheeks = Path()
      ..moveTo(50, 52)
      ..lineTo(22, 60)
      ..cubicTo(24, 78, 40, 86, 50, 78)
      ..cubicTo(60, 86, 76, 78, 78, 60)
      ..close();
    canvas.drawPath(whiteCheeks, Paint()..color = const Color(0xFFFFFBEB));

    // Black Nose
    final nose = Path()..moveTo(46, 68)..lineTo(54, 68)..lineTo(50, 74)..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFF1E293B));

    // Clever Eyes
    canvas.drawOval(const Rect.fromLTWH(31, 43, 11, 14), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(34, 46), 2.5, Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(58, 43, 11, 14), Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(61, 46), 2.5, Paint()..color = Colors.white);

    // Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFF7C2D12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final mouth = Path()..moveTo(46, 76)..quadraticBezierTo(50, 80, 54, 76);
    canvas.drawPath(mouth, mouthPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Interactive dialog for children to select their favorite reading companion avatar
class AvatarSelectionDialog extends StatefulWidget {
  final String currentAvatarId;
  final String currentChildName;
  final Function(String newAvatarId, String newName)? onSaved;

  const AvatarSelectionDialog({
    super.key,
    required this.currentAvatarId,
    required this.currentChildName,
    this.onSaved,
  });

  @override
  State<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog> {
  late String _selectedAvatarId;
  late TextEditingController _nameController;
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _selectedAvatarId = widget.currentAvatarId;
    _nameController = TextEditingController(text: widget.currentChildName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSelectAvatar(ChildAvatar avatar) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAvatarId = avatar.id;
    });
    // Greet the child with this character's voice!
    _audio.speak(avatar.greeting);
  }

  void _saveProfile() async {
    HapticFeedback.mediumImpact();
    final newName = _nameController.text.trim().isEmpty ? 'Juara Cilik' : _nameController.text.trim();
    await StorageService.saveChildAvatar(_selectedAvatarId);
    await StorageService.saveChildName(newName);
    widget.onSaved?.call(_selectedAvatarId, newName);
    if (mounted) {
      Navigator.of(context).pop({
        'avatarId': _selectedAvatarId,
        'childName': newName,
      });
      _audio.playSfx('star');
      _audio.speak('Profil berhasil disimpan! Senang bertualang bersamamu, $newName!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isNarrow = screenSize.width < 500;
    final dialogWidth = math.min(560.0, screenSize.width * 0.94);
    final dialogHeight = math.min(680.0, screenSize.height * 0.92);
    final selectedAvatar = ChildAvatarData.getAvatar(_selectedAvatarId);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFBEB),
                Color(0xFFFEF3C7),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF59E0B), width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35D97706),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎭', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Sahabat Membaca',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Karakter avatar pendamping petualangan ananda',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFEF3C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Avatar Spotlight Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selectedAvatar.borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: selectedAvatar.borderColor.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ChildAvatarWidget(
                              avatarId: selectedAvatar.id,
                              size: 58,
                              showGlow: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        selectedAvatar.name,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: selectedAvatar.borderColor.withAlpha(35),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Dipilih ★',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: selectedAvatar.borderColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    selectedAvatar.title,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: selectedAvatar.borderColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedAvatar.personality,
                                    style: GoogleFonts.nunito(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Child Name Editor Input
                      Text(
                        'Nama Juara Cilik:',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE047), width: 2),
                        ),
                        child: TextField(
                          controller: _nameController,
                          maxLength: 24,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama anak...',
                            hintStyle: GoogleFonts.nunito(color: const Color(0xFF94A3B8), fontSize: 13),
                            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFFD97706), size: 20),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid of 6 Avatars
                      Text(
                        'Pilih Karakter Favoritmu:',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                      const SizedBox(height: 8),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = isNarrow ? 2 : 3;
                          final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 10) / crossAxisCount;
                          final cardAspectRatio = cardWidth / (isNarrow ? 120.0 : 115.0);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ChildAvatarData.allAvatars.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: cardAspectRatio,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, idx) {
                              final avatar = ChildAvatarData.allAvatars[idx];
                              final isSelected = avatar.id == _selectedAvatarId;

                              return GestureDetector(
                                onTap: () => _onSelectAvatar(avatar),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : avatar.primaryColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? avatar.borderColor : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2.5 : 1.2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: avatar.borderColor.withAlpha(50),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ChildAvatarWidget(
                                        avatarId: avatar.id,
                                        size: 42,
                                        showBorder: isSelected,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        avatar.name,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? avatar.borderColor : const Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        avatar.personality,
                                        style: GoogleFonts.nunito(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions (Certificate & Save Profile)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button to view Certificate
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _audio.playSfx('sparkle');
                          showDialog(
                            context: context,
                            builder: (_) => const AchievementCertificateDialog(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: const Color(0xFFFFFBEB),
                        ),
                        icon: const Text('📜', style: TextStyle(fontSize: 15)),
                        label: Text(
                          'Lihat Piagam Juara Ananda 👑',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Primary Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Pilih & Simpan Profil 🚀',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
