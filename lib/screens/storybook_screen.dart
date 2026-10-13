import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';

class StorybookScreen extends StatefulWidget {
  final Function(int stars) onVictory;
  final VoidCallback onBack;

  const StorybookScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends State<StorybookScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  StoryBook? _selectedBook;
  int _currentPageIndex = 0;
  Set<String> _completedStories = {};

  // Karaoke narration state
  bool _isPlayingNarration = false;
  int? _karaokeWordIndex;
  Timer? _karaokeTimer;

  // Interactive touched item animation
  String? _activeInteractiveId;
  String? _activeBubbleText;
  Timer? _bubbleTimer;

  // Tapped word feedback
  String? _lastTappedWord;

  @override
  void initState() {
    super.initState();
    _loadCompletedStories();
  }

  void _loadCompletedStories() async {
    final list = await StorageService.getCompletedStories();
    if (mounted) {
      setState(() {
        _completedStories = list.toSet();
      });
    }
  }

  @override
  void dispose() {
    _karaokeTimer?.cancel();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  void _openBook(StoryBook book) {
    HapticFeedback.mediumImpact();
    _audio.playSfx('whoosh');
    setState(() {
      _selectedBook = book;
      _currentPageIndex = 0;
      _karaokeWordIndex = null;
      _isPlayingNarration = false;
      _activeInteractiveId = null;
      _activeBubbleText = null;
    });

    _audio.speak('Buku ${book.title}! Ayo kita baca bersama!');
  }

  void _closeBook() {
    _karaokeTimer?.cancel();
    _bubbleTimer?.cancel();
    _audio.stop();
    setState(() {
      _selectedBook = null;
      _isPlayingNarration = false;
      _karaokeWordIndex = null;
    });
  }

  void _goToPage(int newIndex) {
    if (_selectedBook == null) return;
    if (newIndex < 0 || newIndex >= _selectedBook!.pages.length) return;

    _karaokeTimer?.cancel();
    _bubbleTimer?.cancel();
    _audio.stop();
    HapticFeedback.lightImpact();
    _audio.playSfx('whoosh');

    setState(() {
      _currentPageIndex = newIndex;
      _karaokeWordIndex = null;
      _isPlayingNarration = false;
      _activeInteractiveId = null;
      _activeBubbleText = null;
      _lastTappedWord = null;
    });

    // Auto-read page sentence for child
    _playPageNarration();
  }

  void _playPageNarration() {
    if (_selectedBook == null) return;
    final page = _selectedBook!.pages[_currentPageIndex];
    final words = page.words;
    if (words.isEmpty) return;

    _karaokeTimer?.cancel();
    _audio.stop();

    setState(() {
      _isPlayingNarration = true;
      _karaokeWordIndex = 0;
    });

    _audio.speak(page.sentence);

    // Approximate speech pacing per word for karaoke highlight
    int currentStep = 0;
    const wordDurationMs = 520;

    _karaokeTimer = Timer.periodic(const Duration(milliseconds: wordDurationMs), (timer) {
      if (!mounted || !_isPlayingNarration) {
        timer.cancel();
        return;
      }

      currentStep++;
      if (currentStep < words.length) {
        setState(() {
          _karaokeWordIndex = currentStep;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isPlayingNarration = false;
            _karaokeWordIndex = null;
          });
        }
      }
    });
  }

  void _onWordTapped(String rawWord) {
    HapticFeedback.lightImpact();
    final cleanWord = rawWord.replaceAll(RegExp(r'[^\w]'), '');
    if (cleanWord.isEmpty) return;

    setState(() {
      _lastTappedWord = cleanWord;
    });

    _audio.playSfx('ding');
    _audio.speak('$cleanWord!');
  }

  void _onInteractiveItemTapped(StoryInteractiveItem item) {
    HapticFeedback.mediumImpact();
    _bubbleTimer?.cancel();

    setState(() {
      _activeInteractiveId = item.id;
      _activeBubbleText = '${item.name}: "${item.soundText}"';
    });

    _audio.playSfx('star');
    _audio.speak(item.soundText);

    _bubbleTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _activeBubbleText = null;
          _activeInteractiveId = null;
        });
      }
    });
  }

  void _finishStory() {
    HapticFeedback.heavyImpact();
    _audio.playSfx('star');
    widget.onVictory(3);

    if (_selectedBook != null) {
      _completedStories.add(_selectedBook!.id);
      StorageService.saveCompletedStories(_completedStories.toList());
      setState(() {});
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VictoryDialog(
        title: 'Tamat! Kamu Pembaca Hebat!',
        subtitle: 'Selamat! Kamu telah membaca seluruh cerita "${_selectedBook?.title}"!',
        onNext: () {
          _closeBook();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFEDE9FE),
            Color(0xFFE0E7FF),
          ],
        ),
      ),
      child: _selectedBook == null
          ? _buildLibraryShelf()
          : _buildStoryReader(),
    );
  }

  // ==========================================
  // 1. RAK BUKU CERITA (LIBRARY SELECTION)
  // ==========================================
  Widget _buildLibraryShelf() {
    return Column(
      children: [
        // Top Toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildBackButton(onTap: widget.onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFC084FC), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22A855F7), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'PULAU BUKU CERITA AJAIB',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF7E22CE),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8B4FE)),
                        ),
                        child: Text(
                          '${_completedStories.length}/${sampleStoryBooks.length} Tamat ⭐',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7E22CE),
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

        // Book Cards Grid / Row
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: sampleStoryBooks.map((book) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildBookCoverCard(book),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCoverCard(StoryBook book) {
    final isCompleted = _completedStories.contains(book.id);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: book.coverColor, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: book.coverColor.withOpacity(0.35),
            offset: const Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Book Header Cover Spine
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
               color: book.coverColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    book.ageRange,
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: book.coverColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '⭐ Tamat',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ],
                Text(
                  '${book.pages.length} Halaman',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Illustration Art
          Expanded(
            child: Container(
              color: book.accentColor.withOpacity(0.18),
              child: Center(
                child: Hero(
                  tag: 'book_cover_${book.id}',
                  child: ObjectIllustrationWidget(
                    illustrationKey: book.coverIllustration,
                    size: 95,
                  ),
                ),
              ),
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => _openBook(book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: book.coverColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: book.coverColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📖 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Buka Cerita',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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
    );
  }

  // ==========================================
  // 2. LAYAR MEMBACA BUKU (STORY READER)
  // ==========================================
  Widget _buildStoryReader() {
    final book = _selectedBook!;
    final page = book.pages[_currentPageIndex];
    final isLastPage = _currentPageIndex == book.pages.length - 1;

    return Column(
      children: [
        // Reader Header Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              _buildBackButton(
                onTap: _closeBook,
                icon: Icons.menu_book_rounded,
                tooltip: 'Kembali ke Rak Buku',
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: book.coverColor, width: 2),
                ),
                child: Row(
                  children: [
                    Text(
                      book.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: book.coverColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: book.coverColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Hal ${_currentPageIndex + 1}/${book.pages.length}',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: book.coverColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Button: Listen / Re-read Page
              ElevatedButton.icon(
                onPressed: _playPageNarration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlayingNarration ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: Icon(
                  _isPlayingNarration ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                  _isPlayingNarration ? 'Sedang Membaca...' : 'Dengarkan Cerita',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Two-Panel Book Reader
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                // Panel Kiri: Ilustrasi Interaktif
                Expanded(
                  flex: 5,
                  child: _buildInteractiveIllustrationCanvas(page),
                ),
                const SizedBox(width: 12),

                // Panel Kanan: Kotak Teks Cerita (Karaoke & Touch-to-Speak)
                Expanded(
                  flex: 5,
                  child: _buildKaraokeTextPanel(page, book),
                ),
              ],
            ),
          ),
        ),

        // Bottom Page Navigator Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Sebelumnya
              ElevatedButton.icon(
                onPressed: _currentPageIndex > 0 ? () => _goToPage(_currentPageIndex - 1) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF475569),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                label: Text(
                  'Sebelumnya',
                  style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),

              // Page Dots Indicator
              Row(
                children: List.generate(book.pages.length, (idx) {
                  final isActive = idx == _currentPageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive ? book.coverColor : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              // Tombol Selanjutnya / Tamat
              isLastPage
                  ? ElevatedButton.icon(
                      onPressed: _finishStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Text('⭐', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'Selesai & Rayakan!',
                        style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _goToPage(_currentPageIndex + 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: book.coverColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      label: Text(
                        'Selanjutnya',
                        style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. KANVAS ILUSTRASI INTERAKTIF
  // ==========================================
  Widget _buildInteractiveIllustrationCanvas(StoryPage page) {
    return Container(
      decoration: BoxDecoration(
        color: page.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), offset: Offset(0, 6), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Background subtle decorations
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: _GardenBackgroundPatternPainter(),
                ),
              ),
            ),

            // Interactive Items
            ...page.interactiveItems.map((item) {
              final isTouched = _activeInteractiveId == item.id;
              return Align(
                alignment: item.alignment,
                child: GestureDetector(
                  onTap: () => _onInteractiveItemTapped(item),
                  child: AnimatedScale(
                    scale: isTouched ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.elasticOut,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.85),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ObjectIllustrationWidget(
                        illustrationKey: item.illustrationKey,
                        size: item.size,
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Floating Speech Bubble for touched item
            if (_activeBubbleText != null)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: AnimatedOpacity(
                  opacity: _activeBubbleText != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x338B5CF6), offset: Offset(0, 3), blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🔊', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _activeBubbleText!,
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF581C87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Tip Sentuh Gambar
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👆', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'Sentuh objek di gambar!',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. KOTAK TEKS KARAOKE & TOUCH-TO-SPEAK
  // ==========================================
  Widget _buildKaraokeTextPanel(StoryPage page, StoryBook book) {
    final words = page.words;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Parchment soft paper
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Teks
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      'Teks Cerita',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_lastTappedWord != null)
                Text(
                  'Lafal: "${_lastTappedWord}" 🔊',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0284C7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Karaoke Word Wrap
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: List.generate(words.length, (idx) {
                  final word = words[idx];
                  final isKaraokeActive = _karaokeWordIndex == idx;
                  final isLastTapped = _lastTappedWord == word.replaceAll(RegExp(r'[^\w]'), '');

                  return GestureDetector(
                    onTap: () => _onWordTapped(word),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isKaraokeActive
                            ? const Color(0xFFFDE047) // Highlight kuning cerah karaoke
                            : isLastTapped
                                ? const Color(0xFFBAE6FD) // Highlight sentuhan kata
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isKaraokeActive
                            ? Border.all(color: const Color(0xFFEAB308), width: 2)
                            : isLastTapped
                                ? Border.all(color: const Color(0xFF38BDF8), width: 1.5)
                                : Border.all(color: Colors.transparent),
                        boxShadow: isKaraokeActive
                            ? [
                                const BoxShadow(
                                  color: Color(0x33F59E0B),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        word,
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: isKaraokeActive ? FontWeight.w900 : FontWeight.w600,
                          color: isKaraokeActive
                              ? const Color(0xFF92400E)
                              : const Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Bottom Prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sentuh kata apa saja di atas untuk mendengarkan lafalnya satu per satu!',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton({
    required VoidCallback onTap,
    IconData icon = Icons.arrow_back_rounded,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? 'Kembali',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: const Color(0xFF334155), size: 20),
          ),
        ),
      ),
    );
  }
}

class _GardenBackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF16A34A);
    // Draw subtle playful dots & leaf shapes
    for (double x = 20; x < size.width; x += 60) {
      for (double y = 20; y < size.height; y += 60) {
        canvas.drawCircle(Offset(x, y), 3, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
