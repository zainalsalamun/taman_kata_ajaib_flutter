import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/level_milestone_dialog.dart';
import '../widgets/level_selector_ribbon.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class BalloonScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const BalloonScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<BalloonScreen> createState() => _BalloonScreenState();
}

class _BalloonScreenState extends State<BalloonScreen>
    with SingleTickerProviderStateMixin {
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  List<BalloonWordData> _balloonWords = GameRepository.getBalloonWords(1);
  final AudioService _audio = AudioService();
  late AnimationController _animController;

  final List<_BalloonItem> _activeBalloons = [];
  final List<String> _poppedWords = [];
  final List<_PopParticle> _particles = [];

  BalloonWordData get _current => _currentIndex < _balloonWords.length
      ? _balloonWords[_currentIndex]
      : _balloonWords[0];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animController.addListener(_updatePhysics);

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('balloon');
    final unl = await StorageService.getUnlockedGameLevel('balloon');
    final idx = await StorageService.getGameLevelIndex('balloon', lvl);
    final words = GameRepository.getBalloonWords(lvl);

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _balloonWords = words;
        _currentIndex = (idx < words.length) ? idx : 0;
      });
      _startBalloonGame();
    }
  }

  void _switchLevel(int newLevel) async {
    final words = GameRepository.getBalloonWords(newLevel);
    final idx = await StorageService.getGameLevelIndex('balloon', newLevel);
    await StorageService.saveGameLevel('balloon', newLevel);

    setState(() {
      _currentLevel = newLevel;
      _balloonWords = words;
      _currentIndex = (idx < words.length) ? idx : 0;
    });

    _startBalloonGame();
    final titles = {
      1: 'Tunas Ajaib',
      2: 'Petualang Kata',
      3: 'Master Literasi'
    };
    _audio.speak(
        'Tingkat $_currentLevel: ${titles[_currentLevel]}! Ayo cari kata ${_current.target}!');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _canvasWidth = 700;
  double _canvasHeight = 350;

  void _startBalloonGame() {
    _poppedWords.clear();
    _activeBalloons.clear();
    _particles.clear();

    final colors = [
      const [Color(0xFFFF6B6B), Color(0xFFEE5253)],
      const [Color(0xFF38BDF8), Color(0xFF0284C7)],
      const [Color(0xFF4ADE80), Color(0xFF16A34A)],
      const [Color(0xFFFDE047), Color(0xFFEAB308)],
    ];

    final shuffled = List<String>.from(_current.choices)..shuffle();
    final availWidth = (_canvasWidth - 140).clamp(240.0, 1400.0);
    final spacing = availWidth / shuffled.length;
    for (int i = 0; i < shuffled.length; i++) {
      _activeBalloons.add(
        _BalloonItem(
          word: shuffled[i],
          colors: colors[i % colors.length],
          x: 40.0 + i * spacing + math.Random().nextDouble() * 15,
          y: (_canvasHeight * 0.45).clamp(110.0, 450.0) + math.Random().nextDouble() * 40,
          speedY: 0.6 + math.Random().nextDouble() * 0.4,
          angle: math.Random().nextDouble() * math.pi * 2,
        ),
      );
    }

    _audio.speak('Ayo cari kata ${_current.target}!');
    setState(() {});
  }

  void _updatePhysics() {
    for (final b in _activeBalloons) {
      b.y -= b.speedY;
      b.angle += 0.03;
      b.x += math.sin(b.angle) * 0.5;

      if (b.y < -110) {
        b.y = (_canvasHeight * 0.78).clamp(200.0, 600.0);
      }
    }

    // Update pop particles
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.12; // soft gravity
      p.opacity = (p.opacity - 0.035).clamp(0.0, 1.0);
    }
    _particles.removeWhere((p) => p.opacity <= 0.0);

    setState(() {});
  }

  void _onBalloonTapped(_BalloonItem item) {
    if (_poppedWords.contains(item.word)) return;

    HapticFeedback.lightImpact();

    // Spawn Burst Particles at balloon center
    final rand = math.Random();
    const particleChars = ['⭐', '✨', '🎈', '🎉', '•'];
    const particleColors = [
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ];

    for (int i = 0; i < 14; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 1.8 + rand.nextDouble() * 4.0;
      _particles.add(
        _PopParticle(
          x: item.x + 35,
          y: item.y + 40,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 1.2,
          color: particleColors[rand.nextInt(particleColors.length)],
          char: particleChars[rand.nextInt(particleChars.length)],
        ),
      );
    }

    setState(() {
      _poppedWords.add(item.word);
    });

    if (item.word == _current.target) {
      HapticFeedback.mediumImpact();
      _audio.playSfx('pop');
      _audio.speak('Pop! ${item.word}! Benar!');

      Future.delayed(const Duration(milliseconds: 400), () async {
        if (!mounted) return;

        final hasMoreInLevel = _currentIndex + 1 < _balloonWords.length;

        if (hasMoreInLevel) {
          // Regular word victory
          widget.onVictory(3);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => VictoryDialog(
              title: 'Pintar! Balon "${item.word}"!',
              subtitle: 'Kamu berhasil menemukan kata ${item.word}!',
              onNext: () {
                setState(() {
                  _currentIndex++;
                });
                StorageService.saveGameLevelIndex(
                    'balloon', _currentLevel, _currentIndex);
                _startBalloonGame();
              },
            ),
          );
        } else {
          // LEVEL GRADUATION / MILESTONE CEREMONY!
          widget.onVictory(15);
          final nextLvl = _currentLevel + 1;
          if (nextLvl <= 3) {
            await StorageService.saveUnlockedGameLevel('balloon', nextLvl);
            if (nextLvl > _unlockedLevel) {
              setState(() {
                _unlockedLevel = nextLvl;
              });
            }
          }
          await StorageService.addTrophy('balloon_l$_currentLevel');
          await StorageService.saveGameLevelIndex('balloon', _currentLevel, 0);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => LevelMilestoneDialog(
              gameTitle: 'Balon Kata Ajaib',
              completedLevel: _currentLevel,
              onNextLevel: () {
                _switchLevel(_currentLevel + 1);
              },
              onReplay: () {
                setState(() {
                  _currentIndex = 0;
                });
                _startBalloonGame();
              },
              onBackToMap: widget.onBack,
            ),
          );
        }
      });
    } else {
      _audio.speak('Itu kata ${item.word}. Ayo cari ${_current.target}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasWidth = constraints.maxWidth;
        _canvasHeight = constraints.maxHeight;

        return Stack(
          children: [
            // Sky Background
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.1,
                  colors: [
                    Color(0xFFE0F2FE),
                    Color(0xFFBAE6FD),
                    Color(0xFF7DD3FC),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8), width: 3),
              ),
            ),

            // Top Control Bar: LevelSelectorRibbon + Target Banner
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: LevelSelectorRibbon(
                      currentLevel: _currentLevel,
                      unlockedLevel: _unlockedLevel,
                      onSelectLevel: _switchLevel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 6,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFF43F5E), width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFFE11D48), offset: Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ObjectIllustrationWidget(
                              illustrationKey: _current.illustrationKey,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _current.target,
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFBE123C),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _audio.speak('Ayo cari kata ${_current.target}');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDE047),
                                  shape: BoxShape.circle,
                                ),
                                child: const VectorIconWidget(
                                    icon: 'speaker',
                                    size: 16,
                                    color: Color(0xFF854D0E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

        // Floating Balloons
        ..._activeBalloons.map((b) {
          final isPopped = _poppedWords.contains(b.word);
          if (isPopped) return const SizedBox.shrink();

          return Positioned(
            left: b.x,
            top: b.y,
            child: GestureDetector(
              onTap: () => _onBalloonTapped(b),
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: b.colors),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    b.word,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Color(0x60000000), offset: Offset(0, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Star Burst & Confetti Particles on Pop
        ..._particles.map((p) {
          return Positioned(
            left: p.x,
            top: p.y,
            child: IgnorePointer(
              child: Opacity(
                opacity: p.opacity,
                child: Text(
                  p.char,
                  style: TextStyle(
                    fontSize: p.char == '•' ? 22 : 18,
                    color: p.color,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  },
);
  }
}

class _PopParticle {
  double x;
  double y;
  final double vx;
  double vy;
  final Color color;
  final String char;
  double opacity = 1.0;

  _PopParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.char,
  });
}

class _BalloonItem {
  final String word;
  final List<Color> colors;
  double x;
  double y;
  double speedY;
  double angle;

  _BalloonItem({
    required this.word,
    required this.colors,
    required this.x,
    required this.y,
    required this.speedY,
    required this.angle,
  });
}
