import 'package:flutter/material.dart';

enum DictionaryCategory {
  all,
  buah,
  hewan,
  benda,
  kendaraan,
  alam,
}

extension DictionaryCategoryExtension on DictionaryCategory {
  String get label {
    switch (this) {
      case DictionaryCategory.all:
        return 'Semua';
      case DictionaryCategory.buah:
        return 'Buah & Sayur';
      case DictionaryCategory.hewan:
        return 'Hewan';
      case DictionaryCategory.benda:
        return 'Benda';
      case DictionaryCategory.kendaraan:
        return 'Kendaraan';
      case DictionaryCategory.alam:
        return 'Alam';
    }
  }

  String get emoji {
    switch (this) {
      case DictionaryCategory.all:
        return '📚';
      case DictionaryCategory.buah:
        return '🍎';
      case DictionaryCategory.hewan:
        return '🐱';
      case DictionaryCategory.benda:
        return '⚽';
      case DictionaryCategory.kendaraan:
        return '🚗';
      case DictionaryCategory.alam:
        return '🌳';
    }
  }

  Color get color {
    switch (this) {
      case DictionaryCategory.all:
        return const Color(0xFF3B82F6);
      case DictionaryCategory.buah:
        return const Color(0xFFEF4444);
      case DictionaryCategory.hewan:
        return const Color(0xFFF59E0B);
      case DictionaryCategory.benda:
        return const Color(0xFF8B5CF6);
      case DictionaryCategory.kendaraan:
        return const Color(0xFF06B6D4);
      case DictionaryCategory.alam:
        return const Color(0xFF10B981);
    }
  }
}

class DictionaryWordItem {
  final String id;
  final String word;
  final List<String> syllables;
  final String letter;
  final String phonicSound;
  final String illustrationKey;
  final DictionaryCategory category;
  final String sentence;
  final String funFact;
  final String emoji;
  final Color accentColor;

  const DictionaryWordItem({
    required this.id,
    required this.word,
    required this.syllables,
    required this.letter,
    required this.phonicSound,
    required this.illustrationKey,
    required this.category,
    required this.sentence,
    required this.funFact,
    required this.emoji,
    this.accentColor = const Color(0xFF3B82F6),
  });
}

class DictionaryRepository {
  static const List<DictionaryWordItem> allWords = [
    // --- HURUF A ---
    DictionaryWordItem(
      id: 'dict_apel',
      word: 'APEL',
      syllables: ['A', 'PEL'],
      letter: 'A',
      phonicSound: 'A... a... Apel!',
      illustrationKey: 'apel',
      category: DictionaryCategory.buah,
      sentence: 'Miko memetik buah apel merah manis dari pohon kebun.',
      funFact: 'Buah apel kaya akan vitamin C dan serat sehat untuk tubuh!',
      emoji: '🍎',
      accentColor: Color(0xFFEF4444),
    ),
    DictionaryWordItem(
      id: 'dict_awan',
      word: 'AWAN',
      syllables: ['A', 'WAN'],
      letter: 'A',
      phonicSound: 'A... a... Awan!',
      illustrationKey: 'awan',
      category: DictionaryCategory.alam,
      sentence: 'Awan putih melayang lembut seperti kapas di langit biru.',
      funFact: 'Awan terbentuk dari jutaan tetes air kecil yang mengapung di udara.',
      emoji: '☁️',
      accentColor: Color(0xFF38BDF8),
    ),

    // --- HURUF B ---
    DictionaryWordItem(
      id: 'dict_balon',
      word: 'BALON',
      syllables: ['BA', 'LON'],
      letter: 'B',
      phonicSound: 'B... beh... Balon!',
      illustrationKey: 'balon',
      category: DictionaryCategory.benda,
      sentence: 'Balon merah muda terbang tinggi ditiup angin sepoi-sepoi.',
      funFact: 'Balon gas bisa terbang karena diisi gas helium yang sangat ringan.',
      emoji: '🎈',
      accentColor: Color(0xFFEC4899),
    ),
    DictionaryWordItem(
      id: 'dict_bola',
      word: 'BOLA',
      syllables: ['BO', 'LA'],
      letter: 'B',
      phonicSound: 'B... beh... Bola!',
      illustrationKey: 'bola',
      category: DictionaryCategory.benda,
      sentence: 'Ayo tendang bola bundar masuk ke dalam gawang!',
      funFact: 'Bola sepak memiliki pola segi enam hitam dan putih yang unik.',
      emoji: '⚽',
      accentColor: Color(0xFF10B981),
    ),
    DictionaryWordItem(
      id: 'dict_buku',
      word: 'BUKU',
      syllables: ['BU', 'KU'],
      letter: 'B',
      phonicSound: 'B... beh... Buku!',
      illustrationKey: 'buku',
      category: DictionaryCategory.benda,
      sentence: 'Miko senang membaca buku cerita bergambar sebelum tidur.',
      funFact: 'Membaca buku membuka jendela ilmu dan imajinasi dunia yang luas.',
      emoji: '📖',
      accentColor: Color(0xFFF59E0B),
    ),
    DictionaryWordItem(
      id: 'dict_burung',
      word: 'BURUNG',
      syllables: ['BU', 'RUNG'],
      letter: 'B',
      phonicSound: 'B... beh... Burung!',
      illustrationKey: 'burung',
      category: DictionaryCategory.hewan,
      sentence: 'Burung kecil bernyanyi merdu di atas dahan pohon.',
      funFact: 'Burung memiliki bulu halus dan sayap yang kuat untuk terbang bebas.',
      emoji: '🐦',
      accentColor: Color(0xFF0284C7),
    ),
    DictionaryWordItem(
      id: 'dict_bunga',
      word: 'BUNGA',
      syllables: ['BUN', 'GA'],
      letter: 'B',
      phonicSound: 'B... beh... Bunga!',
      illustrationKey: 'bunga',
      category: DictionaryCategory.alam,
      sentence: 'Bunga mawar merah mekar indah dan harum semerbak di taman.',
      funFact: 'Warna cerah bunga mengundang lebah untuk menghisap nektar manis.',
      emoji: '🌸',
      accentColor: Color(0xFFF43F5E),
    ),
    DictionaryWordItem(
      id: 'dict_bintang',
      word: 'BINTANG',
      syllables: ['BIN', 'TANG'],
      letter: 'B',
      phonicSound: 'B... beh... Bintang!',
      illustrationKey: 'bintang',
      category: DictionaryCategory.alam,
      sentence: 'Bintang berkelip-kelip indah menghiasi langit malam yang gelap.',
      funFact: 'Bintang sebenarnya adalah bola gas panas raksasa yang bercahaya sendiri.',
      emoji: '⭐',
      accentColor: Color(0xFFFACC15),
    ),
    DictionaryWordItem(
      id: 'dict_bulan',
      word: 'BULAN',
      syllables: ['BU', 'LAN'],
      letter: 'B',
      phonicSound: 'B... beh... Bulan!',
      illustrationKey: 'bulan',
      category: DictionaryCategory.alam,
      sentence: 'Bulan sabit tersenyum menemani malam yang tenang dan sejuk.',
      funFact: 'Bulan adalah satelit alami Bumi yang memantulkan sinar matahari.',
      emoji: '🌙',
      accentColor: Color(0xFFFBBF24),
    ),
    DictionaryWordItem(
      id: 'dict_bus',
      word: 'BUS',
      syllables: ['BUS'],
      letter: 'B',
      phonicSound: 'B... beh... Bus!',
      illustrationKey: 'bus',
      category: DictionaryCategory.kendaraan,
      sentence: 'Bus kuning yang besar mengantar anak-anak pergi ke sekolah.',
      funFact: 'Bus kota dapat mengangkut puluhan penumpang sekaligus dengan aman.',
      emoji: '🚌',
      accentColor: Color(0xFFEAB308),
    ),

    // --- HURUF C ---
    DictionaryWordItem(
      id: 'dict_ceri',
      word: 'CERI',
      syllables: ['CE', 'RI'],
      letter: 'C',
      phonicSound: 'C... ceh... Ceri!',
      illustrationKey: 'ceri',
      category: DictionaryCategory.buah,
      sentence: 'Dua buah ceri merah menggantung manis di atas kue ulang tahun.',
      funFact: 'Ceri sering dipetik berpasangan dengan tangkai hijau yang lucu.',
      emoji: '🍒',
      accentColor: Color(0xFFE11D48),
    ),

    // --- HURUF D ---
    DictionaryWordItem(
      id: 'dict_domba',
      word: 'DOMBA',
      syllables: ['DOM', 'BA'],
      letter: 'D',
      phonicSound: 'D... deh... Domba!',
      illustrationKey: 'domba',
      category: DictionaryCategory.hewan,
      sentence: 'Domba putih mengembik mbeee sambil memakan rumput hijau.',
      funFact: 'Bulu domba yang tebal dan hangat dapat dicukur menjadi benang wol.',
      emoji: '🐑',
      accentColor: Color(0xFF64748B),
    ),
    DictionaryWordItem(
      id: 'dict_dino',
      word: 'DINO',
      syllables: ['DI', 'NO'],
      letter: 'D',
      phonicSound: 'D... deh... Dino!',
      illustrationKey: 'dino',
      category: DictionaryCategory.hewan,
      sentence: 'Dino hijau melompat ceria di lembah zaman purba.',
      funFact: 'Dinosaurus pernah hidup di bumi jutaan tahun yang lalu.',
      emoji: '🦖',
      accentColor: Color(0xFF16A34A),
    ),

    // --- HURUF E ---
    DictionaryWordItem(
      id: 'dict_elang',
      word: 'ELANG',
      syllables: ['E', 'LANG'],
      letter: 'E',
      phonicSound: 'E... eh... Elang!',
      illustrationKey: 'elang',
      category: DictionaryCategory.hewan,
      sentence: 'Burung elang terbang melayang tinggi melintasi puncak gunung.',
      funFact: 'Mata elang sangat tajam dan bisa melihat mangsa dari jarak beberapa kilometer.',
      emoji: '🦅',
      accentColor: Color(0xFF6366F1),
    ),

    // --- HURUF F ---
    DictionaryWordItem(
      id: 'dict_foto',
      word: 'FOTO',
      syllables: ['FO', 'TO'],
      letter: 'F',
      phonicSound: 'F... feh... Foto!',
      illustrationKey: 'foto',
      category: DictionaryCategory.benda,
      sentence: 'Cekrek! Kamera mengambil foto senyum manis Miko dan keluarga.',
      funFact: 'Foto menyimpan kenangan indah masa kecil yang tak terlupakan.',
      emoji: '📸',
      accentColor: Color(0xFFA855F7),
    ),

    // --- HURUF G ---
    DictionaryWordItem(
      id: 'dict_gajah',
      word: 'GAJAH',
      syllables: ['GA', 'JAH'],
      letter: 'G',
      phonicSound: 'G... geh... Gajah!',
      illustrationKey: 'gajah',
      category: DictionaryCategory.hewan,
      sentence: 'Gajah besar menyemprotkan air segar dengan belalainya yang panjang.',
      funFact: 'Gajah adalah hewan darat terbesar di dunia yang suka hidup berkelompok.',
      emoji: '🐘',
      accentColor: Color(0xFF475569),
    ),
    DictionaryWordItem(
      id: 'dict_gunung',
      word: 'GUNUNG',
      syllables: ['GU', 'NUNG'],
      letter: 'G',
      phonicSound: 'G... geh... Gunung!',
      illustrationKey: 'gunung',
      category: DictionaryCategory.alam,
      sentence: 'Gunung tinggi menjulang ke angkasa dihiasi pepohonan hijau rindang.',
      funFact: 'Puncak gunung sering kali terasa dingin dan diselimuti kabut pagi.',
      emoji: '⛰️',
      accentColor: Color(0xFF0D9488),
    ),

    // --- HURUF H ---
    DictionaryWordItem(
      id: 'dict_harimau',
      word: 'HARIMAU',
      syllables: ['HA', 'RI', 'MAU'],
      letter: 'H',
      phonicSound: 'H... heh... Harimau!',
      illustrationKey: 'harimau',
      category: DictionaryCategory.hewan,
      sentence: 'Harimau loreng berbaring santai di bawah pohon hutan yang teduh.',
      funFact: 'Pola garis loreng pada tubuh setiap harimau berbeda-beda seperti sidik jari.',
      emoji: '🐯',
      accentColor: Color(0xFFF97316),
    ),
    DictionaryWordItem(
      id: 'dict_helikopter',
      word: 'HELIKOPTER',
      syllables: ['HE', 'LI', 'KOP', 'TER'],
      letter: 'H',
      phonicSound: 'H... heh... Helikopter!',
      illustrationKey: 'helikopter',
      category: DictionaryCategory.kendaraan,
      sentence: 'Baling-baling helikopter berputar kencang saat lepas landas.',
      funFact: 'Helikopter bisa terbang tegak ke atas, ke bawah, bahkan mundur!',
      emoji: '🚁',
      accentColor: Color(0xFF0284C7),
    ),

    // --- HURUF I ---
    DictionaryWordItem(
      id: 'dict_ikan',
      word: 'IKAN',
      syllables: ['I', 'KAN'],
      letter: 'I',
      phonicSound: 'I... i... Ikan!',
      illustrationKey: 'ikan',
      category: DictionaryCategory.hewan,
      sentence: 'Ikan mas berenang lincah di kolam air yang jernih.',
      funFact: 'Ikan bernapas di dalam air menggunakan organ khusus bernama insang.',
      emoji: '🐟',
      accentColor: Color(0xFF06B6D4),
    ),

    // --- HURUF J ---
    DictionaryWordItem(
      id: 'dict_jeruk',
      word: 'JERUK',
      syllables: ['JE', 'RUK'],
      letter: 'J',
      phonicSound: 'J... jeh... Jeruk!',
      illustrationKey: 'jeruk',
      category: DictionaryCategory.buah,
      sentence: 'Buah jeruk oranye rasanya manis dan sangat menyegarkan tenggorokan.',
      funFact: 'Jeruk sangat kaya air dan vitamin C untuk menjaga daya tahan tubuh.',
      emoji: '🍊',
      accentColor: Color(0xFFEA580C),
    ),
    DictionaryWordItem(
      id: 'dict_jagung',
      word: 'JAGUNG',
      syllables: ['JA', 'GUNG'],
      letter: 'J',
      phonicSound: 'J... jeh... Jagung!',
      illustrationKey: 'jagung',
      category: DictionaryCategory.buah,
      sentence: 'Jagung manis bakar beraroma harum dan sangat lezat dimakan bersama.',
      funFact: 'Biji jagung yang dipanaskan bisa meletup menjadi popcorn yang renyah!',
      emoji: '🌽',
      accentColor: Color(0xFFF59E0B),
    ),
    DictionaryWordItem(
      id: 'dict_jus',
      word: 'JUS',
      syllables: ['JUS'],
      letter: 'J',
      phonicSound: 'J... jeh... Jus!',
      illustrationKey: 'jus',
      category: DictionaryCategory.buah,
      sentence: 'Minum segelas jus buah dingin terasa sangat menyegarkan di siang hari.',
      funFact: 'Jus buah segar mengandung banyak vitamin murni alami yang menyehatkan.',
      emoji: '🧃',
      accentColor: Color(0xFFEAB308),
    ),

    // --- HURUF K ---
    DictionaryWordItem(
      id: 'dict_kucing',
      word: 'KUCING',
      syllables: ['KU', 'CING'],
      letter: 'K',
      phonicSound: 'K... keh... Kucing!',
      illustrationKey: 'kucing',
      category: DictionaryCategory.hewan,
      sentence: 'Kucing belang mengeong manja minta dielus bulunya yang lembut.',
      funFact: 'Kucing memiliki kumis sensitif yang membantunya menjaga keseimbangan.',
      emoji: '🐱',
      accentColor: Color(0xFFF59E0B),
    ),
    DictionaryWordItem(
      id: 'dict_kuda',
      word: 'KUDA',
      syllables: ['KU', 'DA'],
      letter: 'K',
      phonicSound: 'K... keh... Kuda!',
      illustrationKey: 'kuda',
      category: DictionaryCategory.hewan,
      sentence: 'Kuda gagah berlari kencang melewati padang rumput yang luas.',
      funFact: 'Kuda bisa tidur sambil berdiri karena memiliki sendi kaki yang istimewa.',
      emoji: '🐴',
      accentColor: Color(0xFFB45309),
    ),
    DictionaryWordItem(
      id: 'dict_kupu',
      word: 'KUPU-KUPU',
      syllables: ['KU', 'PU', 'KU', 'PU'],
      letter: 'K',
      phonicSound: 'K... keh... Kupu-kupu!',
      illustrationKey: 'kupu',
      category: DictionaryCategory.hewan,
      sentence: 'Kupu-kupu dengan sayap warna-warni hinggap lembut di atas kelopak bunga.',
      funFact: 'Kupu-kupu mengalami metamorfosis dari ulat kecil menjadi serangga indah.',
      emoji: '🦋',
      accentColor: Color(0xFF8B5CF6),
    ),
    DictionaryWordItem(
      id: 'dict_kereta',
      word: 'KERETA',
      syllables: ['KE', 'RE', 'TA'],
      letter: 'K',
      phonicSound: 'K... keh... Kereta!',
      illustrationKey: 'kereta',
      category: DictionaryCategory.kendaraan,
      sentence: 'Tuut tuut! Kereta api melaju cepat di atas rel baja.',
      funFact: 'Kereta api modern dapat melaju hingga ratusan kilometer per jam!',
      emoji: '🚂',
      accentColor: Color(0xFFEF4444),
    ),
    DictionaryWordItem(
      id: 'dict_kapal',
      word: 'KAPAL',
      syllables: ['KA', 'PAL'],
      letter: 'K',
      phonicSound: 'K... keh... Kapal!',
      illustrationKey: 'kapal',
      category: DictionaryCategory.kendaraan,
      sentence: 'Kapal layar putih berlayar anggun membelah ombak lautan biru.',
      funFact: 'Kapal laut dapat mengapung di air karena memiliki lambung yang berongga udara.',
      emoji: '🚢',
      accentColor: Color(0xFF0284C7),
    ),

    // --- HURUF L ---
    DictionaryWordItem(
      id: 'dict_lemon',
      word: 'LEMON',
      syllables: ['LE', 'MON'],
      letter: 'L',
      phonicSound: 'L... leh... Lemon!',
      illustrationKey: 'lemon',
      category: DictionaryCategory.buah,
      sentence: 'Lemon kuning rasanya masam segar jika dibuat minuman teh lemon.',
      funFact: 'Aroma kulit lemon yang wangi sering digunakan sebagai penyegar alami.',
      emoji: '🍋',
      accentColor: Color(0xFFFACC15),
    ),

    // --- HURUF M ---
    DictionaryWordItem(
      id: 'dict_mobil',
      word: 'MOBIL',
      syllables: ['MO', 'BIL'],
      letter: 'M',
      phonicSound: 'M... meh... Mobil!',
      illustrationKey: 'mobil',
      category: DictionaryCategory.kendaraan,
      sentence: 'Mobil merah melaju membawa keluarga pergi bertamasya ke pantai.',
      funFact: 'Mobil memiliki empat roda karet dan sabuk pengaman agar perjalanan nyaman.',
      emoji: '🚗',
      accentColor: Color(0xFFEF4444),
    ),
    DictionaryWordItem(
      id: 'dict_matahari',
      word: 'MATAHARI',
      syllables: ['MA', 'TA', 'HA', 'RI'],
      letter: 'M',
      phonicSound: 'M... meh... Matahari!',
      illustrationKey: 'matahari',
      category: DictionaryCategory.alam,
      sentence: 'Matahari pagi bersinar hangat menyinari seluruh isi bumi.',
      funFact: 'Sinar matahari pagi sangat baik untuk pembentukan vitamin D di tulang.',
      emoji: '☀️',
      accentColor: Color(0xFFF59E0B),
    ),
    DictionaryWordItem(
      id: 'dict_mangga',
      word: 'MANGGA',
      syllables: ['MANG', 'GA'],
      letter: 'M',
      phonicSound: 'M... meh... Mangga!',
      illustrationKey: 'mangga',
      category: DictionaryCategory.buah,
      sentence: 'Buah mangga harum manis berwarna kuning keemasan di dalam.',
      funFact: 'Mangga sering dijuluki sebagai raja buah tropis karena rasanya yang manis.',
      emoji: '🥭',
      accentColor: Color(0xFFF97316),
    ),
    DictionaryWordItem(
      id: 'dict_mata',
      word: 'MATA',
      syllables: ['MA', 'TA'],
      letter: 'M',
      phonicSound: 'M... meh... Mata!',
      illustrationKey: 'mata',
      category: DictionaryCategory.benda,
      sentence: 'Mata jernih kita melihat pemandangan indah penuh warna warni.',
      funFact: 'Kedipan mata kita menjaga bola mata agar tetap bersih dan lembab.',
      emoji: '👀',
      accentColor: Color(0xFF0284C7),
    ),

    // --- HURUF N ---
    DictionaryWordItem(
      id: 'dict_nanas',
      word: 'NANAS',
      syllables: ['NA', 'NAS'],
      letter: 'N',
      phonicSound: 'N... neh... Nanas!',
      illustrationKey: 'nanas',
      category: DictionaryCategory.buah,
      sentence: 'Buah nanas memiliki kulit bersisik dan mahkota daun hijau yang mahkota.',
      funFact: 'Nanas mengandung enzim alami bromelain yang sangat baik untuk pencernaan.',
      emoji: '🍍',
      accentColor: Color(0xFFD97706),
    ),

    // --- HURUF O ---
    DictionaryWordItem(
      id: 'dict_obat',
      word: 'OBAT',
      syllables: ['O', 'BAT'],
      letter: 'O',
      phonicSound: 'O... o... Obat!',
      illustrationKey: 'obat',
      category: DictionaryCategory.benda,
      sentence: 'Dokter yang ramah memberikan obat sirup manis agar badan lekas sembuh.',
      funFact: 'Minum obat sesuai anjuran dokter dan istirahat cukup mempercepat kesembuhan.',
      emoji: '💊',
      accentColor: Color(0xFF0284C7),
    ),

    // --- HURUF P ---
    DictionaryWordItem(
      id: 'dict_pisang',
      word: 'PISANG',
      syllables: ['PI', 'SANG'],
      letter: 'P',
      phonicSound: 'P... peh... Pisang!',
      illustrationKey: 'pisang',
      category: DictionaryCategory.buah,
      sentence: 'Pisang kuning manis adalah makanan favorit monyet di hutan.',
      funFact: 'Pisang kaya akan kalium yang memberi energi cepat saat kita berolahraga.',
      emoji: '🍌',
      accentColor: Color(0xFFEAB308),
    ),
    DictionaryWordItem(
      id: 'dict_pesawat',
      word: 'PESAWAT',
      syllables: ['PE', 'SA', 'WAT'],
      letter: 'P',
      phonicSound: 'P... peh... Pesawat!',
      illustrationKey: 'pesawat',
      category: DictionaryCategory.kendaraan,
      sentence: 'Pesawat terbang melesat menembus awan putih di angkasa luas.',
      funFact: 'Sayap pesawat dirancang aerodinamis meniru sayap burung di udara.',
      emoji: '✈️',
      accentColor: Color(0xFF2563EB),
    ),
    DictionaryWordItem(
      id: 'dict_pohon',
      word: 'POHON',
      syllables: ['PO', 'HON'],
      letter: 'P',
      phonicSound: 'P... peh... Pohon!',
      illustrationKey: 'pohon',
      category: DictionaryCategory.alam,
      sentence: 'Pohon beringin rindang menjadi tempat teduh untuk burung bersarang.',
      funFact: 'Pohon menghasilkan oksigen bersih yang kita hirup setiap saat.',
      emoji: '🌳',
      accentColor: Color(0xFF16A34A),
    ),
    DictionaryWordItem(
      id: 'dict_pelangi',
      word: 'PELANGI',
      syllables: ['PE', 'LANG', 'I'],
      letter: 'P',
      phonicSound: 'P... peh... Pelangi!',
      illustrationKey: 'pelangi',
      category: DictionaryCategory.alam,
      sentence: 'Pelangi indah tujuh warna melengkung di langit setelah hujan reda.',
      funFact: 'Pelangi terjadi saat sinar matahari dibiaskan oleh titik-titik tetes air hujan.',
      emoji: '🌈',
      accentColor: Color(0xFFD946EF),
    ),

    // --- HURUF R ---
    DictionaryWordItem(
      id: 'dict_roti',
      word: 'ROTI',
      syllables: ['RO', 'TI'],
      letter: 'R',
      phonicSound: 'R... reh... Roti!',
      illustrationKey: 'roti',
      category: DictionaryCategory.buah,
      sentence: 'Miko sarapan roti bakar hangat dengan selai cokelat yang lezat.',
      funFact: 'Roti dibuat dari gandum yang dipanggang hingga harum dan empuk.',
      emoji: '🍞',
      accentColor: Color(0xFFB45309),
    ),
    DictionaryWordItem(
      id: 'dict_rumah',
      word: 'RUMAH',
      syllables: ['RU', 'MAH'],
      letter: 'R',
      phonicSound: 'R... reh... Rumah!',
      illustrationKey: 'rumah',
      category: DictionaryCategory.benda,
      sentence: 'Rumah yang nyaman dan bersih adalah tempat berkumpul keluarga tercinta.',
      funFact: 'Atap rumah melindungi kita dari teriknya panas matahari dan derasnya hujan.',
      emoji: '🏠',
      accentColor: Color(0xFF0D9488),
    ),
    DictionaryWordItem(
      id: 'dict_rusa',
      word: 'RUSA',
      syllables: ['RU', 'SA'],
      letter: 'R',
      phonicSound: 'R... reh... Rusa!',
      illustrationKey: 'rusa',
      category: DictionaryCategory.hewan,
      sentence: 'Rusa bertanduk elok berjalan anggun di tepi telaga hutan.',
      funFact: 'Tanduk rusa jantan bisa lepas dan tumbuh kembali lebih besar setiap tahun!',
      emoji: '🦌',
      accentColor: Color(0xFFD97706),
    ),

    // --- HURUF S ---
    DictionaryWordItem(
      id: 'dict_sapi',
      word: 'SAPI',
      syllables: ['SA', 'PI'],
      letter: 'S',
      phonicSound: 'S... seh... Sapi!',
      illustrationKey: 'sapi',
      category: DictionaryCategory.hewan,
      sentence: 'Sapi perah putih hitam menghasilkan susu segar yang menyehatkan tulang.',
      funFact: 'Sapi memiliki empat bagian lambung untuk mencerna rumput dengan sempurna.',
      emoji: '🐮',
      accentColor: Color(0xFF15803D),
    ),
    DictionaryWordItem(
      id: 'dict_sepeda',
      word: 'SEPEDA',
      syllables: ['SE', 'PE', 'DA'],
      letter: 'S',
      phonicSound: 'S... seh... Sepeda!',
      illustrationKey: 'sepeda',
      category: DictionaryCategory.kendaraan,
      sentence: 'Ayo kayuh pedal sepeda roda dua keliling taman di sore hari!',
      funFact: 'Bersepeda adalah olahraga sehat yang ramah lingkungan dan bebas polusi.',
      emoji: '🚲',
      accentColor: Color(0xFF10B981),
    ),
    DictionaryWordItem(
      id: 'dict_sepatu',
      word: 'SEPATU',
      syllables: ['SE', 'PA', 'TU'],
      letter: 'S',
      phonicSound: 'S... seh... Sepatu!',
      illustrationKey: 'sepatu',
      category: DictionaryCategory.benda,
      sentence: 'Pakai sepatu olahraga yang pas sebelum berlari di lapangan.',
      funFact: 'Sepatu melindungi telapak kaki kita dari batu tajam dan kotoran.',
      emoji: '👟',
      accentColor: Color(0xFF4F46E5),
    ),
    DictionaryWordItem(
      id: 'dict_semangka',
      word: 'SEMANGKA',
      syllables: ['SE', 'MANG', 'KA'],
      letter: 'S',
      phonicSound: 'S... seh... Semangka!',
      illustrationKey: 'semangka',
      category: DictionaryCategory.buah,
      sentence: 'Semangka merah tanpa biji sangat manis dan banyak mengandung air segar.',
      funFact: 'Lebih dari 90 persen buah semangka terdiri dari air segar alami!',
      emoji: '🍉',
      accentColor: Color(0xFFEF4444),
    ),

    // --- HURUF T ---
    DictionaryWordItem(
      id: 'dict_topi',
      word: 'TOPI',
      syllables: ['TO', 'PI'],
      letter: 'T',
      phonicSound: 'T... teh... Topi!',
      illustrationKey: 'topi',
      category: DictionaryCategory.benda,
      sentence: 'Miko memakai topi bundar biru agar kepalanya tidak kepanasan.',
      funFact: 'Topi pelindung memiliki lidah depan yang menaungi mata dari silau.',
      emoji: '🧢',
      accentColor: Color(0xFF2563EB),
    ),

    // --- HURUF U ---
    DictionaryWordItem(
      id: 'dict_udang',
      word: 'UDANG',
      syllables: ['U', 'DANG'],
      letter: 'U',
      phonicSound: 'U... u... Udang!',
      illustrationKey: 'udang',
      category: DictionaryCategory.hewan,
      sentence: 'Udang kecil berenang mundur di antara terumbu karang laut.',
      funFact: 'Udang memiliki antena panjang di kepalanya untuk mendeteksi sekitarnya.',
      emoji: '🦐',
      accentColor: Color(0xFFF43F5E),
    ),

    // --- HURUF V ---
    DictionaryWordItem(
      id: 'dict_vas',
      word: 'VAS',
      syllables: ['VAS'],
      letter: 'V',
      phonicSound: 'V... veh... Vas!',
      illustrationKey: 'vas',
      category: DictionaryCategory.benda,
      sentence: 'Vas keramik bunga diletakkan rapi di atas meja ruang tamu.',
      funFact: 'Vas bunga dapat diisi air agar bunga potong tetap segar selama berhari-hari.',
      emoji: '🏺',
      accentColor: Color(0xFF7C3AED),
    ),

    // --- HURUF W ---
    DictionaryWordItem(
      id: 'dict_wortel',
      word: 'WORTEL',
      syllables: ['WOR', 'TEL'],
      letter: 'W',
      phonicSound: 'W... weh... Wortel!',
      illustrationKey: 'wortel',
      category: DictionaryCategory.buah,
      sentence: 'Kelinci putih melompat gembira mengunyah wortel renyah berwarna oranye.',
      funFact: 'Wortel sangat kaya vitamin A yang sangat baik untuk menjaga kesehatan mata kita!',
      emoji: '🥕',
      accentColor: Color(0xFFEA580C),
    ),

    // --- HURUF X ---
    DictionaryWordItem(
      id: 'dict_xilofon',
      word: 'XILOFON',
      syllables: ['XI', 'LO', 'FON'],
      letter: 'X',
      phonicSound: 'X... eks... Xilofon!',
      illustrationKey: 'xilofon',
      category: DictionaryCategory.benda,
      sentence: 'Ting ting ting! Miko memukul bilah logam xilofon menghasilkan melodi ceria.',
      funFact: 'Setiap bilah xilofon memiliki panjang berbeda untuk menghasilkan nada musik tinggi dan rendah.',
      emoji: '🎵',
      accentColor: Color(0xFF0D9488),
    ),

    // --- HURUF Y ---
    DictionaryWordItem(
      id: 'dict_yoyo',
      word: 'YOYO',
      syllables: ['YO', 'YO'],
      letter: 'Y',
      phonicSound: 'Y... yeh... Yoyo!',
      illustrationKey: 'yoyo',
      category: DictionaryCategory.benda,
      sentence: 'Yoyo merah berputar cepat naik turun mengikuti tarikan tali jemari.',
      funFact: 'Yoyo adalah salah satu permainan tertua di dunia yang sangat melatih ketangkasan tangan.',
      emoji: '🪀',
      accentColor: Color(0xFFEC4899),
    ),

    // --- HURUF Z ---
    DictionaryWordItem(
      id: 'dict_zebra',
      word: 'ZEBRA',
      syllables: ['ZE', 'BRA'],
      letter: 'Z',
      phonicSound: 'Z... zeh... Zebra!',
      illustrationKey: 'zebra',
      category: DictionaryCategory.hewan,
      sentence: 'Zebra belang hitam putih berjalan anggun bersama kawanannya di sabana.',
      funFact: 'Garis belang zebra membantu menyamarkan tubuhnya dari pemangsa di padang rumput liar.',
      emoji: '🦓',
      accentColor: Color(0xFF334155),
    ),
  ];

  static List<DictionaryWordItem> getWordsByCategory(DictionaryCategory category) {
    if (category == DictionaryCategory.all) return allWords;
    return allWords.where((w) => w.category == category).toList();
  }

  static List<DictionaryWordItem> getWordsByLetter(String letter) {
    final l = letter.toUpperCase();
    return allWords.where((w) => w.letter.toUpperCase() == l).toList();
  }

  static List<DictionaryWordItem> searchWords(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allWords;
    return allWords.where((w) {
      return w.word.toLowerCase().contains(q) ||
          w.syllables.any((s) => s.toLowerCase().contains(q)) ||
          w.sentence.toLowerCase().contains(q);
    }).toList();
  }

  static List<String> getAvailableLetters() {
    final Set<String> letters = {};
    for (final word in allWords) {
      letters.add(word.letter.toUpperCase());
    }
    final list = letters.toList();
    list.sort();
    return list;
  }
}
