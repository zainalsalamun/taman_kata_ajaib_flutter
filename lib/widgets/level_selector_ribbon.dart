import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';

class LevelSelectorRibbon extends StatelessWidget {
  final int currentLevel;
  final int unlockedLevel;
  final Function(int level) onSelectLevel;

  const LevelSelectorRibbon({
    super.key,
    required this.currentLevel,
    required this.unlockedLevel,
    required this.onSelectLevel,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {'level': 1, 'label': 'Tingkat 1', 'icon': '🌱', 'title': 'Tunas Ajaib'},
      {'level': 2, 'label': 'Tingkat 2', 'icon': '🌿', 'title': 'Petualang'},
      {'level': 3, 'label': 'Tingkat 3', 'icon': '🌳', 'title': 'Master'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: levels.map((lvl) {
          final levelNum = lvl['level'] as int;
          final isCurrent = currentLevel == levelNum;
          final isUnlocked = unlockedLevel >= levelNum;
          final isCompleted = unlockedLevel > levelNum;

          Color bg = Colors.transparent;
          Color border = Colors.transparent;
          Color textColor = const Color(0xFF64748B);

          if (isCurrent) {
            bg = const Color(0xFFFEF08A);
            border = const Color(0xFFEAB308);
            textColor = const Color(0xFF854D0E);
          } else if (isUnlocked) {
            bg = const Color(0xFFF1F5F9);
            border = const Color(0xFFCBD5E1);
            textColor = const Color(0xFF334155);
          } else {
            bg = const Color(0xFFF8FAFC);
            border = Colors.transparent;
            textColor = const Color(0xFF94A3B8);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                if (isUnlocked) {
                  if (currentLevel != levelNum) {
                    HapticFeedback.selectionClick();
                    onSelectLevel(levelNum);
                  }
                } else {
                  HapticFeedback.lightImpact();
                  AudioService().speak(
                      'Tingkat $levelNum masih terkunci! Selesaikan Tingkat ${levelNum - 1} dulu ya!');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: isCurrent ? 2 : 1),
                  boxShadow: isCurrent
                      ? const [
                          BoxShadow(
                            color: Color(0xFFCA8A04),
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUnlocked ? (lvl['icon'] as String) : '🔒',
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked ? null : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lvl['label'] as String,
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight:
                            isCurrent ? FontWeight.w900 : FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (isCompleted && !isCurrent) ...[
                      const SizedBox(width: 3),
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
