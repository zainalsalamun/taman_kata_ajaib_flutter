import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class ParentalGateDialog extends StatefulWidget {
  final int totalStars;
  final Function(int newLimitMinutes)? onLimitChanged;

  const ParentalGateDialog({
    super.key,
    required this.totalStars,
    this.onLimitChanged,
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

  @override
  void initState() {
    super.initState();
    _generateMath();
    _loadScreenTime();
  }

  void _loadScreenTime() async {
    final limit = await StorageService.getScreenTimeLimit();
    final todaySec = await StorageService.getTodayPlayTimeSeconds();
    if (mounted) {
      setState(() {
        _limitMinutes = limit;
        _todaySeconds = todaySec;
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
    } else {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawaban belum tepat. Area ini khusus orang tua.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
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
        child: Column(
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

            if (!_isUnlocked) ...[
              Text(
                'Jawab soal ini untuk membuka laporan perkembangan anak:',
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
                        fontSize: 22,
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
                            borderSide: const BorderSide(color: Color(0xFFC084FC), width: 2),
                          ),
                        ),
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
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
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
            ] else ...[
              // 1. Screen Time Control Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(18),
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
                            fontSize: 14,
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

                    // Minute Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [0, 15, 30, 45, 60].map((mins) {
                          final isSel = _limitMinutes == mins;
                          return GestureDetector(
                            onTap: () => _setLimit(mins),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF7E22CE) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFD8B4FE),
                                ),
                              ),
                              child: Text(
                                mins == 0 ? 'Mati' : '$mins Menit',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : const Color(0xFF6B21A8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Indicator
                    Text(
                      _limitMinutes == 0
                          ? '• Status: Bermain bebas tanpa batas waktu.'
                          : '• Waktu hari ini: ${(_todaySeconds / 60).floor()} menit / $_limitMinutes menit (Sisa: ${math.max(0, _limitMinutes - (_todaySeconds / 60).floor())} mnt).',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF581C87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Child Progress Statistics
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Bintang Terkumpul: ${widget.totalStars} Bintang ⭐', style: _statStyle()),
                    const SizedBox(height: 4),
                    Text('• Materi: Fonik Huruf A–Z (26 Huruf), Kereta Suku Kata (16 Kata).', style: _statStyle()),
                    const SizedBox(height: 4),
                    Text('• Mode: 100% Offline (Local-First), Aman & Bebas Iklan.', style: _statStyle()),
                    const SizedBox(height: 4),
                    Text('• Mesin Suara: ${AudioService().engineStatus}', style: _statStyle()),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E22CE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Game',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _statStyle() {
    return GoogleFonts.fredoka(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF334155),
      height: 1.4,
    );
  }
}
