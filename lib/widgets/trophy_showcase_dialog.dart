import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trophy_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'interactive_fireworks.dart';
import 'vector_illustrations.dart';

class TrophyShowcaseDialog extends StatefulWidget {
  final VoidCallback? onBackToMap;

  const TrophyShowcaseDialog({
    super.key,
    this.onBackToMap,
  });

  @override
  State<TrophyShowcaseDialog> createState() => _TrophyShowcaseDialogState();
}

class _TrophyShowcaseDialogState extends State<TrophyShowcaseDialog>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  List<String> _unlockedTrophyIds = [];
  String _childName = 'Juara Cilik';
  bool _isLoading = true;
  TrophyCategory _selectedCategory = TrophyCategory.all;
  TrophyItem? _selectedTrophy;

  late AnimationController _sparkleAnimController;

  @override
  void initState() {
    super.initState();
    _sparkleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadData();
  }

  void _loadData() async {
    final trophies = await StorageService.getTrophies();
    final name = await StorageService.getChildName();

    if (mounted) {
      setState(() {
        _unlockedTrophyIds = trophies;
        _childName = name;
        _isLoading = false;
        // Default highlight the first unlocked trophy, or first trophy in list
        final firstUnlocked = TrophyRepository.allTrophies.firstWhere(
          (t) => trophies.contains(t.id),
          orElse: () => TrophyRepository.allTrophies.first,
        );
        _selectedTrophy = firstUnlocked;
      });

      _audio.playSfx('magic_chime');
      _audio.speak('Selamat datang di Galeri Trofi Juara! Lihat semua piala dan mahkota yang sudah kamu kumpulkan!');
    }
  }

  @override
  void dispose() {
    _sparkleAnimController.dispose();
    super.dispose();
  }

  List<TrophyItem> get _filteredTrophies {
    if (_selectedCategory == TrophyCategory.all) {
      return TrophyRepository.allTrophies;
    }
    return TrophyRepository.allTrophies
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  void _onTrophyTapped(TrophyItem trophy) {
    final isUnlocked = _unlockedTrophyIds.contains(trophy.id);
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedTrophy = trophy;
    });

    if (isUnlocked) {
      _audio.playSfx(trophy.sfx);
      _audio.speak(trophy.voicePraise);
    } else {
      _audio.playSfx('ding');
      _audio.speak('Piala ${trophy.title} masih tersimpan! ${trophy.howToUnlock}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(580.0, screenSize.width * 0.94);
    final dialogMaxHeight = screenSize.height * 0.92;

    final totalCount = TrophyRepository.allTrophies.length;
    final unlockedCount = _unlockedTrophyIds.length;
    final progress = totalCount > 0 ? (unlockedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
        child: SizedBox(
          width: dialogWidth,
          child: InteractiveFireworksOverlay(
            autoLaunch: false,
            tapEnabled: true,
            showTapHint: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFBEB),
                    Colors.white,
                    Color(0xFFFEF3C7),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF59E0B), width: 4.5),
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
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Header Bar: Title, Child Name, Close Button
                        _buildHeaderRow(),

                        const SizedBox(height: 10),

                        // 2. Progress Bar: "8 / 19 Trofi Terkumpul"
                        _buildProgressBar(unlockedCount, totalCount, progress),

                        const SizedBox(height: 12),

                        // 3. Category Filter Tabs
                        _buildCategoryTabs(),

                        const SizedBox(height: 12),

                        // 4. Scrollable Trophy Grid
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: screenSize.height * 0.44,
                            ),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: dialogWidth > 480 ? 4 : 3,
                                childAspectRatio: 0.88,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _filteredTrophies.length,
                              itemBuilder: (context, idx) {
                                final trophy = _filteredTrophies[idx];
                                final isUnlocked = _unlockedTrophyIds.contains(trophy.id);
                                final isSelected = _selectedTrophy?.id == trophy.id;
                                return _buildTrophyTile(trophy, isUnlocked, isSelected);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 5. Selected Trophy Detail Card (Encouragement or Achievement Box)
                        if (_selectedTrophy != null) _buildSelectedTrophyDetailCard(),

                        const SizedBox(height: 10),

                        // 6. Action Button: Kembali ke Peta / Main Lagi
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                              if (widget.onBackToMap != null) {
                                widget.onBackToMap!();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Tutup Galeri Juara',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                ),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Galeri Juara $_childName',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Koleksi piala emas dan mahkota master!',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int unlocked, int total, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⭐ $unlocked dari $total Trofi Terkumpul',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF854D0E),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Selesai',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'cat': TrophyCategory.all, 'label': 'Semua', 'icon': '⭐'},
      {'cat': TrophyCategory.master, 'label': 'Master', 'icon': '👑'},
      {'cat': TrophyCategory.island, 'label': 'Pulau', 'icon': '🏆'},
      {'cat': TrophyCategory.special, 'label': 'Spesial', 'icon': '✨'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((c) {
          final cat = c['cat'] as TrophyCategory;
          final isSel = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSel
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      )
                    : null,
                color: isSel ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? const Color(0xFFB45309) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: isSel
                    ? const [
                        BoxShadow(
                          color: Color(0x30F59E0B),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Text(c['icon'] as String, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    c['label'] as String,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrophyTile(TrophyItem trophy, bool isUnlocked, bool isSelected) {
    return GestureDetector(
      onTap: () => _onTrophyTapped(trophy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      ? [const Color(0xFFFEF08A), const Color(0xFFFDE047)]
                      : [Colors.white, const Color(0xFFFFFBEB)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD97706)
                : (isUnlocked ? const Color(0xFFFCD34D) : const Color(0xFFCBD5E1)),
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: isSelected ? const Color(0x50F59E0B) : const Color(0x18000000),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Text(
                    isUnlocked ? trophy.iconEmoji : '🔒',
                    style: TextStyle(
                      fontSize: isUnlocked ? 28 : 22,
                      color: isUnlocked ? null : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    trophy.title,
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? (trophy.category == TrophyCategory.master
                              ? const Color(0xFFFDE047)
                              : const Color(0xFFDCFCE7))
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trophy.badgeText,
                      style: GoogleFonts.fredoka(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked
                            ? (trophy.category == TrophyCategory.master
                                ? const Color(0xFF854D0E)
                                : const Color(0xFF166534))
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Star Pin
            if (isSelected)
              const Positioned(
                top: 4,
                right: 4,
                child: Text('✨', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTrophyDetailCard() {
    final trophy = _selectedTrophy!;
    final isUnlocked = _unlockedTrophyIds.contains(trophy.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const MascotWidget(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      trophy.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isUnlocked ? '• Terbuka! ⭐' : '• Terkunci 🔒',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked ? trophy.subtitle : trophy.howToUnlock,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isUnlocked) {
                _audio.playSfx(trophy.sfx);
                _audio.speak(trophy.voicePraise);
              } else {
                _audio.speak(trophy.howToUnlock);
              }
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B), size: 22),
            tooltip: 'Dengarkan Miko',
          ),
        ],
      ),
    );
  }
}
