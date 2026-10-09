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

class StickerItemData {
  final String id;
  final String name;
  final String illustrationKey;
  final int cost;
  final String description;

  StickerItemData({
    required this.id,
    required this.name,
    required this.illustrationKey,
    required this.cost,
    required this.description,
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

  static final List<TrainWordData> trainWords = [
    TrainWordData(
      word: "BOLA",
      syllables: ["BO", "LA"],
      illustrationKey: "bola",
      choices: ["BO", "LA", "MA", "KU"],
    ),
    TrainWordData(
      word: "BUKU",
      syllables: ["BU", "KU"],
      illustrationKey: "buku",
      choices: ["BU", "KU", "KA", "PA"],
    ),
    TrainWordData(
      word: "ROTI",
      syllables: ["RO", "TI"],
      illustrationKey: "roti",
      choices: ["RO", "TI", "PI", "SA"],
    ),
    TrainWordData(
      word: "KUCING",
      syllables: ["KU", "CING"],
      illustrationKey: "kucing",
      choices: ["KU", "CING", "MA", "BA"],
    ),
    TrainWordData(
      word: "MOBIL",
      syllables: ["MO", "BIL"],
      illustrationKey: "mobil",
      choices: ["MO", "BIL", "BE", "DA"],
    ),
    TrainWordData(
      word: "KUDA",
      syllables: ["KU", "DA"],
      illustrationKey: "kuda",
      choices: ["KU", "DA", "SA", "PI"],
    ),
    TrainWordData(
      word: "KERETA",
      syllables: ["KE", "RE", "TA"],
      illustrationKey: "kereta",
      choices: ["KE", "RE", "TA", "MA"],
    ),
    TrainWordData(
      word: "SEPEDA",
      syllables: ["SE", "PE", "DA"],
      illustrationKey: "sepeda",
      choices: ["SE", "PE", "DA", "KU"],
    ),
    TrainWordData(
      word: "SEPATU",
      syllables: ["SE", "PA", "TU"],
      illustrationKey: "sepatu",
      choices: ["SE", "PA", "TU", "KA"],
    ),
    TrainWordData(
      word: "PESAWAT",
      syllables: ["PE", "SA", "WAT"],
      illustrationKey: "pesawat",
      choices: ["PE", "SA", "WAT", "BO"],
    ),
    TrainWordData(
      word: "RUMAH",
      syllables: ["RU", "MAH"],
      illustrationKey: "rumah",
      choices: ["RU", "MAH", "RA", "MI"],
    ),
    TrainWordData(
      word: "PISANG",
      syllables: ["PI", "SANG"],
      illustrationKey: "pisang",
      choices: ["PI", "SANG", "PA", "SING"],
    ),
    TrainWordData(
      word: "TOPI",
      syllables: ["TO", "PI"],
      illustrationKey: "topi",
      choices: ["TO", "PI", "TA", "PU"],
    ),
    TrainWordData(
      word: "IKAN",
      syllables: ["I", "KAN"],
      illustrationKey: "ikan",
      choices: ["I", "KAN", "A", "KUN"],
    ),
    TrainWordData(
      word: "JERUK",
      syllables: ["JE", "RUK"],
      illustrationKey: "jeruk",
      choices: ["JE", "RUK", "JA", "ROK"],
    ),
    TrainWordData(
      word: "BURUNG",
      syllables: ["BU", "RUNG"],
      illustrationKey: "burung",
      choices: ["BU", "RUNG", "BA", "RING"],
    ),
  ];

  static final List<BalloonWordData> balloonWords = [
    BalloonWordData(
      target: "KUDA",
      illustrationKey: "kuda",
      choices: ["KUDA", "SAPI", "KERA", "KURA"],
    ),
    BalloonWordData(
      target: "MATA",
      illustrationKey: "mata",
      choices: ["MATA", "MEJA", "MAMA", "MADU"],
    ),
    BalloonWordData(
      target: "PISANG",
      illustrationKey: "pisang",
      choices: ["PISANG", "PIRING", "PAYUNG", "PINTU"],
    ),
    BalloonWordData(
      target: "RUMAH",
      illustrationKey: "rumah",
      choices: ["RUMAH", "RUMPUT", "RUSA", "ROTI"],
    ),
  ];

  // 12 Contoh Soal Kuis Sentuh Pintar (Tinggal Pencet)
  static final List<QuizQuestionData> quizQuestions = [
    QuizQuestionData(
      question: "Mana gambar APEL?",
      answerKey: "apel",
      answerName: "APEL",
      choices: ["apel", "balon", "bola"],
    ),
    QuizQuestionData(
      question: "Mana gambar MOBIL?",
      answerKey: "mobil",
      answerName: "MOBIL",
      choices: ["mobil", "rumah", "roti"],
    ),
    QuizQuestionData(
      question: "Mana gambar KUCING?",
      answerKey: "kucing",
      answerName: "KUCING",
      choices: ["kucing", "domba", "kuda"],
    ),
    QuizQuestionData(
      question: "Mana gambar BUKU?",
      answerKey: "buku",
      answerName: "BUKU",
      choices: ["buku", "ceri", "pisang"],
    ),
    QuizQuestionData(
      question: "Mana gambar BOLA?",
      answerKey: "bola",
      answerName: "BOLA",
      choices: ["bola", "apel", "mobil"],
    ),
    QuizQuestionData(
      question: "Mana gambar RUMAH?",
      answerKey: "rumah",
      answerName: "RUMAH",
      choices: ["rumah", "buku", "roti"],
    ),
    QuizQuestionData(
      question: "Mana gambar PISANG?",
      answerKey: "pisang",
      answerName: "PISANG",
      choices: ["pisang", "ceri", "apel"],
    ),
    QuizQuestionData(
      question: "Mana gambar ROTI?",
      answerKey: "roti",
      answerName: "ROTI",
      choices: ["roti", "domba", "mata"],
    ),
    QuizQuestionData(
      question: "Mana gambar CERI?",
      answerKey: "ceri",
      answerName: "CERI",
      choices: ["ceri", "balon", "pisang"],
    ),
    QuizQuestionData(
      question: "Mana gambar DOMBA?",
      answerKey: "domba",
      answerName: "DOMBA",
      choices: ["domba", "kucing", "kuda"],
    ),
    QuizQuestionData(
      question: "Mana gambar KUDA?",
      answerKey: "kuda",
      answerName: "KUDA",
      choices: ["kuda", "mobil", "kucing"],
    ),
    QuizQuestionData(
      question: "Mana gambar MATA?",
      answerKey: "mata",
      answerName: "MATA",
      choices: ["mata", "bola", "rumah"],
    ),
  ];

  static final List<StickerItemData> stickers = [
    StickerItemData(id: 'stk_apel', name: 'Apel Merah', illustrationKey: 'apel', cost: 3, description: 'Manis & Segar'),
    StickerItemData(id: 'stk_balon', name: 'Balon Ceria', illustrationKey: 'balon', cost: 6, description: 'Terbang Tinggi'),
    StickerItemData(id: 'stk_ceri', name: 'Ceri Kembar', illustrationKey: 'ceri', cost: 9, description: 'Buah Mungil'),
    StickerItemData(id: 'stk_domba', name: 'Domba Putih', illustrationKey: 'domba', cost: 12, description: 'Bulu Lembut'),
    StickerItemData(id: 'stk_bola', name: 'Bola Juara', illustrationKey: 'bola', cost: 15, description: 'Bintang Lapangan'),
    StickerItemData(id: 'stk_buku', name: 'Buku Ajaib', illustrationKey: 'buku', cost: 18, description: 'Gudang Ilmu'),
    StickerItemData(id: 'stk_mobil', name: 'Mobil Balap', illustrationKey: 'mobil', cost: 21, description: 'Brumm Brumm!'),
    StickerItemData(id: 'stk_kucing', name: 'Sahabat Miko', illustrationKey: 'kucing', cost: 24, description: 'Kucing Lucu'),
    StickerItemData(id: 'stk_kuda', name: 'Kuda Gagah', illustrationKey: 'kuda', cost: 27, description: 'Lari Cepat'),
    StickerItemData(id: 'stk_pisang', name: 'Pisang Manis', illustrationKey: 'pisang', cost: 30, description: 'Kuning Lezat'),
    StickerItemData(id: 'stk_rumah', name: 'Rumah Asri', illustrationKey: 'rumah', cost: 33, description: 'Tempat Tinggal'),
    StickerItemData(id: 'stk_roti', name: 'Roti Panggang', illustrationKey: 'roti', cost: 36, description: 'Wangi Gurih'),
  ];
}
