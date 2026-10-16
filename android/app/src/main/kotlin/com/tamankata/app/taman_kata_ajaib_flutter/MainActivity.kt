package com.tamankata.app.taman_kata_ajaib_flutter

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tamankata.app/audio"
    @Volatile private var isBgmPlaying = false
    private var bgmThread: Thread? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSfx" -> {
                    val sfxType = call.argument<String>("type") ?: "ding"
                    playProceduralSfx(sfxType)
                    result.success(true)
                }
                "startBgm" -> {
                    startBgm()
                    result.success(true)
                }
                "stopBgm" -> {
                    stopBgm()
                    result.success(true)
                }
                "playAsset" -> {
                    result.success(false)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playProceduralSfx(sfxType: String) {
        thread(start = true, isDaemon = true) {
            try {
                val sampleRate = 22050
                val samples: ShortArray = when (sfxType) {
                    "pop" -> generatePop(sampleRate)
                    "ding" -> generateDing(sampleRate)
                    "star" -> generateStar(sampleRate)
                    "tuut" -> generateTuut(sampleRate)
                    "whoosh" -> generateWhoosh(sampleRate)
                    "twinkle" -> generateTwinkle(sampleRate)
                    "boing" -> generateBoing(sampleRate)
                    "fanfare" -> generateFanfare(sampleRate)
                    else -> generateDing(sampleRate)
                }
                playPcm(samples, sampleRate)
            } catch (_: Exception) {}
        }
    }

    private fun startBgm() {
        if (isBgmPlaying) return
        isBgmPlaying = true
        bgmThread = thread(start = true, isDaemon = true) {
            val sampleRate = 22050
            val melody = doubleArrayOf(523.25, 659.25, 783.99, 880.0, 783.99, 659.25, 587.33, 523.25)
            try {
                while (isBgmPlaying) {
                    for (freq in melody) {
                        if (!isBgmPlaying) break
                        val samples = generateTone(freq, 0.28, 0.12, sampleRate)
                        playPcm(samples, sampleRate)
                        Thread.sleep(70)
                    }
                    if (!isBgmPlaying) break
                    Thread.sleep(400)
                }
            } catch (_: InterruptedException) {
            } catch (_: Exception) {}
        }
    }

    private fun stopBgm() {
        isBgmPlaying = false
        try {
            bgmThread?.interrupt()
            bgmThread = null
        } catch (_: Exception) {}
    }

    private fun playPcm(samples: ShortArray, sampleRate: Int) {
        val minBuf = AudioTrack.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufSize = maxOf(minBuf, samples.size * 2)
        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(bufSize)
            .setTransferMode(AudioTrack.MODE_STATIC)
            .build()

        track.write(samples, 0, samples.size)
        track.play()
        val durationMs = (samples.size * 1000L / sampleRate) + 20L
        Thread.sleep(durationMs)
        track.stop()
        track.release()
    }

    private fun generateTone(freq: Double, durationSec: Double, volume: Double, sampleRate: Int): ShortArray {
        val numSamples = (durationSec * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            val envelope = exp(-7.0 * t / durationSec)
            val sample = sin(2.0 * PI * freq * t) * envelope * volume * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generatePop(sampleRate: Int): ShortArray {
        val duration = 0.08
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val progress = i.toDouble() / numSamples
            val freq = 650.0 - 550.0 * progress
            val amp = (1.0 - progress) * 0.7
            phase += 2.0 * PI * freq / sampleRate
            val sample = sin(phase) * amp * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateDing(sampleRate: Int): ShortArray {
        val duration = 0.35
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            val env = exp(-8.0 * t)
            val sample = (sin(2.0 * PI * 1046.5 * t) * 0.6 + sin(2.0 * PI * 2093.0 * t) * 0.2) * env * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateStar(sampleRate: Int): ShortArray {
        val notes = doubleArrayOf(523.25, 659.25, 783.99, 1046.5)
        val noteDur = 0.08
        val totalDur = noteDur * notes.size + 0.1
        val numSamples = (totalDur * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            var sum = 0.0
            for ((idx, freq) in notes.withIndex()) {
                val start = idx * noteDur
                if (t >= start) {
                    val dt = t - start
                    val env = exp(-9.0 * dt)
                    sum += sin(2.0 * PI * freq * dt) * env * 0.45
                }
            }
            buffer[i] = (sum * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateTuut(sampleRate: Int): ShortArray {
        val duration = 0.42
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            val env = if (t < 0.04) t / 0.04 else (1.0 - (t - 0.04) / (duration - 0.04))
            val s1 = sin(2.0 * PI * 440.0 * t)
            val s2 = sin(2.0 * PI * 554.37 * t)
            val sample = (s1 * 0.4 + s2 * 0.4) * env * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateWhoosh(sampleRate: Int): ShortArray {
        val duration = 0.16
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val progress = i.toDouble() / numSamples
            val freq = 220.0 + 400.0 * progress
            val amp = sin(PI * progress) * 0.5
            phase += 2.0 * PI * freq / sampleRate
            val sample = sin(phase) * amp * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateTwinkle(sampleRate: Int): ShortArray {
        val notes = doubleArrayOf(1318.5, 1568.0, 2093.0)
        val noteDur = 0.08
        val totalDur = noteDur * notes.size + 0.1
        val numSamples = (totalDur * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            var sum = 0.0
            for ((idx, freq) in notes.withIndex()) {
                val start = idx * noteDur
                if (t >= start) {
                    val dt = t - start
                    val env = exp(-10.0 * dt)
                    sum += sin(2.0 * PI * freq * dt) * env * 0.35
                }
            }
            buffer[i] = (sum * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateBoing(sampleRate: Int): ShortArray {
        val duration = 0.28
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            val progress = t / duration
            val freq = 160.0 + 220.0 * progress + sin(35.0 * PI * t) * 30.0
            val amp = exp(-5.0 * progress) * 0.6
            phase += 2.0 * PI * freq / sampleRate
            val sample = sin(phase) * amp * 32767.0
            buffer[i] = sample.toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }

    private fun generateFanfare(sampleRate: Int): ShortArray {
        val notes = doubleArrayOf(523.25, 659.25, 783.99, 1046.5)
        val duration = 0.65
        val numSamples = (duration * sampleRate).toInt()
        val buffer = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            val t = i.toDouble() / sampleRate
            var sum = 0.0
            for ((idx, freq) in notes.withIndex()) {
                val start = idx * 0.1
                if (t >= start) {
                    val dt = t - start
                    val env = exp(-4.0 * dt)
                    sum += (sin(2.0 * PI * freq * dt) + 0.3 * sin(4.0 * PI * freq * dt)) * env * 0.25
                }
            }
            buffer[i] = (sum * 32767.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        return buffer
    }
}
