package com.yuka.musicplayer.util

import com.yuka.musicplayer.model.ScannedMusicItem
import java.io.File

object MusicScannerHelper {

    val SUPPORTED_EXTENSIONS = setOf("flac", "wav", "wave")
    val KNOWN_UNSUPPORTED_AUDIO_EXTENSIONS = setOf(
        "mp3", "m4a", "aac", "ogg", "opus", "dsf", "dff", "wma", "alac", "aiff"
    )

    fun isSupportedAudioFile(file: File): Boolean {
        if (!file.isFile) return false
        return file.extension.lowercase() in SUPPORTED_EXTENSIONS
    }

    fun isAudioFile(file: File): Boolean {
        if (!file.isFile) return false
        val ext = file.extension.lowercase()
        return ext in SUPPORTED_EXTENSIONS || ext in KNOWN_UNSUPPORTED_AUDIO_EXTENSIONS
    }

    fun scanMusicDirectory(rootDir: File): List<ScannedMusicItem> {
        if (!rootDir.exists() || !rootDir.isDirectory) return emptyList()

        val results = mutableListOf<ScannedMusicItem>()
        rootDir.walkTopDown()
            .onEnter { dir ->
                if (dir.name.startsWith(".") && dir != rootDir) {
                    false
                } else {
                    !File(dir, ".nomedia").exists()
                }
            }
            .forEach { file ->
                if (isAudioFile(file)) {
                    val ext = file.extension.uppercase()
                    val supported = isSupportedAudioFile(file)
                    val breadcrumb = getRelativeBreadcrumb(file, rootDir)
                    val tags = com.yuka.musicplayer.metadata.AudioTagReader.readTags(file)
                    results.add(
                        ScannedMusicItem(
                            file = file,
                            isSupported = supported,
                            formatLabel = ext,
                            breadcrumb = breadcrumb,
                            title = tags.title,
                            artist = tags.artist,
                            album = tags.album,
                            albumArtist = tags.albumArtist,
                            genre = tags.genre,
                            trackNumber = tags.trackNumber,
                            durationMs = tags.durationMs,
                            year = tags.year,
                            composer = tags.composer,
                            dateAdded = file.lastModified(),
                            dateModified = file.lastModified()
                        )
                    )
                }
            }
        return results
    }

    fun filterPlayableFiles(items: List<ScannedMusicItem>): List<File> {
        return items.filter { it.isSupported }.map { it.file }
    }

    fun getRelativeBreadcrumb(file: File, rootDir: File): String {
        val parent = file.parentFile ?: return ""
        val rootPath = rootDir.absolutePath.trimEnd('/', '\\')
        val parentPath = parent.absolutePath.trimEnd('/', '\\')

        if (parentPath == rootPath) {
            return ""
        }
        if (!parentPath.startsWith("$rootPath/") && !parentPath.startsWith("$rootPath\\")) {
            return ""
        }

        val relative = parentPath.removePrefix(rootPath).trim('/', '\\')
        return relative.replace("/", " / ").replace("\\", " / ")
    }
}
