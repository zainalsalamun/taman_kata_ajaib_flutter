import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';

class WheelSlice {
  final String label;
  final String icon;
  final Color color;
  final Color textColor;
  final int stars;
  final bool isSticker;
  final bool isJackpot;

  const WheelSlice({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.stars = 0,
    this.isSticker = false,
    this.isJackpot = false,
  });
}

class DailyRewardDialog extends StatefulWidget {
  final int currentStars;
  final List<String> unlockedStickers;
  final Function(int newStars, List<String> newUnlockedStickers) onRewardClaimed;

  const DailyRewardDialog({
    super.key,
    required this.currentStars,
    required this.unlockedStickers,
    required this.onRewardClaimed,
  });

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  late AnimationController _confettiController;
  late List<_ConfettiParticle> _confettiParticles;

  bool _isSpinning = false;
  bool _canSpinToday = true;
  int _currentStreak = 1;
  int? _wonIndex;
  String? _wonStickerId;
  String? _wonStickerName;
  bool _hasClaimed = false;

  final List<WheelSlice> _slices = const [
    WheelSlice(label: '+5 Bintang', icon: '⭐', color: Color(0xFF86EFAC), textColor: Color(0xFF166534), stars: 5),
    WheelSlice(label: '+10 Bintang', icon: '⭐', color: Color(0xFFFDE047), textColor: Color(0xFF854D0E), stars: 10),
    WheelSlice(label: 'Stiker Lucu', icon: '🎁', color: Color(0xFFF472B6), textColor: Color(0xFF831843), isSticker: true),
    WheelSlice(label: '+15 Bintang', icon: '⭐', color: Color(0xFF7DD3FC), textColor: Color(0xFF075985), stars: 15),
    WheelSlice(label: '+5 Bintang', icon: '⭐', color: Color(0xFFFDBA74), textColor: Color(0xFF9A3412), stars: 5),
    WheelSlice(label: '+20 Bintang', icon: '⭐', color: Color(0xFFC084FC), textColor: Color(0xFF581C87), stars: 20),
    WheelSlice(label: 'Stiker Ajaib', icon: '🎁', color: Color(0xFFFCD34D), textColor: Color(0xFFB45309), isSticker: true),
    WheelSlice(label: 'JACKPOT +30!', icon: '👑', color: Color(0xFFFB7185), textColor: Color(0xFF881337), stars: 30, isJackpot: true),
  ];

  double _startAngle = 0.0;
  double _targetAngle = 0.0;
  int _lastTickSlice = -1;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _initConfetti();
    _checkDailyStatus();

    // Welcome speech
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.speak('Hore! Roda Keberuntungan Miko! Putar rodanya untuk mendapatkan hadiah spesial hari ini!');
    });
  }

  void _initConfetti() {
    final rand = math.Random();
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF4081),
      const Color(0xFF00E676),
      const Color(0xFF00B0FF),
      const Color(0xFFFF9100),
      const Color(0xFFD500F9),
    ];
    _confettiParticles = List.generate(45, (i) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 150 + rand.nextDouble() * 250;
      return _ConfettiParticle(
        color: colors[rand.nextInt(colors.length)],
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        size: 5 + rand.nextDouble() * 7,
      );
    });
  }

  void _checkDailyStatus() async {
    final canSpin = await StorageService.canClaimDailyReward();
    final streak = await StorageService.getDailyStreak();
    if (mounted) {
      setState(() {
        _canSpinToday = canSpin;
        _currentStreak = streak;
      });
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning || !_canSpinToday) return;

    HapticFeedback.heavyImpact();
    _audio.playSfx('whoosh');

    setState(() {
      _isSpinning = true;
      _wonIndex = null;
      _wonStickerId = null;
      _wonStickerName = null;
    });

    // Pick target slice (weighted for delightful rewards)
    final rand = math.Random();
    final chosenIdx = rand.nextInt(_slices.length);

    // Number of full rotations (5-7 full spins)
    const fullSpins = 5;
    final sliceAngle = (2 * math.pi) / _slices.length;

    // Pointer is at TOP (-pi / 2). A slice's center must align with pointer.
    // slice i center is at angle = i * sliceAngle + sliceAngle / 2.
    // When wheel rotates by R, effective pointer angle = (-pi / 2 - R) mod 2pi.
    // We want (-pi / 2 - R) = chosenIdx * sliceAngle + sliceAngle / 2.
    // R = -pi / 2 - (chosenIdx * sliceAngle + sliceAngle / 2) + fullSpins * 2pi.
    final targetOffset = (2 * math.pi * fullSpins) +
        (2 * math.pi) -
        (chosenIdx * sliceAngle + (sliceAngle / 2)) -
        (math.pi / 2);

    _startAngle = _targetAngle % (2 * math.pi);
    _targetAngle = _startAngle + targetOffset;

    _spinAnimation = Tween<double>(begin: _startAngle, end: _targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    )..addListener(() {
        final currentVal = _spinAnimation.value;
        final currentSlice = ((currentVal / sliceAngle).floor()) % _slices.length;
        if (currentSlice != _lastTickSlice) {
          _lastTickSlice = currentSlice;
          HapticFeedback.selectionClick();
        }
      });

    _spinController.forward(from: 0.0).then((_) {
      _onSpinComplete(chosenIdx);
    });
  }

  void _onSpinComplete(int wonIndex) {
    final slice = _slices[wonIndex];
    String? wonSticker;
    String? stickerName;

    if (slice.isSticker) {
      // Find locked stickers
      final locked = GameRepository.stickers
          .where((s) => !widget.unlockedStickers.contains(s.id))
          .toList();
      if (locked.isNotEmpty) {
        final picked = locked[math.Random().nextInt(locked.length)];
        wonSticker = picked.id;
        stickerName = picked.name;
      }
    }

    setState(() {
      _isSpinning = false;
      _wonIndex = wonIndex;
      _wonStickerId = wonSticker;
      _wonStickerName = stickerName;
    });

    _confettiController.forward(from: 0.0);
    _audio.playSfx('fanfare');

    if (slice.isJackpot) {
      _audio.speak('LUAR BIASA! KAMU MENDAPATKAN JACKPOT TIGA PULUH BINTANG!');
    } else if (wonSticker != null) {
      _audio.speak('Horeee! Kamu mendapatkan stiker baru: $stickerName!');
    } else {
      _audio.speak('Yeeay! Kamu memenangkan ${slice.label}!');
    }
  }

  void _claimReward() async {
    if (_wonIndex == null || _hasClaimed) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _hasClaimed = true;
    });

    final slice = _slices[_wonIndex!];
    int awardedStars = slice.stars;
    // If landed on sticker but all stickers are already unlocked, give 25 bonus stars
    if (slice.isSticker && _wonStickerId == null) {
      awardedStars = 25;
    }

    final res = await StorageService.claimDailyReward(
      rewardStars: awardedStars,
      rewardSticker: _wonStickerId,
    );

    widget.onRewardClaimed(
      res['newStars'] as int,
      (res['unlockedStickers'] as List<dynamic>).map((e) => e.toString()).toList(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(500.0, screenSize.width * 0.94);
    final dialogMaxHeight = screenSize.height * 0.94;

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
              // Confetti Overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confettiController.value,
                        particles: _confettiParticles,
                      ),
                    );
                  },
                ),
              ),

              // Main Card Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFFBBF24), width: 4.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x35F59E0B),
                      blurRadius: 32,
                      spreadRadius: 4,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
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
                        // Header: Title & Close Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const MascotWidget(size: 38),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Roda Keberuntungan Miko! 🎡',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                    Text(
                                      'Putar & menangkan hadiah setiap hari!',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                if (!_isSpinning) {
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 7-Day Attendance Ribbon
                        _buildAttendanceRibbon(),
                        const SizedBox(height: 14),

                        // Interactive Wheel Container
                        _buildWheelView(),
                        const SizedBox(height: 14),

                        // Action Button or Result Card
                        if (_wonIndex != null)
                          _buildRewardResultCard()
                        else
                          _buildSpinButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7-Day Attendance Streak Ribbon
  Widget _buildAttendanceRibbon() {
    final streakDays = [
      {'day': 1, 'reward': '+5', 'icon': '⭐'},
      {'day': 2, 'reward': '+10', 'icon': '⭐'},
      {'day': 3, 'reward': 'Stiker', 'icon': '🎁'},
      {'day': 4, 'reward': '+15', 'icon': '⭐'},
      {'day': 5, 'reward': '+20', 'icon': '⭐'},
      {'day': 6, 'reward': 'Langka', 'icon': '🎁'},
      {'day': 7, 'reward': '+30', 'icon': '👑'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📅 Absensi Belajar 7 Hari Berturut-turut',
                style: GoogleFonts.fredoka(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF92400E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hari ke-$_currentStreak 🔥',
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: streakDays.map((item) {
              final dayNum = item['day'] as int;
              final isCurrent = dayNum == _currentStreak;
              final isPast = dayNum < _currentStreak;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFFF59E0B)
                        : (isPast ? const Color(0xFF86EFAC) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFB45309)
                          : (isPast ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0)),
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? const [
                            BoxShadow(color: Color(0x30F59E0B), blurRadius: 4, offset: Offset(0, 2)),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'H$dayNum',
                        style: GoogleFonts.fredoka(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : (isPast ? const Color(0xFF166534) : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['icon'] as String,
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        item['reward'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isCurrent
                              ? Colors.white
                              : (isPast ? const Color(0xFF166534) : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Interactive 8-Segment Spinning Wheel View
  Widget _buildWheelView() {
    const wheelSize = 210.0;

    return SizedBox(
      width: wheelSize,
      height: wheelSize + 22,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer Glow Shadow
          Container(
            width: wheelSize,
            height: wheelSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x25F59E0B), blurRadius: 24, spreadRadius: 4),
              ],
            ),
          ),

          // The Rotating Wheel Canvas
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, _) {
              final angle = _isSpinning ? _spinAnimation.value : _targetAngle;
              return Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  size: const Size(wheelSize, wheelSize),
                  painter: _WheelPainter(slices: _slices),
                ),
              );
            },
          ),

          // Central Golden Jewel Hub
          GestureDetector(
            onTap: _canSpinToday && !_isSpinning ? _spinWheel : null,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0x35000000), blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Text(
                  _isSpinning ? '🌀' : (_canSpinToday ? 'PUTAR' : 'BESOK'),
                  style: GoogleFonts.fredoka(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF78350F),
                  ),
                ),
              ),
            ),
          ),

          // Top Golden Pointer Indicator
          Positioned(
            top: -10,
            child: CustomPaint(
              size: const Size(26, 26),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // Action Spin Button
  Widget _buildSpinButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _canSpinToday && !_isSpinning ? _spinWheel : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSpinToday ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          foregroundColor: Colors.white,
          elevation: _canSpinToday ? 4 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canSpinToday ? '🎯 Putar Roda Ajaib Sekarang!' : '⏳ Sudah Diputar! Kembali Lagi Besok',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _canSpinToday ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reward Result Card upon landing
  Widget _buildRewardResultCard() {
    final slice = _slices[_wonIndex!];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF86EFAC), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(slice.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                _wonStickerName != null
                    ? 'Selamat! Dapat Stiker $_wonStickerName!'
                    : 'Selamat! Kamu Mendapatkan ${slice.label}!',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _hasClaimed ? null : _claimReward,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              label: Text(
                _hasClaimed ? 'Hadiah Berhasil Disimpan!' : 'Klaim Hadiah 🎁',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for 8-Segment Fortune Wheel
class _WheelPainter extends CustomPainter {
  final List<WheelSlice> slices;

  _WheelPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = (2 * math.pi) / slices.length;

    // Draw Slices
    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final startAngle = i * sliceAngle;

      final slicePaint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        slicePaint,
      );

      // Slice border line
      final borderPaint = Paint()
        ..color = Colors.white.withAlpha(200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final x = center.dx + radius * math.cos(startAngle);
      final y = center.dy + radius * math.sin(startAngle);
      canvas.drawLine(center, Offset(x, y), borderPaint);

      // Text / Label inside slice
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sliceAngle / 2);

      final textSpan = TextSpan(
        text: '${slice.icon} ${slice.label}',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: slice.textColor,
          fontFamily: 'Fredoka',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Position text along radial line
      textPainter.paint(
        canvas,
        Offset(radius * 0.36, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Outer Golden Ring Rim
    final rimPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;
    canvas.drawCircle(center, radius - 3.5, rimPaint);

    final innerRimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 7, innerRimPaint);

    // Decorative Bulbs / Pegs on Rim
    final pegCount = slices.length * 2;
    final pegRadius = radius - 3.5;
    for (int i = 0; i < pegCount; i++) {
      final angle = (2 * math.pi / pegCount) * i;
      final px = center.dx + pegRadius * math.cos(angle);
      final py = center.dy + pegRadius * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(px, py),
        2.5,
        Paint()
          ..color = const Color(0xFFB45309)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

// Custom Painter for Golden Top Pointer Indicator
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height) // Bottom point
      ..lineTo(0, 4)
      ..quadraticBezierTo(size.width / 2, 0, size.width, 4)
      ..close();

    final shadowPaint = Paint()
      ..color = const Color(0x35000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    final fillPaint = Paint()..color = const Color(0xFFDC2626); // Crimson Red Pointer
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);

    // Small jewel on pointer head
    canvas.drawCircle(Offset(size.width / 2, 8), 3.5, Paint()..color = const Color(0xFFFEF08A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Confetti Particles for Celebration Burst
class _ConfettiParticle {
  final Color color;
  final Offset velocity;
  final double size;

  _ConfettiParticle({
    required this.color,
    required this.velocity,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height * 0.45);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final dx = center.dx + p.velocity.dx * progress;
      final dy = center.dy + p.velocity.dy * progress + (180.0 * progress * progress); // Gravity
      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), p.size * (1.0 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
