import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import 'interactive_fireworks.dart';

class IslandMasteryDialog extends StatefulWidget {
  final String islandTitle;
  final String islandRoute;
  final int bonusStars;
  final VoidCallback onBackToMap;
  final VoidCallback onReplay;

  const IslandMasteryDialog({
    super.key,
    required this.islandTitle,
    required this.islandRoute,
    this.bonusStars = 30,
    required this.onBackToMap,
    required this.onReplay,
  });

  @override
  State<IslandMasteryDialog> createState() => _IslandMasteryDialogState();
}

class _IslandMasteryDialogState extends State<IslandMasteryDialog>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  late AnimationController _raysController;

  @override
  void initState() {
    super.initState();
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    HapticFeedback.heavyImpact();
    _audio.playSfx('fanfare');

    Future.delayed(const Duration(milliseconds: 350), () {
      _audio.playSfx('cheer');
      _audio.playSfx('magic_chime');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.speakIslandMastery(widget.islandTitle);
    });
  }

  @override
  void dispose() {
    _raysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(520.0, screenSize.width * 0.94);
    final dialogMaxHeight = screenSize.height * 0.94;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
        child: SizedBox(
          width: dialogWidth,
          child: InteractiveFireworksOverlay(
            autoLaunch: true,
            tapEnabled: true,
            showTapHint: false,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFBEB),
                      Colors.white,
                      Color(0xFFFEF3C7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 5.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4AF59E0B),
                      blurRadius: 40,
                      spreadRadius: 8,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 440,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Sunburst Trophy with Crown
                        SizedBox(
                          height: 120,
                          width: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating Golden Sunburst Rays
                              AnimatedBuilder(
                                animation: _raysController,
                                builder: (context, _) {
                                  return CustomPaint(
                                    size: const Size(130, 130),
                                    painter: _SunburstRaysPainter(
                                      progress: _raysController.value,
                                    ),
                                  );
                                },
                              ),

                              // Central Trophy & Crown
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('👑', style: TextStyle(fontSize: 28)),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x60F59E0B),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Text('🏆', style: TextStyle(fontSize: 42)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Grand Title
                        Text(
                          'SELAMAT! KAMU JUARA PULAU!',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFB45309),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        // Island Subtitle
                        Text(
                          'Luar biasa! Kamu telah menuntaskan seluruh kata dan tantangan di "${widget.islandTitle}"!',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        // Rewards Row: +30 Stars & Master Trophy Pill
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            // +30 Stars
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFACC15), width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2AD97706),
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '+${widget.bonusStars} Bintang Master!',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trophy Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF4ADE80), width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2A15803D),
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('👑', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Gelar Master Pulau ⭐',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Action Buttons: Lanjut Jelajah Peta & Main Lagi
                        Row(
                          children: [
                            // Main Lagi
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop();
                                    widget.onReplay();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFF59E0B), width: 2.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    foregroundColor: const Color(0xFFB45309),
                                  ),
                                  icon: const Icon(Icons.replay_rounded, size: 18),
                                  label: Text(
                                    'Main Lagi',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Lanjut Jelajah Peta
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _audio.playSfx('whoosh');
                                    Navigator.of(context).pop();
                                    widget.onBackToMap();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF22C55E),
                                    elevation: 4,
                                    shadowColor: const Color(0xFF15803D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  icon: const Text('🗺️', style: TextStyle(fontSize: 18)),
                                  label: Text(
                                    'Jelajah Peta Ajaib',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SunburstRaysPainter extends CustomPainter {
  final double progress;

  _SunburstRaysPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const rayCount = 14;

    final rayPaint = Paint()
      ..color = const Color(0xFFFDE047).withAlpha(140)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * math.pi);

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      const spread = (2 * math.pi) / (rayCount * 2.2);

      final ray = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(angle - spread / 2) * radius, math.sin(angle - spread / 2) * radius)
        ..lineTo(math.cos(angle + spread / 2) * radius, math.sin(angle + spread / 2) * radius)
        ..close();
      canvas.drawPath(ray, rayPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunburstRaysPainter oldDelegate) => true;
}
