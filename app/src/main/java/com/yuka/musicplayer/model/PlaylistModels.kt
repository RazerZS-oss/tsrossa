package com.yuka.musicplayer.model

import java.util.UUID

data class Playlist(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val trackPaths: List<String> = emptyList(),
    val createdAt: Long = System.currentTimeMillis()
)
