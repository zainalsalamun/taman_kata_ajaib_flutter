# 📦 Model Packs untuk AI Indonesia (Meta MMS-TTS)

Folder ini digunakan untuk menyimpan bobot model AI offline dari repository:
**[wedhalabs/Voice-Storyboard-Video-Tools-Offline](https://github.com/wedhalabs/Voice-Storyboard-Video-Tools-Offline)**

---

## 📥 Cara Memasang Model:

1. Buka halaman Releases:
   👉 **[Releases Wedhalabs](https://github.com/wedhalabs/Voice-Storyboard-Video-Tools-Offline/releases)**
2. Unduh file: **`voice-video-studio-packs-v21.zip`** (sekitar ~203 MB).
3. Buka zip tersebut, cari dua file berikut di dalam folder `packs/`:
   - **`ort-wasm.js`** (~14.8 MB) — Mesin eksekutor ONNX Runtime Web.
   - **`mms-indonesia.js`** (~51.4 MB) — Bobot model suara Meta Bahasa Indonesia.
4. Letakkan kedua file tersebut langsung di dalam folder ini (`web/packs/`):
   ```text
   web/packs/
   ├── ort-wasm.js
   ├── mms-indonesia.js
   └── README.md
   ```

---

## ⚡ Status di Aplikasi:
- **Jika file sudah ada**: Aplikasi akan otomatis mengaktifkan mesin **AI Indonesia (Meta MMS-TTS)** yang bersuara alami dan natural.
- **Jika file belum ada**: Aplikasi tetap berjalan normal 100% menggunakan suara Web Speech API bawaan browser tanpa error.
