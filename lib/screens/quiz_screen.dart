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

class QuizScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const QuizScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  List<QuizQuestionData> _quizList = GameRepository.getQuizQuestions(1);
  String? _selectedKey;
  String? _wobbleKey;
  bool _isAnswered = false;
  final AudioService _audio = AudioService();
  late AnimationController _wobbleController;

  QuizQuestionData get _current => _currentIndex < _quizList.length
      ? _quizList[_currentIndex]
      : _quizList[0];

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('quiz');
    final unl = await StorageService.getUnlockedGameLevel('quiz');
    final idx = await StorageService.getGameLevelIndex('quiz', lvl);
    final questions = GameRepository.getQuizQuestions(lvl);

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _quizList = questions;
        _currentIndex = (idx < questions.length) ? idx : 0;
      });
      _startQuestion();
    }
  }

  void _switchLevel(int newLevel) async {
    final questions = GameRepository.getQuizQuestions(newLevel);
    final idx = await StorageService.getGameLevelIndex('quiz', newLevel);
    await StorageService.saveGameLevel('quiz', newLevel);

    setState(() {
      _currentLevel = newLevel;
      _quizList = questions;
      _currentIndex = (idx < questions.length) ? idx : 0;
    });

    _startQuestion();
    final titles = {
      1: 'Tunas Ajaib',
      2: 'Petualang Kata',
      3: 'Master Literasi'
    };
    _audio.speak('Tingkat $_currentLevel: ${titles[_currentLevel]}! ${_current.question}');
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  void _startQuestion() {
    setState(() {
      _selectedKey = null;
      _wobbleKey = null;
      _isAnswered = false;
    });
    _audio.speak(_current.question);
  }

  void _onChoiceTapped(String choiceKey) {
    if (_isAnswered) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedKey = choiceKey;
    });

    if (choiceKey == _current.answerKey) {
      // Correct!
      HapticFeedback.mediumImpact();
      _audio.playSfx('ding');
      setState(() {
        _isAnswered = true;
      });

      Future.delayed(const Duration(milliseconds: 350), () async {
        final solvedQuestion = _current;
        _audio.speak('Benar! Ini ${solvedQuestion.answerName}! Hebat!');

        if (!mounted) return;

        final hasMoreInLevel = _currentIndex + 1 < _quizList.length;

        if (hasMoreInLevel) {
          widget.onVictory(3);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => VictoryDialog(
              title: 'Hebat! ${solvedQuestion.answerName}!',
              subtitle:
                  'Kamu pintar sekali menemukan ${solvedQuestion.answerName}!',
              onNext: () {
                setState(() {
                  _currentIndex++;
                });
                StorageService.saveGameLevelIndex(
                    'quiz', _currentLevel, _currentIndex);
                _startQuestion();
              },
            ),
          );
        } else {
          // LEVEL GRADUATION / MILESTONE CEREMONY!
          widget.onVictory(15);
          final nextLvl = _currentLevel + 1;
          if (nextLvl <= 3) {
            await StorageService.saveUnlockedGameLevel('quiz', nextLvl);
            if (nextLvl > _unlockedLevel) {
              setState(() {
                _unlockedLevel = nextLvl;
              });
            }
          }
          await StorageService.addTrophy('quiz_l$_currentLevel');
          await StorageService.saveGameLevelIndex('quiz', _currentLevel, 0);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => LevelMilestoneDialog(
              gameTitle: 'Kuis Sentuh Pintar',
              completedLevel: _currentLevel,
              onNextLevel: () {
                _switchLevel(_currentLevel + 1);
              },
              onReplay: () {
                setState(() {
                  _currentIndex = 0;
                });
                _startQuestion();
              },
              onBackToMap: widget.onBack,
            ),
          );
        }
      });
    } else {
      // Wrong choice - Gentle wobble shake & encouraging voice guidance
      HapticFeedback.lightImpact();
      setState(() {
        _wobbleKey = choiceKey;
      });
      _wobbleController.forward(from: 0.0);

      Future.delayed(const Duration(milliseconds: 250), () {
        _audio.speak(
            'Itu gambar ${choiceKey.toUpperCase()}. Coba cari ${_current.answerName} ya!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Control Bar: LevelSelectorRibbon + Question Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LevelSelectorRibbon(
                currentLevel: _currentLevel,
                unlockedLevel: _unlockedLevel,
                onSelectLevel: _switchLevel,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFC084FC), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF9333EA),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _current.question,
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6B21A8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _audio.speak(_current.question);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE047),
                          borderRadius: BorderRadius.circular(20),
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
                            const VectorIconWidget(
                              icon: 'speaker',
                              size: 16,
                              color: Color(0xFF854D0E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Dengar',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF854D0E),
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

          // 3 Big Choice Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _current.choices.map((key) {
              final isSelected = _selectedKey == key;
              final isCorrect = isSelected && key == _current.answerKey;
              final isWrong = isSelected && key != _current.answerKey;

              Color cardBg = Colors.white;
              Color borderColor = const Color(0xFFE2E8F0);
              Color shadowColor = const Color(0xFFCBD5E1);

              if (isCorrect) {
                cardBg = const Color(0xFFF0FDF4);
                borderColor = const Color(0xFF22C55E);
                shadowColor = const Color(0xFF16A34A);
              } else if (isWrong) {
                cardBg = const Color(0xFFFEF2F2);
                borderColor = const Color(0xFFEF4444);
                shadowColor = const Color(0xFFDC2626);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AnimatedBuilder(
                  animation: _wobbleController,
                  builder: (context, child) {
                    double wobbleOffset = 0.0;
                    if (_wobbleKey == key && _wobbleController.isAnimating) {
                      final val = _wobbleController.value;
                      // 3 full sine cycles decaying smoothly to 0
                      wobbleOffset =
                          math.sin(val * math.pi * 6) * 10.0 * (1.0 - val);
                    }
                    return Transform.translate(
                      offset: Offset(wobbleOffset, 0),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _onChoiceTapped(key),
                    child: Container(
                      width: 200,
                      height: 190,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: const Offset(0, 6),
                          ),
                          const BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ObjectIllustrationWidget(
                            illustrationKey: key,
                            size: 74,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            key.toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isCorrect
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF1E293B),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Bottom Hint
          Text(
            'Pencet salah satu gambar di atas untuk menjawab!',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
