package com.yuka.musicplayer.util

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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerLow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import java.io.File

object AlbumArtThumbnailCache {
    private val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
    // Allocate ~1/16th of available memory for thumbnails (usually 16MB - 32MB)
    private val cacheSize = (maxMemory / 16).coerceIn(8 * 1024, 32 * 1024)

    private val lruCache = object : LruCache<String, Bitmap>(cacheSize) {
        override fun sizeOf(key: String, value: Bitmap): Int {
            return value.byteCount / 1024
        }
    }

    // Negative cache bounded to 2048 entries to prevent unbounded RAM growth
    private val negativeCache = LruCache<String, Boolean>(2048)

    fun get(filePath: String): Bitmap? = lruCache.get(filePath)

    fun put(filePath: String, bitmap: Bitmap) {
        lruCache.put(filePath, bitmap)
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

    suspend fun loadThumbnail(filePath: String, targetSizePx: Int = 144): Bitmap? = withContext(Dispatchers.IO) {
        if (filePath.isEmpty() || isNegative(filePath)) return@withContext null

        lruCache.get(filePath)?.let { return@withContext it }

        val file = File(filePath)
        if (!file.exists() || !file.canRead()) {
            markNegative(filePath)
            return@withContext null
        }

        var retriever: MediaMetadataRetriever? = null
        try {
            retriever = MediaMetadataRetriever()
            retriever.setDataSource(filePath)
            val picture = retriever.embeddedPicture
            if (picture == null || picture.isEmpty()) {
                markNegative(filePath)
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
