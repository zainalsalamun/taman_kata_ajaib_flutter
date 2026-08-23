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
  ];
}
