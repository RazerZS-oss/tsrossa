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
import com.yuka.musicplayer.ui.theme.SignatureDeepNavy
import com.yuka.musicplayer.ui.theme.SignatureSurfaceNavy

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
                    modifier = Modifier.fillMaxSize().blur(24.dp)
                )
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.65f))
                )
            }
            bgMode == "SIGNATURE" -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .drawWithCache {
                            val radialGlow = Brush.radialGradient(
                                colors = listOf(accent.copy(alpha = 0.08f), Color.Transparent),
                                center = Offset(size.width * 0.5f, size.height * 0.28f),
                                radius = size.width * 0.85f
                            )
                            val vertGradient = Brush.verticalGradient(
                                colors = listOf(
                                    SignatureDeepNavy,
                                    SignatureSurfaceNavy.copy(alpha = 0.90f),
                                    SignatureDeepNavy
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
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .drawWithCache {
                            val radialGlow = Brush.radialGradient(
                                colors = listOf(accent.copy(alpha = 0.06f), Color.Transparent),
                                center = Offset(size.width * 0.5f, size.height * 0.26f),
                                radius = size.width * 0.80f
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
