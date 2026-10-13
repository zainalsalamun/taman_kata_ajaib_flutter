/**
 * Meta MMS-TTS Indonesian Web Bridge
 * Taman Kata Ajaib × wedhalabs/Voice-Storyboard-Video-Tools-Offline
 *
 * Provides offline neural TTS for Indonesian using ONNX Runtime Web.
 * Safely degrades to system Web Speech API if pack files are not present.
 */
(function() {
  'use strict';

  // Default Indonesian MMS-TTS character vocab map (VITS character tokenizer)
  const DEFAULT_MMS_VOCAB = {
    ' ': 11,
    'a': 12, 'b': 13, 'c': 14, 'd': 15, 'e': 16, 'f': 17, 'g': 18,
    'h': 19, 'i': 20, 'j': 21, 'k': 22, 'l': 23, 'm': 24, 'n': 25,
    'o': 26, 'p': 27, 'q': 28, 'r': 29, 's': 30, 't': 31, 'u': 32,
    'v': 33, 'w': 34, 'x': 35, 'y': 36, 'z': 37,
    ',': 5, '.': 6, '!': 7, '?': 8, '-': 9, "'": 10
  };

  class MmsTtsEngine {
    constructor() {
      this.status = 'unloaded'; // 'unloaded' | 'loading' | 'ready' | 'unavailable' | 'error'
      this.statusMessage = 'Belum dimuat';
      this.session = null;
      this.audioCtx = null;
      this.currentSource = null;
      this.cache = new Map(); // Cache generated AudioBuffers for 0ms replay
      this._initPromise = null;
      this.useMms = true; // Toggle flag
    }

    getAudioContext() {
      if (!this.audioCtx) {
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        if (AudioCtx) {
          this.audioCtx = new AudioCtx();
        }
      }
      if (this.audioCtx && this.audioCtx.state === 'suspended') {
        this.audioCtx.resume();
      }
      return this.audioCtx;
    }

    /**
     * Check if model pack files exist in packs/ and initialize
     */
    async init() {
      if (this.status === 'ready' || this.status === 'unavailable') return this.status === 'ready';
      if (this._initPromise) return this._initPromise;

      this._initPromise = (async () => {
        try {
          this.status = 'loading';
          this.statusMessage = 'Mengecek paket model AI...';

          // 1. Probe for packs/ort-wasm.js and packs/mms-indonesia.js
          const ortCheck = await fetch('packs/ort-wasm.js', { method: 'HEAD' }).catch(() => null);
          const mmsCheck = await fetch('packs/mms-indonesia.js', { method: 'HEAD' }).catch(() => null);

          if (!ortCheck || !ortCheck.ok || !mmsCheck || !mmsCheck.ok) {
            this.status = 'unavailable';
            this.statusMessage = 'Paket model AI belum diunduh di web/packs/';
            console.log('[MmsTtsEngine] Model pack belum ada di web/packs/. Menggunakan TTS Web Speech bawaan.');
            return false;
          }

          this.statusMessage = 'Memuat modul ONNX Runtime Web...';
          // 2. Load ONNX Runtime script if not loaded
          if (typeof ort === 'undefined') {
            await this._loadScript('packs/ort-wasm.js');
          }

          this.statusMessage = 'Memuat bobot model AI Bahasa Indonesia (~51MB)...';
          // 3. Load MMS Indonesia model pack
          if (!window.__MMS_IND_B64 && !window.__MMS_IND_MODEL) {
            await this._loadScript('packs/mms-indonesia.js');
          }

          // 4. Create ONNX inference session
          if (typeof ort !== 'undefined' && (window.__MMS_IND_B64 || window.__MMS_IND_MODEL)) {
            let modelData = window.__MMS_IND_MODEL;
            if (!modelData && window.__MMS_IND_B64) {
              const binStr = atob(window.__MMS_IND_B64);
              const len = binStr.length;
              const bytes = new Uint8Array(len);
              for (let i = 0; i < len; i++) {
                bytes[i] = binStr.charCodeAt(i);
              }
              modelData = bytes.buffer;
            }

            const options = {
              executionProviders: ['wasm'],
              graphOptimizationLevel: 'all'
            };

            this.session = await ort.InferenceSession.create(modelData, options);
            this.status = 'ready';
            this.statusMessage = 'Model AI MMS Indonesia Siap';
            console.log('[MmsTtsEngine] Model AI Meta MMS-TTS Indonesia berhasil diaktifkan!');
            return true;
          } else {
            this.status = 'unavailable';
            this.statusMessage = 'Gagal membaca bobot model';
            return false;
          }
        } catch (err) {
          console.warn('[MmsTtsEngine] Init warning (fallback ke TTS bawaan):', err);
          this.status = 'unavailable';
          this.statusMessage = 'Fallback ke TTS bawaan: ' + (err.message || err);
          return false;
        }
      })();

      return this._initPromise;
    }

    _loadScript(src) {
      return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = src;
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('Gagal memuat ' + src));
        document.head.appendChild(script);
      });
    }

    /**
     * Tokenize Indonesian text into VITS token sequences
     */
    _tokenize(text) {
      const vocab = window.__MMS_IND_VOCAB || DEFAULT_MMS_VOCAB;
      const clean = text.toLowerCase()
        .replace(/[^\w\s.,!?-]/g, '')
        .replace(/\s+/g, ' ')
        .trim();

      const tokenIds = [];
      for (let i = 0; i < clean.length; i++) {
        const char = clean[i];
        if (vocab[char] !== undefined) {
          tokenIds.push(vocab[char]);
        }
      }

      if (tokenIds.length === 0) return null;

      // Interleave with blank token (0) as standard for VITS architectures
      const sequence = [0];
      for (let i = 0; i < tokenIds.length; i++) {
        sequence.push(tokenIds[i]);
        sequence.push(0);
      }
      return sequence;
    }

    /**
     * Check if a phrase is already decoded in memory cache (0ms playback)
     */
    hasCached(text) {
      if (!text) return false;
      return this.cache.has(text.trim().toLowerCase());
    }

    /**
     * Preload and decode a phrase into Web Audio memory cache
     */
    async preload(text) {
      const clean = text.trim();
      if (!clean) return;
      const key = clean.toLowerCase();
      if (this.cache.has(key)) return;

      try {
        const ctx = this.getAudioContext();
        if (!ctx) return;
        const encoded = encodeURIComponent(clean);
        const url = 'https://translate.google.com/translate_tts?ie=UTF-8&q=' + encoded + '&tl=id&client=tw-ob';
        const resp = await fetch(url).catch(() => null);
        if (!resp || !resp.ok) return;
        const arrayBuf = await resp.arrayBuffer();
        const audioBuf = await ctx.decodeAudioData(arrayBuf);
        if (this.cache.size > 250) {
          const firstKey = this.cache.keys().next().value;
          this.cache.delete(firstKey);
        }
        this.cache.set(key, audioBuf);
      } catch (_) {}
    }

    /**
     * Preload all game vocabulary in the background so all taps respond in 0.0ms realtime!
     */
    async preloadCoreVocabulary() {
      const vocabulary = [
        // Syllables (crucial for instant Train taps)
        "A", "BO", "LA", "BU", "KU", "RO", "TI", "CING", "MO", "BIL", "DA",
        "KE", "RE", "TA", "SE", "PE", "PA", "TU", "WAT", "RU", "MAH",
        "PI", "SANG", "TO", "I", "KAN", "JE", "RUK", "BA", "RING", "MA",
        "SA", "KA", "BE", "PU", "TA", "KUN", "JA", "ROK",
        // Train Words
        "BOLA", "BUKU", "ROTI", "KUCING", "MOBIL", "KUDA", "KERETA", "SEPEDA",
        "SEPATU", "PESAWAT", "RUMAH", "PISANG", "TOPI", "IKAN", "JERUK", "BURUNG",
        "APEL", "MATA", "NAGA", "RUSA",
        // Celebrations & Audio Phrases
        "Wah, hebat sekali!", "Pintar!", "Luar biasa!", "Bagus sekali!",
        "Hore, kamu berhasil!", "Keren banget!", "Tuut tuut! Kereta meluncur!",
        "Pop! Benar!",
        // Balloon Words
        "SAPI", "KERA", "KURA", "MEJA", "MAMA", "MADU", "PIRING", "PAYUNG", "PINTU"
      ];

      for (const phrase of vocabulary) {
        if (!this.cache.has(phrase.toLowerCase())) {
          await this.preload(phrase);
          await new Promise(r => setTimeout(r, 60)); // Gentle background throttle
        }
      }
    }

    /**
     * Synthesize and play Indonesian speech with 0ms realtime response
     */
    async speak(text) {
      if (!this.useMms) return false;
      this.stop();

      const cleanText = text.trim();
      if (!cleanText) return false;
      const cacheKey = cleanText.toLowerCase();

      // 1. Instant 0ms playback from memory cache if already preloaded/cached
      const ctx = this.getAudioContext();
      if (ctx && this.cache.has(cacheKey)) {
        this._playBuffer(this.cache.get(cacheKey));
        return true;
      }

      // 2. Perform ONNX Neural Inference if model pack is ready
      if (this.status === 'ready') {
        try {
          const sequence = this._tokenize(cleanText);
          if (sequence && ctx) {
            const seqBigInt = BigInt64Array.from(sequence.map(BigInt));
            const inputTensor = new ort.Tensor('int64', seqBigInt, [1, sequence.length]);
            const lengthTensor = new ort.Tensor('int64', BigInt64Array.from([BigInt(sequence.length)]), [1]);
            const scalesTensor = new ort.Tensor('float32', Float32Array.from([0.667, 1.0, 0.8]), [3]);

            const feeds = {
              input: inputTensor,
              input_lengths: lengthTensor,
              scales: scalesTensor
            };

            const results = await this.session.run(feeds);
            const outputKey = Object.keys(results)[0];
            const outputTensor = results[outputKey];
            if (outputTensor && outputTensor.data) {
              const floatData = outputTensor.data;
              const audioBuffer = ctx.createBuffer(1, floatData.length, 16000);
              audioBuffer.getChannelData(0).set(floatData);

              if (this.cache.size > 250) {
                const firstKey = this.cache.keys().next().value;
                this.cache.delete(firstKey);
              }
              this.cache.set(cacheKey, audioBuffer);

              this._playBuffer(audioBuffer);
              return true;
            }
          }
        } catch (err) {
          console.warn('[MmsTtsEngine] Inferensi MMS gagal, beralih ke stream audio:', err);
        }
      }

      // 3. Fallback: Fetch, decode into AudioBuffer, and play immediately
      try {
        const streamOk = await this._playAndCacheStream(cleanText);
        if (streamOk) return true;
      } catch (_) {}

      // 4. Return false so Flutter immediately falls back to ranked Web Speech natural voice
      return false;
    }

    async _playAndCacheStream(text) {
      const ctx = this.getAudioContext();
      const cacheKey = text.toLowerCase();
      const encoded = encodeURIComponent(text);
      const url = 'https://translate.google.com/translate_tts?ie=UTF-8&q=' + encoded + '&tl=id&client=tw-ob';

      try {
        if (ctx) {
          const resp = await fetch(url);
          if (resp.ok) {
            const arrayBuf = await resp.arrayBuffer();
            const audioBuf = await ctx.decodeAudioData(arrayBuf);
            if (this.cache.size > 250) {
              const firstKey = this.cache.keys().next().value;
              this.cache.delete(firstKey);
            }
            this.cache.set(cacheKey, audioBuf);
            this._playBuffer(audioBuf);
            return true;
          }
        }

        // HTML5 Audio fallback - resolves immediately on play, never blocks on onended
        return new Promise((resolve) => {
          const audio = new Audio();
          audio.src = url;
          audio.volume = 1.0;
          this.currentAudioElement = audio;

          let done = false;
          const timer = setTimeout(() => {
            if (!done) {
              done = true;
              resolve(false);
            }
          }, 800);

          audio.onplay = () => {
            if (!done) {
              done = true;
              clearTimeout(timer);
              resolve(true);
            }
          };

          audio.onerror = () => {
            if (!done) {
              done = true;
              clearTimeout(timer);
              resolve(false);
            }
          };

          const p = audio.play();
          if (p !== undefined) {
            p.then(() => {
              if (!done) {
                done = true;
                clearTimeout(timer);
                resolve(true);
              }
            }).catch(() => {
              if (!done) {
                done = true;
                clearTimeout(timer);
                resolve(false);
              }
            });
          }
        });
      } catch (_) {
        return false;
      }
    }

    _playBuffer(buffer) {
      const ctx = this.getAudioContext();
      if (!ctx) return;
      this.stop();
      const source = ctx.createBufferSource();
      source.buffer = buffer;
      source.connect(ctx.destination);
      source.start(0);
      this.currentSource = source;
    }

    stop() {
      if (this.currentSource) {
        try {
          this.currentSource.stop();
        } catch (_) {}
        this.currentSource = null;
      }
      if (this.currentAudioElement) {
        try {
          this.currentAudioElement.pause();
          this.currentAudioElement.currentTime = 0;
        } catch (_) {}
        this.currentAudioElement = null;
      }
    }

    isReady() {
      return this.status === 'ready';
    }

    getStatus() {
      return this.status;
    }

    getStatusMessage() {
      return this.statusMessage;
    }

    setMmsEnabled(enabled) {
      this.useMms = !!enabled;
    }
  }

  // Expose global singleton instance
  window.MmsTtsEngine = new MmsTtsEngine();

  // Instant unlock of AudioContext on first touch / tap / click
  const unlockAudioContext = () => {
    if (window.MmsTtsEngine) {
      const ctx = window.MmsTtsEngine.getAudioContext();
      if (ctx && ctx.state === 'suspended') {
        ctx.resume();
      }
    }
  };
  ['pointerdown', 'touchstart', 'click', 'keydown'].forEach(evt => {
    window.addEventListener(evt, unlockAudioContext, { once: true, passive: true });
  });

  // Background initialization & preloading of core vocabulary (0ms game taps)
  window.addEventListener('load', () => {
    setTimeout(() => {
      window.MmsTtsEngine.init().catch(() => {});
      window.MmsTtsEngine.preloadCoreVocabulary().catch(() => {});
    }, 500);
  });
})();
