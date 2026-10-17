import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart';

class FireworkParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double alpha;
  double rotation;
  double rotationSpeed;
  int shape; // 0: glowing dot, 1: four-point star, 2: sparkling diamond, 3: streamer

  FireworkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.alpha = 1.0,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class FireworkRocket {
  double x;
  double y;
  final double targetX;
  final double targetY;
  final double speed;
  final Color trailColor;
  bool exploded = false;

  FireworkRocket({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.trailColor,
  });
}

class InteractiveFireworksOverlay extends StatefulWidget {
  final Widget child;
  final bool autoLaunch;
  final bool tapEnabled;
  final bool showTapHint;

  const InteractiveFireworksOverlay({
    super.key,
    required this.child,
    this.autoLaunch = true,
    this.tapEnabled = true,
    this.showTapHint = true,
  });

  @override
  State<InteractiveFireworksOverlay> createState() => _InteractiveFireworksOverlayState();
}

class _InteractiveFireworksOverlayState extends State<InteractiveFireworksOverlay>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final List<FireworkRocket> _rockets = [];
  final List<FireworkParticle> _particles = [];
  late AnimationController _ticker;

  static const List<List<Color>> _colorPalettes = [
    [Color(0xFFFFD700), Color(0xFFF59E0B), Color(0xFFFDE047)], // Gold / Amber
    [Color(0xFFFF4081), Color(0xFFF43F5E), Color(0xFFFDA4AF)], // Pink / Rose
    [Color(0xFF00E676), Color(0xFF10B981), Color(0xFF86EFAC)], // Emerald / Mint
    [Color(0xFF00B0FF), Color(0xFF0284C7), Color(0xFF7DD3FC)], // Sky / Azure
    [Color(0xFFD500F9), Color(0xFF8B5CF6), Color(0xFFDDD6FE)], // Purple / Violet
    [Color(0xFFFF6D00), Color(0xFFEF4444), Color(0xFFFDBA74)], // Fire / Orange
  ];

  int _autoLaunchTick = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updatePhysics)
      ..repeat();

    if (widget.autoLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialLaunch();
      });
    }
  }

  void _initialLaunch() {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Launch initial celebratory fireworks bursts
    _launchFirework(w * 0.28, h * 0.32);
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _launchFirework(w * 0.72, h * 0.28);
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _launchFirework(w * 0.50, h * 0.24);
    });
  }

  void _launchFirework(double targetX, double targetY) {
    HapticFeedback.lightImpact();
    _audio.playSfx('firework');

    // Create explosion immediately at target position with slight upward burst
    final rand = math.Random();
    final palette = _colorPalettes[rand.nextInt(_colorPalettes.length)];

    final particleCount = 38 + rand.nextInt(18);
    for (int i = 0; i < particleCount; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 120 + rand.nextDouble() * 260;
      _particles.add(
        FireworkParticle(
          x: targetX,
          y: targetY,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 60,
          size: 6 + rand.nextDouble() * 8,
          color: palette[rand.nextInt(palette.length)],
          rotation: rand.nextDouble() * math.pi * 2,
          rotationSpeed: (rand.nextDouble() - 0.5) * 12,
          shape: rand.nextInt(4),
        ),
      );
    }
  }

  void _handleUserTap(TapDownDetails details) {
    if (!widget.tapEnabled) return;
    final pos = details.localPosition;
    _launchFirework(pos.dx, pos.dy);
  }

  void _updatePhysics() {
    if (_particles.isEmpty && _rockets.isEmpty) {
      _autoLaunchTick++;
      if (widget.autoLaunch && _autoLaunchTick % 120 == 0) {
        final size = MediaQuery.of(context).size;
        final rand = math.Random();
        _launchFirework(
          size.width * (0.2 + rand.nextDouble() * 0.6),
          size.height * (0.2 + rand.nextDouble() * 0.4),
        );
      }
      return;
    }

    const dt = 0.016; // approx 60fps
    const gravity = 220.0;

    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += gravity * dt; // gravity
      p.vx *= 0.98; // air resistance
      p.vy *= 0.98;
      p.rotation += p.rotationSpeed * dt;
      p.alpha -= 0.018; // gentle fade
      if (p.alpha <= 0.0) {
        _particles.removeAt(i);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _handleUserTap,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Underlying Content
          widget.child,

          // Active Firework Sparks Canvas Layer
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _InteractiveFireworksPainter(particles: _particles),
              ),
            ),
          ),

          // Gentle child-friendly tap hint at bottom if enabled
          if (widget.showTapHint && widget.tapEnabled)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(90),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(120), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎆', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 6),
                        Text(
                          'Ketuk layar untuk menyalakan kembang api!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InteractiveFireworksPainter extends CustomPainter {
  final List<FireworkParticle> particles;

  _InteractiveFireworksPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    for (final p in particles) {
      if (p.alpha <= 0.0) continue;
      final paint = Paint()
        ..color = p.color.withAlpha((p.alpha * 255).clamp(0, 255).toInt())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      switch (p.shape) {
        case 0:
          // Glowing Circle
          canvas.drawCircle(Offset.zero, p.size * 0.55, paint);
          // Sparkle halo
          canvas.drawCircle(
            Offset.zero,
            p.size * 0.9,
            Paint()..color = p.color.withAlpha((p.alpha * 80).clamp(0, 255).toInt()),
          );
          break;

        case 1:
          // 4-Point Shimmering Star
          final r = p.size * 0.8;
          final star = Path()
            ..moveTo(0, -r)
            ..quadraticBezierTo(0, 0, r, 0)
            ..quadraticBezierTo(0, 0, 0, r)
            ..quadraticBezierTo(0, 0, -r, 0)
            ..quadraticBezierTo(0, 0, 0, -r)
            ..close();
          canvas.drawPath(star, paint);
          break;

        case 2:
          // Diamond Sparkle
          final r = p.size * 0.7;
          final diamond = Path()
            ..moveTo(0, -r)
            ..lineTo(r * 0.6, 0)
            ..lineTo(0, r)
            ..lineTo(-r * 0.6, 0)
            ..close();
          canvas.drawPath(diamond, paint);
          break;

        case 3:
          // Streamer Ribbon
          final rrect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.8, height: p.size * 0.6),
            const Radius.circular(2),
          );
          canvas.drawRRect(rrect, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveFireworksPainter oldDelegate) => true;
}
