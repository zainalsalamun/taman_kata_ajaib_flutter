import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../services/audio_service.dart';

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

class _BalloonScreenState extends State<BalloonScreen> with SingleTickerProviderStateMixin {
  final List<BalloonWordData> _balloonWords = GameRepository.balloonWords;
  int _currentIndex = 0;
  final AudioService _audio = AudioService();
  late AnimationController _animController;

  final List<_BalloonItem> _activeBalloons = [];
  final List<String> _poppedWords = [];

  BalloonWordData get _current => _balloonWords[_currentIndex];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animController.addListener(_updatePhysics);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBalloonGame();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startBalloonGame() {
    _poppedWords.clear();
    _activeBalloons.clear();

    final colors = [
      const [Color(0xFFFF6B6B), Color(0xFFEE5253)],
      const [Color(0xFF38BDF8), Color(0xFF0284C7)],
      const [Color(0xFF4ADE80), Color(0xFF16A34A)],
      const [Color(0xFFFDE047), Color(0xFFEAB308)],
    ];

    final shuffled = List<String>.from(_current.choices)..shuffle();
    for (int i = 0; i < shuffled.length; i++) {
      _activeBalloons.add(
        _BalloonItem(
          word: shuffled[i],
          colors: colors[i % colors.length],
          x: 60.0 + i * 160.0 + math.Random().nextDouble() * 20,
          y: 160.0 + math.Random().nextDouble() * 60,
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

      if (b.y < -100) {
        b.y = 280;
      }
    }
    setState(() {});
  }

  void _onBalloonTapped(_BalloonItem item) {
    if (_poppedWords.contains(item.word)) return;

    HapticFeedback.lightImpact();

    setState(() {
      _poppedWords.add(item.word);
    });

    if (item.word == _current.target) {
      HapticFeedback.mediumImpact();
      _audio.playSfx('pop');
      _audio.speak('Pop! ${item.word}! Benar!');

      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onVictory(3);
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VictoryDialog(
            title: 'Pintar! Balon "${item.word}"!',
            subtitle: 'Kamu berhasil menemukan kata ${item.word}!',
            onNext: () {
              setState(() {
                _currentIndex = (_currentIndex + 1) % _balloonWords.length;
              });
              _startBalloonGame();
            },
          ),
        );
      });
    } else {
      _audio.speak('Itu kata ${item.word}. Ayo cari ${_current.target}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky Background
        Container(
          margin: const EdgeInsets.all(12),
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

        // Target Banner
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    size: 42,
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
                    onTap: () => _audio.speak('Ayo cari kata ${_current.target}'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDE047),
                        shape: BoxShape.circle,
                      ),
                      child: const VectorIconWidget(icon: 'speaker', size: 16, color: Color(0xFF854D0E)),
                    ),
                  ),
                ],
              ),
            ),
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
      ],
    );
  }
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
