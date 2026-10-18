package com.yuka.musicplayer.model

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.ui.graphics.Color
import java.io.File

enum class ViewState { LIBRARY, PLAYLIST, TRACK, SETTINGS }

enum class PlaybackSource { LIBRARY, PLAYLIST }

enum class RepeatMode { OFF, ALL, ONE }

enum class SortField(val displayName: String) {
    TITLE("Title"),
    ALBUM("Album"),
    ARTIST("Artist"),
    ALBUM_ARTIST("Album Artist"),
    GENRE("Genre"),
    TRACK_NUMBER("Track Number"),
    DURATION("Duration"),
    YEAR("Year"),
    COMPOSER("Composer"),
    DATE_ADDED("Date Added"),
    DATE_MODIFIED("Date Modified")
}

enum class SortOrder(val displayName: String) {
    ASCENDING("Ascending"),
    DESCENDING("Descending")
}

fun sortScannedItemsByField(
    items: List<com.yuka.musicplayer.model.ScannedMusicItem>,
    field: SortField,
    order: SortOrder = SortOrder.ASCENDING
): List<com.yuka.musicplayer.model.ScannedMusicItem> {
    val comparator = when (field) {
        SortField.TITLE -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.title.lowercase() }
        SortField.ALBUM -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.album.lowercase() }
        SortField.ARTIST -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.artist.lowercase() }
        SortField.ALBUM_ARTIST -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.albumArtist.lowercase() }
        SortField.GENRE -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.genre.lowercase() }
        SortField.TRACK_NUMBER -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.trackNumber }
        SortField.DURATION -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.durationMs }
        SortField.YEAR -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.year }
        SortField.COMPOSER -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.composer.lowercase() }
        SortField.DATE_ADDED -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.dateAdded }
        SortField.DATE_MODIFIED -> compareBy<com.yuka.musicplayer.model.ScannedMusicItem> { it.dateModified }
    }
    return if (order == SortOrder.ASCENDING) {
        items.sortedWith(comparator)
    } else {
        items.sortedWith(comparator.reversed())
    }
}

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
    val isMqa: Boolean = false,
    val albumArtist: String = "",
    val genre: String = "",
    val trackNumber: String = "",
    val composer: String = ""
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
