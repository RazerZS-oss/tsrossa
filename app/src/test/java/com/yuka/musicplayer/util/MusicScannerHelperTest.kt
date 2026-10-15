package com.yuka.musicplayer.util

import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

class MusicScannerHelperTest {

    @get:Rule
    val tempFolder = TemporaryFolder()

    @Test
    fun testScannerClassifiesSupportedAndUnsupportedAudioFiles() {
        val root = tempFolder.newFolder("MusicTest")
        val artistDir = File(root, "Artist A/Album 1").apply { mkdirs() }
        val flacFile = File(artistDir, "song1.flac").apply { createNewFile() }
        val wavFile = File(artistDir, "song2.wav").apply { createNewFile() }
        val mp3File = File(artistDir, "song3.mp3").apply { createNewFile() }
        val m4aFile = File(artistDir, "song4.m4a").apply { createNewFile() }
        val imageFile = File(artistDir, "cover.jpg").apply { createNewFile() }
        val hiddenDir = File(root, ".thumbnails").apply { mkdirs() }
        File(hiddenDir, "thumb.flac").apply { createNewFile() }

        val scanned = MusicScannerHelper.scanMusicDirectory(root)

        assertEquals(4, scanned.size) // 2 supported + 2 unsupported audio
        val flacItem = scanned.first { it.file.name == "song1.flac" }
        assertTrue(flacItem.isSupported)
        assertEquals("FLAC", flacItem.formatLabel)
        assertEquals("Artist A / Album 1", flacItem.breadcrumb)

        val mp3Item = scanned.first { it.file.name == "song3.mp3" }
        assertFalse(mp3Item.isSupported)
        assertEquals("MP3", mp3Item.formatLabel)

        // Verify playable extraction ignores MP3/M4A
        val playable = MusicScannerHelper.filterPlayableFiles(scanned)
        assertEquals(2, playable.size)
        assertTrue(playable.contains(flacFile))
        assertTrue(playable.contains(wavFile))
        assertFalse(playable.contains(mp3File))
        assertFalse(playable.contains(imageFile))
    }

    @Test
    fun testBreadcrumbExtraction() {
        val root = File("/sdcard/Music")
        val track = File("/sdcard/Music/Deep/Nested/Folder/track.flac")
        val breadcrumb = MusicScannerHelper.getRelativeBreadcrumb(track, root)
        assertEquals("Deep / Nested / Folder", breadcrumb)

        val rootTrack = File("/sdcard/Music/root_track.flac")
        val rootBreadcrumb = MusicScannerHelper.getRelativeBreadcrumb(rootTrack, root)
        assertEquals("", rootBreadcrumb)
    }

    @Test
    fun testNomediaFolderIsIgnored() {
        val root = tempFolder.newFolder("MusicNomediaTest")
        val normalDir = File(root, "Normal").apply { mkdirs() }
        File(normalDir, "song1.flac").apply { createNewFile() }

        val ignoredDir = File(root, "Ignored").apply { mkdirs() }
        File(ignoredDir, ".nomedia").apply { createNewFile() }
        File(ignoredDir, "secret.flac").apply { createNewFile() }

        val scanned = MusicScannerHelper.scanMusicDirectory(root)
        assertEquals(1, scanned.size)
        assertEquals("song1.flac", scanned[0].file.name)
    }

    @Test
    fun testScannerHandlesMixedCaseExtensions() {
        val root = tempFolder.newFolder("MixedCaseTest")
        File(root, "TEST1.FLAC").apply { createNewFile() }
        File(root, "TEST2.Wav").apply { createNewFile() }
        File(root, "TEST3.Mp3").apply { createNewFile() }

        val scanned = MusicScannerHelper.scanMusicDirectory(root)
        assertEquals(3, scanned.size)
        assertTrue(scanned.first { it.file.name == "TEST1.FLAC" }.isSupported)
        assertTrue(scanned.first { it.file.name == "TEST2.Wav" }.isSupported)
        assertFalse(scanned.first { it.file.name == "TEST3.Mp3" }.isSupported)
    }

    @Test
    fun testScannerHandlesRootWithTrailingSlashAndDeepNesting() {
        val root = tempFolder.newFolder("DeepTest")
        val deep = File(root, "Level1/Level2/Level3").apply { mkdirs() }
        File(deep, "deep.flac").apply { createNewFile() }

        val scanned = MusicScannerHelper.scanMusicDirectory(File(root.absolutePath + "/"))
        assertEquals(1, scanned.size)
        assertEquals("Level1 / Level2 / Level3", scanned[0].breadcrumb)
    }
}

