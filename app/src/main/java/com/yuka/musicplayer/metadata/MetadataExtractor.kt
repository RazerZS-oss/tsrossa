package com.yuka.musicplayer.metadata

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import androidx.compose.ui.graphics.Color
import androidx.palette.graphics.Palette
import com.yuka.musicplayer.model.TrackInfo
import java.io.File

// Ekstrak metadata & Palette Warna
fun extractMetadata(file: File): TrackInfo {
    val retriever = MediaMetadataRetriever()
    var title = file.nameWithoutExtension
    var artist = "Unknown Artist"
    var album = "Unknown Album"
    var year = "----"
    var durationSec = 0.0
    var bitmap: Bitmap? = null
    var dominantColor = Color(0xFF00FF00) // Default Terminal Green

    try {
        retriever.setDataSource(file.absolutePath)
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)?.let { title = it }
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)?.let { artist = it }
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)?.let { album = it }
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)?.let { year = it }
        
        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull()?.let { ms ->
            durationSec = ms / 1000.0
        }

        val artBytes = retriever.embeddedPicture
        if (artBytes != null) {
            bitmap = BitmapFactory.decodeByteArray(artBytes, 0, artBytes.size)
            if (bitmap != null) {
                // Ekstraksi warna adaptif: Palette Swatches + HSV Scoring dari algoritma Qt
                try {
                    val palette = Palette.from(bitmap).generate()
                    val swatch = palette.vibrantSwatch 
                        ?: palette.dominantSwatch 
                        ?: palette.lightVibrantSwatch 
                        ?: palette.darkVibrantSwatch 
                        ?: palette.mutedSwatch
                    if (swatch != null) {
                        dominantColor = Color(swatch.rgb)
                    } else {
                        // Algoritma Qt extractDominantColor (Downscale ke 32x32 & HSV score: s * v)
                        val scaled = Bitmap.createScaledBitmap(bitmap, 32, 32, false)
                        var bestScore = 0L
                        var bestColorInt = 0xFF00FF00.toInt()
                        val hsv = FloatArray(3)
                        for (y in 0 until scaled.height) {
                            for (x in 0 until scaled.width) {
                                val pixel = scaled.getPixel(x, y)
                                android.graphics.Color.colorToHSV(pixel, hsv)
                                val s = (hsv[1] * 100).toInt()
                                val v = (hsv[2] * 100).toInt()
                                if (s > 35 && v > 35 && v < 245) {
                                    val score = s.toLong() * v
                                    if (score > bestScore) {
                                        bestScore = score
                                        bestColorInt = pixel
                                    }
                                }
                            }
                        }
                        if (bestScore > 0) {
                            dominantColor = Color(bestColorInt)
                        } else {
                            dominantColor = Color(palette.getDominantColor(0xFF00FF00.toInt()))
                        }
                    }
                } catch (e: Exception) {
                    // Fallback
                }
            }
        }
    } catch (e: Exception) {
        // Abaikan jika error membaca metadata
    } finally {
        retriever.release()
    }

    // MQA Detection: check filename conventions and Vorbis Comment / ID3 header
    val isMqa = detectMqa(file)

    return TrackInfo(file, title, artist, album, year, durationSec, bitmap, dominantColor, isMqa)
}

/**
 * Checks for MQA indicators in filename or raw file header bytes.
 */
fun detectMqa(file: File): Boolean {
    val nameLower = file.name.lowercase()
    if (nameLower.contains("[mqa]") || nameLower.contains(".mqa.") || nameLower.contains("mqa.flac")) {
        return true
    }
    // Inspect first 8KB of FLAC header for Vorbis Comment "MQAENCODER" or "MQA" tag
    if (file.extension.equals("flac", ignoreCase = true) && file.exists() && file.length() > 64) {
        try {
            file.inputStream().use { input ->
                val header = ByteArray(8192)
                val read = input.read(header)
                if (read > 0) {
                    val headerStr = String(header, 0, read, Charsets.ISO_8859_1)
                    if (headerStr.contains("MQAENCODER", ignoreCase = true) ||
                        headerStr.contains("MQA", ignoreCase = false) && headerStr.contains("ORIGINALSAMPLERATE", ignoreCase = true)) {
                        return true
                    }
                }
            }
        } catch (_: Exception) {
            // Non-critical check failure fallback
        }
    }
    return false
}
