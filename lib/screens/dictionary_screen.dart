import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dictionary_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/voice_record_dialog.dart';

class DictionaryScreen extends StatefulWidget {
  final Function(int count) onVictory;
  final VoidCallback onBack;

  const DictionaryScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final TextEditingController _searchController = TextEditingController();

  DictionaryCategory _selectedCategory = DictionaryCategory.all;
  String _selectedLetter = ''; // empty means all letters
  String _searchQuery = '';
  List<String> _learnedWords = [];
  bool _isLoading = true;

  // Flashcard 3D Mode State
  bool _isFlashcardMode = false;
  int _flashcardIndex = 0;
  bool _isCardFlipped = false;
  bool _isShuffled = false;
  List<DictionaryWordItem> _customFlashcardList = [];
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    _loadLearnedState();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLearnedState() async {
    final learned = await StorageService.getLearnedWords();
    if (mounted) {
      setState(() {
        _learnedWords = learned;
        _isLoading = false;
      });
    }
  }

  List<DictionaryWordItem> get _filteredWords {
    List<DictionaryWordItem> list = DictionaryRepository.getWordsByCategory(_selectedCategory);

    if (_selectedLetter.isNotEmpty) {
      list = list.where((w) => w.letter.toUpperCase() == _selectedLetter.toUpperCase()).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((w) {
        return w.word.toLowerCase().contains(q) ||
            w.syllables.any((s) => s.toLowerCase().contains(q)) ||
            w.sentence.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  List<DictionaryWordItem> get _activeFlashcardList {
    if (_isShuffled && _customFlashcardList.isNotEmpty) {
      return _customFlashcardList;
    }
    return _filteredWords;
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    _audio.playSfx('whoosh');

    if (_isCardFlipped) {
      _flipController.reverse();
      setState(() => _isCardFlipped = false);
    } else {
      _flipController.forward();
      setState(() => _isCardFlipped = true);
      final list = _activeFlashcardList;
      if (list.isNotEmpty && _flashcardIndex < list.length) {
        _audio.speak(list[_flashcardIndex].word);
      }
    }
  }

  void _nextCard() {
    final list = _activeFlashcardList;
    if (list.isEmpty) return;

    if (_flashcardIndex < list.length - 1) {
      HapticFeedback.mediumImpact();
      _audio.playSfx('pop');
      if (_isCardFlipped) {
        _flipController.reset();
        _isCardFlipped = false;
      }
      setState(() {
        _flashcardIndex++;
      });
    } else {
      _celebrateDeckCompletion();
    }
  }

  void _prevCard() {
    if (_flashcardIndex > 0) {
      HapticFeedback.mediumImpact();
      _audio.playSfx('pop');
      if (_isCardFlipped) {
        _flipController.reset();
        _isCardFlipped = false;
      }
      setState(() {
        _flashcardIndex--;
      });
    }
  }

  void _shuffleCards() {
    HapticFeedback.mediumImpact();
    _audio.playSfx('sparkle');
    final list = List<DictionaryWordItem>.from(_filteredWords);
    list.shuffle();
    if (_isCardFlipped) {
      _flipController.reset();
      _isCardFlipped = false;
    }
    setState(() {
      _isShuffled = true;
      _customFlashcardList = list;
      _flashcardIndex = 0;
    });
    _audio.speak('Kartu diacak! Siap untuk tantangan seru?');
  }

  void _resetFlashcardDeck() {
    _isShuffled = false;
    _customFlashcardList = [];
    _flashcardIndex = 0;
    if (_isCardFlipped) {
      _flipController.reset();
      _isCardFlipped = false;
    }
  }

  void _playClueAudio(DictionaryWordItem word) {
    HapticFeedback.lightImpact();
    _audio.speak('Huruf awalnya huruf ${word.letter}! Kata apakah ini? Coba tebak!');
  }

  void _markCardAsRemembered(DictionaryWordItem word) async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('star');
    _audio.speak('Hebat! Kamu mengingat kata ${word.word}!');

    final newlyLearned = await StorageService.markWordLearned(word.word);
    if (newlyLearned) {
      widget.onVictory(1);
      final updated = await StorageService.getLearnedWords();
      setState(() {
        _learnedWords = updated;
      });
    }
    StorageService.updateDailyMissionProgress('dict', 1);

    final list = _activeFlashcardList;
    if (_flashcardIndex < list.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _isFlashcardMode) {
          _nextCard();
        }
      });
    }
  }

  void _celebrateDeckCompletion() {
    HapticFeedback.heavyImpact();
    _audio.playSfx('win');
    _audio.speak('Luar biasa! Kamu telah menyelesaikan semua kartu pintar!');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Tantangan Selesai!',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0369A1),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hebat sekali! Kamu sudah menuntaskan rangkaian kartu flashcard di kategori ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _flashcardIndex = 0;
                  if (_isCardFlipped) {
                    _flipController.reset();
                    _isCardFlipped = false;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ulangi Lagi 🔄',
                style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWordInspector(DictionaryWordItem word) async {
    _audio.playSfx('pop');
    _audio.speak(word.word);
    StorageService.updateDailyMissionProgress('dict', 1);

    final wasNewlyLearned = await StorageService.markWordLearned(word.word);
    if (wasNewlyLearned) {
      widget.onVictory(1);
      _audio.playSfx('sparkle');
      final updatedList = await StorageService.getLearnedWords();

      if (updatedList.length >= 10) {
        await StorageService.addTrophy('dictionary_explorer');
      }
      if (updatedList.length >= 25) {
        await StorageService.addTrophy('dictionary_master');
      }

      if (mounted) {
        setState(() {
          _learnedWords = updatedList;
        });
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _WordInspectorDialog(
        word: word,
        isNewlyLearned: wasNewlyLearned,
        audio: _audio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
    }

    final availableLetters = DictionaryRepository.getAvailableLetters();
    final words = _filteredWords;
    final totalLearned = _learnedWords.length;
    final totalWords = DictionaryRepository.allWords.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFFEF9C3),
            Color(0xFFF0FDF4),
          ],
        ),
      ),
      child: Column(
        children: [
          // 1. TOP APP BAR / TOOLBAR
          _buildTopBar(totalLearned, totalWords),

          // 2. CATEGORY TABS & SEARCH
          _buildCategoryRibbon(),

          // 3. A-Z ALPHABET QUICK FILTER BAR
          if (!_isFlashcardMode) _buildAlphabetRibbon(availableLetters),

          // 4. MAIN WORD GRID OR 3D FLASHCARD
          Expanded(
            child: _isFlashcardMode
                ? _buildFlashcardView()
                : (words.isEmpty ? _buildEmptyState() : _buildWordsGrid(words)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(int learnedCount, int totalCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFACC15), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⬅️', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 4),
                  Text(
                    'Peta',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title
          MascotWidget(size: isMobile ? 30 : 38),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        isMobile ? 'Kamus Miko' : 'Kamus Bergambar & Suara Miko',
                        style: GoogleFonts.fredoka(
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0369A1),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('📚', style: TextStyle(fontSize: 16)),
                  ],
                ),
                if (!isMobile)
                  Text(
                    'Sentuh kata untuk mendengar suku kata & contoh kalimat!',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Mode Switcher Toggle Pill
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModePill(
                  icon: '📚',
                  label: isMobile ? 'Kamus' : 'Kamus Grid',
                  isActive: !_isFlashcardMode,
                  onTap: () {
                    if (_isFlashcardMode) {
                      _audio.playSfx('ding');
                      setState(() {
                        _isFlashcardMode = false;
                      });
                    }
                  },
                ),
                _buildModePill(
                  icon: '🃏',
                  label: isMobile ? 'Kartu' : 'Flashcard 3D',
                  isActive: _isFlashcardMode,
                  onTap: () {
                    if (!_isFlashcardMode) {
                      _audio.playSfx('sparkle');
                      setState(() {
                        _isFlashcardMode = true;
                        _resetFlashcardDeck();
                      });
                      _audio.speak('Mode Kartu Pintar! Tebak gambar dan balik kartunya!');
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 6 : 10),

          // Learned Words Pill Counter
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFF16A34A), offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  isMobile ? '$learnedCount/$totalCount' : '$learnedCount / $totalCount Kata',
                  style: GoogleFonts.fredoka(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRibbon() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Category chips scroll
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DictionaryCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = DictionaryCategory.values[index];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    _audio.playSfx('ding');
                    setState(() {
                      _selectedCategory = cat;
                      _resetFlashcardDeck();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? cat.color : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cat.color.withAlpha(90),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : const [
                              BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2)),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Search Field
          SizedBox(
            width: 170,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _resetFlashcardDeck();
                });
              },
              style: GoogleFonts.fredoka(fontSize: 13, color: const Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Cari kata...',
                hintStyle: GoogleFonts.fredoka(fontSize: 12, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _resetFlashcardDeck();
                          });
                        },
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF0284C7), width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabetRibbon(List<String> letters) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: letters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = _selectedLetter.isEmpty;
            return GestureDetector(
              onTap: () {
                _audio.playSfx('ding');
                setState(() {
                  _selectedLetter = '';
                  _resetFlashcardDeck();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAll ? const Color(0xFF0284C7) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAll ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Semua A-Z',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAll ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }

          final letter = letters[index - 1];
          final isSelected = _selectedLetter == letter;

          return GestureDetector(
            onTap: () {
              _audio.playSfx('ding');
              setState(() {
                _selectedLetter = isSelected ? '' : letter;
                _resetFlashcardDeck();
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD97706) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x33D97706),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordsGrid(List<DictionaryWordItem> words) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute adaptive column count
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 850) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 5;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.88,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            final isLearned = _learnedWords.contains(word.word.toLowerCase());
            return _buildWordCard(word, isLearned);
          },
        );
      },
    );
  }

  Widget _buildWordCard(DictionaryWordItem word, bool isLearned) {
    final syllableText = word.syllables.join(' • ');

    return GestureDetector(
      onTap: () => _openWordInspector(word),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isLearned ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
            width: isLearned ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isLearned ? const Color(0x1F22C55E) : const Color(0x0F000000),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background accent glow on top
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: word.accentColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Row: Letter Badge & Learned Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: word.accentColor.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              word.letter,
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: word.accentColor,
                              ),
                            ),
                          ),
                        ),
                        if (isLearned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 2),
                                Text(
                                  'Paham',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Big Illustration
                    Hero(
                      tag: 'dict_illus_${word.id}',
                      child: ObjectIllustrationWidget(
                        illustrationKey: word.illustrationKey,
                        size: 64,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Word Text
                    Text(
                      word.word,
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // Syllables Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        syllableText,
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              // Mini Speaker Audio Button in bottom right
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
                  ),
                  child: const Center(
                    child: Text('🔊', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MascotWidget(size: 64),
          const SizedBox(height: 12),
          Text(
            'Kata belum ditemukan!',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah kata kunci pencarian atau pilih kategori lain.',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategory = DictionaryCategory.all;
                _selectedLetter = '';
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              'Tampilkan Semua Kata',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? const [
                  BoxShadow(color: Color(0x330284C7), blurRadius: 4, offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardView() {
    final list = _activeFlashcardList;
    if (list.isEmpty) {
      return _buildEmptyState();
    }

    final safeIndex = _flashcardIndex.clamp(0, list.length - 1);
    final word = list[safeIndex];
    final isLearned = _learnedWords.contains(word.word);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sub-toolbar: Deck counter, Status badge, Shuffle button
            Container(
              constraints: const BoxConstraints(maxWidth: 440),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          '🃏 Kartu ${safeIndex + 1} / ${list.length}',
                          style: GoogleFonts.fredoka(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                      if (isLearned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                'Sudah Dihafal',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  GestureDetector(
                    onTap: _shuffleCards,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isShuffled
                              ? [const Color(0xFFFEF08A), const Color(0xFFFDE047)]
                              : [Colors.white, const Color(0xFFF8FAFC)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isShuffled ? const Color(0xFFEAB308) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔀', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            _isShuffled ? 'Diacak' : 'Acak Kartu',
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _isShuffled ? const Color(0xFF854D0E) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3D Flip Card Container
            GestureDetector(
              onTap: _flipCard,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -150) {
                    _nextCard();
                  } else if (details.primaryVelocity! > 150) {
                    _prevCard();
                  }
                }
              },
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isBack = angle > (math.pi / 2);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildFlashcardBack(word, isLearned, isMobile),
                          )
                        : _buildFlashcardFront(word, isLearned, isMobile),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Navigation Controls
            Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Card Button
                  ElevatedButton(
                    onPressed: safeIndex > 0 ? _prevCard : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0369A1),
                      disabledBackgroundColor: Colors.white54,
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: safeIndex > 0 ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: safeIndex > 0 ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: 10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⬅️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Sebelumnya',
                          style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Flip Card Button
                  ElevatedButton(
                    onPressed: _flipCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: const Color(0xFF78350F),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFFD97706), width: 2),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 22,
                        vertical: 11,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔄', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          _isCardFlipped ? 'Lihat Gambar' : 'Balik Kartu',
                          style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),

                  // Next Card Button
                  ElevatedButton(
                    onPressed: _nextCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF0369A1), width: 1.5),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                        vertical: 10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          safeIndex < list.length - 1 ? 'Lanjut' : 'Selesai',
                          style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Text('➡️', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              '💡 Tips: Geser layar ke kiri/kanan untuk ganti kartu, sentuh kartu untuk membalik!',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardFront(DictionaryWordItem word, bool isLearned, bool isMobile) {
    return Container(
      width: isMobile ? 320 : 380,
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: word.accentColor.withAlpha(160), width: 3),
        boxShadow: [
          BoxShadow(
            color: word.accentColor.withAlpha(50),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          const BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Header: Category & First Letter Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: word.category.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: word.category.color.withAlpha(80), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(word.category.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      word.category.label,
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: word.category.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFACC15), width: 1.5),
                ),
                child: Text(
                  'Huruf ${word.letter}',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ),
            ],
          ),

          // Central Illustration & Mystery Prompt
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: word.accentColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ObjectIllustrationWidget(
                    illustrationKey: word.illustrationKey,
                    size: 96,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tebak Gambar Ini! 🤔',
                style: GoogleFonts.fredoka(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              // Audio clue button
              GestureDetector(
                onTap: () => _playClueAudio(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔊', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'Petunjuk Huruf "${word.letter}"',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Footer Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👆', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  'Sentuh kartu untuk melihat jawaban & suku kata!',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardBack(DictionaryWordItem word, bool isLearned, bool isMobile) {
    return Container(
      width: isMobile ? 320 : 380,
      height: 380,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: word.accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: word.accentColor.withAlpha(55),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          const BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Category Pill & Speak Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'Jawaban Benar',
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _audio.playSfx('ding');
                  _audio.speak(word.word);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔊', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'Bunyikan',
                        style: GoogleFonts.fredoka(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Big Word Typography & Syllables
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.word,
                style: GoogleFonts.fredoka(
                  fontSize: isMobile ? 32 : 36,
                  fontWeight: FontWeight.w900,
                  color: word.accentColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Interactive Syllable Pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: word.syllables.map((syl) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _audio.playSfx('pop');
                      _audio.speak(syl);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF9C3), Color(0xFFFEF08A)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFACC15), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFCA8A04), offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            syl,
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF854D0E),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.volume_up, size: 14, color: Color(0xFFCA8A04)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Example Sentence Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    word.sentence,
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _audio.speak(word.sentence);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7), size: 16),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: Remember (+1 ⭐) & Inspector Modal
          Row(
            children: [
              Expanded(
                child: isLearned
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              'Sudah Dihafal',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => _markCardAsRemembered(word),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              'Hafal (+1 ⭐)',
                              style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              // Open full modal dialog
              OutlinedButton(
                onPressed: () => _openWordInspector(word),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0369A1),
                  side: const BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'Detail',
                      style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// INTERACTIVE WORD INSPECTOR MODAL DIALOG
/// With interactive syllable breakdown buttons, phonic audio, sentences & fun facts!
/// ---------------------------------------------------------------------------
class _WordInspectorDialog extends StatefulWidget {
  final DictionaryWordItem word;
  final bool isNewlyLearned;
  final AudioService audio;

  const _WordInspectorDialog({
    required this.word,
    required this.isNewlyLearned,
    required this.audio,
  });

  @override
  State<_WordInspectorDialog> createState() => _WordInspectorDialogState();
}

class _WordInspectorDialogState extends State<_WordInspectorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String? _activeSyllable;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _playSyllable(String syl) {
    setState(() {
      _activeSyllable = syl;
    });
    widget.audio.playSfx('pop');
    widget.audio.speak(syl);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _activeSyllable == syl) {
        setState(() {
          _activeSyllable = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: word.accentColor, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. TOP HEADER RIBBON
                    _buildModalHeader(word),

                    // 2. MAIN BODY
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Newly learned celebratory toast banner
                          if (widget.isNewlyLearned) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEAB308), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🌟', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Hore! Kamu dapat +1 Bintang mempelajari kata ini!',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Illustration & Big Word Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ObjectIllustrationWidget(
                                illustrationKey: word.illustrationKey,
                                size: 84,
                              ),
                              const SizedBox(width: 18),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      word.word,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: word.accentColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Huruf Awal: ${word.letter}',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: word.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 3. INTERACTIVE SYLLABLE BREAKDOWN BUTTONS
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('👉', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Sentuh suku katanya untuk membunyikan:',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: word.syllables.map((syl) {
                                    final isActive = _activeSyllable == syl;
                                    return GestureDetector(
                                      onTap: () => _playSyllable(syl),
                                      child: AnimatedScale(
                                        scale: isActive ? 1.15 : 1.0,
                                        duration: const Duration(milliseconds: 150),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isActive
                                                  ? [const Color(0xFFFDE047), const Color(0xFFFACC15)]
                                                  : [Colors.white, const Color(0xFFF1F5F9)],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isActive ? const Color(0xFFD97706) : word.accentColor,
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isActive
                                                    ? const Color(0x40D97706)
                                                    : const Color(0x15000000),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🔊', style: TextStyle(fontSize: 14)),
                                              const SizedBox(width: 6),
                                              Text(
                                                syl,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: isActive
                                                      ? const Color(0xFF92400E)
                                                      : const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 4. ACTION BUTTONS: Baca Utuh, Fonik, Kalimat, Suaraku
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.audio.playSfx('sparkle');
                                  widget.audio.speak(word.word);
                                },
                                icon: const Text('🗣️', style: TextStyle(fontSize: 16)),
                                label: Text(
                                  'Baca Utuh',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.audio.playSfx('ding');
                                  widget.audio.speak(word.phonicSound);
                                },
                                icon: const Text('🔤', style: TextStyle(fontSize: 16)),
                                label: Text(
                                  'Bunyi Fonik',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.audio.playSfx('cheer');
                                  widget.audio.speak(word.sentence);
                                },
                                icon: const Text('📖', style: TextStyle(fontSize: 16)),
                                label: Text(
                                  'Kalimat',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => VoiceRecordDialog(
                                      recordingKey: 'dict_${word.word}',
                                      wordOrLetter: word.word,
                                      displayLabel: 'Kata ${word.word}',
                                      category: 'Kata',
                                      illustrationKey: word.illustrationKey,
                                      phoneticTip: word.sentence,
                                    ),
                                  );
                                },
                                icon: const Text('🎙️', style: TextStyle(fontSize: 16)),
                                label: Text(
                                  'Suaraku',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7E22CE),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 5. CONTOH KALIMAT DENGAN MIKO
                          GestureDetector(
                            onTap: () {
                              widget.audio.playSfx('ding');
                              widget.audio.speak(word.sentence);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  const MascotWidget(size: 42),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Contoh Kalimat Miko:',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2563EB),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text('🔊', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '"${word.sentence}"',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 6. LAMPU FAKTA MENARIK
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tahukah Kamu?',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        word.funFact,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12,
                                          color: const Color(0xFF78350F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(DictionaryWordItem word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: word.accentColor,
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(word.category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                word.category.label,
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              widget.audio.playSfx('pop');
              Navigator.of(context).pop();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
