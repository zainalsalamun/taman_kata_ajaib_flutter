import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';

class StickerAlbumDialog extends StatefulWidget {
  final int currentStars;
  final List<String> unlockedStickers;
  final Function(int newStars, List<String> newUnlocked) onUpdate;
  final VoidCallback? onGoToPlayground;

  const StickerAlbumDialog({
    super.key,
    required this.currentStars,
    required this.unlockedStickers,
    required this.onUpdate,
    this.onGoToPlayground,
  });

  @override
  State<StickerAlbumDialog> createState() => _StickerAlbumDialogState();
}

class _StickerAlbumDialogState extends State<StickerAlbumDialog> {
  late int _stars;
  late List<String> _unlocked;
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _stars = widget.currentStars;
    _unlocked = List.from(widget.unlockedStickers);
  }

  void _buySticker(StickerItemData item) {
    if (_stars >= item.cost) {
      setState(() {
        _stars -= item.cost;
        _unlocked.add(item.id);
      });
      widget.onUpdate(_stars, _unlocked);
      _audio.speak('Hore, kamu dapat stiker ${item.name}!');
    } else {
      _audio.speak('Bintangmu belum cukup, ayo main lagi!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stickers = GameRepository.stickers;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF472B6), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Buku Album Stiker',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFBE185D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tukarkan bintangmu untuk membuka stiker!',
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // Grid
            SizedBox(
              height: 240,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final item = stickers[index];
                  final isUnlocked = _unlocked.contains(item.id);

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.white : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked ? const Color(0xFFFDE047) : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              const BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: isUnlocked ? 1.0 : 0.25,
                          child: ObjectIllustrationWidget(
                            illustrationKey: item.illustrationKey,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        if (isUnlocked)
                          Text(
                            'Terkoleksi',
                            style: GoogleFonts.fredoka(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _buySticker(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF08A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.cost} ⭐',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Footer Buttons
            Row(
              children: [
                if (widget.onGoToPlayground != null) ...[
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onGoToPlayground!();
                        },
                        icon: const Icon(Icons.park_rounded, color: Colors.white, size: 20),
                        label: Text(
                          'Hias Taman Stiker',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
