import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  // Animation controller for tapping/bouncing sun
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
    _sunAnimController.dispose();
    super.dispose();
  }

  void _loadPlacedStickers() async {
    final loaded = await StorageService.getPlacedStickers();
    if (mounted) {
      setState(() {
        _placedStickers = loaded;
        _isLoading = false;
      });
    }
  }

  void _saveStickers() {
    StorageService.savePlacedStickers(_placedStickers);
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
    });

    _saveStickers();
    _audio.speak('Hore, ${item.name} ditempel!');
  }

  void _removeSticker(String uniqueId) {
    setState(() {
      _placedStickers.removeWhere((s) => s.uniqueId == uniqueId);
      if (_selectedUniqueId == uniqueId) {
        _selectedUniqueId = null;
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
    setState(() {
      _selectedUniqueId = sticker.uniqueId;
    });

    final item = GameRepository.stickers.firstWhere(
      (s) => s.id == sticker.stickerId,
      orElse: () => GameRepository.stickers.first,
    );

    _audio.speak('${item.name}! ${item.description}!');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // 1. Garden Landscape & Interactive Canvas Area
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Scenery Custom Background
                  Positioned.fill(
                    child: _buildGardenBackground(constraints.maxWidth, constraints.maxHeight),
                  ),

                  // Mascot Miko on the ground corner cheering
                  Positioned(
                    left: 16,
                    bottom: _isDrawerOpen ? 140 : 20,
                    child: GestureDetector(
                      onTap: () {
                        _audio.speak('Tamanmu cantik sekali! Tempel dan geser stiker sesukamu ya!');
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
                              'Ayo Hias Taman!',
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

        // 2. Top Header Navigation & Controls
        Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              ElevatedButton.icon(
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

              // Title Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    const Icon(Icons.park_rounded, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Taman Kreasi Stiker',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_placedStickers.length} Stiker',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons: Clear & Open Album
              Row(
                children: [
                  if (_placedStickers.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: _clearCanvas,
                      icon: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFDC2626), size: 16),
                      label: Text(
                        'Bersihkan',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ],
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

          // Sticker Body with Bounce & Glow
          Container(
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
