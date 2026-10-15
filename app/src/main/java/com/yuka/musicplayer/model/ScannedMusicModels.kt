package com.yuka.musicplayer.model

import java.io.File

data class ScannedMusicItem(
    val file: File,
    val isSupported: Boolean,
    val formatLabel: String,
    val breadcrumb: String
)
