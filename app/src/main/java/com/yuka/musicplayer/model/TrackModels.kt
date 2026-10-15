package com.yuka.musicplayer.model

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.ui.graphics.Color
import java.io.File

enum class ViewState { LIBRARY, PLAYLIST, TRACK, SETTINGS }

enum class PlaybackSource { LIBRARY, PLAYLIST }

enum class RepeatMode { OFF, ALL, ONE }

enum class LibrarySortMode(val label: String, val shortLabel: String) {
    DATE_DESC("DATE (NEWEST)", "DATE ↓"),
    DATE_ASC("DATE (OLDEST)", "DATE ↑"),
    NAME_ASC("NAME (A-Z)", "A-Z"),
    NAME_DESC("NAME (Z-A)", "Z-A");

    fun next(): LibrarySortMode = when (this) {
        DATE_DESC -> DATE_ASC
        DATE_ASC -> NAME_ASC
        NAME_ASC -> NAME_DESC
        NAME_DESC -> DATE_DESC
    }
}

fun sortLibraryFiles(files: List<File>, mode: LibrarySortMode): List<File> {
    return when (mode) {
        LibrarySortMode.DATE_DESC -> files.sortedWith(compareBy<File>({ !it.isDirectory }).thenByDescending { it.lastModified() })
        LibrarySortMode.DATE_ASC -> files.sortedWith(compareBy<File>({ !it.isDirectory }).thenBy { it.lastModified() })
        LibrarySortMode.NAME_ASC -> files.sortedWith(compareBy<File>({ !it.isDirectory }).thenBy { it.name.lowercase() })
        LibrarySortMode.NAME_DESC -> files.sortedWith(compareBy<File>({ !it.isDirectory }).thenByDescending { it.name.lowercase() })
    }
}

fun sortScannedMusicItems(items: List<com.yuka.musicplayer.model.ScannedMusicItem>, mode: LibrarySortMode): List<com.yuka.musicplayer.model.ScannedMusicItem> {
    return when (mode) {
        LibrarySortMode.DATE_DESC -> items.sortedByDescending { it.file.lastModified() }
        LibrarySortMode.DATE_ASC -> items.sortedBy { it.file.lastModified() }
        LibrarySortMode.NAME_ASC -> items.sortedBy { it.file.name.lowercase() }
        LibrarySortMode.NAME_DESC -> items.sortedByDescending { it.file.name.lowercase() }
    }
}

data class AltSettingInfo(
    val interfaceNum: Int,
    val altSetting: Int,
    val subframeSize: Int
)

data class RefusedTrackEntry(
    val filename: String,
    val bitDepth: Int,
    val sampleRate: Int,
    val reason: String
)

data class TrackInfo(
    val file: File,
    val title: String,
    val artist: String,
    val album: String,
    val year: String,
    val durationSeconds: Double,
    val coverArt: Bitmap?,
    val dominantColor: Color,
    val isMqa: Boolean = false
) {
    val codec: String
        get() = when (file.extension.lowercase()) {
            "flac" -> "FLAC"
            "wav", "wave" -> "WAV"
            else -> file.extension.uppercase().ifEmpty { "AUDIO" }
        }

    val bitrateKbps: Int
        get() {
            val size = try { file.length() } catch (_: Exception) { 0L }
            return if (durationSeconds > 0 && size > 0) {
                ((size * 8.0) / (durationSeconds * 1000.0)).toInt()
            } else {
                0
            }
        }
}
