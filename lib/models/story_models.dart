import 'package:flutter/material.dart';

/// Item interaktif yang dapat disentuh anak pada ilustrasi buku cerita
class StoryInteractiveItem {
  final String id;
  final String name;
  final String soundText;
  final String illustrationKey;
  final Alignment alignment;
  final double size;

  const StoryInteractiveItem({
    required this.id,
    required this.name,
    required this.soundText,
    required this.illustrationKey,
    required this.alignment,
    this.size = 64,
  });
}

/// Satu halaman cerita dengan teks dan ilustrasi
class StoryPage {
  final int pageNumber;
  final String sentence;
  final String illustrationKey;
  final Color backgroundColor;
  final List<StoryInteractiveItem> interactiveItems;

  const StoryPage({
    required this.pageNumber,
    required this.sentence,
    required this.illustrationKey,
    required this.backgroundColor,
    required this.interactiveItems,
  });

  /// Daftar kata-kata individual untuk fitur karaoke & touch-to-speak
  List<String> get words {
    return sentence.split(' ').where((w) => w.trim().isNotEmpty).toList();
  }
}

/// Pilihan jawaban kuis pemahaman dongeng
class StoryQuizOption {
  final String text;
  final String illustrationKey;
  final bool isCorrect;
  final String feedbackText;

  const StoryQuizOption({
    required this.text,
    required this.illustrationKey,
    required this.isCorrect,
    required this.feedbackText,
  });
}

/// Soal kuis pemahaman membaca dongeng
class StoryQuizQuestion {
  final String questionText;
  final List<StoryQuizOption> options;

  const StoryQuizQuestion({
    required this.questionText,
    required this.options,
  });
}

/// Buku cerita lengkap
class StoryBook {
  final String id;
  final String title;
  final String subtitle;
  final String ageRange;
  final String coverIllustration;
  final Color coverColor;
  final Color accentColor;
  final List<StoryPage> pages;
  final List<StoryQuizQuestion> quizQuestions;

  const StoryBook({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ageRange,
    required this.coverIllustration,
    required this.coverColor,
    required this.accentColor,
    required this.pages,
    this.quizQuestions = const [],
  });
}

/// Koleksi 4 Buku Cerita Bergambar Interaktif
final List<StoryBook> sampleStoryBooks = [
  // Buku 1: Miko & Pohon Apel Ajaib
  StoryBook(
    id: 'story_apel',
    title: 'Miko & Pohon Apel Ajaib',
    subtitle: 'Kisah Miko memetik apel merah manis dan berbagi bersama sahabat.',
    ageRange: 'Usia 3–6 Thn',
    coverIllustration: 'apel',
    coverColor: const Color(0xFFEF4444),
    accentColor: const Color(0xFFFCA5A5),
    pages: [
      StoryPage(
        pageNumber: 1,
        sentence: 'Pagi yang cerah di taman ajaib. Miko melompat gembira melihat kebun apel.',
        illustrationKey: 'miko_taman',
        backgroundColor: const Color(0xFFFEF3C7),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_sun',
            name: 'Matahari',
            soundText: 'Matahari tersenyum hangat di langit biru!',
            illustrationKey: 'matahari',
            alignment: Alignment(-0.85, -0.75),
            size: 65,
          ),
          StoryInteractiveItem(
            id: 'item_miko',
            name: 'Miko',
            soundText: 'Hai! Aku Miko si kucing petualang!',
            illustrationKey: 'kucing',
            alignment: Alignment(0.45, 0.45),
            size: 90,
          ),
          StoryInteractiveItem(
            id: 'item_flower',
            name: 'Bunga',
            soundText: 'Bunga mawar merah mekar dengan indah!',
            illustrationKey: 'bunga',
            alignment: Alignment(-0.55, 0.65),
            size: 55,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 2,
        sentence: 'Di atas dahan yang tinggi, ada sebuah apel merah yang ranum dan berkilau.',
        illustrationKey: 'pohon_apel',
        backgroundColor: const Color(0xFFDCFCE7),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_apple',
            name: 'Apel Merah',
            soundText: 'Apel merah manis kaya akan vitamin!',
            illustrationKey: 'apel',
            alignment: Alignment(-0.1, -0.3),
            size: 80,
          ),
          StoryInteractiveItem(
            id: 'item_butterfly',
            name: 'Kupu-kupu',
            soundText: 'Kupu-kupu terbang riang menari di dahan!',
            illustrationKey: 'kupu',
            alignment: Alignment(0.65, -0.65),
            size: 50,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 3,
        sentence: 'Miko melompat tinggi dan memetik apel merah itu dengan kedua tangannya.',
        illustrationKey: 'miko_lompat',
        backgroundColor: const Color(0xFFE0F2FE),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_star',
            name: 'Bintang Ajaib',
            soundText: 'Tring! Bintang keberuntungan bersinar untuk Miko!',
            illustrationKey: 'bintang',
            alignment: Alignment(-0.65, -0.65),
            size: 60,
          ),
          StoryInteractiveItem(
            id: 'item_miko_jump',
            name: 'Miko Melompat',
            soundText: 'Hup! Miko berhasil meraih apel impiannya!',
            illustrationKey: 'kucing',
            alignment: Alignment(0.0, 0.1),
            size: 100,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 4,
        sentence: 'Miko memotong apel menjadi dua bagian untuk dinikmati bersama. Berbagi itu sangat menyenangkan!',
        illustrationKey: 'miko_berbagi',
        backgroundColor: const Color(0xFFFCE7F3),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_slice',
            name: 'Potongan Apel',
            soundText: 'Nyam nyam! Apel manis terasa sangat lezat saat dinikmati bersama sahabat!',
            illustrationKey: 'apel',
            alignment: Alignment(0.0, 0.25),
            size: 85,
          ),
          StoryInteractiveItem(
            id: 'item_heart',
            name: 'Hati Bahagia',
            soundText: 'Hati Miko gembira karena suka berbagi!',
            illustrationKey: 'hati',
            alignment: Alignment(0.75, -0.6),
            size: 55,
          ),
        ],
      ),
    ],
    quizQuestions: [
      StoryQuizQuestion(
        questionText: 'Buah manis apa yang dipetik oleh Miko di kebun?',
        options: [
          StoryQuizOption(
            text: 'Apel Merah',
            illustrationKey: 'apel',
            isCorrect: true,
            feedbackText: 'Hebat! Miko memetik apel merah yang manis dan ranum!',
          ),
          StoryQuizOption(
            text: 'Pisang Kuning',
            illustrationKey: 'pisang',
            isCorrect: false,
            feedbackText: 'Bukan pisang, Miko memetik buah apel merah!',
          ),
          StoryQuizOption(
            text: 'Nanas Segar',
            illustrationKey: 'nanas',
            isCorrect: false,
            feedbackText: 'Coba ingat lagi, buah di kebun itu apel merah!',
          ),
        ],
      ),
      StoryQuizQuestion(
        questionText: 'Apa yang dilakukan Miko setelah memetik buah apel?',
        options: [
          StoryQuizOption(
            text: 'Membagi dua untuk sahabat',
            illustrationKey: 'hati',
            isCorrect: true,
            feedbackText: 'Pintar sekali! Miko suka berbagi bersama sahabat!',
          ),
          StoryQuizOption(
            text: 'Menyimpan sendiri di tas',
            illustrationKey: 'buku',
            isCorrect: false,
            feedbackText: 'Miko anak yang baik dan suka berbagi bersama!',
          ),
        ],
      ),
    ],
  ),

  // Buku 2: Kereta Kelinci Keliling Pulau
  StoryBook(
    id: 'story_kereta',
    title: 'Kereta Kelinci Keliling Pulau',
    subtitle: 'Petualangan masinis cilik menaiki kereta uap melintasi pulau pelangi.',
    ageRange: 'Usia 4–7 Thn',
    coverIllustration: 'kereta',
    coverColor: const Color(0xFF0284C7),
    accentColor: const Color(0xFF7DD3FC),
    pages: [
      StoryPage(
        pageNumber: 1,
        sentence: 'Kiki si kelinci bersiap mengemudikan kereta uap berwarna biru cerah.',
        illustrationKey: 'kereta_stasiun',
        backgroundColor: const Color(0xFFE0F2FE),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_train',
            name: 'Kereta Uap',
            soundText: 'Tuut tuut! Kereta api siap meluncur kencang!',
            illustrationKey: 'kereta',
            alignment: Alignment(0.1, 0.3),
            size: 105,
          ),
          StoryInteractiveItem(
            id: 'item_cloud',
            name: 'Awan Putih',
            soundText: 'Awan lembut melayang di langit cerah!',
            illustrationKey: 'awan',
            alignment: Alignment(-0.65, -0.7),
            size: 65,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 2,
        sentence: 'Tuut tuut! Kereta meluncur kencang melewati jembatan pelangi yang indah.',
        illustrationKey: 'kereta_jembatan',
        backgroundColor: const Color(0xFFF3E8FF),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_rainbow',
            name: 'Pelangi',
            soundText: 'Pelangi tujuh warna melengkung indah di atas bukit!',
            illustrationKey: 'pelangi',
            alignment: Alignment(0.0, -0.7),
            size: 90,
          ),
          StoryInteractiveItem(
            id: 'item_train_run',
            name: 'Kereta Cepat',
            soundText: 'Guus guus tuut tuut! Kereta meluncur melewati jembatan!',
            illustrationKey: 'kereta',
            alignment: Alignment(0.2, 0.35),
            size: 95,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 3,
        sentence: 'Di stasiun bukit hijau, Gajah dan Rusa naik sambil melambaikan tangan gembira.',
        illustrationKey: 'kereta_penumpang',
        backgroundColor: const Color(0xFFDCFCE7),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_elephant',
            name: 'Gajah',
            soundText: 'Trot trot! Halo sahabat, aku suka naik kereta!',
            illustrationKey: 'gajah',
            alignment: Alignment(-0.5, 0.25),
            size: 85,
          ),
          StoryInteractiveItem(
            id: 'item_deer',
            name: 'Rusa',
            soundText: 'Hai! Rusa manis siap bertualang ke bukit bintang!',
            illustrationKey: 'rusa',
            alignment: Alignment(0.55, 0.3),
            size: 80,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 4,
        sentence: 'Semua sahabat bersorak bahagia. Kereta tiba dengan selamat di puncak pulau bintang!',
        illustrationKey: 'kereta_puncak',
        backgroundColor: const Color(0xFFFEF9C3),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_trophy',
            name: 'Piala Bintang',
            soundText: 'Hore! Petualangan kereta sukses membawa kebahagiaan!',
            illustrationKey: 'bintang',
            alignment: Alignment(0.0, -0.4),
            size: 85,
          ),
        ],
      ),
    ],
    quizQuestions: [
      StoryQuizQuestion(
        questionText: 'Kendaraan apa yang dikemudikan oleh Kiki si kelinci?',
        options: [
          StoryQuizOption(
            text: 'Kereta Uap Biru',
            illustrationKey: 'kereta',
            isCorrect: true,
            feedbackText: 'Luar biasa! Kiki menjadi masinis kereta uap yang meluncur kencang!',
          ),
          StoryQuizOption(
            text: 'Mobil Balap',
            illustrationKey: 'mobil',
            isCorrect: false,
            feedbackText: 'Kiki mengemudikan kereta uap berbunyi tuut tuut!',
          ),
          StoryQuizOption(
            text: 'Sepeda Onthel',
            illustrationKey: 'sepeda',
            isCorrect: false,
            feedbackText: 'Bukan sepeda, Kiki meluncur di rel kereta api!',
          ),
        ],
      ),
      StoryQuizQuestion(
        questionText: 'Siapa sahabat yang naik di stasiun bukit hijau?',
        options: [
          StoryQuizOption(
            text: 'Gajah dan Rusa',
            illustrationKey: 'gajah',
            isCorrect: true,
            feedbackText: 'Tepat sekali! Gajah dan Rusa naik sambil melambai riang!',
          ),
          StoryQuizOption(
            text: 'Ikan Emas',
            illustrationKey: 'ikan',
            isCorrect: false,
            feedbackText: 'Ikan berenang di air, yang naik kereta adalah Gajah dan Rusa!',
          ),
        ],
      ),
    ],
  ),

  // Buku 3: Kancil & Ikan di Danau Bintang
  StoryBook(
    id: 'story_danau',
    title: 'Kancil & Ikan di Danau Bintang',
    subtitle: 'Cerita persahabatan hangat di tepi danau berair jernih.',
    ageRange: 'Usia 5–8 Thn',
    coverIllustration: 'ikan',
    coverColor: const Color(0xFF10B981),
    accentColor: const Color(0xFF6EE7B7),
    pages: [
      StoryPage(
        pageNumber: 1,
        sentence: 'Di tepi danau yang jernih, Kancil yang cerdik sedang membaca buku cerita di bawah pohon rindang.',
        illustrationKey: 'danau_baca',
        backgroundColor: const Color(0xFFECFDF5),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_book',
            name: 'Buku Cerita',
            soundText: 'Membaca buku membuka jendela ilmu dunia!',
            illustrationKey: 'buku',
            alignment: Alignment(-0.2, 0.3),
            size: 75,
          ),
          StoryInteractiveItem(
            id: 'item_tree',
            name: 'Pohon Rindang',
            soundText: 'Pohon rindang memberi keteduhan yang sejuk!',
            illustrationKey: 'pohon',
            alignment: Alignment(-0.7, -0.2),
            size: 90,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 2,
        sentence: 'Tiba-tiba, seekor ikan kecil melompat keluar dari air dan menyapa Kancil dengan ramah.',
        illustrationKey: 'danau_ikan',
        backgroundColor: const Color(0xFFE0F2FE),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_fish',
            name: 'Ikan Emas',
            soundText: 'Kecipak kecipuk! Halo Kancil, air danau hari ini sejuk sekali!',
            illustrationKey: 'ikan',
            alignment: Alignment(0.4, 0.2),
            size: 80,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 3,
        sentence: 'Kancil membacakan dongeng seru untuk si ikan kecil. Keduanya mendengarkan dengan penuh rasa ingin tahu.',
        illustrationKey: 'danau_dongeng',
        backgroundColor: const Color(0xFFFEF3C7),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_sunglasses',
            name: 'Topi Petualang',
            soundText: 'Topi petualang melindungi dari terik mentari!',
            illustrationKey: 'topi',
            alignment: Alignment(-0.45, -0.1),
            size: 65,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 4,
        sentence: 'Sahabat sejati selalu ada untuk berbagi cerita dan tersenyum bersama di setiap langkah.',
        illustrationKey: 'danau_sahabat',
        backgroundColor: const Color(0xFFFDF2F8),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_celebrate',
            name: 'Bintang Kasih Sayang',
            soundText: 'Persahabatan yang tulus adalah harta paling berharga di dunia!',
            illustrationKey: 'bintang',
            alignment: Alignment(0.0, -0.4),
            size: 80,
          ),
        ],
      ),
    ],
    quizQuestions: [
      StoryQuizQuestion(
        questionText: 'Di mana Kancil membaca buku cerita?',
        options: [
          StoryQuizOption(
            text: 'Di bawah pohon rindang',
            illustrationKey: 'pohon',
            isCorrect: true,
            feedbackText: 'Benar sekali! Di bawah pohon rindang tepi danau yang sejuk!',
          ),
          StoryQuizOption(
            text: 'Di dalam mobil balap',
            illustrationKey: 'mobil',
            isCorrect: false,
            feedbackText: 'Kancil duduk membaca di bawah pohon rindang tepi danau!',
          ),
        ],
      ),
      StoryQuizQuestion(
        questionText: 'Hewan apa yang melompat dari air dan menyapa Kancil?',
        options: [
          StoryQuizOption(
            text: 'Ikan Emas Kecil',
            illustrationKey: 'ikan',
            isCorrect: true,
            feedbackText: 'Hebat! Ikan kecil berenang gembira dan menyapa Kancil!',
          ),
          StoryQuizOption(
            text: 'Burung Elang',
            illustrationKey: 'elang',
            isCorrect: false,
            feedbackText: 'Burung elang terbang di langit, yang melompat dari air adalah ikan!',
          ),
        ],
      ),
    ],
  ),

  // Buku 4: Dino Cilik & Balon Pelangi
  StoryBook(
    id: 'story_dino',
    title: 'Dino Cilik & Balon Pelangi',
    subtitle: 'Kisah Dodi si dino ramah membagi balon warna-warni di lembah pelangi.',
    ageRange: 'Usia 4–7 Thn',
    coverIllustration: 'balon',
    coverColor: const Color(0xFFF97316),
    accentColor: const Color(0xFFFED7AA),
    pages: [
      StoryPage(
        pageNumber: 1,
        sentence: 'Dodi si dino cilik melangkah gembira membawa seikat balon warna-warni.',
        illustrationKey: 'dino_balon',
        backgroundColor: const Color(0xFFFFF7ED),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_dino',
            name: 'Dodi si Dino',
            soundText: 'Rawr! Halo sahabat, namaku Dodi dino cilik yang ramah!',
            illustrationKey: 'dino',
            alignment: Alignment(-0.3, 0.2),
            size: 90,
          ),
          StoryInteractiveItem(
            id: 'item_balloon_bunch',
            name: 'Balon Pelangi',
            soundText: 'Balon-balon terbang ringan berwarna merah, kuning, dan hijau!',
            illustrationKey: 'balon',
            alignment: Alignment(0.4, -0.4),
            size: 80,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 2,
        sentence: 'Angin sepoi-sepoi berhembus lembut. Balon-balon menari indah di bawah pelangi.',
        illustrationKey: 'dino_pelangi',
        backgroundColor: const Color(0xFFFDF4FF),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_rainbow_dino',
            name: 'Pelangi Indah',
            soundText: 'Wah, indahnya busur pelangi melengkung di langit biru!',
            illustrationKey: 'pelangi',
            alignment: Alignment(0.0, -0.7),
            size: 85,
          ),
          StoryInteractiveItem(
            id: 'item_wind_cloud',
            name: 'Awan Putih',
            soundText: 'Awan lembut berarak ditiup angin sepoi-sepoi!',
            illustrationKey: 'awan',
            alignment: Alignment(0.6, -0.5),
            size: 65,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 3,
        sentence: 'Dodi melihat burung pipit dan kelinci manis sedang bermain di dekat bunga mekar.',
        illustrationKey: 'dino_sahabat',
        backgroundColor: const Color(0xFFECFDF5),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_bird',
            name: 'Burung Pipit',
            soundText: 'Cicit cuit! Halo Dodi, balonmu cantik sekali!',
            illustrationKey: 'burung',
            alignment: Alignment(-0.6, -0.3),
            size: 75,
          ),
          StoryInteractiveItem(
            id: 'item_flower_dino',
            name: 'Bunga Mekar',
            soundText: 'Bunga harum mewarnai lembah pelangi!',
            illustrationKey: 'bunga',
            alignment: Alignment(0.5, 0.4),
            size: 65,
          ),
        ],
      ),
      StoryPage(
        pageNumber: 4,
        sentence: 'Dodi memberikan balon pelangi kepada sahabatnya. Mereka semua tertawa dan menari gembira!',
        illustrationKey: 'dino_pesta',
        backgroundColor: const Color(0xFFFEF3C7),
        interactiveItems: [
          StoryInteractiveItem(
            id: 'item_heart_dino',
            name: 'Hati Ceria',
            soundText: 'Tersenyum dan berbagi membuat hati kita dipenuhi kebahagiaan!',
            illustrationKey: 'hati',
            alignment: Alignment(0.0, -0.4),
            size: 80,
          ),
          StoryInteractiveItem(
            id: 'item_star_dino',
            name: 'Bintang Sukacita',
            soundText: 'Kelap kelip bintang ajaib menghiasi persahabatan mereka!',
            illustrationKey: 'bintang',
            alignment: Alignment(0.65, -0.6),
            size: 65,
          ),
        ],
      ),
    ],
    quizQuestions: [
      StoryQuizQuestion(
        questionText: 'Benda apa yang dibawa oleh Dodi si dino cilik?',
        options: [
          StoryQuizOption(
            text: 'Balon Warna-warni',
            illustrationKey: 'balon',
            isCorrect: true,
            feedbackText: 'Tepat sekali! Dodi membawa seikat balon pelangi yang indah!',
          ),
          StoryQuizOption(
            text: 'Topi Petualang',
            illustrationKey: 'topi',
            isCorrect: false,
            feedbackText: 'Dodi membawa seikat balon warna-warni yang menari di udara!',
          ),
          StoryQuizOption(
            text: 'Sepatu Olahraga',
            illustrationKey: 'sepatu',
            isCorrect: false,
            feedbackText: 'Bukan sepatu, benda yang dibawa adalah balon warna-warni!',
          ),
        ],
      ),
      StoryQuizQuestion(
        questionText: 'Kepada siapa Dodi membagikan balonnya?',
        options: [
          StoryQuizOption(
            text: 'Sahabat di lembah',
            illustrationKey: 'burung',
            isCorrect: true,
            feedbackText: 'Hebat sekali! Dodi membagikan balon kepada burung dan sahabatnya!',
          ),
          StoryQuizOption(
            text: 'Harimau galak',
            illustrationKey: 'harimau',
            isCorrect: false,
            feedbackText: 'Dodi membagikan balon kepada para sahabat yang ramah!',
          ),
        ],
      ),
    ],
  ),
];
