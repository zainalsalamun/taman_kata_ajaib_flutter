# Taman Kata Ajaib

**Taman Kata Ajaib** adalah aplikasi game edukasi interaktif berbasis Flutter yang dirancang khusus untuk membantu anak-anak usia dini (PAUD & TK / 3–8 tahun) belajar membaca, menulis, mengenal fonik huruf, menyusun suku kata, dan memperkaya kosakata bahasa Indonesia dengan cara yang menyenangkan, interaktif, aman, dan bebas iklan.

---

## Fitur & Wahana Belajar Utama

Aplikasi ini memiliki 4 pulau petualangan edukatif yang dirancang sesuai tahapan perkembangan anak:

### 1. Pulau Jejak Huruf (Letter Tracing) — *Usia 3–5 Tahun*
* Latihan motorik halus untuk menulis huruf alfabet besar (*uppercase*).
* Dilengkapi panduan titik (*guide points*) dan kuas beranimasi.
* Audio fonik pengucapan huruf dan contoh kata secara otomatis.

### 2. Pulau Kereta Suku Kata (Syllable Train) — *Usia 5–7 Tahun*
* Belajar menyusun potongan suku kata menjadi satu kata utuh (misal: `BO` + `LA` = `BOLA`).
* Melatih logika anak dalam memadukan bunyi vokal dan konsonan.
* Dilengkapi animasi gerbong kereta melaju dan efek suara peluit saat berhasil.

### 3. Pulau Balon Kata Ajaib (Word Balloons) — *Usia 6–8 Tahun*
* Mencocokkan kata yang tertulis pada balon dengan gambar objek yang ditampilkan.
* Melatih kecepatan membaca dan daya ingat visual kata.

### 4. Pulau Kuis Sentuh Pintar (Smart Touch Quiz) — *Semua Usia*
* Kuis interaktif berbasis instruksi suara (*"Mana gambar APEL?"*).
* Cukup menyentuh pilihan gambar yang benar tanpa perlu mengetik, cocok untuk anak yang baru mulai belajar.

---

## Fitur Pendukung & Gamifikasi

* **Sistem Hadiah Bintang (Star Rewards)**: Anak mendapatkan bintang setiap kali menyelesaikan tantangan belajar sebagai bentuk apresiasi.
* **Album Stiker & Toko Hadiah**: Bintang yang dikumpulkan dapat ditukarkan dengan berbagai stiker lucu untuk melengkapi koleksi album.
* **Zona Orang Tua (Parental Gate)**: Dilengkapi verifikasi matematika sederhana untuk melihat ringkasan progres belajar anak dan mencegah perubahan setting tanpa pengawasan.
* **Audio Fonik Bahasa Indonesia**: Menggunakan Text-to-Speech (TTS) dengan intonasi ceria dan kecepatan bicara yang disesuaikan untuk anak-anak.
* **Grafis Vektor Mandiri (Canvas Paint)**: Menggunakan ilustrasi vektor mandiri (*custom painter*) yang tajam di seluruh resolusi layar, ringan, dan tidak memerlukan unduhan aset eksternal.
* **Desain Khusus Landscape / Tablet**: Tata letak dioptimalkan untuk tablet/iPad atau smartphone landscape dengan tombol besar dan warna cerah yang ramah anak.
* **Offline-First & Bebas Iklan**: Dapat dimainkan 100% tanpa koneksi internet dan bebas dari gangguan iklan.

---

## Struktur Direktori Proyek

```text
lib/
├── main.dart                      # Titik masuk aplikasi & konfigurasi routing
├── models/
│   └── game_models.dart           # Model data soal, huruf, kata, dan stiker
├── screens/
│   ├── map_screen.dart            # Menu peta petualangan pulau belajar
│   ├── tracing_screen.dart        # Wahana menulis huruf (Tracing)
│   ├── train_screen.dart          # Wahana kereta suku kata
│   ├── balloon_screen.dart        # Wahana letuskan balon kata
│   └── quiz_screen.dart           # Wahana kuis sentuh pintar
├── services/
│   ├── audio_service.dart         # Layanan Text-to-Speech (TTS) fonik
│   └── storage_service.dart       # Penyimpanan lokal (Shared Preferences)
└── widgets/
    ├── parental_gate_dialog.dart  # Dialog keamanan zona orang tua
    ├── sticker_album_dialog.dart  # Dialog album & penukaran stiker
    ├── ui_header.dart             # Header navigasi, bintang & kontrol suara
    ├── vector_illustrations.dart  # Ilustrasi vektor objek & ikon game
    └── victory_dialog.dart        # Dialog selebrasi kemenangan/level selesai
```

---

## Memulai (Getting Started)

### Prasyarat
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.10.8 atau lebih baru)
* [Dart SDK](https://dart.dev/)
* Emulator Android/iOS atau Perangkat Fisik (disarankan mode Tablet atau Smartphone Landscape)

### Langkah Instalasi

1. **Clone repository**:
   ```bash
   git clone https://github.com/username/taman_kata_ajaib_flutter.git
   cd taman_kata_ajaib_flutter
   ```

2. **Pasang dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

## Paket & Dependensi Utama

| Paket | Deskripsi Kegunaan |
|---|---|
| [`flutter_tts`](https://pub.dev/packages/flutter_tts) | Sintesis suara fonik dan narasi instruksi dalam bahasa Indonesia (`id-ID`). |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Penyimpanan data lokal untuk perolehan bintang dan stiker yang telah dibuka. |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Tipografi ramah anak menggunakan font *Fredoka* dan *Nunito*. |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | Kumpulan ikon bawaan pelengkap antarmuka. |

---

## Lisensi

Proyek ini dikembangkan untuk tujuan edukasi anak usia dini. Bebas digunakan dan dimodifikasi untuk pengembangan pembelajaran yang lebih baik.
