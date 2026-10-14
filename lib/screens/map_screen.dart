import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/vector_illustrations.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class MapScreen extends StatefulWidget {
  final Function(String route) onSelectGame;

  const MapScreen({super.key, required this.onSelectGame});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _trainLevel = 1;
  int _balloonLevel = 1;
  int _quizLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() async {
    final tr = await StorageService.getUnlockedGameLevel('train');
    final bl = await StorageService.getUnlockedGameLevel('balloon');
    final qz = await StorageService.getUnlockedGameLevel('quiz');
    if (mounted) {
      setState(() {
        _trainLevel = tr;
        _balloonLevel = bl;
        _quizLevel = qz;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.2,
          colors: [
            Color(0xFFBBF7D0),
            Color(0xFFBAE6FD),
            Color(0xFFE0F2FE),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Banner Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFCD34D), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFF59E0B),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'PETUALANGAN TAMAN KATA AJAIB',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD97706),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 6 Islands Horizontal Scroll / Responsive Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIslandCard(
                      context,
                      title: 'Jejak Huruf',
                      age: 'Usia 3-5 Thn',
                      levelBadge: '🌱 26 Huruf',
                      desc: 'Tarik garis ajaib dan kenali bunyi fonik huruf!',
                      colorGrad: const [Color(0xFFFEF9C3), Colors.white],
                      borderColor: const Color(0xFFFDE047),
                      illustrationKey: 'apel',
                      onTap: () => widget.onSelectGame('tracing'),
                    ),
                    const SizedBox(width: 14),
                    _buildIslandCard(
                      context,
                      title: 'Kereta Suku Kata',
                      age: 'Usia 5-7 Thn',
                      levelBadge: 'Tingkat $_trainLevel ${_trainLevel > 1 ? "⭐" : ""}',
                      desc: 'Susun gerbong kata dan bunyikan peluit kereta!',
                      colorGrad: const [Color(0xFFE0F2FE), Colors.white],
                      borderColor: const Color(0xFFBAE6FD),
                      illustrationKey: 'bola',
                      onTap: () => widget.onSelectGame('train'),
                    ),
                    const SizedBox(width: 14),
                    _buildIslandCard(
                      context,
                      title: 'Balon Kata Ajaib',
                      age: 'Usia 6-8 Thn',
                      levelBadge: 'Tingkat $_balloonLevel ${_balloonLevel > 1 ? "⭐" : ""}',
                      desc: 'Letuskan balon kata yang tepat dan raih bintang!',
                      colorGrad: const [Color(0xFFFCE7F3), Colors.white],
                      borderColor: const Color(0xFFFBCFE8),
                      illustrationKey: 'balon',
                      onTap: () => widget.onSelectGame('balloon'),
                    ),
                    const SizedBox(width: 14),
                    _buildIslandCard(
                      context,
                      title: 'Kuis Sentuh Pintar',
                      age: 'Semua Usia',
                      levelBadge: 'Tingkat $_quizLevel ${_quizLevel > 1 ? "⭐" : ""}',
                      desc: 'Dengarkan suaranya, tinggal pencet gambar yang benar!',
                      colorGrad: const [Color(0xFFEDE9FE), Colors.white],
                      borderColor: const Color(0xFFDDD6FE),
                      illustrationKey: 'kucing',
                      onTap: () => widget.onSelectGame('quiz'),
                    ),
                    const SizedBox(width: 14),
                    _buildIslandCard(
                      context,
                      title: 'Taman Kreasi Stiker',
                      age: 'Kreativitas',
                      levelBadge: '🎨 Kreasi',
                      desc: 'Hias taman ajaib sesukamu dengan stiker hadiahmu!',
                      colorGrad: const [Color(0xFFDCFCE7), Colors.white],
                      borderColor: const Color(0xFF86EFAC),
                      illustrationKey: 'rumah',
                      onTap: () => widget.onSelectGame('playground'),
                    ),
                    const SizedBox(width: 14),
                    _buildIslandCard(
                      context,
                      title: 'Buku Cerita Ajaib',
                      age: 'Membaca Cerita',
                      levelBadge: '📖 Dongeng',
                      desc: 'Dengar dongeng bersuara & sentuh gambar ajaibnya!',
                      colorGrad: const [Color(0xFFF3E8FF), Colors.white],
                      borderColor: const Color(0xFFD8B4FE),
                      illustrationKey: 'buku',
                      onTap: () => widget.onSelectGame('storybook'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslandCard(
    BuildContext context, {
    required String title,
    required String age,
    required String levelBadge,
    required String desc,
    required List<Color> colorGrad,
    required Color borderColor,
    required String illustrationKey,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 210,
      height: 270,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colorGrad,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Level Badge
          Positioned(
            top: -10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF08A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEAB308), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                levelBadge,
                style: GoogleFonts.fredoka(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF854D0E),
                ),
              ),
            ),
          ),

          // Right Age Badge
          Positioned(
            top: -10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                age,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 6),
                ObjectIllustrationWidget(illustrationKey: illustrationKey, size: 58),
                Column(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      AudioService().playSfx('whoosh');
                      AudioService().speak('Ayo main $title!');
                      onTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      elevation: 4,
                      shadowColor: const Color(0xFF15803D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Mulai Main',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
}
