import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/vector_illustrations.dart';

class StickerPlaygroundScreen extends StatefulWidget {
  final List<String> unlockedStickers;
  final VoidCallback onBack;
  final VoidCallback onOpenAlbum;

  const StickerPlaygroundScreen({
    super.key,
    required this.unlockedStickers,
    required this.onBack,
    required this.onOpenAlbum,
  });

  @override
  State<StickerPlaygroundScreen> createState() => _StickerPlaygroundScreenState();
}

class _StickerPlaygroundScreenState extends State<StickerPlaygroundScreen> with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  List<PlacedSticker> _placedStickers = [];
  String? _selectedUniqueId;
  bool _isDrawerOpen = true;
  bool _isLoading = true;

  // Multi-Theme State
  String _currentTheme = 'garden'; // 'garden', 'ocean', 'galaxy'

  // Interactive Sound & Bounce State
  String? _bouncingUniqueId;
  String? _activeSpeechBubbleId;
  String? _activeSpeechBubbleText;
  Timer? _speechBubbleTimer;

  // Animation controller for rotating sun or moon
  late AnimationController _sunAnimController;

  @override
  void initState() {
    super.initState();
    _sunAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadPlacedStickers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.speak('Selamat datang di Taman Kreasi! Hias taman dengan stikermu!');
    });
  }

  @override
  void dispose() {
    _speechBubbleTimer?.cancel();
    _sunAnimController.dispose();
    super.dispose();
  }

  void _loadPlacedStickers() async {
    final loaded = await StorageService.getPlacedStickers();
    final theme = await StorageService.getPlaygroundTheme();
    if (mounted) {
      setState(() {
        _placedStickers = loaded;
        _currentTheme = theme;
        _isLoading = false;
      });
    }
  }

  void _saveStickers() {
    StorageService.savePlacedStickers(_placedStickers);
  }

  void _switchTheme(String newTheme) {
    if (_currentTheme == newTheme) return;
    HapticFeedback.mediumImpact();
    _audio.playSfx('whoosh');

    setState(() {
      _currentTheme = newTheme;
    });
    StorageService.savePlaygroundTheme(newTheme);

    if (newTheme == 'garden') {
      _audio.speak('Pemandangan Kebun Siang Ceria!');
    } else if (newTheme == 'ocean') {
      _audio.speak('Pemandangan Dunia Bawah Laut Ajaib!');
    } else if (newTheme == 'galaxy') {
      _audio.speak('Pemandangan Galaksi Malam Penuh Bintang!');
    }
  }

  void _addStickerToCanvas(String stickerId) {
    final item = GameRepository.stickers.firstWhere(
      (s) => s.id == stickerId,
      orElse: () => GameRepository.stickers.first,
    );

    // Place slightly around the center
    final random = math.Random();
    final newX = (0.35 + random.nextDouble() * 0.3).clamp(0.1, 0.85);
    final newY = (0.25 + random.nextDouble() * 0.3).clamp(0.15, 0.65);

    final uniqueId = '${stickerId}_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999)}';
    final newPlaced = PlacedSticker(
      uniqueId: uniqueId,
      stickerId: stickerId,
      x: newX,
      y: newY,
      scale: 1.0,
    );

    setState(() {
      _placedStickers.add(newPlaced);
      _selectedUniqueId = uniqueId;
      _bouncingUniqueId = uniqueId;
    });

    _saveStickers();

    // Check 12th trophy milestone!
    if (_placedStickers.length >= 3) {
      StorageService.addTrophy('sticker_artist_master');
    }

    _audio.playSfx(item.sfx);
    _audio.speak('Hore, stiker ${item.name} ditempel!');

    Timer(const Duration(milliseconds: 600), () {
      if (mounted && _bouncingUniqueId == uniqueId) {
        setState(() {
          _bouncingUniqueId = null;
        });
      }
    });
  }

  void _removeSticker(String uniqueId) {
    setState(() {
      _placedStickers.removeWhere((s) => s.uniqueId == uniqueId);
      if (_selectedUniqueId == uniqueId) {
        _selectedUniqueId = null;
      }
      if (_activeSpeechBubbleId == uniqueId) {
        _activeSpeechBubbleId = null;
        _activeSpeechBubbleText = null;
      }
    });
    _saveStickers();
    _audio.speak('Stiker dilepas dari taman.');
  }

  void _cycleStickerScale(PlacedSticker sticker) {
    setState(() {
      if (sticker.scale < 1.0) {
        sticker.scale = 1.0;
      } else if (sticker.scale < 1.3) {
        sticker.scale = 1.35;
      } else {
        sticker.scale = 0.8;
      }
    });
    _saveStickers();
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧹', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                'Bersihkan Taman?',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah kamu ingin mengosongkan semua stiker untuk menghias ulang?',
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _placedStickers.clear();
                          _selectedUniqueId = null;
                        });
                        _saveStickers();
                        _audio.speak('Taman sudah bersih dan siap dihias lagi!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Bersihkan',
                        style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStickerTapped(PlacedSticker sticker) {
    HapticFeedback.mediumImpact();
    _speechBubbleTimer?.cancel();

    final item = GameRepository.stickers.firstWhere(
      (s) => s.id == sticker.stickerId,
      orElse: () => GameRepository.stickers.first,
    );

    setState(() {
      _selectedUniqueId = sticker.uniqueId;
      _bouncingUniqueId = sticker.uniqueId;
      _activeSpeechBubbleId = sticker.uniqueId;
      _activeSpeechBubbleText = item.soundQuote.isNotEmpty
          ? item.soundQuote
          : '${item.name}: ${item.description}';
    });

    _audio.playSfx(item.sfx);
    _audio.speak(item.soundQuote.isNotEmpty
        ? item.soundQuote
        : '${item.name}! ${item.description}!');

    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _bouncingUniqueId == sticker.uniqueId) {
        setState(() {
          _bouncingUniqueId = null;
        });
      }
    });

    _speechBubbleTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _activeSpeechBubbleId = null;
          _activeSpeechBubbleText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // 1. Theme-Based Scenery & Interactive Canvas Area
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Dynamic Scenery Custom Background
                  Positioned.fill(
                    child: _buildCurrentBackground(constraints.maxWidth, constraints.maxHeight),
                  ),

                  // Mascot Miko on the ground corner cheering
                  Positioned(
                    left: 16,
                    bottom: _isDrawerOpen ? 140 : 20,
                    child: GestureDetector(
                      onTap: () {
                        if (_currentTheme == 'ocean') {
                          _audio.speak('Bawah laut ini penuh keajaiban! Ayo tempel stiker kesukaanmu!');
                        } else if (_currentTheme == 'galaxy') {
                          _audio.speak('Langit malam berbintang sungguh mempesona! Hias dengan stiker ajaib!');
                        } else {
                          _audio.speak('Tamanmu cantik sekali! Tempel dan geser stiker sesukamu ya!');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const MascotWidget(size: 38),
                            const SizedBox(width: 8),
                            Text(
                              _currentTheme == 'ocean'
                                  ? 'Petualang Laut!'
                                  : _currentTheme == 'galaxy'
                                      ? 'Penjelajah Bintang!'
                                      : 'Ayo Hias Taman!',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Placed Stickers on Canvas
                  ..._placedStickers.map((sticker) {
                    final isSelected = sticker.uniqueId == _selectedUniqueId;
                    final item = GameRepository.stickers.firstWhere(
                      (s) => s.id == sticker.stickerId,
                      orElse: () => GameRepository.stickers.first,
                    );

                    final posX = sticker.x * constraints.maxWidth;
                    final posY = sticker.y * constraints.maxHeight;

                    return Positioned(
                      left: posX,
                      top: posY,
                      child: _buildPlacedStickerWidget(
                        sticker: sticker,
                        item: item,
                        isSelected: isSelected,
                        canvasWidth: constraints.maxWidth,
                        canvasHeight: constraints.maxHeight,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),

        // 2. Top Header Navigation & Controls (Theme Switcher, Title, Album)
        Positioned(
          top: 8,
          left: 12,
          right: 12,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: math.max(MediaQuery.of(context).size.width - 24, 620),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  FittedBox(
                fit: BoxFit.scaleDown,
                child: ElevatedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF78350F), size: 18),
                  label: Text(
                    'Peta',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF78350F),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF3C7),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title Badge
              Flexible(
                flex: 4,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(240),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentTheme == 'ocean' ? '🌊' : _currentTheme == 'galaxy' ? '🌌' : '🎨',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Taman Kreasi Stiker',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_placedStickers.length}',
                            style: GoogleFonts.fredoka(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Theme Switcher Segmented Pill
              Flexible(
                flex: 5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: _buildThemeSwitcher(),
                ),
              ),
              const SizedBox(width: 8),

              // Action Buttons: Clear & Open Album
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_placedStickers.isNotEmpty) ...[
                      ElevatedButton.icon(
                        onPressed: _clearCanvas,
                        icon: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFDC2626), size: 16),
                        label: Text(
                          'Bersihkan',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: widget.onOpenAlbum,
                      icon: const Icon(Icons.collections_bookmark_rounded, color: Color(0xFFBE185D), size: 16),
                      label: Text(
                        'Album',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFBE185D),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCE7F3),
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

        // 3. Bottom Sticker Drawer / Tray
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildStickerDrawer(),
        ),
      ],
    );
  }

  // Placed Sticker Interactive Widget
  Widget _buildPlacedStickerWidget({
    required PlacedSticker sticker,
    required StickerItemData item,
    required bool isSelected,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final baseSize = 64.0 * sticker.scale;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _selectedUniqueId = sticker.uniqueId;
          final newX = (sticker.x + details.delta.dx / canvasWidth).clamp(0.02, 0.88);
          final newY = (sticker.y + details.delta.dy / canvasHeight).clamp(0.12, 0.72);
          sticker.x = newX;
          sticker.y = newY;
        });
      },
      onPanEnd: (_) {
        _saveStickers();
      },
      onTap: () => _onStickerTapped(sticker),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Controls when selected
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x20000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cycle Scale Button
                  GestureDetector(
                    onTap: () => _cycleStickerScale(sticker),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF08A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.aspect_ratio_rounded, size: 14, color: Color(0xFFB45309)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Delete Button
                  GestureDetector(
                    onTap: () => _removeSticker(sticker.uniqueId),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Close Selection
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUniqueId = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),

          // Animated Speech Bubble when tapped
          if (_activeSpeechBubbleId == sticker.uniqueId && _activeSpeechBubbleText != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              constraints: const BoxConstraints(maxWidth: 160),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30F59E0B),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _activeSpeechBubbleText!,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E),
                  height: 1.15,
                ),
              ),
            ),

          // Sticker Body with Bounce & Glow
          AnimatedScale(
            scale: _bouncingUniqueId == sticker.uniqueId ? 1.32 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.elasticOut,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white.withAlpha(210) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: const Color(0xFFF59E0B), width: 2.5)
                    : Border.all(color: Colors.transparent),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x30F59E0B),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ObjectIllustrationWidget(
                illustrationKey: item.illustrationKey,
                size: baseSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sticker Bottom Tray / Drawer
  Widget _buildStickerDrawer() {
    final unlocked = widget.unlockedStickers;
    final availableStickers = GameRepository.stickers.where((s) => unlocked.contains(s.id)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle Handle Pill
        GestureDetector(
          onTap: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDrawerOpen ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _isDrawerOpen ? 'Tutup Baki Stiker' : '🎁 Buka Baki Stiker (${availableStickers.length})',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tray Content
        if (_isDrawerOpen)
          Container(
            height: 122,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(245),
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 2)),
              boxShadow: const [
                BoxShadow(color: Color(0x15000000), blurRadius: 12, offset: Offset(0, -4)),
              ],
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: availableStickers.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                // Last item is button to buy more stickers
                if (index == availableStickers.length) {
                  return GestureDetector(
                    onTap: widget.onOpenAlbum,
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE047), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFB45309), size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'Beli Stiker\nBaru ⭐',
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB45309),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = availableStickers[index];
                return GestureDetector(
                  onTap: () => _addStickerToCanvas(item.id),
                  child: Container(
                    width: 95,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ObjectIllustrationWidget(illustrationKey: item.illustrationKey, size: 40),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: GoogleFonts.fredoka(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+ Pasang',
                            style: GoogleFonts.fredoka(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Custom Garden Landscape Background
  Widget _buildGardenBackground(double width, double height) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7DD3FC), // Sky top
            Color(0xFFBAE6FD), // Sky mid
            Color(0xFFFEF08A), // Sun horizon
          ],
          stops: [0.0, 0.45, 0.75],
        ),
      ),
      child: Stack(
        children: [
          // Smiling Sun in Top Right
          Positioned(
            top: 20,
            right: 40,
            child: GestureDetector(
              onTap: () {
                _audio.speak('Matahari tersenyum! Hari yang cerah untuk menghias taman!');
              },
              child: RotationTransition(
                turns: _sunAnimController,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x40F59E0B), blurRadius: 18, spreadRadius: 4),
                    ],
                  ),
                  child: const Center(
                    child: Text('☀️', style: TextStyle(fontSize: 34)),
                  ),
                ),
              ),
            ),
          ),

          // Clouds
          Positioned(
            top: 35,
            left: 70,
            child: _buildCloud(size: 42),
          ),
          Positioned(
            top: 75,
            left: 240,
            child: _buildCloud(size: 32),
          ),
          Positioned(
            top: 45,
            right: 150,
            child: _buildCloud(size: 38),
          ),

          // Rolling Lush Hills (Custom Painter)
          Positioned.fill(
            child: CustomPaint(
              painter: _GardenLandscapePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud({required double size}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size * 0.2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(size),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_rounded, color: Colors.white.withAlpha(240), size: size),
        ],
      ),
    );
  }

  // Multi-Theme Background Switcher
  Widget _buildCurrentBackground(double width, double height) {
    switch (_currentTheme) {
      case 'ocean':
        return _buildOceanBackground(width, height);
      case 'galaxy':
        return _buildGalaxyBackground(width, height);
      case 'garden':
      default:
        return _buildGardenBackground(width, height);
    }
  }

  // Theme Switcher Segmented Control in Top Bar
  Widget _buildThemeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemePill(
            themeKey: 'garden',
            icon: '🌅',
            label: 'Kebun',
            isActive: _currentTheme == 'garden',
            activeColor: const Color(0xFF22C55E),
          ),
          const SizedBox(width: 4),
          _buildThemePill(
            themeKey: 'ocean',
            icon: '🌊',
            label: 'Laut',
            isActive: _currentTheme == 'ocean',
            activeColor: const Color(0xFF0EA5E9),
          ),
          const SizedBox(width: 4),
          _buildThemePill(
            themeKey: 'galaxy',
            icon: '🌌',
            label: 'Galaksi',
            isActive: _currentTheme == 'galaxy',
            activeColor: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePill({
    required String themeKey,
    required String icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () => _switchTheme(themeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ocean / Underwater Wonderland Background
  Widget _buildOceanBackground(double width, double height) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF38BDF8), // Light Aqua surface
            Color(0xFF0284C7), // Deep ocean blue
            Color(0xFF0369A1), // Deep seabed blue
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Gentle light rays filtering through water
          Positioned.fill(
            child: CustomPaint(
              painter: _OceanRaysPainter(),
            ),
          ),

          // Interactive floating bubbles
          Positioned(
            top: 30,
            left: 100,
            child: _buildOceanBubble(size: 26, label: 'Plop! Gelembung air meletup!'),
          ),
          Positioned(
            top: 70,
            left: 280,
            child: _buildOceanBubble(size: 34, label: 'Blub! Air laut segar sekali!'),
          ),
          Positioned(
            top: 45,
            right: 180,
            child: _buildOceanBubble(size: 22, label: 'Cring! Gelembung ajaib!'),
          ),
          Positioned(
            top: 110,
            right: 80,
            child: _buildOceanBubble(size: 30, label: 'Wush! Bawah laut penuh misteri!'),
          ),

          // Sandy Seabed, Seaweed, and Starfish Custom Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _OceanLandscapePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOceanBubble({required double size, required String label}) {
    return GestureDetector(
      onTap: () {
        _audio.playSfx('pop');
        _audio.speak(label);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(80),
          border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withAlpha(60),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Align(
          alignment: const Alignment(-0.4, -0.4),
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Galaxy / Cosmic Starry Night Background
  Widget _buildGalaxyBackground(double width, double height) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // Dark Midnight Void
            Color(0xFF1E1B4B), // Cosmic Indigo
            Color(0xFF311042), // Deep Nebula Violet
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Twinkling stars and cosmic nebula
          Positioned.fill(
            child: CustomPaint(
              painter: _GalaxyStarsPainter(),
            ),
          ),

          // Glowing Golden Crescent Moon
          Positioned(
            top: 25,
            right: 50,
            child: GestureDetector(
              onTap: () {
                _audio.playSfx('twinkle');
                _audio.speak('Bulan tersenyum ramah di langit malam!');
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x60FDE047), blurRadius: 20, spreadRadius: 4),
                  ],
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 38)),
                ),
              ),
            ),
          ),

          // Distant Saturn planet
          Positioned(
            top: 50,
            left: 90,
            child: GestureDetector(
              onTap: () {
                _audio.playSfx('boing');
                _audio.speak('Planet cincin emas yang menawan!');
              },
              child: const Text('🪐', style: TextStyle(fontSize: 32)),
            ),
          ),

          // Cosmic Alien Hills and Crystals Custom Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _GalaxyLandscapePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Lush Rolling Hills & Decorative Garden Grass
class _GardenLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back Hill (Teal / Sage Green)
    final backHillPaint = Paint()..color = const Color(0xFF86EFAC);
    final backHillPath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.25, h * 0.52, w * 0.55, h * 0.62)
      ..quadraticBezierTo(w * 0.8, h * 0.70, w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backHillPath, backHillPaint);

    // Front Lush Hill (Vibrant Grass Green)
    final frontHillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
      ).createShader(Rect.fromLTWH(0, h * 0.68, w, h * 0.32));

    final frontHillPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.35, h * 0.66, w * 0.7, h * 0.74)
      ..quadraticBezierTo(w * 0.88, h * 0.78, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontHillPath, frontHillPaint);

    // Cute decorative flowers on the lawn
    _drawFlower(canvas, Offset(w * 0.12, h * 0.84), Colors.white, Colors.amber);
    _drawFlower(canvas, Offset(w * 0.28, h * 0.88), const Color(0xFFFBCFE8), const Color(0xFFEC4899));
    _drawFlower(canvas, Offset(w * 0.48, h * 0.82), Colors.white, Colors.amber);
    _drawFlower(canvas, Offset(w * 0.68, h * 0.86), const Color(0xFFFEF08A), const Color(0xFFCA8A04));
    _drawFlower(canvas, Offset(w * 0.84, h * 0.84), Colors.white, Colors.amber);
  }

  void _drawFlower(Canvas canvas, Offset center, Color petalColor, Color centerColor) {
    final petalPaint = Paint()..color = petalColor;
    const petalRadius = 4.0;
    const dist = 4.5;

    // 4 petals
    canvas.drawCircle(center + const Offset(0, -dist), petalRadius, petalPaint);
    canvas.drawCircle(center + const Offset(dist, 0), petalRadius, petalPaint);
    canvas.drawCircle(center + const Offset(0, dist), petalRadius, petalPaint);
    canvas.drawCircle(center + const Offset(-dist, 0), petalRadius, petalPaint);

    // Center
    canvas.drawCircle(center, 3.5, Paint()..color = centerColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Ocean Light Rays Painter
class _OceanRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(45),
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.75));

    final rayPath = Path();
    // Ray 1
    rayPath.moveTo(w * 0.15, 0);
    rayPath.lineTo(w * 0.05, h * 0.7);
    rayPath.lineTo(w * 0.22, h * 0.7);
    rayPath.lineTo(w * 0.25, 0);
    rayPath.close();

    // Ray 2
    rayPath.moveTo(w * 0.45, 0);
    rayPath.lineTo(w * 0.38, h * 0.75);
    rayPath.lineTo(w * 0.58, h * 0.75);
    rayPath.lineTo(w * 0.55, 0);
    rayPath.close();

    // Ray 3
    rayPath.moveTo(w * 0.75, 0);
    rayPath.lineTo(w * 0.70, h * 0.65);
    rayPath.lineTo(w * 0.88, h * 0.65);
    rayPath.lineTo(w * 0.84, 0);
    rayPath.close();

    canvas.drawPath(rayPath, rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Underwater Seabed with Sandy Dunes, Corals, Seaweeds, and Starfish
class _OceanLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Deep seabed sandy floor (Warm sand gradient)
    final sandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
      ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28));

    final sandPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.3, h * 0.72, w * 0.6, h * 0.80)
      ..quadraticBezierTo(w * 0.85, h * 0.86, w, h * 0.76)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(sandPath, sandPaint);

    // Decorative Seaweed clusters
    _drawSeaweed(canvas, Offset(w * 0.06, h * 0.82), 48, const Color(0xFF10B981));
    _drawSeaweed(canvas, Offset(w * 0.09, h * 0.84), 38, const Color(0xFF059669));
    _drawSeaweed(canvas, Offset(w * 0.91, h * 0.80), 52, const Color(0xFF10B981));
    _drawSeaweed(canvas, Offset(w * 0.94, h * 0.82), 40, const Color(0xFF047857));

    // Starfish on sand
    _drawStarfish(canvas, Offset(w * 0.22, h * 0.86), const Color(0xFFF97316), 14);
    _drawStarfish(canvas, Offset(w * 0.78, h * 0.88), const Color(0xFFEC4899), 11);

    // Cute sea pebbles
    final pebblePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.42, h * 0.89), width: 14, height: 7), pebblePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.91), width: 18, height: 8), pebblePaint);
  }

  void _drawSeaweed(Canvas canvas, Offset base, double height, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(base.dx, base.dy);
    path.cubicTo(
      base.dx - 12,
      base.dy - height * 0.35,
      base.dx + 12,
      base.dy - height * 0.7,
      base.dx - 4,
      base.dy - height,
    );
    canvas.drawPath(path, paint);
  }

  void _drawStarfish(Canvas canvas, Offset center, Color color, double radius) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angleOuter = (i * 72 - 90) * math.pi / 180;
      final angleInner = ((i * 72 + 36) - 90) * math.pi / 180;
      final outerX = center.dx + radius * math.cos(angleOuter);
      final outerY = center.dy + radius * math.sin(angleOuter);
      final innerX = center.dx + (radius * 0.45) * math.cos(angleInner);
      final innerY = center.dy + (radius * 0.45) * math.sin(angleInner);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Eye dot or center dot
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.white.withAlpha(200));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Twinkling Stars & Nebula for Galaxy Theme
class _GalaxyStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Nebula dust glow
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withAlpha(50),
          const Color(0xFFEC4899).withAlpha(25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.4, h * 0.35), radius: w * 0.35));
    canvas.drawCircle(Offset(w * 0.4, h * 0.35), w * 0.35, nebulaPaint);

    // Twinkling static stars array
    final stars = [
      Offset(w * 0.08, h * 0.12),
      Offset(w * 0.18, h * 0.28),
      Offset(w * 0.26, h * 0.14),
      Offset(w * 0.34, h * 0.42),
      Offset(w * 0.48, h * 0.18),
      Offset(w * 0.58, h * 0.26),
      Offset(w * 0.68, h * 0.15),
      Offset(w * 0.78, h * 0.38),
      Offset(w * 0.88, h * 0.22),
      Offset(w * 0.94, h * 0.45),
      Offset(w * 0.14, h * 0.55),
      Offset(w * 0.82, h * 0.58),
    ];

    final starPaint = Paint()..color = Colors.white;
    final goldPaint = Paint()..color = const Color(0xFFFDE047);
    final cyanPaint = Paint()..color = const Color(0xFF67E8F9);

    for (int i = 0; i < stars.length; i++) {
      final pos = stars[i];
      final paint = i % 3 == 0 ? goldPaint : (i % 3 == 1 ? starPaint : cyanPaint);
      final r = (i % 2 == 0) ? 2.5 : 1.8;
      canvas.drawCircle(pos, r, paint);

      // Add a 4-point twinkle sparkle on larger stars
      if (i % 3 == 0) {
        final sparkPaint = Paint()
          ..color = paint.color.withAlpha(180)
          ..strokeWidth = 1.0;
        canvas.drawLine(pos - const Offset(5, 0), pos + const Offset(5, 0), sparkPaint);
        canvas.drawLine(pos - const Offset(0, 5), pos + const Offset(0, 5), sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Cosmic Alien Hills and Glowing Crystals Painter
class _GalaxyLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Distant cosmic mountain (Deep violet)
    final backMountainPaint = Paint()..color = const Color(0xFF4C1D95);
    final backMountainPath = Path()
      ..moveTo(0, h * 0.68)
      ..lineTo(w * 0.22, h * 0.56)
      ..lineTo(w * 0.46, h * 0.65)
      ..lineTo(w * 0.72, h * 0.54)
      ..lineTo(w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backMountainPath, backMountainPaint);

    // Front alien rolling cratered hill (Vibrant purple to midnight indigo)
    final frontHillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7C3AED), Color(0xFF3B0764)],
      ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28));

    final frontHillPath = Path()
      ..moveTo(0, h * 0.76)
      ..quadraticBezierTo(w * 0.35, h * 0.68, w * 0.68, h * 0.75)
      ..quadraticBezierTo(w * 0.88, h * 0.80, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontHillPath, frontHillPaint);

    // Glowing Neon Cosmic Crystals
    _drawCrystal(canvas, Offset(w * 0.12, h * 0.84), const Color(0xFF38BDF8), 16);
    _drawCrystal(canvas, Offset(w * 0.15, h * 0.86), const Color(0xFF06B6D4), 11);
    _drawCrystal(canvas, Offset(w * 0.82, h * 0.83), const Color(0xFFF472B6), 18);
    _drawCrystal(canvas, Offset(w * 0.86, h * 0.85), const Color(0xFFA855F7), 13);
  }

  void _drawCrystal(Canvas canvas, Offset base, Color color, double height) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx + height * 0.3, base.dy)
      ..lineTo(base.dx - height * 0.3, base.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Highlight facet
    final highlightPaint = Paint()..color = Colors.white.withAlpha(160);
    final highlightPath = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx, base.dy)
      ..lineTo(base.dx - height * 0.3, base.dy)
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

