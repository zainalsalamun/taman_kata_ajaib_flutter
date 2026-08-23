import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/vector_illustrations.dart';
import '../services/audio_service.dart';

class MapScreen extends StatelessWidget {
  final Function(String route) onSelectGame;

  const MapScreen({super.key, required this.onSelectGame});

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

              // 3 Islands Horizontal Scroll / Responsive Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIslandCard(
                      context,
                      title: 'Jejak Huruf',
                      age: 'Usia 3-5 Thn',
                      desc: 'Tarik garis ajaib dan kenali bunyi fonik huruf!',
                      colorGrad: const [Color(0xFFFEF9C3), Colors.white],
                      borderColor: const Color(0xFFFDE047),
                      illustrationKey: 'apel',
                      onTap: () => onSelectGame('tracing'),
                    ),
                    const SizedBox(width: 16),
                    _buildIslandCard(
                      context,
                      title: 'Kereta Suku Kata',
                      age: 'Usia 5-7 Thn',
                      desc: 'Susun gerbong kata dan bunyikan peluit kereta!',
                      colorGrad: const [Color(0xFFE0F2FE), Colors.white],
                      borderColor: const Color(0xFFBAE6FD),
                      illustrationKey: 'bola',
                      onTap: () => onSelectGame('train'),
                    ),
                    const SizedBox(width: 16),
                    _buildIslandCard(
                      context,
                      title: 'Balon Kata Ajaib',
                      age: 'Usia 6-8 Thn',
                      desc: 'Letuskan balon kata yang tepat dan raih bintang!',
                      colorGrad: const [Color(0xFFFCE7F3), Colors.white],
                      borderColor: const Color(0xFFFBCFE8),
                      illustrationKey: 'balon',
                      onTap: () => onSelectGame('balloon'),
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
    required String desc,
    required List<Color> colorGrad,
    required Color borderColor,
    required String illustrationKey,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 220,
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
                ObjectIllustrationWidget(illustrationKey: illustrationKey, size: 60),
                Column(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
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
