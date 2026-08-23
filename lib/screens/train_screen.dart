import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../services/audio_service.dart';

class TrainScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const TrainScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> with SingleTickerProviderStateMixin {
  final List<TrainWordData> _trainWords = GameRepository.trainWords;
  int _currentIndex = 0;
  final List<String> _filledSlots = [];
  final List<String> _hiddenChoices = [];
  final AudioService _audio = AudioService();

  late AnimationController _trainAnimController;
  late Animation<double> _trainSlideAnimation;

  TrainWordData get _current => _trainWords[_currentIndex];

  @override
  void initState() {
    super.initState();
    _trainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _trainSlideAnimation = Tween<double>(begin: 0, end: 800).animate(
      CurvedAnimation(parent: _trainAnimController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWord();
    });
  }

  @override
  void dispose() {
    _trainAnimController.dispose();
    super.dispose();
  }

  void _startWord() {
    setState(() {
      _filledSlots.clear();
      _hiddenChoices.clear();
      _trainAnimController.reset();
    });
    _audio.speak('Susun kata ${_current.word}!');
  }

  void _onSyllableTapped(String syl) {
    if (_filledSlots.length >= _current.syllables.length) return;

    _audio.speak(syl);

    setState(() {
      _filledSlots.add(syl);
      _hiddenChoices.add(syl);
    });

    if (_filledSlots.length == _current.syllables.length) {
      final formed = _filledSlots.join('');
      if (formed == _current.word) {
        // Success
        Future.delayed(const Duration(milliseconds: 300), () {
          _audio.speak('${_current.word}! Hebat sekali!');
          _trainAnimController.forward();

          Future.delayed(const Duration(milliseconds: 1400), () {
            widget.onVictory(3);
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => VictoryDialog(
                title: 'Hebat! Kata "${_current.word}"!',
                subtitle: 'Kereta meluncur membawa kata ${_current.word}!',
                onNext: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _trainWords.length;
                  });
                  _startWord();
                },
              ),
            );
          });
        });
      } else {
        // Wrong
        Future.delayed(const Duration(milliseconds: 800), () {
          _audio.speak('Ayo coba susun lagi ya!');
          _startWord();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Target Object Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF86EFAC), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF4ADE80), offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ObjectIllustrationWidget(
                  illustrationKey: _current.illustrationKey,
                  size: 54,
                ),
                const SizedBox(width: 14),
                Text(
                  _current.word,
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF166534),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _audio.speak(_current.word),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE047),
                      shape: BoxShape.circle,
                    ),
                    child: const VectorIconWidget(icon: 'speaker', size: 18, color: Color(0xFF854D0E)),
                  ),
                ),
              ],
            ),
          ),

          // Train Track & Train Assembly
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Railroad Track Line
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF78350F),
                      border: Border(top: BorderSide(color: Color(0xFF451A03), width: 3)),
                    ),
                  ),
                ),

                // Animated Train
                AnimatedBuilder(
                  animation: _trainSlideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_trainSlideAnimation.value, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Locomotive
                          Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              border: Border.all(color: const Color(0xFFB91C1C), width: 3),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -12,
                                  left: 18,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 22,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF08A),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFB91C1C), width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Wagon Slots
                          Row(
                            children: List.generate(_current.syllables.length, (idx) {
                              final isFilled = idx < _filledSlots.length;
                              final sylText = isFilled ? _filledSlots[idx] : '?';

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 80,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: isFilled
                                      ? const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)])
                                      : null,
                                  color: isFilled ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isFilled ? const Color(0xFF0369A1) : const Color(0xFF94A3B8),
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x15000000), offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    sylText,
                                    style: GoogleFonts.nunito(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isFilled ? Colors.white : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Syllable Choices Palette
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _current.choices.map((syl) {
              final isHidden = _hiddenChoices.contains(syl);

              return Visibility(
                visible: !isHidden,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _onSyllableTapped(syl),
                    child: Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDE047), Color(0xFFFACC15)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEAB308), width: 3),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFCA8A04), offset: Offset(0, 5)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          syl,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF713F12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
