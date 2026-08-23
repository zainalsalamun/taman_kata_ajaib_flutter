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

class GameRepository {
  static final List<LetterTracingData> letters = [
    LetterTracingData(
      letter: 'A',
      word: 'APEL',
      illustrationKey: 'apel',
      hint: 'Tarik garis miring ke bawah, lalu garis tengah!',
      guidePoints: [
        const Offset(175, 60),
        const Offset(95, 290),
        const Offset(175, 60),
        const Offset(255, 290),
        const Offset(130, 200),
        const Offset(220, 200),
      ],
    ),
    LetterTracingData(
      letter: 'B',
      word: 'BALON',
      illustrationKey: 'balon',
      hint: 'Tarik garis tegak lurus, lalu buat 2 lengkungan!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 290),
        const Offset(110, 60),
        const Offset(220, 115),
        const Offset(110, 175),
        const Offset(235, 235),
        const Offset(110, 290),
      ],
    ),
    LetterTracingData(
      letter: 'C',
      word: 'CERI',
      illustrationKey: 'ceri',
      hint: 'Putar setengah lingkaran besar ke arah kiri!',
      guidePoints: [
        const Offset(255, 95),
        const Offset(175, 55),
        const Offset(100, 175),
        const Offset(175, 295),
        const Offset(255, 255),
      ],
    ),
    LetterTracingData(
      letter: 'D',
      word: 'DOMBA',
      illustrationKey: 'domba',
      hint: 'Garis tegak lurus, lalu satu perut melengkung besar!',
      guidePoints: [
        const Offset(110, 60),
        const Offset(110, 290),
        const Offset(110, 60),
        const Offset(255, 175),
        const Offset(110, 290),
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

  static final List<StickerItemData> stickers = [
    StickerItemData(id: 'stk_apel', name: 'Apel Merah', illustrationKey: 'apel', cost: 3, description: 'Manis & Segar'),
    StickerItemData(id: 'stk_balon', name: 'Balon Ceria', illustrationKey: 'balon', cost: 6, description: 'Terbang Tinggi'),
    StickerItemData(id: 'stk_ceri', name: 'Ceri Kembar', illustrationKey: 'ceri', cost: 9, description: 'Buah Mungil'),
    StickerItemData(id: 'stk_domba', name: 'Domba Putih', illustrationKey: 'domba', cost: 12, description: 'Bulu Lembut'),
    StickerItemData(id: 'stk_bola', name: 'Bola Juara', illustrationKey: 'bola', cost: 15, description: 'Bintang Lapangan'),
    StickerItemData(id: 'stk_buku', name: 'Buku Ajaib', illustrationKey: 'buku', cost: 18, description: 'Gudang Ilmu'),
    StickerItemData(id: 'stk_mobil', name: 'Mobil Balap', illustrationKey: 'mobil', cost: 21, description: 'Brumm Brumm!'),
    StickerItemData(id: 'stk_kucing', name: 'Sahabat Miko', illustrationKey: 'kucing', cost: 24, description: 'Kucing Lucu'),
  ];
}
