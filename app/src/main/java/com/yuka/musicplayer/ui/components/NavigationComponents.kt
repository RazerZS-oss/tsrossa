package com.yuka.musicplayer.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.model.ViewState
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.M3SurfaceContainer
import com.yuka.musicplayer.ui.theme.M3SurfaceContainerHigh
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import com.yuka.musicplayer.ui.theme.getM3ContainerColor
import com.yuka.musicplayer.ui.theme.resolveM3TonalSurface

/**
 * Clean Material 3 Top Status & Utility Bar.
 * - Flat borderless tonal surface.
 * - Left: Clean app/DAC status pill with active USB DAC state / sample rate.
 * - Right: Circular/pill tonal action buttons (36dp) for Warmup, Lock, Diagnostics, and Update.
 */
@Composable
fun AppHeader(
    viewState: ViewState,
    isHardwareVolumeActive: Boolean,
    isForceSoftwareVolume: Boolean,
    isHardwareVolumeLockedBySystem: Boolean,
    onToggleLogs: () -> Unit,
    onToggleUpdate: () -> Unit,
    hasUpdateAvailable: Boolean = false,
    onWarmupClick: () -> Unit = {},
    isWarmingUp: Boolean = false,
    onToggleLockTask: () -> Unit = {},
    isTaskLocked: Boolean = false
) {
    val accent = LocalAccentColor.current
    val statusColor = when {
        isHardwareVolumeLockedBySystem -> Color(0xFFFF9100)
        isForceSoftwareVolume -> Color(0xFFFF5252)
        isHardwareVolumeActive -> Color(0xFFFFD700)
        else -> accent
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp)
    ) {
        // Row 1: Brand / Screen Title + Action Cluster
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Left: Title + subtle status dot + DAC status
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "tsrossa",
                    fontFamily = ModernSansFont,
                    fontWeight = FontWeight.Bold,
                    fontSize = 19.sp,
                    letterSpacing = (-0.3).sp,
                    color = TerminalWhite
                )
                Spacer(modifier = Modifier.width(10.dp))
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .background(statusColor, CircleShape)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (isHardwareVolumeActive) "Bit-Perfect" else "USB Audio",
                    fontFamily = ModernSansFont,
                    fontWeight = FontWeight.Medium,
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.65f)
                )
            }

            // Right: M3 Borderless Tonal Icon Action Cluster (36dp buttons)
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Button 1: DIAGNOSTICS
                TactileBox(
                    onClick = onToggleLogs,
                    pressedScale = 0.90f,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(accent.copy(alpha = 0.12f))
                ) {
                    GlyphDiagnostics(
                        color = accent,
                        modifier = Modifier.size(17.dp)
                    )
                }

                // Button 2: UPDATES
                TactileBox(
                    onClick = onToggleUpdate,
                    pressedScale = 0.90f,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(
                            if (hasUpdateAvailable) Color(0xFF00E676).copy(alpha = 0.22f)
                            else accent.copy(alpha = 0.12f)
                        )
                ) {
                    GlyphUpdate(
                        color = if (hasUpdateAvailable) Color(0xFF00E676) else accent,
                        modifier = Modifier.size(17.dp)
                    )
                }

                // Button 3: DAC WARMUP
                TactileBox(
                    onClick = onWarmupClick,
                    pressedScale = 0.90f,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(
                            if (isWarmingUp) Color(0xFF00E5FF).copy(alpha = 0.25f)
                            else accent.copy(alpha = 0.12f)
                        )
                ) {
                    GlyphBolt(
                        color = if (isWarmingUp) Color(0xFF00E5FF) else TerminalWhite.copy(alpha = 0.90f),
                        modifier = Modifier.size(16.dp)
                    )
                }

                // Button 4: SCREEN PINNING / LOCK TASK
                TactileBox(
                    onClick = onToggleLockTask,
                    pressedScale = 0.90f,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(
                            if (isTaskLocked) Color(0xFFFFB300).copy(alpha = 0.25f)
                            else accent.copy(alpha = 0.12f)
                        )
                ) {
                    if (isTaskLocked) {
                        GlyphLock(color = Color(0xFFFFB300), modifier = Modifier.size(16.dp))
                    } else {
                        GlyphUnlock(color = TerminalWhite.copy(alpha = 0.75f), modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}

/**
 * Authentic Material 3 Tonal Floating Mini-Player.
 * - Soft borderless tonal surface (RoundedCornerShape(16.dp)).
 * - 44dp squircle album art / tonal music placeholder.
 * - Bold Title & Artist subtitle.
 * - Circular play/pause toggle.
 * - 2dp M3 linear progress hairline along bottom.
 */
@Composable
fun MiniPlayerView(
    track: TrackInfo,
    isPlaying: Boolean,
    playbackPosition: Double = 0.0,
    durationSeconds: Double = 0.0,
    bgMode: String = "SIGNATURE",
    onTogglePlay: () -> Unit,
    onNavigateToNowPlaying: () -> Unit,
    modifier: Modifier = Modifier
) {
    val dynamicColor = LocalAccentColor.current
    val progress = if (durationSeconds > 0.0) (playbackPosition / durationSeconds).toFloat().coerceIn(0f, 1f) else 0f
    val containerColor = com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh()

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp, vertical = 4.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(containerColor)
            .border(0.8.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(28.dp))
            .clickable { onNavigateToNowPlaying() }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            val imageMod = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(Color.White.copy(alpha = 0.08f))

            if (track.coverArt != null) {
                Image(
                    bitmap = track.coverArt.asImageBitmap(),
                    contentDescription = "Cover",
                    modifier = imageMod,
                    contentScale = ContentScale.Crop
                )
            } else {
                Box(
                    modifier = imageMod,
                    contentAlignment = Alignment.Center
                ) {
                    GlyphMusicNote(color = dynamicColor, modifier = Modifier.size(20.dp))
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = track.title,
                    color = TerminalWhite,
                    fontSize = 13.sp,
                    fontFamily = ModernSansFont,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(2.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = track.artist,
                        color = Color(0xFFCAC4D0),
                        fontSize = 11.5.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.Normal,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    val badgeText = if (track.bitrateKbps > 0) "${track.codec} · ${track.bitrateKbps}k" else track.codec
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(dynamicColor.copy(alpha = 0.16f))
                            .padding(horizontal = 5.dp, vertical = 1.dp)
                    ) {
                        Text(
                            text = badgeText,
                            color = dynamicColor,
                            fontSize = 8.5.sp,
                            fontFamily = TerminalFont,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            TactileBox(
                onClick = onTogglePlay,
                pressedScale = 0.88f,
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(dynamicColor)
            ) {
                val iconColor = Color(0xFF0E0D13)
                if (isPlaying) {
                    GlyphPause(color = iconColor, modifier = Modifier.size(16.dp))
                } else {
                    Box(modifier = Modifier.padding(start = 2.dp)) {
                        GlyphPlay(color = iconColor, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }

        // 2.dp Material 3 Progress Indicator hairline along the bottom
        if (progress > 0f) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .fillMaxWidth(progress)
                    .height(2.dp)
                    .background(dynamicColor)
            )
        }
    }
}

/**
 * Authentic Material 3 NavigationBar:
 * - Flat tonal surface (SurfaceContainer).
 * - 4 navigation items (LIBRARY, PLAYLIST, TRACK, SETTINGS).
 * - M3 Active Pill Indicator (64dp x 32dp, RoundedCornerShape(50), LocalAccentColor 22% fill)
 *   behind the icon with smooth animated transition.
 * - Modern sans-serif label underneath.
 */
@Composable
fun BottomNavigationBar(
    currentView: ViewState,
    bgMode: String = "SIGNATURE",
    onNavClick: (ViewState) -> Unit
) {
    val items = listOf(
        ViewState.LIBRARY to "Library",
        ViewState.PLAYLIST to "Playlist",
        ViewState.TRACK to "Now Playing",
        ViewState.SETTINGS to "Settings"
    )

    val accent = LocalAccentColor.current
    val navBarBg = com.yuka.musicplayer.ui.theme.m3SurfaceContainer()

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 12.dp, end = 12.dp, top = 2.dp, bottom = 8.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(navBarBg)
            .border(0.8.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(28.dp))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 6.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            items.forEach { (view, label) ->
                val isSelected = currentView == view

                TactileBox(
                    onClick = { onNavClick(view) },
                    pressedScale = 0.94f,
                    modifier = Modifier
                        .weight(1f)
                        .padding(horizontal = 2.dp)
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                        modifier = Modifier.padding(vertical = 4.dp)
                    ) {
                        // Material 3 Active Pill Indicator behind Icon
                        Box(
                            modifier = Modifier
                                .width(56.dp)
                                .height(30.dp)
                                .clip(RoundedCornerShape(50))
                                .background(
                                    if (isSelected) com.yuka.musicplayer.ui.theme.m3ActivePillContainer() else Color.Transparent
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            val iconColor = if (isSelected) accent else Color.White.copy(alpha = 0.65f)
                            when (view) {
                                ViewState.LIBRARY -> GlyphLibrary(color = iconColor, modifier = Modifier.size(20.dp))
                                ViewState.PLAYLIST -> GlyphPlaylists(color = iconColor, modifier = Modifier.size(20.dp))
                                ViewState.TRACK -> GlyphNowPlaying(color = iconColor, modifier = Modifier.size(20.dp))
                                ViewState.SETTINGS -> GlyphSettings(color = iconColor, modifier = Modifier.size(20.dp))
                            }
                        }

                        Spacer(modifier = Modifier.height(3.dp))

                        Text(
                            text = label,
                            color = if (isSelected) accent else Color.White.copy(alpha = 0.60f),
                            fontSize = 11.sp,
                            fontFamily = ModernSansFont,
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                            textAlign = TextAlign.Center,
                            maxLines = 1
                        )
                    }
                }
            }
        }
    }
}

