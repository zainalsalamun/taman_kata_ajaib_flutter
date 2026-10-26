import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'child_avatar_widget.dart';
import 'interactive_fireworks.dart';

enum CertificateTheme {
  royalGold,
  oceanRainbow,
}

/// ---------------------------------------------------------------------------
/// ACHIEVEMENT CERTIFICATE DIALOG (PIAGAM PRESTASI & KELULUSAN JUARA)
/// High-resolution, printable/shareable certificate of achievement for the child.
/// ---------------------------------------------------------------------------
class AchievementCertificateDialog extends StatefulWidget {
  final VoidCallback? onBackToMap;

  const AchievementCertificateDialog({
    super.key,
    this.onBackToMap,
  });

  @override
  State<AchievementCertificateDialog> createState() =>
      _AchievementCertificateDialogState();
}

class _AchievementCertificateDialogState
    extends State<AchievementCertificateDialog>
    with SingleTickerProviderStateMixin {
  final GlobalKey _certificateKey = GlobalKey();
  final AudioService _audio = AudioService();

  bool _isLoading = true;
  String _childName = 'Juara Cilik';
  String _avatarId = 'miko';
  int _totalStars = 0;
  int _masteredIslandsCount = 0;
  int _learnedWordsCount = 0;
  int _storiesCount = 0;
  int _trophiesCount = 0;
  late String _completionDate;
  late String _certificateNumber;

  CertificateTheme _theme = CertificateTheme.royalGold;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _completionDate = _formatCurrentDateIndonesian();
    _loadCertificateData();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  String _formatCurrentDateIndonesian() {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final monthName = months[now.month - 1];
    return '${now.day} $monthName ${now.year}';
  }

  void _loadCertificateData() async {
    final name = await StorageService.getChildName();
    final avatar = await StorageService.getChildAvatar();
    final stars = await StorageService.getStars();
    final learnedWords = await StorageService.getLearnedWords();
    final completedStories = await StorageService.getCompletedStories();
    final trophies = await StorageService.getTrophies();

    // Check island levels
    int mastered = 0;
    for (final game in ['tracing', 'train', 'balloon', 'quiz', 'maze']) {
      final lvl = await StorageService.getUnlockedGameLevel(game);
      if (lvl >= 3) mastered++;
    }
    if (completedStories.length >= 3) mastered++;
    if (learnedWords.length >= 10) mastered++;

    final certHash = name.hashCode.abs().toString().padLeft(5, '0');
    final certNo = 'TKA-${DateTime.now().year}-${certHash.substring(0, math.min(5, certHash.length))}';

    if (mounted) {
      setState(() {
        _childName = name;
        _avatarId = avatar;
        _totalStars = stars;
        _learnedWordsCount = learnedWords.length;
        _storiesCount = completedStories.length;
        _trophiesCount = trophies.length;
        _masteredIslandsCount = mastered;
        _certificateNumber = certNo;
        _isLoading = false;
      });

      HapticFeedback.heavyImpact();
      _audio.playSfx('fanfare');
      Future.delayed(const Duration(milliseconds: 400), () {
        _audio.playSfx('cheer');
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          _audio.speak(
            'Selamat kepada $_childName! Inilah Sertifikat Piagam Juara Membaca resmi dari Taman Kata Ajaib! Ayah, Bunda, dan Miko sangat bangga atas prestasimu!',
          );
        }
      });
    }
  }

  String get _championTitle {
    if (_totalStars >= 150 || _masteredIslandsCount >= 5) {
      return 'MAHAGURU LITERASI CILIK 👑';
    } else if (_totalStars >= 80 || _masteredIslandsCount >= 3) {
      return 'KSATRIA KATA CEMERLANG 🌟';
    } else if (_totalStars >= 30 || _masteredIslandsCount >= 1) {
      return 'PENJELAJAH PULAU AJAIB 🏝️';
    }
    return 'PETUALANG KATA PEMBERANI 🎈';
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _childName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('✏️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Ubah Nama di Piagam',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tulis nama lengkap ananda yang ingin dicetak pada sertifikat:',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.fredoka(fontSize: 16, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Nama Juara Cilik',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0284C7), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.fredoka(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await StorageService.saveChildName(newName);
                if (mounted) {
                  setState(() {
                    _childName = newName;
                  });
                  _audio.playSfx('sparkle');
                  _audio.speak('Nama sertifikat diperbarui menjadi $newName!');
                }
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Simpan Nama',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    HapticFeedback.selectionClick();
    _audio.playSfx('ding');
    setState(() {
      _theme = _theme == CertificateTheme.royalGold
          ? CertificateTheme.oceanRainbow
          : CertificateTheme.royalGold;
    });
  }

  Future<void> _captureAndShowPreview() async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('sparkle');

    try {
      final boundary = _certificateKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null && mounted) {
        _audio.playSfx('win');
        _audio.speak('Piagam resolusi tinggi siap disimpan dan dibagikan!');

        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'Pratinjau Piagam Siap Cetak',
                            style: GoogleFonts.fredoka(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      pngBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Text('📸', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Piagam berhasil dirender dalam kualitas gambar ultra-jernih! Ayah/Bunda dapat mengambil tangkapan layar (screenshot) untuk dicetak.',
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      'Tutup Pratinjau',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating certificate preview: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(640.0, screenSize.width * 0.96);
    final dialogMaxHeight = screenSize.height * 0.94;
    final isSmallScreen = screenSize.width < 500;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
        child: SizedBox(
          width: dialogWidth,
          child: InteractiveFireworksOverlay(
            autoLaunch: true,
            tapEnabled: true,
            showTapHint: false,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFEF3C7),
                    Colors.white,
                    Color(0xFFFFFBEB),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFF59E0B), width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35F59E0B),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Action Bar inside Dialog: Controls & Close
                        _buildTopToolbar(isSmallScreen),

                        const SizedBox(height: 8),

                        // The Scrollable Certificate Canvas Container
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Center(
                              child: RepaintBoundary(
                                key: _certificateKey,
                                child: _buildCertificateCard(isSmallScreen),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Bottom Actions: Download/Preview & Close
                        _buildBottomActions(isSmallScreen),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopToolbar(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                ),
              ),
              child: const Text('📜', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            Text(
              'Piagam Juara Membaca',
              style: GoogleFonts.fredoka(
                fontSize: isSmallScreen ? 15 : 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Theme toggle button
            GestureDetector(
              onTap: _toggleTheme,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _theme == CertificateTheme.royalGold ? '👑' : '🌈',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _theme == CertificateTheme.royalGold ? 'Emas' : 'Pelangi',
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
            const SizedBox(width: 8),

            // Edit Name button
            GestureDetector(
              onTap: _showEditNameDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF0369A1)),
                    const SizedBox(width: 4),
                    Text(
                      'Ubah Nama',
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
            const SizedBox(width: 8),

            // Close dialog
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
        ),
      ],
    );
  }

  Widget _buildCertificateCard(bool isSmallScreen) {
    final isGold = _theme == CertificateTheme.royalGold;

    final primaryGold = isGold ? const Color(0xFFD97706) : const Color(0xFF0284C7);
    final secondaryGold = isGold ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9);

    final bgGradient = isGold
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFDF5),
              Color(0xFFFEFCE8),
              Color(0xFFFEF9C3),
              Color(0xFFFFFDF7),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFE0F2FE),
              Color(0xFFFEF9C3),
              Color(0xFFFAF5FF),
            ],
          );

    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withAlpha(50),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CertificateBorderPainter(
          primaryColor: primaryGold,
          secondaryColor: secondaryGold,
          isGold: isGold,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 18 : 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. TOP HEADER: Ribbon & App Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGold
                        ? [const Color(0xFFB45309), const Color(0xFF92400E)]
                        : [const Color(0xFF0369A1), const Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      'TAMAN KATA AJAIB • PIAGAM KELULUSAN RESMI',
                      style: GoogleFonts.fredoka(
                        fontSize: isSmallScreen ? 9.5 : 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 2. MAIN TITLE
              Text(
                'SERTIFIKAT JUARA MEMBACA',
                style: GoogleFonts.fredoka(
                  fontSize: isSmallScreen ? 20 : 25,
                  fontWeight: FontWeight.w900,
                  color: isGold ? const Color(0xFF78350F) : const Color(0xFF0369A1),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              Text(
                'Dianugerahkan dengan bangga dan rasa hormat kepada:',
                style: GoogleFonts.nunito(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 3. CHILD AVATAR & NAME
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar badge with glowing border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryGold, secondaryGold],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGold.withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ChildAvatarWidget(
                        avatarId: _avatarId,
                        size: isSmallScreen ? 52 : 64,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Child Full Name
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _childName,
                          style: GoogleFonts.fredoka(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: primaryGold.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryGold.withAlpha(80), width: 1),
                          ),
                          child: Text(
                            _championTitle,
                            style: GoogleFonts.fredoka(
                              fontSize: isSmallScreen ? 10.5 : 12,
                              fontWeight: FontWeight.bold,
                              color: isGold ? const Color(0xFF92400E) : const Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. PRAISE DESCRIPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Telah menunjukkan semangat belajar, ketekunan merangkai huruf dan suku kata, serta keberanian berpetualang menaklukkan pulau-pulau ajaib.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 5. FOUR ACHIEVEMENT STATS PILLS
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatBadge('⭐', '$_totalStars Bintang', const Color(0xFFF59E0B)),
                  _buildStatBadge('🏝️', '$_masteredIslandsCount Pulau Kuasai', const Color(0xFF10B981)),
                  _buildStatBadge('📚', '$_learnedWordsCount Kata Hafal', const Color(0xFF3B82F6)),
                  _buildStatBadge('🏆', '$_trophiesCount Piala Juara', const Color(0xFF8B5CF6)),
                ],
              ),

              const SizedBox(height: 16),

              // 6. OFFICIAL FOOTER: Seal & Signatures
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left Signature: Miko si Kucing Ajaib
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🐾', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            'Miko Ajaib',
                            style: GoogleFonts.caveat(
                              fontSize: isSmallScreen ? 20 : 23,
                              fontWeight: FontWeight.w900,
                              color: isGold ? const Color(0xFF78350F) : const Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: isSmallScreen ? 90 : 110,
                        height: 1.5,
                        color: const Color(0xFF94A3B8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        'Pemandu Pulau Kata',
                        style: GoogleFonts.nunito(
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  // Center: Embossed Royal Seal
                  _buildEmbossedSeal(primaryGold, secondaryGold, isSmallScreen),

                  // Right Signature: Ayah & Bunda
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 4),
                          Text(
                            'Ayah & Bunda',
                            style: GoogleFonts.caveat(
                              fontSize: isSmallScreen ? 20 : 23,
                              fontWeight: FontWeight.w900,
                              color: isGold ? const Color(0xFF78350F) : const Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: isSmallScreen ? 90 : 110,
                        height: 1.5,
                        color: const Color(0xFF94A3B8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        'Pendamping Hebat',
                        style: GoogleFonts.nunito(
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Bottom Date & Certificate Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No: $_certificateNumber',
                    style: GoogleFonts.fredoka(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'Diterbitkan: $_completionDate',
                    style: GoogleFonts.fredoka(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
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

  Widget _buildStatBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(90), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbossedSeal(Color primaryGold, Color secondaryGold, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 60 : 72,
      height: isSmallScreen ? 60 : 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            secondaryGold,
            primaryGold,
            const Color(0xFF78350F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFFEF08A), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFFBEB), width: 1),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 14)),
              Text(
                'RESMI',
                style: GoogleFonts.fredoka(
                  fontSize: isSmallScreen ? 8 : 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'TKA',
                style: GoogleFonts.fredoka(
                  fontSize: isSmallScreen ? 7 : 8,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFEF08A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Download / Preview Print Certificate Button
        ElevatedButton.icon(
          onPressed: _captureAndShowPreview,
          icon: const Icon(Icons.photo_camera_rounded, size: 18),
          label: Text(
            'Pratinjau Gambar Cetak 📸',
            style: GoogleFonts.fredoka(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 14 : 20,
              vertical: 10,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Close Button
        OutlinedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            if (widget.onBackToMap != null) {
              widget.onBackToMap!();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 14 : 20,
              vertical: 10,
            ),
          ),
          child: Text(
            'Tutup Piagam',
            style: GoogleFonts.fredoka(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// CUSTOM PAINTER FOR ORNAMENTAL CERTIFICATE BORDER
/// Draws royal double borders and classical corner flourishes.
/// ---------------------------------------------------------------------------
class _CertificateBorderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isGold;

  _CertificateBorderPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isGold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      const Radius.circular(20),
    );

    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(16),
    );

    // 1. Outer Border
    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(outerRect, outerPaint);

    // 2. Inner Border
    final innerPaint = Paint()
      ..color = secondaryColor.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(innerRect, innerPaint);

    // 3. Corner Flourishes (4 corners)
    final flourishPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    const cornerOffset = 18.0;
    const cornerSize = 14.0;

    // Top-Left Corner
    _drawCornerFlourish(canvas, 14, 14, cornerSize, flourishPaint, dotPaint, 0);

    // Top-Right Corner
    _drawCornerFlourish(
      canvas,
      size.width - 14,
      14,
      cornerSize,
      flourishPaint,
      dotPaint,
      math.pi / 2,
    );

    // Bottom-Right Corner
    _drawCornerFlourish(
      canvas,
      size.width - 14,
      size.height - 14,
      cornerSize,
      flourishPaint,
      dotPaint,
      math.pi,
    );

    // Bottom-Left Corner
    _drawCornerFlourish(
      canvas,
      14,
      size.height - 14,
      cornerSize,
      flourishPaint,
      dotPaint,
      3 * math.pi / 2,
    );
  }

  void _drawCornerFlourish(
    Canvas canvas,
    double cx,
    double cy,
    double size,
    Paint linePaint,
    Paint dotPaint,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);

    final path = Path();
    path.moveTo(0, size);
    path.quadraticBezierTo(size * 0.4, size * 0.4, size, 0);
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(Offset(size * 0.35, size * 0.35), 2.2, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CertificateBorderPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isGold != isGold;
  }
}
