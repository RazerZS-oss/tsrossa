package com.yuka.musicplayer.ui.views

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.dp
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.M3Surface
import com.yuka.musicplayer.ui.theme.M3SurfaceContainerLowest

@Composable
fun AppBackgroundContainer(
    bgMode: String,
    wallpaperBitmap: ImageBitmap?,
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    val accent = LocalAccentColor.current
    Box(modifier = modifier.fillMaxSize()) {
        when {
            bgMode == "BLUR" && wallpaperBitmap != null -> {
                Image(
                    bitmap = wallpaperBitmap,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize().blur(28.dp)
                )
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.72f))
                )
            }
            bgMode == "SIGNATURE" -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .drawWithCache {
                            val radialGlow = Brush.radialGradient(
                                colors = listOf(accent.copy(alpha = 0.07f), Color.Transparent),
                                center = Offset(size.width * 0.5f, size.height * 0.22f),
                                radius = size.width * 0.95f
                            )
                            val vertGradient = Brush.verticalGradient(
                                colors = listOf(
                                    M3SurfaceContainerLowest,
                                    M3Surface,
                                    M3SurfaceContainerLowest
                                )
                            )
                            onDrawBehind {
                                drawRect(vertGradient)
                                drawRect(radialGlow)
                            }
                        }
                )
            }
            else -> {
                // True Black M3 Mode with ultra-subtle tonal ambiance
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .drawWithCache {
                            val radialGlow = Brush.radialGradient(
                                colors = listOf(accent.copy(alpha = 0.05f), Color.Transparent),
                                center = Offset(size.width * 0.5f, size.height * 0.22f),
                                radius = size.width * 0.90f
                            )
                            onDrawBehind {
                                drawRect(Color.Black)
                                drawRect(radialGlow)
                            }
                        }
                )
            }
        }
        content()
    }
}
