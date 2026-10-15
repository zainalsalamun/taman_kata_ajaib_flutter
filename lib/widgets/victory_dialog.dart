import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';

class VictoryDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNext;

  const VictoryDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onNext,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();

    _initParticles();

    // Haptic feedback & celebratory cheering audio
    HapticFeedback.heavyImpact();
    AudioService().playSfx('star');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService().speakCelebration();
    });
  }

  void _initParticles() {
    final rand = math.Random();
    final colors = [
      const Color(0xFFFF4081),
      const Color(0xFFFF5252),
      const Color(0xFFFFD740),
      const Color(0xFF69F0AE),
      const Color(0xFF40C4FF),
      const Color(0xFF7C4DFF),
      const Color(0xFFFFAB40),
      const Color(0xFFEEFF41),
    ];

    _particles = List.generate(65, (i) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 180 + rand.nextDouble() * 320;
      return _ConfettiParticle(
        startX: 0.5 + (rand.nextDouble() - 0.5) * 0.25,
        startY: 0.35 + (rand.nextDouble() - 0.5) * 0.15,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 160, // upward burst
        size: 8 + rand.nextDouble() * 10,
        color: colors[rand.nextInt(colors.length)],
        rotation: rand.nextDouble() * 2 * math.pi,
        rotationSpeed: (rand.nextDouble() - 0.5) * 14,
        type: rand.nextInt(3), // 0: rectangle, 1: circle, 2: star
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
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(480.0, screenSize.width * 0.92);
    final dialogMaxHeight = screenSize.height * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
        child: SizedBox(
          width: dialogWidth,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Confetti Particles Fireworks Layer
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _animController.value,
                        particles: _particles,
                      ),
                    );
                  },
                ),
              ),

              // 2. Main Victory Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFFDE047), width: 5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x35F59E0B),
                      blurRadius: 36,
                      spreadRadius: 6,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // 3 Animated Stars Burst
                  _buildAnimatedStars(),
                  const SizedBox(height: 10),

                  // Title with warm glow
                  Text(
                    widget.title,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFEA580C),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Reward Badge (+3 Stars)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFACC15), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFEAB308), offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '+3 Bintang Didapatkan!',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // "Lanjut Main" Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        widget.onNext();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        elevation: 4,
                        shadowColor: const Color(0xFF15803D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjut Main',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3 Animated Stars that pop into view sequentially
  Widget _buildAnimatedStars() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final t = _animController.value;

        // Star 1 (Left) curve [0.05 to 0.40]
        final s1Progress = ((t - 0.05) / 0.35).clamp(0.0, 1.0);
        final s1Scale = _elasticCurve(s1Progress);

        // Star 2 (Center, largest) curve [0.25 to 0.60]
        final s2Progress = ((t - 0.25) / 0.35).clamp(0.0, 1.0);
        final s2Scale = _elasticCurve(s2Progress);

        // Star 3 (Right) curve [0.45 to 0.80]
        final s3Progress = ((t - 0.45) / 0.35).clamp(0.0, 1.0);
        final s3Scale = _elasticCurve(s3Progress);

        return SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Star
              Transform.scale(
                scale: s1Scale,
                child: const VectorIconWidget(icon: 'star', size: 46),
              ),
              const SizedBox(width: 10),

              // Middle Star (Large with golden glow)
              Transform.scale(
                scale: s2Scale * 1.18,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x60F59E0B),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const VectorIconWidget(icon: 'star', size: 62),
                ),
              ),
              const SizedBox(width: 10),

              // Right Star
              Transform.scale(
                scale: s3Scale,
                child: const VectorIconWidget(icon: 'star', size: 46),
              ),
            ],
          ),
        );
      },
    );
  }

  double _elasticCurve(double t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    // Bouncy elastic overshoot curve
    return math.sin(-13.0 * (t + 1.0) * math.pi / 2) * math.pow(2.0, -10.0 * t) + 1.0;
  }
}

// Model for Confetti Particle
class _ConfettiParticle {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final int type;

  _ConfettiParticle({
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

// Confetti Particle Custom Painter with gravity & flutter physics
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    const gravity = 480.0;
    final t = progress * 2.8; // simulated time in seconds
    final fade = progress > 0.75 ? (1.0 - (progress - 0.75) / 0.25).clamp(0.0, 1.0) : 1.0;

    for (final p in particles) {
      // Calculate current position with gravity and gentle air flutter
      final currentX = p.startX * size.width + p.vx * t + math.sin(t * 5 + p.rotation) * 18.0;
      final currentY = p.startY * size.height + p.vy * t + 0.5 * gravity * t * t;
      final currentRot = p.rotation + p.rotationSpeed * t;

      final paint = Paint()
        ..color = p.color.withOpacity((p.color.opacity * fade).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRot);

      switch (p.type) {
        case 0:
          // Ribbon / Streamer Rectangle
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.7),
              const Radius.circular(2),
            ),
            paint,
          );
          break;
        case 1:
          // Circle Dot
          canvas.drawCircle(Offset.zero, p.size * 0.55, paint);
          break;
        case 2:
          // 4-Point Star Sparkle
          final r = p.size * 0.65;
          final starPath = Path()
            ..moveTo(0, -r)
            ..quadraticBezierTo(0, 0, r, 0)
            ..quadraticBezierTo(0, 0, 0, r)
            ..quadraticBezierTo(0, 0, -r, 0)
            ..quadraticBezierTo(0, 0, 0, -r)
            ..close();
          canvas.drawPath(starPath, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
