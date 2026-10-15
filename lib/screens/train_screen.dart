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

class _TrainScreenState extends State<TrainScreen>
    with SingleTickerProviderStateMixin {
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  List<TrainWordData> _trainWords = GameRepository.getTrainWords(1);
  final List<String> _filledSlots = [];
  final List<String> _hiddenChoices = [];
  final AudioService _audio = AudioService();

  late AnimationController _trainAnimController;
  late Animation<double> _trainSlideAnimation;

  TrainWordData get _current =>
      _currentIndex < _trainWords.length ? _trainWords[_currentIndex] : _trainWords[0];

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

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('train');
    final unl = await StorageService.getUnlockedGameLevel('train');
    final idx = await StorageService.getGameLevelIndex('train', lvl);
    final words = GameRepository.getTrainWords(lvl);

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _trainWords = words;
        _currentIndex = (idx < words.length) ? idx : 0;
      });
      _startWord();
    }
  }

  void _switchLevel(int newLevel) async {
    final words = GameRepository.getTrainWords(newLevel);
    final idx = await StorageService.getGameLevelIndex('train', newLevel);
    await StorageService.saveGameLevel('train', newLevel);

    setState(() {
      _currentLevel = newLevel;
      _trainWords = words;
      _currentIndex = (idx < words.length) ? idx : 0;
    });

    _startWord();
    final titles = {1: 'Tunas Ajaib', 2: 'Petualang Kata', 3: 'Master Literasi'};
    _audio.speak('Tingkat $_currentLevel: ${titles[_currentLevel]}! Ayo susun kata ${_current.word}!');
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

    HapticFeedback.lightImpact();
    _audio.speak(syl);

    setState(() {
      _filledSlots.add(syl);
      _hiddenChoices.add(syl);
    });

    if (_filledSlots.length == _current.syllables.length) {
      final formed = _filledSlots.join('');
      if (formed == _current.word) {
        // Success
        HapticFeedback.mediumImpact();
        _audio.playSfx('tuut');
        Future.delayed(const Duration(milliseconds: 300), () {
          final syllablesSpelled = _current.syllables.join('... ');
          _audio.speak(
              '$syllablesSpelled... ${_current.word}! Tuut tuut, kereta meluncur!');
          _trainAnimController.forward();

          Future.delayed(const Duration(milliseconds: 1400), () async {
            if (!mounted) return;

            final hasMoreInLevel = _currentIndex + 1 < _trainWords.length;

            if (hasMoreInLevel) {
              // Regular word victory
              widget.onVictory(3);
              final solvedWord = _current.word;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => VictoryDialog(
                  title: 'Hebat! Kata "$solvedWord"!',
                  subtitle:
                      'Kereta meluncur membawa kata $solvedWord!',
                  onNext: () {
                    setState(() {
                      _currentIndex++;
                    });
                    StorageService.saveGameLevelIndex(
                        'train', _currentLevel, _currentIndex);
                    _startWord();
                  },
                ),
              );
            } else {
              // LEVEL GRADUATION / MILESTONE CEREMONY!
              widget.onVictory(15);
              final nextLvl = _currentLevel + 1;
              if (nextLvl <= 3) {
                await StorageService.saveUnlockedGameLevel('train', nextLvl);
                if (nextLvl > _unlockedLevel) {
                  setState(() {
                    _unlockedLevel = nextLvl;
                  });
                }
              }
              await StorageService.addTrophy('train_l$_currentLevel');
              await StorageService.saveGameLevelIndex(
                  'train', _currentLevel, 0);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => LevelMilestoneDialog(
                  gameTitle: 'Kereta Suku Kata',
                  completedLevel: _currentLevel,
                  onNextLevel: () {
                    _switchLevel(_currentLevel + 1);
                  },
                  onReplay: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                    _startWord();
                  },
                  onBackToMap: widget.onBack,
                ),
              );
            }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Top Control Bar: Level Selector Ribbon + Target Object Banner
          Row(
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
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _current.word,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF166534),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _audio.speak('Susun kata ${_current.word}!');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
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

          // Main Responsive Game Area (Track + Choices)
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 700,
                  height: 230,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Train Track & Train Assembly
                      SizedBox(
                        height: 135,
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
                              clipBehavior: Clip.none,
                              children: [
                                // Smokestack
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
                                // Animated Smoke Puffs
                                if (_trainAnimController.value > 0.02) ...[
                                  Positioned(
                                    top: -24 - (20 * _trainAnimController.value),
                                    left: 20 - (8 * _trainAnimController.value),
                                    child: Opacity(
                                      opacity: (1.0 - _trainAnimController.value).clamp(0.0, 1.0),
                                      child: Container(
                                        width: 14 + (10 * _trainAnimController.value),
                                        height: 14 + (10 * _trainAnimController.value),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(220),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(color: Color(0x20000000), blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -38 - (32 * _trainAnimController.value),
                                    left: 14 - (16 * _trainAnimController.value),
                                    child: Opacity(
                                      opacity: (0.85 - _trainAnimController.value).clamp(0.0, 1.0),
                                      child: Container(
                                        width: 20 + (16 * _trainAnimController.value),
                                        height: 20 + (16 * _trainAnimController.value),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(190),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(color: Color(0x20000000), blurRadius: 4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                          border:
                              Border.all(color: const Color(0xFFEAB308), width: 3),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFCA8A04), offset: Offset(0, 5)),
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
