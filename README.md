# Taman Kata Ajaib

**Taman Kata Ajaib** adalah aplikasi game edukasi interaktif berbasis Flutter yang dirancang khusus untuk membantu anak-anak usia dini (PAUD, TK & SD Awal / 3–8 tahun) belajar membaca, menulis huruf besar & kecil, mengenal fonik, menyusun suku kata, membaca buku dongeng bersuara, dan memperkaya kosakata bahasa Indonesia dengan cara yang menyenangkan, aman, dan 100% bebas iklan.

---

## 🏝️ 8 Pulau Petualangan & Wahana Belajar Utama

Aplikasi ini menyajikan **Peta Kepulauan Kata Ajaib** dengan siklus cuaca dinamis (Siang, Senja, Malam), kapal layar beranimasi, peti harta karun harian, dan 8 wahana belajar bertingkat:

### 1. Dermaga Jejak Huruf (Letter, Number & Shape Tracing) — *Usia 3–5 Tahun*
* **3 Sub-Mode Alfabet (Tingkat 1)**:
  * **Huruf Besar (`A–Z`)**: Latihan motorik halus menulis huruf kapital lengkap dengan panduan titik dan contoh kata.
  * **Huruf Kecil (`a–z`)**: Latihan menulis 26 huruf kecil untuk membiasakan anak membaca buku cerita.
  * **Mini-Game Pasangan Huruf (`Aa`)**: Mencocokkan induk huruf besar (`A–Z`) dengan anak huruf kecilnya (`a–z`).
* **Tingkat 2 (Angka `1–10`) & Tingkat 3 (Bentuk Geometri)**: Menulis angka dan menggambar bentuk dasar (Lingkaran, Segitiga, Persegi, Bintang, Hati).
* **Mode Panduan vs Mode Mandiri**: Dilengkapi garis bantu 3 baris (*kindergarten ruling*) serta 7 pilihan **Kuas Ajaib** (termasuk *Kuas Pelangi* dan *Pena Bintang Glitter*).

### 2. Pelabuhan Kereta Kata (Syllable Train) — *Usia 5–7 Tahun*
* Belajar menyusun potongan gerbong suku kata menjadi kata utuh:
  * **Tingkat 1**: Kata 2 suku kata terbuka (`BO` + `LA` = `BOLA`).
  * **Tingkat 2**: Kata 3–4 suku kata (`SE` + `PE` + `DA`, `MA` + `TA` + `HA` + `RI`).
  * **Tingkat 3**: Suku kata tertutup dan bunyi sengau `NG` / diftong (`BIN` + `TANG`, `KU` + `CING`, `HA` + `RI` + `MAU`).

### 3. Puncak Balon Ajaib (Word Balloons) — *Usia 6–8 Tahun*
* Mencocokkan dan meletuskan balon kata yang terbang sesuai gambar dan konteks (Tingkat 1: Kata Benda, Tingkat 2: Kata Kerja & Sifat, Tingkat 3: Kosakata Alam & Sekitar).

### 4. Kuil Sentuh Pintar & Tantangan Kilat 60 Detik (Smart Quiz & Speed Rush) — *Semua Usia*
* **Kuis Multi-Tingkat**: Identifikasi gambar objek (Tingkat 1), analisis fonik huruf awal & jumlah suku kata (Tingkat 2), serta teka-teki logika deskriptif (Tingkat 3).
* **Tantangan Kilat 60 Detik (*Speed Rush*)**: Mode berpacu dengan waktu dan *combo streak* untuk melatih refleks membaca cepat.

### 5. Taman Kreasi Stiker (Sticker Playground) — *Kreativitas*
* Kanvas interaktif dengan 3 tema latar (**Kebun Ceria**, **Samudra Biru**, **Galaksi Angkasa**) tempat anak menempel, menggeser, memperbesar, dan membunyikan koleksi stiker yang telah dibuka.

### 6. Lembah Labirin Kata (Word Maze) — *Usia 4–7 Tahun*
* Memandu maskot Miko menyusuri labirin untuk menjemput urutan huruf (Tingkat 1), 2 suku kata (Tingkat 2), dan 3 suku kata (Tingkat 3) menuju peti harta karun.

### 7. Kastil Dongeng Ajaib (Interactive Storybook) — *Membaca Cerita*
* Perpustakaan buku cerita bergambar dengan fitur **Narasi Karaoke** (penyorotan kata demi kata saat dibacakan), objek ilustrasi yang bisa disentuh, serta **Kuis Pemahaman Bacaan** di akhir cerita.

### 8. Perpustakaan Kamus Ajaib & Flashcard 3D (Visual Dictionary) — *50+ Kosakata*
* Eksplorasi puluhan kosakata bergambar lintas kategori dengan filter alfabet `A–Z`, pemecah suku kata bersuara, contoh kalimat, serta mode **Kartu Pintar (Flashcard 3D)** yang bisa dibalik dan diacak.

---

## 🌟 Fitur Pendukung, Gamifikasi & Zona Orang Tua

* **🎙️ Suaraku Ajaib (Voice Recording & Galeri Suara)**: Anak dapat merekam suaranya sendiri saat menirukan pelafalan huruf atau kata dan mendengarkannya kembali di Galeri Suara.
* **📅 Misi Harian & Runtutan Belajar 7 Hari (*Daily Missions & 7-Day Streak*)**: 3 misi harian otomatis dengan hadiah bintang ekstra dan Peti Emas Mingguan.
* **🎡 Roda Hadiah Harian (*Daily Reward Spin*)**: Hadiah bintang dan stiker kejutan setiap hari saat membuka aplikasi.
* **🏆 Galeri Trofi & 📜 Piagam Kelulusan Juara**: Lemari piala interaktif (20+ trofi pencapaian) serta Sertifikat Digital bernama profil anak.
* **🔒 Zona Orang Tua (*Parental Gate*) & Pengatur Waktu Layar (*Screen Time Limiter*)**:
  * Dilindungi soal matematika untuk melihat **Rapor Belajar Anak**, **Lemari Trofi**, **Galeri Rekaman Suara**, pengaturan suara/kecepatan bicara TTS, serta pembatas waktu bermain otomatis (*Rest Time Reminder*).
* **🎨 Grafis Vektor Mandiri (*Custom Canvas Painter*) & Offline-First**: Seluruh ilustrasi objek, karakter, dan efek kembang api digambar secara prosedural dengan `CustomPainter`, tajam di segala ukuran layar (Mobile & Tablet, Portrait & Landscape) dan berjalan 100% tanpa internet.

---

## 📂 Struktur Direktori Proyek

```text
lib/
├── main.dart                                # Titik masuk aplikasi, state utama & timer waktu layar
├── models/
│   ├── daily_mission_models.dart            # Model & generator misi belajar harian
│   ├── dictionary_models.dart               # Repositori 50+ kosakata kamus bergambar
│   ├── game_models.dart                     # Data huruf besar/kecil, angka, bentuk, kereta, balon, kuis, labirin & stiker
│   ├── story_models.dart                    # Data buku dongeng interaktif & kuis pemahaman
│   └── trophy_models.dart                   # Definisi piala dan mahkota master
├── screens/
│   ├── splash_screen.dart                   # Layar pembuka animasi
│   ├── map_screen.dart                      # Peta kepulauan interaktif & daftar cepat
│   ├── tracing_screen.dart                  # Wahana menulis huruf A-Z, a-z, pasangan Aa, angka & bentuk
│   ├── train_screen.dart                    # Wahana kereta suku kata (Tingkat 1-3)
│   ├── balloon_screen.dart                  # Wahana balon kata ajaib (Tingkat 1-3)
│   ├── quiz_screen.dart                     # Wahana kuis sentuh pintar & mode kilat 60 detik
│   ├── maze_screen.dart                     # Wahana labirin kata (Tingkat 1-3)
│   ├── storybook_screen.dart                # Wahana buku dongeng karaoke & kuis bacaan
│   ├── dictionary_screen.dart               # Wahana kamus bergambar & flashcard 3D
│   └── sticker_playground_screen.dart       # Kanvas kreasi taman stiker
├── services/
│   ├── audio_service.dart                   # Layanan efek suara, BGM & Text-to-Speech (id-ID)
│   ├── storage_service.dart                 # Penyimpanan progres lokal (SharedPreferences)
│   ├── voice_recording_service.dart         # Layanan perekam suara anak
│   ├── audio/                               # Implementasi pemutar audio lintas platform (IO & Web)
│   └── tts/                                 # Implementasi TTS lintas platform (IO & Web)
└── widgets/
    ├── achievement_certificate_dialog.dart  # Piagam penghargaan kelulusan anak
    ├── app_logo_widget.dart                 # Widget logo Taman Kata Ajaib
    ├── child_avatar_widget.dart             # Pilihan avatar & profil petualang cilik
    ├── daily_missions_dialog.dart           # Dialog misi harian & streak 7 hari
    ├── daily_reward_dialog.dart             # Dialog klaim hadiah harian
    ├── interactive_fireworks.dart           # Efek partikel kembang api selebrasi
    ├── island_mastery_dialog.dart           # Selebrasi penaklukan Tingkat 3 Master
    ├── level_milestone_dialog.dart          # Dialog kenaikan tingkat belajar
    ├── level_selector_ribbon.dart           # Pita pemilih Tingkat 1, 2, dan 3
    ├── parental_gate_dialog.dart            # Dashboard orang tua (Trofi, Rapor, Waktu & Galeri Suara)
    ├── rest_time_dialog.dart                # Pengingat istirahat batas waktu layar
    ├── settings_dialog.dart                 # Pengaturan BGM, suara Miko, kecepatan bicara & profil
    ├── sticker_album_dialog.dart            # Toko penukaran bintang & koleksi stiker
    ├── trophy_showcase_dialog.dart          # Galeri piala prestasi anak
    ├── ui_header.dart                       # Header navigasi utama, bintang & pintasan
    ├── vector_illustrations.dart            # Ilustrasi vektor CustomPainter untuk objek & maskot
    ├── victory_dialog.dart                  # Dialog selebrasi penyelesaian tantangan
    └── voice_record_dialog.dart             # Dialog perekam suara pelafalan anak
```

---

## 🚀 Memulai (Getting Started)

1. **Pasang dependensi**:
   ```bash
   flutter pub get
   ```
2. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```
3. **Analisis kode & pengujian**:
   ```bash
   flutter analyze
   flutter test
   ```
