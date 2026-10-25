import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/daily_mission_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'child_avatar_widget.dart';

class DailyMissionsDialog extends StatefulWidget {
  final Function(String route) onNavigateToIsland;
  final Function(int bonusStars)? onBonusStars;
  final String childName;
  final String avatarId;

  const DailyMissionsDialog({
    super.key,
    required this.onNavigateToIsland,
    this.onBonusStars,
    this.childName = 'Juara Cilik',
    this.avatarId = 'miko',
  });

  @override
  State<DailyMissionsDialog> createState() => _DailyMissionsDialogState();
}

class _DailyMissionsDialogState extends State<DailyMissionsDialog> with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  DailyMissionsState? _state;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _loadMissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadMissions() async {
    final state = await StorageService.getDailyMissionsState();
    if (mounted) {
      setState(() {
        _state = state;
        _isLoading = false;
      });
    }
  }

  void _claimMission(DailyMissionItem mission) async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('star');

    final stars = await StorageService.claimDailyMission(mission.id);
    if (stars > 0) {
      widget.onBonusStars?.call(stars);
      _audio.speak('Bagus sekali ${widget.childName}! Kamu dapat +$stars bintang!');
      final updatedState = await StorageService.getDailyMissionsState();
      if (mounted) {
        setState(() {
          _state = updatedState;
        });
      }
    }
  }

  void _claimAllBonus() async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('fanfare');

    final bonus = await StorageService.claimAllDailyMissionsBonus();
    if (bonus > 0) {
      widget.onBonusStars?.call(bonus);
      _audio.speak('Luar biasa ${widget.childName}! Semua misi harian selesai! Kamu mendapatkan hadiah spesial!');
      final updatedState = await StorageService.getDailyMissionsState();
      if (mounted) {
        setState(() {
          _state = updatedState;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(540.0, screenSize.width * 0.94);
    final dialogHeight = math.min(680.0, screenSize.height * 0.92);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFBEB),
                Color(0xFFFEF3C7),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF59E0B), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35D97706),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Toolbar
              _buildHeader(),

              // 2. Body Scrollable
              Flexible(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Color(0xFFD97706)),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 7-Day Streak Calendar Ribbon
                            _buildStreakBoard(),
                            const SizedBox(height: 14),

                            // Daily Missions Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎯', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Misi Belajar Hari Ini',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF08A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                                  ),
                                  child: Text(
                                    '${_state?.completedCount ?? 0}/3 Selesai',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 3 Daily Mission Cards
                            if (_state != null)
                              ..._state!.missions.map((m) => _buildMissionCard(m)),

                            const SizedBox(height: 14),

                            // Grand Bonus Banner
                            _buildGrandBonusBanner(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        children: [
          ChildAvatarWidget(avatarId: widget.avatarId, size: 40, showGlow: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '📅 Misi Harian',
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Juara Cilik',
                        style: GoogleFonts.fredoka(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Selesaikan misi & jaga nyala apimu!',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFEF3C7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBoard() {
    final streak = _state?.streakDays ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12D97706),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Title & Flame Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    'Runtutan Belajar: $streak Hari Berturut-turut!',
                    style: GoogleFonts.fredoka(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFBBF24)),
                ),
                child: Text(
                  'Hari ke-$streak / 7',
                  style: GoogleFonts.fredoka(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7-Day Visual Stamp Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isReached = dayNum <= streak;
              final isCurrent = dayNum == streak;
              final isDay7 = dayNum == 7;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isReached
                          ? (isDay7
                              ? const LinearGradient(colors: [Color(0xFFFDE047), Color(0xFFF59E0B)])
                              : const LinearGradient(colors: [Color(0xFFFEF08A), Color(0xFFFBBF24)]))
                          : null,
                      color: isReached ? null : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFEA580C)
                            : (isReached ? const Color(0xFFD97706) : const Color(0xFFCBD5E1)),
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              const BoxShadow(
                                color: Color(0x40F97316),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isDay7
                            ? '🎁'
                            : (isReached ? '⭐' : '$dayNum'),
                        style: TextStyle(
                          fontSize: isDay7 ? 17 : (isReached ? 16 : 12),
                          fontWeight: FontWeight.bold,
                          color: isReached ? const Color(0xFF78350F) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'H$dayNum',
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(DailyMissionItem mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: mission.isCompleted
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
          width: mission.isCompleted ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: mission.isCompleted ? const Color(0x1522C55E) : const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mission Icon in round colored container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mission.isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
              shape: BoxShape.circle,
              border: Border.all(
                color: mission.isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFFDE047),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(mission.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Title, Description & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${mission.currentCount}/${mission.targetCount}',
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: mission.isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  mission.description,
                  style: GoogleFonts.nunito(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Linear Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.isCompleted ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action Button (Klaim vs Mulai vs Selesai)
          _buildMissionActionButton(mission),
        ],
      ),
    );
  }

  Widget _buildMissionActionButton(DailyMissionItem mission) {
    if (mission.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              'Selesai',
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      );
    }

    if (mission.isCompleted) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.06);
          return Transform.scale(
            scale: scale,
            child: ElevatedButton(
              onPressed: () => _claimMission(mission),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                shadowColor: const Color(0x4010B981),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    'Klaim',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        widget.onNavigateToIsland(mission.targetIslandRoute);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3E8FF),
        foregroundColor: const Color(0xFF7E22CE),
        side: const BorderSide(color: Color(0xFFD8B4FE), width: 1.2),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mulai',
            style: GoogleFonts.fredoka(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_forward_rounded, size: 13),
        ],
      ),
    );
  }

  Widget _buildGrandBonusBanner() {
    final allCompleted = _state?.allCompleted ?? false;
    final allClaimed = _state?.allClaimed ?? false;

    if (allClaimed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua Misi Hari Ini Berhasil Dituntaskan!',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                  Text(
                    'Hebat sekali! Sampai jumpa besok dengan misi seru baru!',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (allCompleted) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAB308), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25F59E0B),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonus Sempurna 3 Misi: +5 Bintang Extra!',
                        style: GoogleFonts.fredoka(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      Text(
                        'Ketiga misi hari ini telah kamu selesaikan!',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _claimAllBonus,
                icon: const Text('⭐', style: TextStyle(fontSize: 16)),
                label: Text(
                  'KLAIM BONUS MISI HARIAN (+5 BINTANG)',
                  style: GoogleFonts.fredoka(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tuntaskan 3 misi di atas untuk mendapatkan bonus +5 Bintang Ajaib!',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
