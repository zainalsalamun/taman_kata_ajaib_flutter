import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';

class LevelMilestoneDialog extends StatefulWidget {
  final String gameTitle;
  final int completedLevel;
  final int totalLevels;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onBackToMap;

  const LevelMilestoneDialog({
    super.key,
    required this.gameTitle,
    required this.completedLevel,
    this.totalLevels = 3,
    required this.onNextLevel,
    required this.onReplay,
    required this.onBackToMap,
  });

  @override
  State<LevelMilestoneDialog> createState() => _LevelMilestoneDialogState();
}

class _LevelMilestoneDialogState extends State<LevelMilestoneDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_MilestoneParticle> _particles;

  bool get hasNextLevel => widget.completedLevel < widget.totalLevels;
  int get nextLevel => widget.completedLevel + 1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    _initParticles();

    HapticFeedback.heavyImpact();
    final audio = AudioService();
    audio.playSfx('ding');
    Future.delayed(const Duration(milliseconds: 300), () {
      audio.playSfx('star');
      if (widget.completedLevel < 3) {
        audio.speak(
            'Horeee! Luar biasa! Kamu berhasil lulus Tingkat ${widget.completedLevel}! Bintang dan piala emas untukmu!');
      } else {
        audio.speak(
            'Horeee! Selamat! Kamu telah menjadi Master Sejati di ${widget.gameTitle}! Kamu hebat sekali!');
      }
    });
  }

  void _initParticles() {
    final rand = math.Random();
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF4081),
      const Color(0xFF00E676),
      const Color(0xFF00B0FF),
      const Color(0xFFFF9100),
      const Color(0xFFD500F9),
      const Color(0xFFEEFF41),
    ];

    _particles = List.generate(70, (i) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 190 + rand.nextDouble() * 300;
      return _MilestoneParticle(
        startX: 0.5 + (rand.nextDouble() - 0.5) * 0.2,
        startY: 0.35 + (rand.nextDouble() - 0.5) * 0.1,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 150,
        size: 9 + rand.nextDouble() * 9,
        color: colors[rand.nextInt(colors.length)],
        rotation: rand.nextDouble() * 2 * math.pi,
        rotationSpeed: (rand.nextDouble() - 0.5) * 12,
        type: rand.nextInt(3),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelNames = {
      1: 'Tunas Ajaib',
      2: 'Petualang Kata',
      3: 'Master Literasi',
    };
    final currentLevelName = levelNames[widget.completedLevel] ?? 'Tingkat ${widget.completedLevel}';
    final nextLevelName = levelNames[nextLevel] ?? 'Tingkat $nextLevel';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: 520,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Fireworks & Confetti
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _MilestoneConfettiPainter(
                      progress: _animController.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
            ),

            // Card Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFBBF24), width: 6),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40F59E0B),
                    blurRadius: 36,
                    spreadRadius: 6,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 20,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Golden Trophy + Laurel Wreath Header
                  _buildTrophyHeader(),

                  const SizedBox(height: 12),

                  // Celebration Headline
                  Text(
                    hasNextLevel
                        ? 'HORE! LULUS TINGKAT ${widget.completedLevel}!'
                        : 'SELAMAT! MASTER LITERASI!',
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Island & Level Subtitle
                  Text(
                    '${widget.gameTitle} • $currentLevelName',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Reward Star Pill (+15 Bintang Bonus)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFEAB308), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFCA8A04),
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          hasNextLevel
                              ? '+15 BINTANG JUARA TINGKAT!'
                              : '+25 BINTANG MASTER SEJATI!',
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF854D0E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mascot Miko Advice Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: const Color(0xFF86EFAC), width: 2),
                    ),
                    child: Row(
                      children: [
                        const MascotWidget(size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasNextLevel
                                ? 'Kamu hebat sekali! Semua materi di Tingkat ${widget.completedLevel} berhasil kamu kuasai. Ayo lanjut ke $nextLevelName!'
                                : 'Luar biasa! Kamu telah menamatkan semua tingkat di ${widget.gameTitle}! Kamu adalah Master Sejati!',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF166534),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Map Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFCBD5E1), width: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          widget.onBackToMap();
                        },
                        icon: const Text('🗺️', style: TextStyle(fontSize: 18)),
                        label: Text(
                          'Ke Peta',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Next Level / Replay Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(
                                color: Color(0xFF16A34A), width: 3),
                          ),
                          shadowColor: const Color(0xFF15803D),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                          if (hasNextLevel) {
                            widget.onNextLevel();
                          } else {
                            widget.onReplay();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasNextLevel ? '🚀' : '🔄',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasNextLevel
                                  ? 'Buka Tingkat $nextLevel Sekarang!'
                                  : 'Mainkan Lagi Tingkat 3',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyHeader() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x50F59E0B),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: const Center(
        child: Text(
          '🏆',
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}

class _MilestoneParticle {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final int type;

  _MilestoneParticle({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.type,
  });
}

class _MilestoneConfettiPainter extends CustomPainter {
  final double progress;
  final List<_MilestoneParticle> particles;

  _MilestoneConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1.0) return;

    final t = progress * 2.2;
    final gravity = 380.0;
    final opacity = (1.0 - (progress * 0.95)).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = p.startX * size.width + p.vx * t;
      final y = p.startY * size.height + p.vy * t + 0.5 * gravity * t * t;
      final rot = p.rotation + p.rotationSpeed * t;

      if (x < -20 || x > size.width + 20 || y > size.height + 20) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      if (p.type == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      } else if (p.type == 1) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        // Mini star
        final path = Path();
        const r1 = 6.0;
        const r2 = 3.0;
        for (int i = 0; i < 5; i++) {
          final a1 = (i * 72 - 90) * math.pi / 180;
          final a2 = (i * 72 + 36 - 90) * math.pi / 180;
          if (i == 0) {
            path.moveTo(math.cos(a1) * r1, math.sin(a1) * r1);
          } else {
            path.lineTo(math.cos(a1) * r1, math.sin(a1) * r1);
          }
          path.lineTo(math.cos(a2) * r2, math.sin(a2) * r2);
        }
        path.close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MilestoneConfettiPainter oldDelegate) => true;
}
