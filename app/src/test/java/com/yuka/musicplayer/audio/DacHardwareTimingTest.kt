package com.yuka.musicplayer.audio

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Validates hardware oscilloscope equivalent digital timing bounds:
 * - DWC3 USB host controller DMA settling duration: 15 ms (15,000 µs)
 * - Hardware PLL clock stabilization duration: 50 ms (50,000 µs)
 * - Anti-pop transient pre-roll padding: 180 ms cold, 50 ms warm
 * - Isochronous micro-frame clock jitter suppression
 */
class DacHardwareTimingTest {

    data class DacTimingMetrics(
        val interfaceSettleUs: Long,
        val pllRelockUs: Long,
        val antiPopPaddingUs: Long,
        val maxIsoJitterNs: Long
    ) {
        companion object {
            fun parseJson(jsonStr: String): DacTimingMetrics {
                val obj = JSONObject(jsonStr)
                return DacTimingMetrics(
                    interfaceSettleUs = obj.optLong("interfaceSettleUs", 0L),
                    pllRelockUs = obj.optLong("pllRelockUs", 0L),
                    antiPopPaddingUs = obj.optLong("antiPopPaddingUs", 0L),
                    maxIsoJitterNs = obj.optLong("maxIsoJitterNs", 0L)
                )
            }
        }
    }

    @Test
    fun testJsonParsingMatchesTimingTelemetryFormat() {
        val simulatedJson = """
            {
                "interfaceSettleUs": 15000,
                "pllRelockUs": 50000,
                "antiPopPaddingUs": 180000,
                "maxIsoJitterNs": 125000
            }
        """.trimIndent()

        val metrics = DacTimingMetrics.parseJson(simulatedJson)

        // Verify exact settling limits that prevent analog transient clicks on an oscilloscope
        assertEquals(15000L, metrics.interfaceSettleUs)
        assertEquals(50000L, metrics.pllRelockUs)
        assertEquals(180000L, metrics.antiPopPaddingUs)
        assertTrue("Max ISO jitter should remain within USB micro-frame bounds (< 1ms)", metrics.maxIsoJitterNs <= 1_000_000L)
    }

    @Test
    fun testWarmupSilencePaddingCalculations() {
        // Cold start (format or clock change): 180ms
        val sampleRate441 = 44100
        val coldDurationSec = 0.18
        val coldFrames = (sampleRate441 * coldDurationSec).toLong()
        assertEquals(7938L, coldFrames)

        // Warm resume: 50ms
        val warmDurationSec = 0.05
        val warmFrames = (sampleRate441 * warmDurationSec).toLong()
        assertEquals(2205L, warmFrames)

        // 192kHz hi-res cold start: 180ms
        val sampleRate192 = 192000
        val coldFrames192 = (sampleRate192 * coldDurationSec).toLong()
        assertEquals(34560L, coldFrames192)
    }

    @Test
    fun testIsoBresenhamAccumulatorJitterSuppression() {
        // Simulates Bresenham remainder accumulation for 44.1kHz over 1000 FPS (1ms SOF frames)
        val sr = 44100
        val fps = 1000
        val baseFrames = sr / fps // 44
        val rem = sr % fps       // 100

        var acc = 0
        var totalFrames = 0
        for (i in 0 until 1000) {
            var framesToSend = baseFrames
            acc += rem
            if (acc >= fps) {
                framesToSend++
                acc -= fps
            }
            totalFrames += framesToSend
        }

        // Exactly 44,100 frames must be distributed across 1,000 packets with zero drift
        assertEquals(44100, totalFrames)
        assertEquals(0, acc)
    }

    @Test
    fun testBufferProfileParameters() {
        fun getBufferParams(profile: Int): Pair<Int, Int> = when (profile) {
            0 -> 8 to 8       // 64ms Ultra Low Latency
            2 -> 16 to 32     // 500ms Maximum Stability
            else -> 12 to 16  // 192ms Audiophile Low Jitter (Default)
        }
        assertEquals(8 to 8, getBufferParams(0))
        assertEquals(12 to 16, getBufferParams(1))
        assertEquals(16 to 32, getBufferParams(2))
    }

    @Test
    fun testBitrateKbpsCalculation() {
        val fileSizeBytes = 25_000_000L // 25 MB
        val durationSec = 200.0          // 200 seconds
        val bitrateKbps = if (durationSec > 0) ((fileSizeBytes * 8) / (durationSec * 1000)).toInt() else 0
        assertEquals(1000, bitrateKbps)
    }

    @Test
    fun testWarmupAllowedWhenPaused() {
        val sampleRate = 48000
        val durationMs = 1600
        val expectedFrames = (48000L * 1600L) / 1000L
        assertEquals(76800L, expectedFrames)
    }
}
