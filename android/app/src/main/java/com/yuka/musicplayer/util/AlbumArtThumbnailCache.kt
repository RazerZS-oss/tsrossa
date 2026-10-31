package com.yuka.musicplayer.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.util.LruCache
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerLow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest

object AlbumArtThumbnailCache {
    private val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
    // Allocate ~1/16th of available memory for thumbnails (usually 16MB - 32MB)
    private val cacheSize = (maxMemory / 16).coerceIn(8 * 1024, 32 * 1024)

    // Thread-safe JVM-compatible LRU map for bitmaps bounded by memory KB
    private class BitmapLruCache(private val maxKb: Int) {
        private var currentKb = 0
        private val map = LinkedHashMap<String, Bitmap>(64, 0.75f, true)

        @Synchronized
        fun get(key: String): Bitmap? = map[key]

        @Synchronized
        fun put(key: String, value: Bitmap) {
            val sizeKb = try { value.byteCount / 1024 } catch (_: Throwable) { 16 }
            map.remove(key)?.let { old ->
                currentKb -= try { old.byteCount / 1024 } catch (_: Throwable) { 16 }
            }
            map[key] = value
            currentKb += sizeKb
            val it = map.entries.iterator()
            while (currentKb > maxKb && it.hasNext()) {
                val entry = it.next()
                currentKb -= try { entry.value.byteCount / 1024 } catch (_: Throwable) { 16 }
                it.remove()
            }
        }

        @Synchronized
        fun evictAll() {
            map.clear()
            currentKb = 0
        }
    }

    private class SimpleLruCache<K, V>(private val maxEntries: Int) {
        private val map = object : LinkedHashMap<K, V>(maxEntries, 0.75f, true) {
            override fun removeEldestEntry(eldest: MutableMap.MutableEntry<K, V>?): Boolean {
                return size > maxEntries
            }
        }
        @Synchronized fun get(key: K): V? = map[key]
        @Synchronized fun put(key: K, value: V) { map[key] = value }
        @Synchronized fun evictAll() { map.clear() }
    }

    private val lruCache = BitmapLruCache(cacheSize)
    private val negativeCache = SimpleLruCache<String, Boolean>(2048)
    private val colorCache = SimpleLruCache<String, Color>(1024)

    @Volatile
    private var diskCacheDir: File? = null

    fun init(context: Context) {
        if (diskCacheDir == null) {
            synchronized(this) {
                if (diskCacheDir == null) {
                    val dir = File(context.cacheDir, "album_art_cache")
                    if (!dir.exists()) {
                        dir.mkdirs()
                    }
                    // Purge legacy color cache files so new color extraction algorithm takes effect
                    try {
                        dir.listFiles { _, name ->
                            name.endsWith("_color.txt") ||
                            name.endsWith("_color_v2.txt") ||
                            name.endsWith("_color_v3.txt")
                        }?.forEach { f ->
                            f.delete()
                        }
                    } catch (_: Throwable) {}
                    diskCacheDir = dir
                }
            }
        }
    }

    fun get(filePath: String): Bitmap? = lruCache.get(filePath)

    fun put(filePath: String, bitmap: Bitmap) {
        lruCache.put(filePath, bitmap)
    }

    fun getCachedDominantColor(filePath: String, lastModified: Long): Color? {
        val key = cacheKey(filePath, lastModified)
        synchronized(colorCache) {
            val ramColor = colorCache.get(key)
            if (ramColor != null && ramColor.alpha > 0.5f) return ramColor
        }
        val dir = diskCacheDir ?: return null
        val colorFile = File(dir, "${key}_color_v4.txt")
        if (colorFile.exists()) {
            try {
                val hex = colorFile.readText().trim()
                if (hex.equals("#00000000", ignoreCase = true) || hex.equals("#000000", ignoreCase = true)) {
                    colorFile.delete()
                    return null
                }
                val parsed = Color(android.graphics.Color.parseColor(hex))
                if (parsed.alpha < 0.5f) {
                    colorFile.delete()
                    return null
                }
                synchronized(colorCache) {
                    colorCache.put(key, parsed)
                }
                return parsed
            } catch (_: Throwable) {
                colorFile.delete()
            }
        }
        return null
    }

    fun putCachedDominantColor(filePath: String, lastModified: Long, color: Color) {
        if (color.alpha < 0.5f) return
        val key = cacheKey(filePath, lastModified)
        synchronized(colorCache) {
            colorCache.put(key, color)
        }
        val dir = diskCacheDir ?: return
        try {
            val colorFile = File(dir, "${key}_color_v4.txt")
            val hex = String.format("#%08X", color.toArgb())
            colorFile.writeText(hex)
        } catch (_: Throwable) {}
    }

    private fun isNegative(filePath: String): Boolean {
        synchronized(negativeCache) {
            return negativeCache.get(filePath) == true
        }
    }

    private fun markNegative(filePath: String) {
        synchronized(negativeCache) {
            negativeCache.put(filePath, true)
        }
    }

    fun cacheKey(filePath: String, lastModified: Long): String {
        val raw = "$filePath:$lastModified"
        return try {
            val md = MessageDigest.getInstance("MD5")
            val digest = md.digest(raw.toByteArray(Charsets.UTF_8))
            digest.joinToString("") { "%02x".format(it) }
        } catch (_: Throwable) {
            (raw.hashCode().toLong() and 0xFFFFFFFFL).toString(16)
        }
    }

    suspend fun loadThumbnail(filePath: String, targetSizePx: Int = 144): Bitmap? = withContext(Dispatchers.IO) {
        if (filePath.isEmpty() || isNegative(filePath)) return@withContext null

        lruCache.get(filePath)?.let { return@withContext it }

        val file = File(filePath)
        if (!file.exists() || !file.canRead()) {
            markNegative(filePath)
            return@withContext null
        }

        val key = cacheKey(filePath, file.lastModified())
        val dir = diskCacheDir

        // Check persistent disk cache
        if (dir != null) {
            val noArtMarker = File(dir, "${key}.noart")
            if (noArtMarker.exists()) {
                markNegative(filePath)
                return@withContext null
            }

            val diskThumb = File(dir, "${key}_thumb.jpg")
            if (diskThumb.exists() && diskThumb.length() > 0) {
                try {
                    val decoded = BitmapFactory.decodeFile(diskThumb.absolutePath)
                    if (decoded != null) {
                        lruCache.put(filePath, decoded)
                        return@withContext decoded
                    }
                } catch (_: Throwable) {}
            }
        }

        // Cache miss: Extract from audio file embedded picture
        var retriever: MediaMetadataRetriever? = null
        try {
            retriever = MediaMetadataRetriever()
            retriever.setDataSource(filePath)
            val picture = retriever.embeddedPicture
            if (picture == null || picture.isEmpty() || picture.size > 16 * 1024 * 1024) {
                markNegative(filePath)
                if (dir != null) {
                    try { File(dir, "${key}.noart").createNewFile() } catch (_: Throwable) {}
                }
                return@withContext null
            }

            // Decode bounds
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeByteArray(picture, 0, picture.size, options)

            // Compute inSampleSize
            var sampleSize = 1
            val (width, height) = options.outWidth to options.outHeight
            if (width > targetSizePx || height > targetSizePx) {
                val halfWidth = width / 2
                val halfHeight = height / 2
                while ((halfWidth / sampleSize) >= targetSizePx && (halfHeight / sampleSize) >= targetSizePx) {
                    sampleSize *= 2
                }
            }

            options.inJustDecodeBounds = false
            options.inSampleSize = sampleSize.coerceAtLeast(1)
            options.inPreferredConfig = Bitmap.Config.RGB_565 // Fast and 50% memory saving

            val decoded = BitmapFactory.decodeByteArray(picture, 0, picture.size, options)
            if (decoded != null) {
                lruCache.put(filePath, decoded)
                // Persist to disk cache
                if (dir != null) {
                    try {
                        val tmp = File(dir, "${key}_thumb.tmp")
                        FileOutputStream(tmp).use { fos ->
                            decoded.compress(Bitmap.CompressFormat.JPEG, 85, fos)
                        }
                        tmp.renameTo(File(dir, "${key}_thumb.jpg"))
                    } catch (_: Throwable) {}
                }
                return@withContext decoded
            } else {
                markNegative(filePath)
                return@withContext null
            }
        } catch (_: Throwable) {
            markNegative(filePath)
            null
        } finally {
            try {
                retriever?.release()
            } catch (_: Throwable) {}
        }
    }

    fun clearCache() {
        lruCache.evictAll()
        synchronized(negativeCache) { negativeCache.evictAll() }
        synchronized(colorCache) { colorCache.evictAll() }
        diskCacheDir?.let { dir ->
            try {
                dir.listFiles()?.forEach { it.delete() }
            } catch (_: Throwable) {}
        }
    }
}

@Composable
fun TrackAlbumThumbnail(
    filePath: String,
    isCurrentTrack: Boolean,
    currentTrackArt: Bitmap?,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 12.dp,
    fallback: @Composable () -> Unit
) {
    // If playing track and art is already in memory from player manager
    if (isCurrentTrack && currentTrackArt != null) {
        Image(
            bitmap = currentTrackArt.asImageBitmap(),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = modifier
                .clip(RoundedCornerShape(cornerRadius))
                .background(m3SurfaceContainerLow())
        )
        return
    }

    val cached = remember(filePath) { AlbumArtThumbnailCache.get(filePath) }
    var loadedBitmap by remember(filePath) { mutableStateOf(cached) }

    if (loadedBitmap == null && filePath.isNotEmpty()) {
        LaunchedEffect(filePath) {
            // Debounce tiny 40ms to avoid work during rapid list flinging
            delay(40)
            val bmp = AlbumArtThumbnailCache.loadThumbnail(filePath, 144)
            if (bmp != null) {
                loadedBitmap = bmp
            }
        }
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(m3SurfaceContainerLow()),
        contentAlignment = Alignment.Center
    ) {
        Crossfade(targetState = loadedBitmap, animationSpec = tween(180), label = "artCrossfade") { bmp ->
            if (bmp != null) {
                Image(
                    bitmap = bmp.asImageBitmap(),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                fallback()
            }
        }
    }
}
