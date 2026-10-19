import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback? onOpenParentalGate;

  const SettingsDialog({
    super.key,
    this.onOpenParentalGate,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final AudioService _audio = AudioService();
  bool _isPlayingTest = false;

  void _testSpeech(String gender) async {
    HapticFeedback.mediumImpact();
    setState(() => _isPlayingTest = true);

    if (gender == 'male') {
      await _audio.speak('Halo adik pintar! Aku Miko dengan suara Kakak Cowok, siap menemani belajar membaca!');
    } else {
      await _audio.speak('Halo adik manis! Aku Miko dengan suara Kakak Cewek, siap menemani belajar membaca!');
    }

    if (mounted) {
      setState(() => _isPlayingTest = false);
    }
  }

  void _selectVoice(String gender) async {
    HapticFeedback.selectionClick();
    await _audio.setVoiceGender(gender);
    setState(() {});
    _testSpeech(gender);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(540.0, screenSize.width * 0.94);
    final dialogHeight = math.min(680.0, screenSize.height * 0.92);
    final currentGender = _audio.voiceGender;

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
                Color(0xFFFFFFFF),
                Color(0xFFF8FAFC),
                Color(0xFFF1F5F9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFC084FC), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x357E22CE),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7E22CE), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⚙️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengaturan Aplikasi',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Karakter Suara Miko & Audio Permainan',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE9D5FF),
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
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body Scrollable
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Karakter Suara
                      Row(
                        children: [
                          const Text('🗣️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Karakter Suara Maskot Miko',
                            style: GoogleFonts.fredoka(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF581C87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih karakter suara pemandu yang paling disukai ananda saat belajar membaca:',
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Two Voice Cards
                      Row(
                        children: [
                          // Kakak Cewek Card
                          Expanded(
                            child: _buildVoiceCard(
                              gender: 'female',
                              icon: '👧',
                              title: 'Kakak Cewek',
                              subtitle: 'Ceria & Lembut',
                              description: 'Ramah, bersahabat, nada hangat untuk balita',
                              isSelected: currentGender == 'female',
                              color: const Color(0xFFFDF2F8),
                              borderColor: const Color(0xFFF472B6),
                              activeColor: const Color(0xFFBE185D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Kakak Cowok Card
                          Expanded(
                            child: _buildVoiceCard(
                              gender: 'male',
                              icon: '👦',
                              title: 'Kakak Cowok',
                              subtitle: 'Hangat & Jelas',
                              description: 'Tegas, semangat, pelafalan fonik mantap',
                              isSelected: currentGender == 'male',
                              color: const Color(0xFFEFF6FF),
                              borderColor: const Color(0xFF60A5FA),
                              activeColor: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Test Voice & Engine Status Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Text('🔊', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isPlayingTest
                                    ? 'Memutar contoh suara Miko...'
                                    : 'Karakter aktif: ${currentGender == 'male' ? 'Kakak Cowok 👦' : 'Kakak Cewek 👧'}',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _testSpeech(currentGender),
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              label: const Text('Tes Suara'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7E22CE),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                textStyle: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section 2: Audio & Musik
                      Row(
                        children: [
                          const Text('🎵', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Efek Suara & Musik Latar',
                            style: GoogleFonts.fredoka(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF581C87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Sound Effects Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: _audio.isMuted
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _audio.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: _audio.isMuted ? const Color(0xFF94A3B8) : const Color(0xFF16A34A),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Suara Efek & Maskot Miko',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Pemberitahuan fonik, pujian bintang & panduan belajar',
                                    style: GoogleFonts.nunito(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: !_audio.isMuted,
                              activeColor: const Color(0xFF16A34A),
                              onChanged: (val) {
                                setState(() {
                                  _audio.toggleMute();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // BGM Music Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: (_audio.isBgmMuted || _audio.isMuted)
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFE0E7FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (_audio.isBgmMuted || _audio.isMuted)
                                    ? Icons.music_off_rounded
                                    : Icons.music_note_rounded,
                                color: (_audio.isBgmMuted || _audio.isMuted)
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF4F46E5),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Musik Latar Ceria (BGM)',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Melodi instrumental riang pengiring petualangan',
                                    style: GoogleFonts.nunito(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: !_audio.isBgmMuted && !_audio.isMuted,
                              activeColor: const Color(0xFF4F46E5),
                              onChanged: (val) {
                                setState(() {
                                  _audio.toggleBgm();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section 3: Parental Gate Shortcut
                      if (widget.onOpenParentalGate != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3E8FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('👨‍👩‍👧', style: TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zona Orang Tua',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6B21A8),
                                      ),
                                    ),
                                    Text(
                                      'Batas waktu main, rapor belajar & sertifikat kelulusan',
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF7E22CE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onOpenParentalGate!();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF7E22CE),
                                  textStyle: GoogleFonts.fredoka(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Buka'),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 11),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E22CE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Tutup & Lanjut Bermain 🚀',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceCard({
    required String gender,
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required Color color,
    required Color borderColor,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () => _selectVoice(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : borderColor,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          'Dipilih',
                          style: GoogleFonts.fredoka(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Pilih',
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? activeColor : const Color(0xFF1E293B),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description,
                style: GoogleFonts.nunito(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
