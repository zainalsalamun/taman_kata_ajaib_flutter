import 'dart:math';
import 'package:flutter/material.dart';

class LetterTracingData {
  final String letter;
  final String word;
  final String illustrationKey;
  final String hint;
  final List<Offset> guidePoints;

  LetterTracingData({
    required this.letter,
    required this.word,
    required this.illustrationKey,
    required this.hint,
    required this.guidePoints,
  });
}

class TrainWordData {
  final String word;
  final List<String> syllables;
  final String illustrationKey;
  final List<String> choices;

  TrainWordData({
    required this.word,
    required this.syllables,
    required this.illustrationKey,
    required this.choices,
  });
}

class BalloonWordData {
  final String target;
  final String illustrationKey;
  final List<String> choices;

  BalloonWordData({
    required this.target,
    required this.illustrationKey,
    required this.choices,
  });
}

class QuizQuestionData {
  final String question;
  final String answerKey;
  final String answerName;
  final List<String> choices;

  QuizQuestionData({
    required this.question,
    required this.answerKey,
    required this.answerName,
    required this.choices,
  });
}

class MazeWordData {
  final String word;
  final String illustrationKey;
  final List<String> sequence;
  final int rows;
  final int cols;
  final List<List<int>> grid;
  final Point<int> startPos;
  final Point<int> goalPos;
  final List<Point<int>> itemPositions;
  final List<Point<int>> bonusStars;

  const MazeWordData({
    required this.word,
    required this.illustrationKey,
    required this.sequence,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.startPos,
    required this.goalPos,
    required this.itemPositions,
    this.bonusStars = const [],
  });
}

class StickerItemData {
  final String id;
  final String name;
  final String illustrationKey;
  final int cost;
  final String description;
  final String soundQuote;
  final String sfx;

  StickerItemData({
    required this.id,
    required this.name,
    required this.illustrationKey,
    required this.cost,
    required this.description,
    this.soundQuote = '',
    this.sfx = 'ding',
  });
}

class PlacedSticker {
  final String uniqueId;
  final String stickerId;
  double x; // 0.0 to 1.0 (relative canvas coordinates)
  double y; // 0.0 to 1.0 (relative canvas coordinates)
  double scale;

  PlacedSticker({
    required this.uniqueId,
    required this.stickerId,
    required this.x,
    required this.y,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'uniqueId': uniqueId,
    'stickerId': stickerId,
    'x': x,
    'y': y,
    'scale': scale,
  };

  factory PlacedSticker.fromJson(Map<String, dynamic> json) => PlacedSticker(
    uniqueId: json['uniqueId'] as String,
    stickerId: json['stickerId'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  );
}

class GameRepository {
  static final List<LetterTracingData> letters = [
    LetterTracingData(
      letter: 'A',
      word: 'APEL',
      illustrationKey: 'apel',
      hint: 'Tarik garis miring ke kiri, ke kanan, lalu garis tengah!',
      guidePoints: [
        const Offset(160, 60),
        const Offset(95, 285),
        const Offset(160, 60),
        const Offset(225, 285),
        const Offset(125, 195),
        const Offset(195, 195),
      ],
    ),
    LetterTracingData(
      letter: 'B',
      word: 'BALON',
      illustrationKey: 'balon',
      hint: 'Tarik garis tegak lurus, lalu buat 2 lengkungan perut!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 175),
        const Offset(110, 285),
        const Offset(175, 75),
        const Offset(215, 115),
        const Offset(120, 175),
        const Offset(180, 185),
        const Offset(225, 230),
        const Offset(120, 285),
      ],
    ),
    LetterTracingData(
      letter: 'C',
      word: 'CERI',
      illustrationKey: 'ceri',
      hint: 'Putar setengah lingkaran besar terbuka ke arah kanan!',
      guidePoints: [
        const Offset(235, 95),
        const Offset(160, 55),
        const Offset(100, 170),
        const Offset(160, 285),
        const Offset(235, 250),
      ],
    ),
    LetterTracingData(
      letter: 'D',
      word: 'DOMBA',
      illustrationKey: 'domba',
      hint: 'Garis tegak lurus, lalu satu perut melengkung besar!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 175),
        const Offset(110, 285),
        const Offset(180, 75),
        const Offset(230, 170),
        const Offset(180, 275),
        const Offset(110, 285),
      ],
    ),
    LetterTracingData(
      letter: 'E',
      word: 'ELANG',
      illustrationKey: 'elang',
      hint: 'Garis tegak, lalu tiga garis mendatar: atas, tengah, bawah!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 175),
        const Offset(110, 285),
        const Offset(220, 60),
        const Offset(190, 175),
        const Offset(220, 285),
      ],
    ),
    LetterTracingData(
      letter: 'F',
      word: 'FOTO',
      illustrationKey: 'foto',
      hint: 'Garis tegak lurus, lalu dua garis mendatar di atas dan tengah!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 175),
        const Offset(110, 285),
        const Offset(220, 60),
        const Offset(190, 175),
      ],
    ),
    LetterTracingData(
      letter: 'G',
      word: 'GAJAH',
      illustrationKey: 'gajah',
      hint: 'Putar melengkung seperti huruf C, lalu beri garis masuk!',
      guidePoints: [
        const Offset(235, 95),
        const Offset(160, 55),
        const Offset(100, 170),
        const Offset(160, 285),
        const Offset(230, 250),
        const Offset(230, 180),
        const Offset(180, 180),
      ],
    ),
    LetterTracingData(
      letter: 'H',
      word: 'HARIMAU',
      illustrationKey: 'harimau',
      hint: 'Dua tiang tegak lurus, lalu hubungkan jembatan di tengah!',
      guidePoints: [
        const Offset(105, 60),
        const Offset(105, 285),
        const Offset(215, 60),
        const Offset(215, 285),
        const Offset(105, 170),
        const Offset(215, 170),
      ],
    ),
    LetterTracingData(
      letter: 'I',
      word: 'IKAN',
      illustrationKey: 'ikan',
      hint: 'Tarik satu garis lurus dari atas ke bawah!',
      guidePoints: [
        const Offset(160, 60),
        const Offset(160, 135),
        const Offset(160, 210),
        const Offset(160, 285),
      ],
    ),
    LetterTracingData(
      letter: 'J',
      word: 'JERUK',
      illustrationKey: 'jeruk',
      hint: 'Tarik garis ke bawah lalu lengkungkan ke kiri seperti pancing!',
      guidePoints: [
        const Offset(200, 60),
        const Offset(200, 200),
        const Offset(175, 275),
        const Offset(115, 250),
      ],
    ),
    LetterTracingData(
      letter: 'K',
      word: 'KUDA',
      illustrationKey: 'kuda',
      hint: 'Garis tegak lurus, satu tangan ke atas, satu kaki ke bawah!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 170),
        const Offset(110, 285),
        const Offset(220, 60),
        const Offset(120, 170),
        const Offset(220, 285),
      ],
    ),
    LetterTracingData(
      letter: 'L',
      word: 'LEMON',
      illustrationKey: 'lemon',
      hint: 'Garis tegak dari atas ke bawah, lalu belok ke kanan!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 170),
        const Offset(110, 285),
        const Offset(170, 285),
        const Offset(225, 285),
      ],
    ),
    LetterTracingData(
      letter: 'M',
      word: 'MOBIL',
      illustrationKey: 'mobil',
      hint: 'Dua gunung kembar! Naik, turun ke lembah, naik, lalu turun!',
      guidePoints: [
        const Offset(95, 285),
        const Offset(95, 60),
        const Offset(160, 200),
        const Offset(225, 60),
        const Offset(225, 285),
      ],
    ),
    LetterTracingData(
      letter: 'N',
      word: 'NANAS',
      illustrationKey: 'nanas',
      hint: 'Tiang kiri ke atas, miring ke kanan, lalu tiang tegak!',
      guidePoints: [
        const Offset(105, 285),
        const Offset(105, 60),
        const Offset(215, 285),
        const Offset(215, 60),
      ],
    ),
    LetterTracingData(
      letter: 'O',
      word: 'OBAT',
      illustrationKey: 'obat',
      hint: 'Putar lingkaran bulat utuh seperti roda atau donat!',
      guidePoints: [
        const Offset(160, 55),
        const Offset(95, 170),
        const Offset(160, 285),
        const Offset(225, 170),
      ],
    ),
    LetterTracingData(
      letter: 'P',
      word: 'PISANG',
      illustrationKey: 'pisang',
      hint: 'Garis tegak lurus, lalu satu kepala melengkung di atas!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 170),
        const Offset(110, 285),
        const Offset(175, 60),
        const Offset(220, 115),
        const Offset(120, 170),
      ],
    ),
    LetterTracingData(
      letter: 'Q',
      word: 'QURAN',
      illustrationKey: 'buku',
      hint: 'Buat lingkaran bulat O, lalu beri ekor miring di kanan bawah!',
      guidePoints: [
        const Offset(160, 55),
        const Offset(95, 170),
        const Offset(160, 285),
        const Offset(225, 170),
        const Offset(190, 240),
        const Offset(245, 285),
      ],
    ),
    LetterTracingData(
      letter: 'R',
      word: 'ROTI',
      illustrationKey: 'roti',
      hint: 'Garis tegak lurus, kepala melengkung, lalu kaki miring ke bawah!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 170),
        const Offset(110, 285),
        const Offset(175, 60),
        const Offset(220, 115),
        const Offset(120, 170),
        const Offset(220, 285),
      ],
    ),
    LetterTracingData(
      letter: 'S',
      word: 'SAPI',
      illustrationKey: 'sapi',
      hint: 'Liuk-liuk melengkung indah seperti ombak laut!',
      guidePoints: [
        const Offset(225, 95),
        const Offset(160, 55),
        const Offset(105, 115),
        const Offset(160, 170),
        const Offset(215, 225),
        const Offset(160, 285),
        const Offset(105, 255),
      ],
    ),
    LetterTracingData(
      letter: 'T',
      word: 'TOPI',
      illustrationKey: 'topi',
      hint: 'Buat atap mendatar di atas, lalu tiang tegak di tengahnya!',
      guidePoints: [
        const Offset(95, 60),
        const Offset(160, 60),
        const Offset(225, 60),
        const Offset(160, 170),
        const Offset(160, 285),
      ],
    ),
    LetterTracingData(
      letter: 'U',
      word: 'UDANG',
      illustrationKey: 'udang',
      hint: 'Meluncur ke bawah, lengkungkan di dasar, lalu naik ke atas!',
      guidePoints: [
        const Offset(105, 60),
        const Offset(105, 210),
        const Offset(160, 285),
        const Offset(215, 210),
        const Offset(215, 60),
      ],
    ),
    LetterTracingData(
      letter: 'V',
      word: 'VAS',
      illustrationKey: 'vas',
      hint: 'Garis miring turun bertemu di satu titik, lalu miring naik!',
      guidePoints: [
        const Offset(95, 60),
        const Offset(160, 285),
        const Offset(225, 60),
      ],
    ),
    LetterTracingData(
      letter: 'W',
      word: 'WORTEL',
      illustrationKey: 'wortel',
      hint: 'Dua lembah berdampingan! Turun, naik ke puncak, turun, lalu naik!',
      guidePoints: [
        const Offset(85, 60),
        const Offset(115, 285),
        const Offset(160, 130),
        const Offset(205, 285),
        const Offset(235, 60),
      ],
    ),
    LetterTracingData(
      letter: 'X',
      word: 'XILOFON',
      illustrationKey: 'xilofon',
      hint: 'Dua garis miring menyilang tepat di tengah-tengah!',
      guidePoints: [
        const Offset(95, 60),
        const Offset(160, 170),
        const Offset(225, 285),
        const Offset(225, 60),
        const Offset(95, 285),
      ],
    ),
    LetterTracingData(
      letter: 'Y',
      word: 'YOYO',
      illustrationKey: 'yoyo',
      hint: 'Dua cabang pendek bertemu di tengah, lalu tiang ke bawah!',
      guidePoints: [
        const Offset(95, 60),
        const Offset(160, 160),
        const Offset(225, 60),
        const Offset(160, 160),
        const Offset(160, 285),
      ],
    ),
    LetterTracingData(
      letter: 'Z',
      word: 'ZEBRA',
      illustrationKey: 'zebra',
      hint: 'Garis mendatar ke kanan, seluncur miring ke kiri, lalu ke kanan!',
      guidePoints: [
        const Offset(95, 60),
        const Offset(225, 60),
        const Offset(95, 285),
        const Offset(225, 285),
      ],
    ),
  ];

  // ==========================================
  // KERETA SUKU KATA (TRAIN) MULTI-LEVEL DATA
  // ==========================================
  static final List<TrainWordData> trainWordsLevel1 = [
    TrainWordData(word: "BOLA", syllables: ["BO", "LA"], illustrationKey: "bola", choices: ["BO", "LA", "MA", "KU"]),
    TrainWordData(word: "BUKU", syllables: ["BU", "KU"], illustrationKey: "buku", choices: ["BU", "KU", "KA", "PA"]),
    TrainWordData(word: "KUDA", syllables: ["KU", "DA"], illustrationKey: "kuda", choices: ["KU", "DA", "SA", "PI"]),
    TrainWordData(word: "ROTI", syllables: ["RO", "TI"], illustrationKey: "roti", choices: ["RO", "TI", "PI", "SA"]),
    TrainWordData(word: "MATA", syllables: ["MA", "TA"], illustrationKey: "mata", choices: ["MA", "TA", "BA", "LA"]),
    TrainWordData(word: "CERI", syllables: ["CE", "RI"], illustrationKey: "ceri", choices: ["CE", "RI", "CA", "RO"]),
    TrainWordData(word: "TOPI", syllables: ["TO", "PI"], illustrationKey: "topi", choices: ["TO", "PI", "TA", "PU"]),
    TrainWordData(word: "IKAN", syllables: ["I", "KAN"], illustrationKey: "ikan", choices: ["I", "KAN", "A", "KUN"]),
    TrainWordData(word: "GIGI", syllables: ["GI", "GI"], illustrationKey: "gigi", choices: ["GI", "GA", "GU", "GO"]),
    TrainWordData(word: "KAKI", syllables: ["KA", "KI"], illustrationKey: "kaki", choices: ["KA", "KI", "KU", "KO"]),
    TrainWordData(word: "DUKU", syllables: ["DU", "KU"], illustrationKey: "duku", choices: ["DU", "KU", "DA", "KA"]),
    TrainWordData(word: "SAWI", syllables: ["SA", "WI"], illustrationKey: "sawi", choices: ["SA", "WI", "SI", "WA"]),
    TrainWordData(word: "CABE", syllables: ["CA", "BE"], illustrationKey: "cabe", choices: ["CA", "BE", "CI", "BA"]),
    TrainWordData(word: "MEJA", syllables: ["ME", "JA"], illustrationKey: "meja", choices: ["ME", "JA", "MA", "JI"]),
    TrainWordData(word: "TALI", syllables: ["TA", "LI"], illustrationKey: "tali", choices: ["TA", "LI", "TU", "LA"]),
    TrainWordData(word: "NASI", syllables: ["NA", "SI"], illustrationKey: "nasi", choices: ["NA", "SI", "NI", "SA"]),
  ];

  static final List<TrainWordData> trainWordsLevel2 = [
    TrainWordData(word: "SEPEDA", syllables: ["SE", "PE", "DA"], illustrationKey: "sepeda", choices: ["SE", "PE", "DA", "KU"]),
    TrainWordData(word: "PESAWAT", syllables: ["PE", "SA", "WAT"], illustrationKey: "pesawat", choices: ["PE", "SA", "WAT", "BO"]),
    TrainWordData(word: "KERETA", syllables: ["KE", "RE", "TA"], illustrationKey: "kereta", choices: ["KE", "RE", "TA", "MA"]),
    TrainWordData(word: "SEPATU", syllables: ["SE", "PA", "TU"], illustrationKey: "sepatu", choices: ["SE", "PA", "TU", "KA"]),
    TrainWordData(word: "LEMARI", syllables: ["LE", "MA", "RI"], illustrationKey: "lemari", choices: ["LE", "MA", "RI", "LU"]),
    TrainWordData(word: "BONEKA", syllables: ["BO", "NE", "KA"], illustrationKey: "boneka", choices: ["BO", "NE", "KA", "BA"]),
    TrainWordData(word: "GURITA", syllables: ["GU", "RI", "TA"], illustrationKey: "gurita", choices: ["GU", "RI", "TA", "GA"]),
    TrainWordData(word: "KAMERA", syllables: ["KA", "ME", "RA"], illustrationKey: "kamera", choices: ["KA", "ME", "RA", "KO"]),
    TrainWordData(word: "CELANA", syllables: ["CE", "LA", "NA"], illustrationKey: "celana", choices: ["CE", "LA", "NA", "CI"]),
    TrainWordData(word: "PELANGI", syllables: ["PE", "LA", "NGI"], illustrationKey: "pelangi", choices: ["PE", "LA", "NGI", "PO"]),
    TrainWordData(word: "TOMAT", syllables: ["TO", "MA", "AT"], illustrationKey: "tomat", choices: ["TO", "MA", "AT", "TI"]),
    TrainWordData(word: "MATAHARI", syllables: ["MA", "TA", "HA", "RI"], illustrationKey: "matahari", choices: ["MA", "TA", "HA", "RI"]),
  ];

  static final List<TrainWordData> trainWordsLevel3 = [
    TrainWordData(word: "BUNGA", syllables: ["BU", "NGA"], illustrationKey: "bunga", choices: ["BU", "NGA", "BA", "NGI"]),
    TrainWordData(word: "BINTANG", syllables: ["BIN", "TANG"], illustrationKey: "bintang", choices: ["BIN", "TANG", "BAN", "TING"]),
    TrainWordData(word: "KUCING", syllables: ["KU", "CING"], illustrationKey: "kucing", choices: ["KU", "CING", "MA", "BA"]),
    TrainWordData(word: "BURUNG", syllables: ["BU", "RUNG"], illustrationKey: "burung", choices: ["BU", "RUNG", "BA", "RING"]),
    TrainWordData(word: "DOMBA", syllables: ["DOM", "BA"], illustrationKey: "domba", choices: ["DOM", "BA", "DAM", "BO"]),
    TrainWordData(word: "GAJAH", syllables: ["GA", "JAH"], illustrationKey: "gajah", choices: ["GA", "JAH", "GI", "JOH"]),
    TrainWordData(word: "POHON", syllables: ["PO", "HON"], illustrationKey: "pohon", choices: ["PO", "HON", "PA", "HAN"]),
    TrainWordData(word: "PISANG", syllables: ["PI", "SANG"], illustrationKey: "pisang", choices: ["PI", "SANG", "PA", "SING"]),
    TrainWordData(word: "HARIMAU", syllables: ["HA", "RI", "MAU"], illustrationKey: "harimau", choices: ["HA", "RI", "MAU", "MI"]),
    TrainWordData(word: "HUJAN", syllables: ["HU", "JAN"], illustrationKey: "hujan", choices: ["HU", "JAN", "HA", "JIN"]),
    TrainWordData(word: "PANTAI", syllables: ["PAN", "TAI"], illustrationKey: "pantai", choices: ["PAN", "TAI", "PIN", "TI"]),
    TrainWordData(word: "TANGAN", syllables: ["TA", "NGAN"], illustrationKey: "tangan", choices: ["TA", "NGAN", "TI", "NGIN"]),
  ];

  static List<TrainWordData> getTrainWords(int level) {
    switch (level) {
      case 2:
        return trainWordsLevel2;
      case 3:
        return trainWordsLevel3;
      case 1:
      default:
        return trainWordsLevel1;
    }
  }

  static List<TrainWordData> get trainWords => getTrainWords(1);

  // ==========================================
  // BALON KATA AJAIB (BALLOON) MULTI-LEVEL DATA
  // ==========================================
  static final List<BalloonWordData> balloonWordsLevel1 = [
    BalloonWordData(target: "KUDA", illustrationKey: "kuda", choices: ["KUDA", "SAPI", "KERA", "KURA"]),
    BalloonWordData(target: "MATA", illustrationKey: "mata", choices: ["MATA", "MEJA", "MAMA", "MADU"]),
    BalloonWordData(target: "PISANG", illustrationKey: "pisang", choices: ["PISANG", "PIRING", "PAYUNG", "PINTU"]),
    BalloonWordData(target: "RUMAH", illustrationKey: "rumah", choices: ["RUMAH", "RUMPUT", "RUSA", "ROTI"]),
    BalloonWordData(target: "BOLA", illustrationKey: "bola", choices: ["BOLA", "BUKU", "BOLU", "BOTOL"]),
    BalloonWordData(target: "BUKU", illustrationKey: "buku", choices: ["BUKU", "BULU", "BUMI", "BUSA"]),
    BalloonWordData(target: "ROTI", illustrationKey: "roti", choices: ["ROTI", "RODA", "ROKET", "RUSA"]),
    BalloonWordData(target: "CERI", illustrationKey: "ceri", choices: ["CERI", "CABE", "CELANA", "CINCIN"]),
  ];

  static final List<BalloonWordData> balloonWordsLevel2 = [
    BalloonWordData(target: "LARI", illustrationKey: "kuda", choices: ["LARI", "LAMA", "LACI", "LALU"]),
    BalloonWordData(target: "TERBANG", illustrationKey: "burung", choices: ["TERBANG", "TERANG", "TERJUN", "TERBIT"]),
    BalloonWordData(target: "LOMPAT", illustrationKey: "domba", choices: ["LOMPAT", "LEMPAR", "LONCAT", "LUMBA"]),
    BalloonWordData(target: "SENANG", illustrationKey: "kucing", choices: ["SENANG", "TENANG", "MENANG", "RENANG"]),
    BalloonWordData(target: "BERSIH", illustrationKey: "rumah", choices: ["BERSIH", "BENIH", "BASAH", "BEDAK"]),
    BalloonWordData(target: "MANIS", illustrationKey: "ceri", choices: ["MANIS", "MINIS", "MANDI", "MAWIS"]),
    BalloonWordData(target: "CEPAT", illustrationKey: "mobil", choices: ["CEPAT", "CATAT", "CEKAT", "CAPAI"]),
    BalloonWordData(target: "TERANG", illustrationKey: "bintang", choices: ["TERANG", "TENANG", "TERBIT", "TELUR"]),
  ];

  static final List<BalloonWordData> balloonWordsLevel3 = [
    BalloonWordData(target: "AIR", illustrationKey: "ikan", choices: ["AIR", "API", "ASIN", "AWAN"]),
    BalloonWordData(target: "WORTEL", illustrationKey: "wortel", choices: ["WORTEL", "WADAH", "WAYANG", "WARNA"]),
    BalloonWordData(target: "LANGIT", illustrationKey: "pesawat", choices: ["LANGIT", "LAUT", "LEMBAH", "LAPANGAN"]),
    BalloonWordData(target: "BINTANG", illustrationKey: "bintang", choices: ["BINTANG", "BATANG", "BANTENG", "BANTU"]),
    BalloonWordData(target: "POHON", illustrationKey: "pohon", choices: ["POHON", "PONDOK", "PINTU", "POTONG"]),
    BalloonWordData(target: "MADU", illustrationKey: "madu", choices: ["MADU", "MAJU", "MALU", "MATA"]),
    BalloonWordData(target: "BUNGA", illustrationKey: "bunga", choices: ["BUNGA", "BUSA", "BULU", "BUKU"]),
    BalloonWordData(target: "SEPATU", illustrationKey: "sepatu", choices: ["SEPATU", "SEPEDA", "SEMUT", "SENDAL"]),
  ];

  static List<BalloonWordData> getBalloonWords(int level) {
    switch (level) {
      case 2:
        return balloonWordsLevel2;
      case 3:
        return balloonWordsLevel3;
      case 1:
      default:
        return balloonWordsLevel1;
    }
  }

  static List<BalloonWordData> get balloonWords => getBalloonWords(1);

  // ==========================================
  // KUIS SENTUH PINTAR (QUIZ) MULTI-LEVEL DATA
  // ==========================================
  static final List<QuizQuestionData> quizQuestionsLevel1 = [
    QuizQuestionData(question: "Mana gambar APEL?", answerKey: "apel", answerName: "APEL", choices: ["apel", "balon", "bola"]),
    QuizQuestionData(question: "Mana gambar MOBIL?", answerKey: "mobil", answerName: "MOBIL", choices: ["mobil", "rumah", "roti"]),
    QuizQuestionData(question: "Mana gambar KUCING?", answerKey: "kucing", answerName: "KUCING", choices: ["kucing", "domba", "kuda"]),
    QuizQuestionData(question: "Mana gambar BUKU?", answerKey: "buku", answerName: "BUKU", choices: ["buku", "ceri", "pisang"]),
    QuizQuestionData(question: "Mana gambar BOLA?", answerKey: "bola", answerName: "BOLA", choices: ["bola", "apel", "mobil"]),
    QuizQuestionData(question: "Mana gambar RUMAH?", answerKey: "rumah", answerName: "RUMAH", choices: ["rumah", "buku", "roti"]),
    QuizQuestionData(question: "Mana gambar PISANG?", answerKey: "pisang", answerName: "PISANG", choices: ["pisang", "ceri", "apel"]),
    QuizQuestionData(question: "Mana gambar ROTI?", answerKey: "roti", answerName: "ROTI", choices: ["roti", "domba", "mata"]),
    QuizQuestionData(question: "Mana gambar CERI?", answerKey: "ceri", answerName: "CERI", choices: ["ceri", "balon", "pisang"]),
    QuizQuestionData(question: "Mana gambar DOMBA?", answerKey: "domba", answerName: "DOMBA", choices: ["domba", "kucing", "kuda"]),
    QuizQuestionData(question: "Mana gambar KUDA?", answerKey: "kuda", answerName: "KUDA", choices: ["kuda", "mobil", "kucing"]),
    QuizQuestionData(question: "Mana gambar MATA?", answerKey: "mata", answerName: "MATA", choices: ["mata", "bola", "rumah"]),
  ];

  static final List<QuizQuestionData> quizQuestionsLevel2 = [
    QuizQuestionData(question: "Benda mana yang berawalan huruf B?", answerKey: "bola", answerName: "BOLA", choices: ["bola", "apel", "mobil"]),
    QuizQuestionData(question: "Benda mana yang berawalan huruf K?", answerKey: "kucing", answerName: "KUCING", choices: ["kucing", "domba", "rumah"]),
    QuizQuestionData(question: "Benda mana yang berawalan huruf P?", answerKey: "pisang", answerName: "PISANG", choices: ["pisang", "buku", "ceri"]),
    QuizQuestionData(question: "Benda mana yang berawalan huruf M?", answerKey: "mobil", answerName: "MOBIL", choices: ["mobil", "roti", "kuda"]),
    QuizQuestionData(question: "Benda mana yang berawalan huruf R?", answerKey: "roti", answerName: "ROTI", choices: ["roti", "apel", "kucing"]),
    QuizQuestionData(question: "Benda mana yang berawalan huruf C?", answerKey: "ceri", answerName: "CERI", choices: ["ceri", "balon", "bola"]),
    QuizQuestionData(question: "Kata mana yang berakhiran bunyi NG?", answerKey: "kucing", answerName: "KUCING", choices: ["kucing", "kuda", "domba"]),
    QuizQuestionData(question: "Kata mana yang punya 3 suku kata?", answerKey: "sepeda", answerName: "SEPEDA", choices: ["sepeda", "bola", "buku"]),
    QuizQuestionData(question: "Kendaraan mana yang bisa terbang?", answerKey: "pesawat", answerName: "PESAWAT", choices: ["pesawat", "mobil", "sepeda"]),
    QuizQuestionData(question: "Benda mana yang dipakai di kepala?", answerKey: "topi", answerName: "TOPI", choices: ["topi", "buku", "bola"]),
    QuizQuestionData(question: "Buah mana yang berwarna merah ceria?", answerKey: "apel", answerName: "APEL", choices: ["apel", "pisang", "roti"]),
    QuizQuestionData(question: "Hewan mana yang berbulu lembut putih?", answerKey: "domba", answerName: "DOMBA", choices: ["domba", "kucing", "kuda"]),
  ];

  static final List<QuizQuestionData> quizQuestionsLevel3 = [
    QuizQuestionData(question: "Roda dua dan dikayuh pedal! Siapa aku?", answerKey: "sepeda", answerName: "SEPEDA", choices: ["sepeda", "mobil", "pesawat"]),
    QuizQuestionData(question: "Buah kuning manis disukai monyet!", answerKey: "pisang", answerName: "PISANG", choices: ["pisang", "apel", "ceri"]),
    QuizQuestionData(question: "Suka mengeong dan menangkap tikus!", answerKey: "kucing", answerName: "KUCING", choices: ["kucing", "domba", "kuda"]),
    QuizQuestionData(question: "Punya sayap besar terbang di awan!", answerKey: "pesawat", answerName: "PESAWAT", choices: ["pesawat", "mobil", "kereta"]),
    QuizQuestionData(question: "Tempat tinggal kita yang hangat!", answerKey: "rumah", answerName: "RUMAH", choices: ["rumah", "buku", "topi"]),
    QuizQuestionData(question: "Bunyinya tuut tuut berjalan di rel!", answerKey: "kereta", answerName: "KERETA", choices: ["kereta", "sepeda", "mobil"]),
    QuizQuestionData(question: "Benda bundar ditendang memantul!", answerKey: "bola", answerName: "BOLA", choices: ["bola", "apel", "balon"]),
    QuizQuestionData(question: "Hewan gagah bisa ditunggangi lari!", answerKey: "kuda", answerName: "KUDA", choices: ["kuda", "domba", "kucing"]),
    QuizQuestionData(question: "Hewan berbulu tebal penghasil wol!", answerKey: "domba", answerName: "DOMBA", choices: ["domba", "kuda", "kucing"]),
    QuizQuestionData(question: "Buah merah mungil tangkai kembar!", answerKey: "ceri", answerName: "CERI", choices: ["ceri", "apel", "pisang"]),
    QuizQuestionData(question: "Wangi dipanggang enak dioles selai!", answerKey: "roti", answerName: "ROTI", choices: ["roti", "buku", "rumah"]),
    QuizQuestionData(question: "Kertas berjilid penuh cerita & ilmu!", answerKey: "buku", answerName: "BUKU", choices: ["buku", "topi", "bola"]),
  ];

  static List<QuizQuestionData> getQuizQuestions(int level) {
    switch (level) {
      case 2:
        return quizQuestionsLevel2;
      case 3:
        return quizQuestionsLevel3;
      case 1:
      default:
        return quizQuestionsLevel1;
    }
  }

  static List<QuizQuestionData> get quizQuestions => getQuizQuestions(1);

  // ==========================================
  // LABIRIN KATA AJAIB (MAZE) MULTI-LEVEL DATA
  // ==========================================
  static final List<MazeWordData> mazeWordsLevel1 = [
    const MazeWordData(
      word: 'BOLA',
      illustrationKey: 'bola',
      sequence: ['B', 'O', 'L', 'A'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 2), Point(2, 1), Point(2, 4), Point(4, 2)],
      bonusStars: [Point(4, 0), Point(0, 6)],
    ),
    const MazeWordData(
      word: 'BUKU',
      illustrationKey: 'buku',
      sequence: ['B', 'U', 'K', 'U'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 3), Point(2, 1), Point(2, 5), Point(4, 3)],
      bonusStars: [Point(2, 0), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'APEL',
      illustrationKey: 'apel',
      sequence: ['A', 'P', 'E', 'L'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 1, 0, 0, 0, 0],
        [1, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(1, 1), Point(2, 3), Point(3, 5), Point(4, 2)],
      bonusStars: [Point(0, 4), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'IKAN',
      illustrationKey: 'ikan',
      sequence: ['I', 'K', 'A', 'N'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 1, 0, 0],
        [0, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 2), Point(2, 3), Point(2, 6), Point(4, 2)],
      bonusStars: [Point(0, 6), Point(3, 2)],
    ),
    const MazeWordData(
      word: 'ROTI',
      illustrationKey: 'roti',
      sequence: ['R', 'O', 'T', 'I'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 0, 0, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 2), Point(1, 4), Point(3, 2), Point(3, 5)],
      bonusStars: [Point(3, 0), Point(4, 3)],
    ),
  ];

  static final List<MazeWordData> mazeWordsLevel2 = [
    const MazeWordData(
      word: 'KUDA',
      illustrationKey: 'kuda',
      sequence: ['KU', 'DA'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(2, 1), Point(4, 3)],
      bonusStars: [Point(4, 0), Point(0, 6)],
    ),
    const MazeWordData(
      word: 'SAPI',
      illustrationKey: 'sapi',
      sequence: ['SA', 'PI'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(2, 2), Point(2, 5)],
      bonusStars: [Point(2, 0), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'MATA',
      illustrationKey: 'mata',
      sequence: ['MA', 'TA'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 1, 0, 0, 0, 0],
        [1, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(2, 2), Point(3, 5)],
      bonusStars: [Point(0, 4), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'RUMAH',
      illustrationKey: 'rumah',
      sequence: ['RU', 'MAH'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 1, 0, 0],
        [0, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(2, 3), Point(4, 3)],
      bonusStars: [Point(0, 6), Point(3, 2)],
    ),
    const MazeWordData(
      word: 'PISANG',
      illustrationKey: 'pisang',
      sequence: ['PI', 'SANG'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 0, 0, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(1, 4), Point(3, 4)],
      bonusStars: [Point(3, 0), Point(4, 3)],
    ),
  ];

  static final List<MazeWordData> mazeWordsLevel3 = [
    const MazeWordData(
      word: 'KERETA',
      illustrationKey: 'kereta',
      sequence: ['KE', 'RE', 'TA'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 2), Point(2, 3), Point(4, 2)],
      bonusStars: [Point(4, 0), Point(0, 6)],
    ),
    const MazeWordData(
      word: 'PESAWAT',
      illustrationKey: 'pesawat',
      sequence: ['PE', 'SA', 'WAT'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 4), Point(2, 2), Point(4, 2)],
      bonusStars: [Point(2, 0), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'KELAPA',
      illustrationKey: 'apel',
      sequence: ['KE', 'LA', 'PA'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 1, 0, 0, 0, 0],
        [1, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(1, 1), Point(2, 4), Point(4, 3)],
      bonusStars: [Point(0, 4), Point(4, 0)],
    ),
    const MazeWordData(
      word: 'PELANGI',
      illustrationKey: 'balon',
      sequence: ['PE', 'LA', 'NGI'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 0, 1, 0, 0],
        [0, 1, 1, 0, 1, 0, 1],
        [0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 3), Point(2, 4), Point(4, 2)],
      bonusStars: [Point(0, 6), Point(3, 2)],
    ),
    const MazeWordData(
      word: 'KUCING',
      illustrationKey: 'kucing',
      sequence: ['KU', 'CI', 'NG'],
      rows: 5,
      cols: 7,
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 0, 0, 0, 1, 0],
      ],
      startPos: Point(0, 0),
      goalPos: Point(4, 6),
      itemPositions: [Point(0, 2), Point(2, 4), Point(3, 5)],
      bonusStars: [Point(3, 0), Point(4, 3)],
    ),
  ];

  static List<MazeWordData> getMazeWords(int level) {
    switch (level) {
      case 2:
        return mazeWordsLevel2;
      case 3:
        return mazeWordsLevel3;
      case 1:
      default:
        return mazeWordsLevel1;
    }
  }

  static List<MazeWordData> get mazeWords => getMazeWords(1);

  static final List<StickerItemData> stickers = [
    StickerItemData(
      id: 'stk_apel',
      name: 'Apel Merah',
      illustrationKey: 'apel',
      cost: 3,
      description: 'Manis & Segar',
      soundQuote: 'Nyam nyam! Apel merah manis kaya vitamin!',
      sfx: 'star',
    ),
    StickerItemData(
      id: 'stk_balon',
      name: 'Balon Ceria',
      illustrationKey: 'balon',
      cost: 6,
      description: 'Terbang Tinggi',
      soundQuote: 'Pop! Balon warna-warni terbang tinggi di angkasa!',
      sfx: 'pop',
    ),
    StickerItemData(
      id: 'stk_ceri',
      name: 'Ceri Kembar',
      illustrationKey: 'ceri',
      cost: 9,
      description: 'Buah Mungil',
      soundQuote: 'Ceri mungil kembar siap dipetik di kebun!',
      sfx: 'ding',
    ),
    StickerItemData(
      id: 'stk_domba',
      name: 'Domba Putih',
      illustrationKey: 'domba',
      cost: 12,
      description: 'Bulu Lembut',
      soundQuote: 'Mbeee! Buluku lembut dan putih seperti awan!',
      sfx: 'ding',
    ),
    StickerItemData(
      id: 'stk_bola',
      name: 'Bola Juara',
      illustrationKey: 'bola',
      cost: 15,
      description: 'Bintang Lapangan',
      soundQuote: 'Boing boing! Tendangan gol spektakuler juara!',
      sfx: 'ding',
    ),
    StickerItemData(
      id: 'stk_buku',
      name: 'Buku Ajaib',
      illustrationKey: 'buku',
      cost: 18,
      description: 'Gudang Ilmu',
      soundQuote: 'Sret sret! Buka lembaran buku untuk menjelajah dunia!',
      sfx: 'whoosh',
    ),
    StickerItemData(
      id: 'stk_mobil',
      name: 'Mobil Balap',
      illustrationKey: 'mobil',
      cost: 21,
      description: 'Brumm Brumm!',
      soundQuote: 'Brumm brumm! Mobil balap merah meluncur kencang di sirkuit!',
      sfx: 'whoosh',
    ),
    StickerItemData(
      id: 'stk_kucing',
      name: 'Sahabat Miko',
      illustrationKey: 'kucing',
      cost: 24,
      description: 'Kucing Lucu',
      soundQuote: 'Meong! Halo sahabat cilik, Miko senang bermain denganmu!',
      sfx: 'ding',
    ),
    StickerItemData(
      id: 'stk_kuda',
      name: 'Kuda Gagah',
      illustrationKey: 'kuda',
      cost: 27,
      description: 'Lari Cepat',
      soundQuote: 'Klip klop klip klop! Kuda gagah berlari kencang di padang rumput!',
      sfx: 'whoosh',
    ),
    StickerItemData(
      id: 'stk_pisang',
      name: 'Pisang Manis',
      illustrationKey: 'pisang',
      cost: 30,
      description: 'Kuning Lezat',
      soundQuote: 'Nyam! Pisang manis kuning memberi banyak energi petualang!',
      sfx: 'star',
    ),
    StickerItemData(
      id: 'stk_rumah',
      name: 'Rumah Asri',
      illustrationKey: 'rumah',
      cost: 33,
      description: 'Tempat Tinggal',
      soundQuote: 'Tok tok tok! Selamat datang di rumah ajaib yang hangat dan nyaman!',
      sfx: 'ding',
    ),
    StickerItemData(
      id: 'stk_roti',
      name: 'Roti Panggang',
      illustrationKey: 'roti',
      cost: 36,
      description: 'Wangi Gurih',
      soundQuote: 'Hmm, wangi harum roti panggang mentega sangat lezat!',
      sfx: 'star',
    ),
    StickerItemData(
      id: 'stk_ikan',
      name: 'Ikan Emas',
      illustrationKey: 'ikan',
      cost: 39,
      description: 'Berenang Lincah',
      soundQuote: 'Kecipak kecipuk! Ikan emas berenang lincah di air jernih!',
      sfx: 'star',
    ),
    StickerItemData(
      id: 'stk_bintang',
      name: 'Bintang Kejora',
      illustrationKey: 'bintang',
      cost: 42,
      description: 'Kelap Kelip',
      soundQuote: 'Tring tring! Bintang ajaib berkilau menerangi mimpi indahmu!',
      sfx: 'star',
    ),
    StickerItemData(
      id: 'stk_pesawat',
      name: 'Pesawat Terbang',
      illustrationKey: 'pesawat',
      cost: 45,
      description: 'Jelajah Angkasa',
      soundQuote: 'Wuuush! Pesawat putih menembus awan tinggi di angkasa!',
      sfx: 'whoosh',
    ),
    StickerItemData(
      id: 'stk_dino',
      name: 'Dino Cilik',
      illustrationKey: 'dino',
      cost: 48,
      description: 'Sahabat Purba',
      soundQuote: 'Rawr! Halo sahabat, Dodi si dino cilik siap bertualang!',
      sfx: 'ding',
    ),
  ];
}
