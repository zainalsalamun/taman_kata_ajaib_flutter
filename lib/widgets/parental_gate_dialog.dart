import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';
import 'child_avatar_widget.dart';
import '../services/voice_recording_service.dart';

class TrophyDef {
  final String id;
  final String title;
  final String icon;
  final String island;
  final String desc;
  final Color glowColor;

  const TrophyDef({
    required this.id,
    required this.title,
    required this.icon,
    required this.island,
    required this.desc,
    required this.glowColor,
  });
}

const List<TrophyDef> _allTrophies = [
  TrophyDef(
    id: 'train_l1',
    title: 'Piala Tunas Kereta',
    icon: '🏆',
    island: 'Kereta Suku Kata',
    desc: 'Tamat Tingkat 1: 16 kata 2 suku kata (KV-KV)',
    glowColor: Color(0xFFFACC15),
  ),
  TrophyDef(
    id: 'train_l2',
    title: 'Piala Petualang Kereta',
    icon: '🥈',
    island: 'Kereta Suku Kata',
    desc: 'Tamat Tingkat 2: 12 kata 3 suku kata (KV-KV-KV)',
    glowColor: Color(0xFF38BDF8),
  ),
  TrophyDef(
    id: 'train_l3',
    title: 'Mahkota Master Kereta',
    icon: '👑',
    island: 'Kereta Suku Kata',
    desc: 'Tamat Tingkat 3: Konsonan rangkap & sengau NG/NY',
    glowColor: Color(0xFFA855F7),
  ),
  TrophyDef(
    id: 'balloon_l1',
    title: 'Piala Balon Ceria',
    icon: '🏆',
    island: 'Balon Kata Ajaib',
    desc: 'Tamat Tingkat 1: Letuskan 8 kata benda visual',
    glowColor: Color(0xFFF43F5E),
  ),
  TrophyDef(
    id: 'balloon_l2',
    title: 'Piala Balon Petualang',
    icon: '🥈',
    island: 'Balon Kata Ajaib',
    desc: 'Tamat Tingkat 2: 8 kata kerja & aksi ceria',
    glowColor: Color(0xFFEC4899),
  ),
  TrophyDef(
    id: 'balloon_l3',
    title: 'Mahkota Master Balon',
    icon: '👑',
    island: 'Balon Kata Ajaib',
    desc: 'Tamat Tingkat 3: Lengkapi kalimat mini rumpang',
    glowColor: Color(0xFF8B5CF6),
  ),
  TrophyDef(
    id: 'quiz_l1',
    title: 'Piala Kuis Pintar',
    icon: '🏆',
    island: 'Kuis Sentuh Pintar',
    desc: 'Tamat Tingkat 1: 12 soal identifikasi objek',
    glowColor: Color(0xFF10B981),
  ),
  TrophyDef(
    id: 'quiz_l2',
    title: 'Piala Fonik Pintar',
    icon: '🥈',
    island: 'Kuis Sentuh Pintar',
    desc: 'Tamat Tingkat 2: 12 soal fonik awal & suku kata',
    glowColor: Color(0xFF06B6D4),
  ),
  TrophyDef(
    id: 'quiz_l3',
    title: 'Mahkota Logika Pintar',
    icon: '👑',
    island: 'Kuis Sentuh Pintar',
    desc: 'Tamat Tingkat 3: 12 teka-teki logika ceria',
    glowColor: Color(0xFFF59E0B),
  ),
  TrophyDef(
    id: 'tracing_alphabet_master',
    title: 'Piala Emas 26 Huruf',
    icon: '🌟',
    island: 'Jejak Huruf',
    desc: 'Tulis dan kuasai seluruh alfabet A sampai Z',
    glowColor: Color(0xFFEAB308),
  ),
  TrophyDef(
    id: 'story_comprehension_master',
    title: 'Mahkota Pendongeng Ajaib',
    icon: '👑',
    island: 'Buku Cerita Ajaib',
    desc: 'Tamat 4 dongeng bergambar dan tuntaskan kuis pemahaman!',
    glowColor: Color(0xFFC084FC),
  ),
  TrophyDef(
    id: 'sticker_artist_master',
    title: 'Piala Seniman Cilik',
    icon: '🎨',
    island: 'Taman Stiker',
    desc: 'Hias kanvas kreasi dengan stiker ajaib pilihanmu!',
    glowColor: Color(0xFF10B981),
  ),
  TrophyDef(
    id: 'maze_l1',
    title: 'Piala Tunas Labirin',
    icon: '🧭',
    island: 'Labirin Kata',
    desc: 'Tamat Tingkat 1: Pandu Miko jemput huruf alfabet di labirin',
    glowColor: Color(0xFFF97316),
  ),
  TrophyDef(
    id: 'maze_l2',
    title: 'Piala Suku Kata Labirin',
    icon: '🥈',
    island: 'Labirin Kata',
    desc: 'Tamat Tingkat 2: Pandu Miko jemput suku kata berirama',
    glowColor: Color(0xFFFB923C),
  ),
  TrophyDef(
    id: 'maze_l3',
    title: 'Mahkota Master Labirin',
    icon: '👑',
    island: 'Labirin Kata',
    desc: 'Tamat Tingkat 3: Taklukkan labirin kata kaya 3 suku kata',
    glowColor: Color(0xFFEA580C),
  ),
  TrophyDef(
    id: 'voice_first_star',
    title: 'Bintang Suara Pertama',
    icon: '🎙️',
    island: 'Suaraku Ajaib',
    desc: 'Rekam suaramu menirukan bunyi huruf atau kata pertama kali!',
    glowColor: Color(0xFFA855F7),
  ),
  TrophyDef(
    id: 'voice_master',
    title: 'Penyiar Cilik Berbakat',
    icon: '🌟',
    island: 'Suaraku Ajaib',
    desc: 'Koleksi 5+ rekaman suara ananda di Galeri Suara!',
    glowColor: Color(0xFFF59E0B),
  ),
  TrophyDef(
    id: 'daily_mission_master',
    title: 'Penakluk Misi Harian',
    icon: '🏆',
    island: 'Misi Harian',
    desc: 'Tuntaskan ketiga misi belajar harian dalam satu hari penuh!',
    glowColor: Color(0xFF10B981),
  ),
  TrophyDef(
    id: 'streak_3_star',
    title: 'Bintang Rajin 3 Hari',
    icon: '🔥',
    island: 'Misi Harian',
    desc: 'Belajar dan selesaikan misi 3 hari berturut-turut tanpa putus!',
    glowColor: Color(0xFFF97316),
  ),
  TrophyDef(
    id: 'streak_7_champion',
    title: 'Juara Konsistensi 7 Hari',
    icon: '👑',
    island: 'Misi Harian',
    desc: 'Taklukkan runtutan belajar 7 hari penuh dan raih Peti Emas!',
    glowColor: Color(0xFFEAB308),
  ),
];

class ParentalGateDialog extends StatefulWidget {
  final int totalStars;
  final Function(int newLimitMinutes)? onLimitChanged;
  final VoidCallback? onDataReset;

  const ParentalGateDialog({
    super.key,
    required this.totalStars,
    this.onLimitChanged,
    this.onDataReset,
  });

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _a;
  late int _b;
  late int _answer;
  final TextEditingController _controller = TextEditingController();
  bool _isUnlocked = false;
  int _limitMinutes = 0;
  int _todaySeconds = 0;
  int _activeTab = 0; // 0: Trofi, 1: Rapor, 2: Waktu & Reset
  String _childName = 'Juara Cilik';
  String _childAvatar = 'miko';
  int _trophyFilterIndex = 0; // 0: Semua, 1: Diraih, 2: Terkunci
  String? _tappedTrophyId;

  List<String> _trophies = [];
  int _trainLevel = 1;
  int _balloonLevel = 1;
  int _quizLevel = 1;
  int _mazeLevel = 1;
  int _tracingIndex = 0;
  int _storiesCount = 0;
  int _stickersCount = 0;
  List<Map<String, dynamic>> _voiceRecordings = [];
  String? _activePlayingVoiceKey;

  @override
  void initState() {
    super.initState();
    _generateMath();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    final limit = await StorageService.getScreenTimeLimit();
    final todaySec = await StorageService.getTodayPlayTimeSeconds();
    final trophies = await StorageService.getTrophies();
    final trLvl = await StorageService.getUnlockedGameLevel('train');
    final blLvl = await StorageService.getUnlockedGameLevel('balloon');
    final qzLvl = await StorageService.getUnlockedGameLevel('quiz');
    final mzLvl = await StorageService.getUnlockedGameLevel('maze');
    final trcIdx = await StorageService.getTracingIndex();
    final stories = await StorageService.getCompletedStories();
    final stickers = await StorageService.getUnlockedStickers();
    final name = await StorageService.getChildName();
    final avatar = await StorageService.getChildAvatar();
    final recordings = await StorageService.getVoiceRecordingMetas();

    if (stories.length >= 4 && !trophies.contains('story_comprehension_master')) {
      await StorageService.addTrophy('story_comprehension_master');
      trophies.add('story_comprehension_master');
    }

    if (mounted) {
      setState(() {
        _limitMinutes = limit;
        _todaySeconds = todaySec;
        _trophies = trophies;
        _trainLevel = trLvl;
        _balloonLevel = blLvl;
        _quizLevel = qzLvl;
        _mazeLevel = mzLvl;
        _tracingIndex = trcIdx;
        _storiesCount = stories.length;
        _stickersCount = stickers.length;
        _childName = name;
        _childAvatar = avatar;
        _voiceRecordings = recordings;
      });
    }
  }

  void _setLimit(int minutes) {
    setState(() {
      _limitMinutes = minutes;
    });
    StorageService.saveScreenTimeLimit(minutes);
    widget.onLimitChanged?.call(minutes);
  }

  void _resetTodayTime() async {
    await StorageService.resetTodayPlayTime();
    if (mounted) {
      setState(() {
        _todaySeconds = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu bermain hari ini telah di-reset.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _generateMath() {
    final rand = math.Random();
    _a = rand.nextInt(7) + 4;
    _b = rand.nextInt(7) + 3;
    _answer = _a + _b;
  }

  void _verify() {
    final val = int.tryParse(_controller.text.trim());
    if (val == _answer) {
      setState(() {
        _isUnlocked = true;
      });
      HapticFeedback.mediumImpact();
    } else {
      _controller.clear();
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawaban belum tepat. Area ini khusus orang tua.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmResetLevelOne() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ulangi Dari Tingkat 1?',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ronde materi akan dimulai dari Tingkat 1 lagi agar anak bisa mengulang belajar. Trofi piala dan bintang anak tetap aman tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E22CE),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await StorageService.resetToLevelOneKeepTrophies();
              _loadDashboardData();
              widget.onDataReset?.call();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Materi telah disetel kembali ke Tingkat 1.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Ya, Ulangi'),
          ),
        ],
      ),
    );
  }

  void _confirmResetFactory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Total Data Belajar?',
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFDC2626),
          ),
        ),
        content: const Text(
          'Semua bintang, stiker, dan trofi piala akan dihapus seperti baru diinstal. Gunakan ini jika anak baru/adik yang lebih kecil ingin memulai dari nol.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await StorageService.resetAllDataFactory();
              _loadDashboardData();
              widget.onDataReset?.call();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data belajar telah di-reset dari awal.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset Total'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogMaxWidth = math.min(_isUnlocked ? 680.0 : 460.0, screenSize.width * 0.94);
    final dialogMaxHeight = math.min(_isUnlocked ? 480.0 : 420.0, screenSize.height * 0.92);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Container(
          width: dialogMaxWidth,
          height: _isUnlocked ? dialogMaxHeight : null,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFC084FC), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: _isUnlocked ? _buildUnlockedDashboard() : _buildLockScreen(),
        ),
      ),
    );
  }

  Widget _buildLockScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Zona Orang Tua',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7E22CE),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Jawab soal ini untuk membuka lemari trofi & laporan perkembangan anak:',
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Berapa $_a + $_b = ?',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7E22CE),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF581C87),
                  ),
                  decoration: InputDecoration(
                    hintText: '?',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFC084FC), width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E22CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Buka Kunci',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              ),
              child: Text(
                'Tutup',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnlockedDashboard() {
    return Column(
      children: [
        // Header Bar with Title and Close Button
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MascotWidget(size: 30),
                    const SizedBox(width: 8),
                    Text(
                      'Zona Orang Tua',
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6B21A8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _openCertificateDialog,
              icon: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB45309), size: 15),
              label: Text(
                '📜 Sertifikat',
                style: GoogleFonts.fredoka(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB45309),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF3C7),
                elevation: 1,
                side: const BorderSide(color: Color(0xFFFDE047), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tabs Selector (Trofi, Rapor, Pengaturan, Galeri Suara)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabButton(
                index: 0,
                icon: '🏆',
                label: 'Lemari Trofi (${_trophies.length}/${_allTrophies.length})',
              ),
              const SizedBox(width: 6),
              _buildTabButton(
                index: 1,
                icon: '📊',
                label: 'Rapor Belajar',
              ),
              const SizedBox(width: 6),
              _buildTabButton(
                index: 2,
                icon: '⚙️',
                label: 'Waktu, Suara & Reset',
              ),
              const SizedBox(width: 6),
              _buildTabButton(
                index: 3,
                icon: '🎙️',
                label: 'Galeri Suara (${_voiceRecordings.length})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Active Tab Viewport
        Expanded(
          child: _buildActiveTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required int index,
    required String icon,
    required String label,
  }) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7E22CE) : const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B21A8)
                : const Color(0xFFDDD6FE),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF6B21A8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildLuxuryTrophyCabinet();
      case 1:
        return _buildLearningReport();
      case 2:
        return _buildSettingsAndReset();
      case 3:
        return _buildVoiceRecordingsGallery();
      default:
        return _buildLuxuryTrophyCabinet();
    }
  }

  // --- TAB 1: LEMARI TROFI MEWAH BERKILAU ---
  Widget _buildLuxuryTrophyCabinet() {
    List<TrophyDef> displayedTrophies;
    if (_trophyFilterIndex == 1) {
      displayedTrophies = _allTrophies.where((t) => _trophies.contains(t.id)).toList();
    } else if (_trophyFilterIndex == 2) {
      displayedTrophies = _allTrophies.where((t) => !_trophies.contains(t.id)).toList();
    } else {
      displayedTrophies = _allTrophies;
    }

    return Column(
      children: [
        // Filter Chips Row
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTrophyFilterChip(0, 'Semua (${_allTrophies.length})'),
                    const SizedBox(width: 6),
                    _buildTrophyFilterChip(1, '🏆 Diraih (${_trophies.length})'),
                    const SizedBox(width: 6),
                    _buildTrophyFilterChip(2, '🔒 Terkunci (${_allTrophies.length - _trophies.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Ketuk piala!',
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Polished Wooden Cabinet Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E1065), // Deep royal purple
                  Color(0xFF451A03), // Mahogany wood
                  Color(0xFF78350F), // Polished cedar
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x30000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                // Top Golden Spotlight Rays
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SpotlightRaysPainter(),
                  ),
                ),

                // Trophies Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;
                    final crossAxisCount = isNarrow ? 1 : 2;
                    final cardWidth = (constraints.maxWidth - 20 - (crossAxisCount - 1) * 10) / crossAxisCount;
                    final targetHeight = isNarrow ? 92.0 : 86.0;
                    final cardAspectRatio = (cardWidth / targetHeight).clamp(0.5, 4.5);

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: cardAspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: displayedTrophies.length,
                      itemBuilder: (context, idx) {
                    final trophy = displayedTrophies[idx];
                    final isUnlocked = _trophies.contains(trophy.id);
                    final isTapped = _tappedTrophyId == trophy.id;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _tappedTrophyId = trophy.id;
                        });
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (mounted && _tappedTrophyId == trophy.id) {
                            setState(() => _tappedTrophyId = null);
                          }
                        });

                        if (isUnlocked) {
                          AudioService().playSfx('star');
                          AudioService().speak(
                              'Piala ${trophy.title}! Diraih dengan membanggakan oleh ananda $_childName karena telah ${trophy.desc}!');
                        } else {
                          AudioService().playSfx('pop');
                          AudioService().speak(
                              'Piala ${trophy.title} masih terkunci. Ayo semangati ananda untuk menyelesaikan ${trophy.desc}!');
                        }
                      },
                      child: AnimatedScale(
                        scale: isTapped ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isUnlocked
                                ? const LinearGradient(
                                    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.black.withAlpha(90),
                                      Colors.black.withAlpha(120),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isUnlocked ? const Color(0xFFFACC15) : const Color(0xFF78716C),
                              width: isUnlocked ? 2.2 : 1.2,
                            ),
                            boxShadow: isUnlocked
                                ? [
                                    BoxShadow(
                                      color: trophy.glowColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // 3D Pedestal Stand with Trophy
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? trophy.glowColor.withOpacity(0.25)
                                      : const Color(0xFF44403C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isUnlocked ? const Color(0xFFFDE047) : const Color(0xFF78716C),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isUnlocked ? trophy.icon : '🔒',
                                    style: TextStyle(fontSize: isUnlocked ? 24 : 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            trophy.title,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isUnlocked
                                                  ? const Color(0xFF854D0E)
                                                  : const Color(0xFFD6D3D1),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isUnlocked)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF16A34A),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'DIRAIH',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      trophy.desc,
                                      style: GoogleFonts.nunito(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: isUnlocked
                                            ? const Color(0xFF713F12)
                                            : const Color(0xFFA8A29E),
                                        height: 1.15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrophyFilterChip(int index, String label) {
    final isSel = _trophyFilterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _trophyFilterIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF7E22CE) : const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFDDD6FE),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : const Color(0xFF6B21A8),
          ),
        ),
      ),
    );
  }

  // --- SERTIFIKAT DIGITAL KELULUSAN JUARA CILIK ---
  void _openCertificateDialog() {
    HapticFeedback.mediumImpact();
    AudioService().playSfx('star');
    AudioService().speak('Sertifikat Penghargaan Juara Cilik untuk ananda $_childName!');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final now = DateTime.now();
          final months = [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ];
          final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
          final screenSize = MediaQuery.of(context).size;
          final certMaxWidth = math.min(680.0, screenSize.width * 0.95);
          final certMaxHeight = math.min(540.0, screenSize.height * 0.94);

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: certMaxWidth,
                maxHeight: certMaxHeight,
              ),
              child: Container(
                width: certMaxWidth,
                padding: EdgeInsets.all(screenSize.width < 500 ? 10 : 18),
              decoration: BoxDecoration(
                // Antique Parchment Ivory
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFDF5),
                    Color(0xFFFEFCE8),
                    Color(0xFFFFFDF5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD97706), width: 5),
                boxShadow: const [
                  BoxShadow(color: Color(0x40000000), blurRadius: 28, offset: Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  // Inner Ornate Thin Border
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                      ),
                    ),
                  ),

                  // Close Button top right
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),

                  // Certificate Content
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width < 500 ? 10 : 22,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Royal Emblems
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'TAMAN KATA AJAIB • PROGRAM LITERASI ANAK',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB45309),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('⭐', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Certificate Title
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'SERTIFIKAT KELULUSAN JUARA',
                              style: GoogleFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF854D0E),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Penghargaan Prestasi Membaca & Literasi Dini',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF78350F),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Decorative Star Ribbon Divider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 60, height: 1.5, color: const Color(0xFFF59E0B)),
                              const SizedBox(width: 8),
                              const Text('👑', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Container(width: 60, height: 1.5, color: const Color(0xFFF59E0B)),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Sertifikat ini dianugerahkan dengan penuh rasa bangga kepada:',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Recipient Child Name with Avatar & Edit Button
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChildAvatarWidget(
                                  avatarId: _childAvatar,
                                  size: 38,
                                  showGlow: true,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _childName,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF7E22CE),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _editChildNameDialog(setDialogState),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF7E22CE)),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Ubah Profil',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF7E22CE),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Citation Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Atas ketekunan, keceriaan, dan keberhasilan luar biasa dalam menguasai alfabet A–Z, merangkai suku kata, memecahkan teka-teki logika membaca, dan mengumpulkan prestasi bintang di Taman Kata Ajaib.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3 Achievement Seals
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCertificateMiniBadge(
                                  icon: '⭐',
                                  title: '${widget.totalStars} Bintang',
                                  subtitle: 'Bintang Terkumpul',
                                  color: const Color(0xFFFEF08A),
                                  borderColor: const Color(0xFFEAB308),
                                ),
                                const SizedBox(width: 8),
                                _buildCertificateMiniBadge(
                                  icon: '🏆',
                                  title: '${_trophies.length} / ${_allTrophies.length} Piala',
                                  subtitle: 'Trofi Diraih',
                                  color: const Color(0xFFEDE9FE),
                                  borderColor: const Color(0xFFA855F7),
                                ),
                                const SizedBox(width: 8),
                                _buildCertificateMiniBadge(
                                  icon: '🌟',
                                  title: 'Tingkat $_trainLevel',
                                  subtitle: 'Kategori Membaca',
                                  color: const Color(0xFFDCFCE7),
                                  borderColor: const Color(0xFF22C55E),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Bottom Signatures & Seal
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: 580,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left: Official Wax Stamp of Miko
                                  Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(color: Color(0x30991B1B), blurRadius: 6, offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text('🐾', style: TextStyle(fontSize: 22)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cap Sahabat Miko',
                                            style: GoogleFonts.fredoka(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF991B1B),
                                            ),
                                          ),
                                          Text(
                                            'Miko si Kucing Ajaib',
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Right: Date & Parent Signature
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Diterbitkan: $dateStr',
                                        style: GoogleFonts.nunito(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(width: 110, height: 1, color: const Color(0xFF94A3B8)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Orang Tua / Pendidik',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Screenshot / Print Tip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE047)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('📸', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  'Tips: Ambil tangkapan layar (screenshot) untuk dicetak atau dibagikan ke WhatsApp keluarga!',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  void _editChildNameDialog(StateSetter setDialogState) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AvatarSelectionDialog(
        currentAvatarId: _childAvatar,
        currentChildName: _childName,
      ),
    );
    if (result != null && mounted) {
      final newAvatar = result['avatarId'] ?? _childAvatar;
      final newName = result['childName'] ?? _childName;
      setState(() {
        _childAvatar = newAvatar;
        _childName = newName;
      });
      setDialogState(() {
        _childAvatar = newAvatar;
        _childName = newName;
      });
    }
  }

  Widget _buildCertificateMiniBadge({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: RAPOR BELAJAR ANAK ---
  Widget _buildLearningReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Total Stars Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAB308), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.totalStars} Bintang Juara Terkumpul!',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF854D0E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Prestasi luar biasa dalam membaca & eksplorasi kata.',
                              style: GoogleFonts.nunito(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF713F12),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Aktif Belajar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 6 Islands Report Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Jejak Huruf',
                  icon: '✍️',
                  levelInfo: '$_tracingIndex / 26 Huruf Terlatih',
                  detail: 'Melatih motorik halus & bentuk fonik A–Z.',
                  color: const Color(0xFFFEF9C3),
                  borderColor: const Color(0xFFFDE047),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Kereta Suku Kata',
                  icon: '🚂',
                  levelInfo: 'Tingkat $_trainLevel dari 3',
                  detail: 'Menyusun suku kata terbuka & tertutup.',
                  color: const Color(0xFFE0F2FE),
                  borderColor: const Color(0xFFBAE6FD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Balon Kata Ajaib',
                  icon: '🎈',
                  levelInfo: 'Tingkat $_balloonLevel dari 3',
                  detail: 'Refleks cepat membaca & kosakata rumpang.',
                  color: const Color(0xFFFCE7F3),
                  borderColor: const Color(0xFFFBCFE8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Kuis Sentuh Pintar',
                  icon: '🧠',
                  levelInfo: 'Tingkat $_quizLevel dari 3',
                  detail: 'Analisis fonik awal & teka-teki logika.',
                  color: const Color(0xFFEDE9FE),
                  borderColor: const Color(0xFFDDD6FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Buku Cerita Ajaib',
                  icon: '📖',
                  levelInfo: '$_storiesCount dari 4 Dongeng Tamat',
                  detail: 'Pemahaman bacaan & kuis dongeng.',
                  color: const Color(0xFFF3E8FF),
                  borderColor: const Color(0xFFD8B4FE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Taman Stiker',
                  icon: '🎨',
                  levelInfo: '$_stickersCount Stiker Terbuka',
                  detail: 'Kreativitas visual & komposisi seni.',
                  color: const Color(0xFFDCFCE7),
                  borderColor: const Color(0xFF86EFAC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildIslandProgressCard(
                  title: 'Lembah Labirin Kata',
                  icon: '🧭',
                  levelInfo: 'Tingkat $_mazeLevel dari 3',
                  detail: 'Logika arah & urutan fonem kata.',
                  color: const Color(0xFFFFEDD5),
                  borderColor: const Color(0xFFFED7AA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pedagogical Insights Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips Edukasi: Aplikasi ini 100% lokal offline dan bebas iklan. Ajak anak membaca kata secara bersuara saat bermain kereta dan berikan apresiasi saat mereka menyelesaikan setiap tingkat!',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                      height: 1.3,
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

  Widget _buildIslandProgressCard({
    required String title,
    required String icon,
    required String levelInfo,
    required String detail,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  levelInfo,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0369A1),
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: WAKTU MAIN & RESET AMAN ---
  Widget _buildSettingsAndReset() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Child Profile Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
            ),
            child: Row(
              children: [
                ChildAvatarWidget(avatarId: _childAvatar, size: 48, showGlow: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Petualang Cilik',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7E22CE),
                        ),
                      ),
                      Text(
                        _childName,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF581C87),
                        ),
                      ),
                      Text(
                        'Sahabat: ${ChildAvatarData.getAvatar(_childAvatar).name}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: const Color(0xFF6B21A8),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _editChildNameDialog(setState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E22CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Ubah Profil', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1. Screen Time Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⏱️ Batas Waktu Main Harian',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B21A8),
                      ),
                    ),
                    if (_todaySeconds > 0)
                      GestureDetector(
                        onTap: _resetTodayTime,
                        child: Text(
                          'Reset Hari Ini',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9333EA),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [0, 15, 30, 45, 60].map((mins) {
                    final isSel = _limitMinutes == mins;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setLimit(mins),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF7E22CE) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF6B21A8)
                                  : const Color(0xFFD8B4FE),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              mins == 0 ? 'Mati' : '$mins Mnt',
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF6B21A8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  _limitMinutes == 0
                      ? '• Status: Bermain santai bebas tanpa batas waktu.'
                      : '• Waktu hari ini: ${(_todaySeconds / 60).floor()} menit / $_limitMinutes menit (Sisa: ${math.max(0, _limitMinutes - (_todaySeconds / 60).floor())} mnt).',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF581C87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Audio & Musik Latar Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎵 Pengaturan Suara & Musik',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            AudioService().isMuted ? Icons.volume_off : Icons.volume_up,
                            color: const Color(0xFF16A34A),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Suara Efek & Narator',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !AudioService().isMuted,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: (val) {
                        setState(() {
                          AudioService().toggleMute();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            (AudioService().isBgmMuted || AudioService().isMuted)
                                ? Icons.music_off
                                : Icons.music_note,
                            color: const Color(0xFF16A34A),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Musik Latar Ceria (BGM)',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !AudioService().isBgmMuted && !AudioService().isMuted,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: (val) {
                        setState(() {
                          AudioService().toggleBgm();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFBBF7D0), height: 1),
                const SizedBox(height: 10),

                // Voice Character Gender Selector
                Text(
                  '🗣️ Karakter Suara Maskot Miko (TTS)',
                  style: GoogleFonts.fredoka(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Option: Cewek (Perempuan)
                    Expanded(
                      child: _buildVoiceGenderOption(
                        gender: 'female',
                        icon: '👧',
                        title: 'Kakak Cewek',
                        subtitle: 'Ceria & Lembut',
                        isSelected: AudioService().voiceGender == 'female',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Option: Cowok (Laki-laki)
                    Expanded(
                      child: _buildVoiceGenderOption(
                        gender: 'male',
                        icon: '👦',
                        title: 'Kakak Cowok',
                        subtitle: 'Hangat & Semangat',
                        isSelected: AudioService().voiceGender == 'male',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFBBF7D0), height: 1),
                const SizedBox(height: 10),

                // Voice Speech Rate Selector
                Text(
                  '🐢 Kecepatan Pelafalan Pemandu',
                  style: GoogleFonts.fredoka(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Option: Santai (0.75x)
                    Expanded(
                      child: _buildVoiceSpeedOption(
                        speed: 'slow',
                        icon: '🐢',
                        title: 'Mode Santai',
                        subtitle: '0.75x (Balita/Pemula)',
                        isSelected: AudioService().speechSpeed == 'slow',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Option: Ceria (1.0x)
                    Expanded(
                      child: _buildVoiceSpeedOption(
                        speed: 'normal',
                        icon: '🐰',
                        title: 'Mode Ceria',
                        subtitle: '1.0x (Anak Lancar)',
                        isSelected: AudioService().speechSpeed != 'slow',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Test Speech button & Engine info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${AudioService().engineStatus} • ${AudioService().isSlowSpeed ? "Santai 🐢 (0.75x)" : "Ceria 🐰 (1.0x)"}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF15803D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final isSlow = AudioService().isSlowSpeed;
                        if (AudioService().voiceGender == 'male') {
                          AudioService().speak(
                            isSlow
                                ? 'Ha-lo! A-ku Mi-ko, mo-de san-tai un-tuk be-la-jar!'
                                : 'Halo! Aku Miko, suara laki-laki siap menemani belajar!',
                          );
                        } else {
                          AudioService().speak(
                            isSlow
                                ? 'Ha-lo! A-ku Mi-ko, mo-de san-tai un-tuk be-la-jar!'
                                : 'Halo! Aku Miko, suara perempuan siap menemani belajar!',
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Color(0x20000000), blurRadius: 2, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Tes Suara',
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Granular Reset Section
          Text(
            'Zona Reset Progres Belajar',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),

          // Option A: Repeat from Level 1
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔄 Ulangi Materi Dari Tingkat 1',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Menyetel kembali materi belajar ke tingkat 1 agar anak dapat mengulang, tanpa menghapus piala dan bintang yang telah diraih.',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E22CE),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmResetLevelOne,
                  child: Text(
                    'Ulangi',
                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Option B: Total Factory Reset
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Reset Total Data Belajar',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Menghapus semua bintang, stiker, dan trofi piala untuk memulai dari awal (cocok jika tablet digunakan oleh adik baru).',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmResetFactory,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceGenderOption({
    required String gender,
    required String icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await AudioService().setVoiceGender(gender);
        setState(() {});
        if (gender == 'male') {
          AudioService().speak('Halo! Aku Miko, suara laki-laki siap menemani belajar!');
        } else {
          AudioService().speak('Halo! Aku Miko, suara perempuan siap menemani belajar!');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF14532D)
                                : const Color(0xFF334155),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF16A34A),
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSpeedOption({
    required String speed,
    required String icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await AudioService().setSpeechSpeed(speed);
        setState(() {});
        final isSlow = speed == 'slow';
        if (AudioService().voiceGender == 'male') {
          AudioService().speak(
            isSlow
                ? 'Ha-lo! Mo-de san-tai ak-tif.'
                : 'Halo! Mode ceria aktif!',
          );
        } else {
          AudioService().speak(
            isSlow
                ? 'Ha-lo! Mo-de san-tai ak-tif.'
                : 'Halo! Mode ceria aktif!',
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF14532D)
                                : const Color(0xFF334155),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF16A34A),
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    VoiceRecordingService().stopPlayback();
    super.dispose();
  }

  // --- TAB 4: GALERI SUARA ANANDA ---
  Widget _buildVoiceRecordingsGallery() {
    if (_voiceRecordings.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x107E22CE),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD8B4FE), width: 3),
                  ),
                  child: const Center(
                    child: Text('🎙️', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Rekaman Suara',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF581C87),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajak $_childName menekan tombol 🎙️ "Rekam Suaraku" saat bermain Menulis Huruf, Kereta Kata, atau Kamus Kata.\n\nSetiap rekaman akan tersimpan di sini agar Ayah & Bunda bisa mendengarkan pelafalan ananda dan memberikan apresiasi! ⭐',
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Top Info Header Banner
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
          ),
          child: Row(
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Galeri Suara Emas Ananda (${_voiceRecordings.length} Rekaman)',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B21A8),
                      ),
                    ),
                    Text(
                      'Dengarkan pelafalan kata & huruf yang telah direkam oleh $_childName!',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7E22CE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of Recording Cards
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: _voiceRecordings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final rec = _voiceRecordings[index];
              final key = rec['key'] as String? ?? '';
              final word = rec['wordOrLetter'] as String? ?? '';
              final label = rec['displayLabel'] as String? ?? '';
              final category = rec['category'] as String? ?? 'Kata';
              final avatar = rec['avatarId'] as String? ?? _childAvatar;
              final recordedAt = rec['recordedAt'] as String? ?? '';
              final duration = (rec['durationSeconds'] as num?)?.toInt() ?? 2;
              final isPlaying = _activePlayingVoiceKey == key;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPlaying ? const Color(0xFFA855F7) : const Color(0xFFE2E8F0),
                    width: isPlaying ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPlaying ? const Color(0x257E22CE) : const Color(0x08000000),
                      blurRadius: isPlaying ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Child Avatar with mic badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ChildAvatarWidget(avatarId: avatar, size: 38, showGlow: false),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF9333EA),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🎙️', style: TextStyle(fontSize: 9)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Word and Meta Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.fredoka(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF7E22CE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$label • ${_formatRecordingDate(recordedAt)} • ${duration}s',
                            style: GoogleFonts.nunito(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Playback Button (Child Voice)
                    ElevatedButton.icon(
                      onPressed: () => _toggleVoicePlayback(key, word, duration),
                      icon: Text(isPlaying ? '⏹️' : '▶️', style: const TextStyle(fontSize: 13)),
                      label: Text(
                        isPlaying ? 'Stop' : 'Suaraku',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPlaying ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Compare with Teacher Audio
                    IconButton(
                      icon: const Text('🗣️', style: TextStyle(fontSize: 16)),
                      tooltip: 'Dengar Suara Pemandu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        AudioService().speak(word);
                      },
                    ),

                    // Delete Recording Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                      tooltip: 'Hapus Rekaman',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => _confirmDeleteRecording(key, word),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _toggleVoicePlayback(String key, String word, int durationSec) async {
    HapticFeedback.selectionClick();
    if (_activePlayingVoiceKey == key) {
      await VoiceRecordingService().stopPlayback();
      if (mounted) {
        setState(() => _activePlayingVoiceKey = null);
      }
      return;
    }

    setState(() => _activePlayingVoiceKey = key);
    final success = await VoiceRecordingService().playRecording(key);
    if (!success) {
      await AudioService().speak(word);
    }

    Future.delayed(Duration(seconds: math.max(2, durationSec + 1)), () {
      if (mounted && _activePlayingVoiceKey == key) {
        setState(() => _activePlayingVoiceKey = null);
      }
    });
  }

  void _confirmDeleteRecording(String key, String word) async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Rekaman?',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Ayah/Bunda ingin menghapus rekaman suara untuk "$word"?',
          style: GoogleFonts.nunito(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: GoogleFonts.fredoka(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Hapus', style: GoogleFonts.fredoka(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await VoiceRecordingService().deleteRecording(key);
      final updated = await StorageService.getVoiceRecordingMetas();
      if (mounted) {
        setState(() {
          _voiceRecordings = updated;
          if (_activePlayingVoiceKey == key) {
            _activePlayingVoiceKey = null;
          }
        });
      }
    }
  }

  String _formatRecordingDate(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $hour:$minute';
  }
}

class _SpotlightRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFDE047).withAlpha(45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final rayPath = Path();
    rayPath.moveTo(w * 0.35, 0);
    rayPath.lineTo(w * 0.1, h);
    rayPath.lineTo(w * 0.45, h);
    rayPath.lineTo(w * 0.5, 0);
    rayPath.close();

    rayPath.moveTo(w * 0.65, 0);
    rayPath.lineTo(w * 0.55, h);
    rayPath.lineTo(w * 0.9, h);
    rayPath.lineTo(w * 0.7, 0);
    rayPath.close();

    canvas.drawPath(rayPath, rayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
