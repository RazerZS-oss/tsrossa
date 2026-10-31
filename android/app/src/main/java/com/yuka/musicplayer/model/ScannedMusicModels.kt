package com.yuka.musicplayer.model

import java.io.File

data class ScannedMusicItem(
    val file: File,
    val isSupported: Boolean,
    val formatLabel: String,
    val breadcrumb: String,
    val title: String = file.nameWithoutExtension,
    val artist: String = "Unknown Artist",
    val album: String = "Unknown Album",
    val albumArtist: String = "",
    val genre: String = "",
    val trackNumber: Int = 0,
    val durationMs: Long = 0L,
    val year: Int = 0,
    val composer: String = "",
    val dateAdded: Long = file.lastModified(),
    val dateModified: Long = file.lastModified()
)
