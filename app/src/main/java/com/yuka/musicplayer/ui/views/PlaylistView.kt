package com.yuka.musicplayer.ui.views

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.Image
import androidx.compose.ui.graphics.asImageBitmap
import com.yuka.musicplayer.model.Playlist
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.ui.components.*
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalWhite
import com.yuka.musicplayer.ui.theme.m3ActivePillContainer
import java.io.File

/**
 * Material 3 Playlist Screen:
 * - Top scrollable M3 FilterChip playlist selector strip.
 * - Active playlist management & transport bar (Rename, Clear, Delete, Shuffle, Repeat, Queue).
 * - Empty state with friendly illustration.
 * - Flat borderless track rows with squircle leading icons and trailing action menus.
 * - Signature M3 Squircle Floating Action Button (FAB) at bottom-end.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PlaylistView(
    playlists: List<Playlist>,
    selectedPlaylistId: String,
    activePlayingPlaylistId: String?,
    currentTrack: TrackInfo?,
    isShuffleEnabled: Boolean,
    repeatMode: RepeatMode,
    priorityQueueSize: Int,
    onSelectPlaylistTab: (String) -> Unit,
    onCreatePlaylistClick: () -> Unit,
    onRenamePlaylistClick: (Playlist) -> Unit,
    onDeletePlaylistClick: (Playlist) -> Unit,
    onToggleShuffle: () -> Unit,
    onCycleRepeat: () -> Unit,
    onOpenQueue: () -> Unit,
    onFileSelected: (File, String) -> Unit,
    onFileRemoved: (String, String) -> Unit,
    onClearPlaylist: (String) -> Unit,
    onTrackLongPressed: (File) -> Unit = {},
    modifier: Modifier = Modifier
) {
    val haptic = LocalHapticFeedback.current
    val accent = LocalAccentColor.current

    val currentPlaylist = remember(playlists, selectedPlaylistId) {
        playlists.firstOrNull { it.id == selectedPlaylistId }
    }
    val currentTracks = currentPlaylist?.trackPaths ?: emptyList()
    val isCurrentPlaying = activePlayingPlaylistId == selectedPlaylistId

    Box(modifier = modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 6.dp)
        ) {
            // 1. Horizontal Scrollable M3 FilterChips for Playlist Selection
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    modifier = Modifier
                        .weight(1f)
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    playlists.forEach { playlist ->
                        val isSelected = playlist.id == selectedPlaylistId
                        val isPlayingThis = activePlayingPlaylistId == playlist.id

                        TactileBox(
                            onClick = {
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                onSelectPlaylistTab(playlist.id)
                            },
                            pressedScale = 0.92f,
                            modifier = Modifier
                                .clip(RoundedCornerShape(50))
                                .background(
                                    if (isSelected) accent.copy(alpha = 0.22f)
                                    else Color.White.copy(alpha = 0.08f)
                                )
                                .padding(horizontal = 14.dp, vertical = 8.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = playlist.name,
                                    color = if (isSelected) accent else TerminalWhite,
                                    fontSize = 12.sp,
                                    fontFamily = ModernSansFont,
                                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                                )
                                if (isPlayingThis) {
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Box(
                                        modifier = Modifier
                                            .size(6.dp)
                                            .background(accent, CircleShape)
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // 2. Active Playlist Header & Management Strip
            if (currentPlaylist != null) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(Color.White.copy(alpha = 0.05f))
                        .padding(horizontal = 14.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = currentPlaylist.name,
                                color = TerminalWhite,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold,
                                fontFamily = ModernSansFont,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            if (isCurrentPlaying) {
                                Spacer(modifier = Modifier.width(8.dp))
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(50))
                                        .background(accent.copy(alpha = 0.16f))
                                        .padding(horizontal = 6.dp, vertical = 2.dp)
                                ) {
                                    Text(
                                        text = "PLAYING",
                                        color = accent,
                                        fontSize = 8.sp,
                                        fontWeight = FontWeight.Bold,
                                        fontFamily = ModernSansFont
                                    )
                                }
                            }
                        }
                        Text(
                            text = "${currentTracks.size} tracks",
                            color = Color.White.copy(alpha = 0.55f),
                            fontSize = 11.5.sp,
                            fontFamily = ModernSansFont
                        )
                    }

                    // Tonal Action Buttons for active playlist
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        if (currentTracks.isNotEmpty()) {
                            TactileBox(
                                onClick = { onClearPlaylist(currentPlaylist.id) },
                                pressedScale = 0.88f,
                                modifier = Modifier
                                    .clip(RoundedCornerShape(50))
                                    .background(accent.copy(alpha = 0.12f))
                                    .padding(horizontal = 10.dp, vertical = 5.dp)
                            ) {
                                Text("CLEAR", color = accent, fontSize = 9.sp, fontFamily = ModernSansFont, fontWeight = FontWeight.SemiBold)
                            }
                        }

                        TactileBox(
                            onClick = { onRenamePlaylistClick(currentPlaylist) },
                            pressedScale = 0.88f,
                            modifier = Modifier
                                .clip(RoundedCornerShape(50))
                                .background(accent.copy(alpha = 0.12f))
                                .padding(horizontal = 10.dp, vertical = 5.dp)
                        ) {
                            Text("RENAME", color = accent, fontSize = 9.sp, fontFamily = ModernSansFont, fontWeight = FontWeight.SemiBold)
                        }

                        TactileBox(
                            onClick = { onDeletePlaylistClick(currentPlaylist) },
                            pressedScale = 0.88f,
                            modifier = Modifier
                                .clip(RoundedCornerShape(50))
                                .background(Color(0xFFFF5252).copy(alpha = 0.15f))
                                .padding(horizontal = 10.dp, vertical = 5.dp)
                        ) {
                            Text("DELETE", color = Color(0xFFFF5252), fontSize = 9.sp, fontFamily = ModernSansFont, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Transport Quick Controls Strip (Shuffle, Repeat, Queue)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Shuffle Pill
                    TactileBox(
                        onClick = onToggleShuffle,
                        pressedScale = 0.92f,
                        modifier = Modifier
                            .weight(1f)
                            .height(36.dp)
                            .clip(RoundedCornerShape(50))
                            .background(if (isShuffleEnabled) accent.copy(alpha = 0.22f) else Color.White.copy(alpha = 0.08f))
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            GlyphShuffle(color = if (isShuffleEnabled) accent else Color.White.copy(alpha = 0.65f), modifier = Modifier.size(15.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Shuffle",
                                color = if (isShuffleEnabled) accent else Color.White.copy(alpha = 0.65f),
                                fontSize = 11.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }

                    // Repeat Pill
                    val isRepActive = repeatMode != RepeatMode.OFF
                    TactileBox(
                        onClick = onCycleRepeat,
                        pressedScale = 0.92f,
                        modifier = Modifier
                            .weight(1f)
                            .height(36.dp)
                            .clip(RoundedCornerShape(50))
                            .background(if (isRepActive) accent.copy(alpha = 0.22f) else Color.White.copy(alpha = 0.08f))
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            GlyphRepeat(color = if (isRepActive) accent else Color.White.copy(alpha = 0.65f), modifier = Modifier.size(15.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            val repText = when (repeatMode) {
                                RepeatMode.OFF -> "Repeat"
                                RepeatMode.ALL -> "All"
                                RepeatMode.ONE -> "Single"
                            }
                            Text(
                                text = repText,
                                color = if (isRepActive) accent else Color.White.copy(alpha = 0.65f),
                                fontSize = 11.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }

                    // Queue Pill
                    TactileBox(
                        onClick = onOpenQueue,
                        pressedScale = 0.92f,
                        modifier = Modifier
                            .weight(1f)
                            .height(36.dp)
                            .clip(RoundedCornerShape(50))
                            .background(if (priorityQueueSize > 0) accent.copy(alpha = 0.22f) else Color.White.copy(alpha = 0.08f))
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            GlyphQueue(color = if (priorityQueueSize > 0) accent else Color.White.copy(alpha = 0.65f), modifier = Modifier.size(15.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Queue ($priorityQueueSize)",
                                color = if (priorityQueueSize > 0) accent else Color.White.copy(alpha = 0.65f),
                                fontSize = 11.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))
            }

            // 3. Track List or Empty State
            if (playlists.isEmpty()) {
                Box(
                    modifier = Modifier.weight(1f).fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(32.dp)
                    ) {
                        GlyphPlaylists(color = accent.copy(alpha = 0.60f), modifier = Modifier.size(64.dp))
                        Spacer(modifier = Modifier.height(14.dp))
                        Text(
                            text = "No playlists found",
                            color = TerminalWhite,
                            fontSize = 17.sp,
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "Create a new playlist using the + button below or add songs from Library.",
                            color = Color.White.copy(alpha = 0.55f),
                            fontSize = 13.sp,
                            fontFamily = ModernSansFont,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else if (currentTracks.isEmpty()) {
                Box(
                    modifier = Modifier.weight(1f).fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(32.dp)
                    ) {
                        GlyphMusicNote(color = accent.copy(alpha = 0.50f), modifier = Modifier.size(56.dp))
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Playlist is empty",
                            color = TerminalWhite,
                            fontSize = 16.sp,
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Add songs to this playlist from the Library screen.",
                            color = Color.White.copy(alpha = 0.55f),
                            fontSize = 12.5.sp,
                            fontFamily = ModernSansFont,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.weight(1f).fillMaxWidth(),
                    contentPadding = PaddingValues(bottom = 168.dp)
                ) {
                    items(currentTracks.mapIndexed { index, path -> index to path }, key = { it.second }) { (index, path) ->
                        val file = File(path)
                        val isPlaying = isCurrentPlaying && file.absolutePath == currentTrack?.file?.absolutePath
                        val displayName = file.nameWithoutExtension.ifEmpty { file.name }
                        val (trackTitle, trackArtist) = remember(displayName) {
                            com.yuka.musicplayer.util.TrackTitleParser.parse(displayName)
                        }

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(14.dp))
                                .background(
                                    if (isPlaying) accent.copy(alpha = 0.12f) else Color.Transparent
                                )
                                .combinedClickable(
                                    onClick = {
                                        currentPlaylist?.let { onFileSelected(file, it.id) }
                                    },
                                    onLongClick = {
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        onTrackLongPressed(file)
                                    }
                                )
                                .padding(horizontal = 8.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Leading squircle with album art thumbnail or sequence number fallback
                            com.yuka.musicplayer.util.TrackAlbumThumbnail(
                                filePath = file.absolutePath,
                                isCurrentTrack = isPlaying,
                                currentTrackArt = currentTrack?.coverArt,
                                modifier = Modifier.size(44.dp),
                                cornerRadius = 12.dp
                            ) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .background(
                                            if (isPlaying) accent.copy(alpha = 0.22f) else Color.White.copy(alpha = 0.08f)
                                        ),
                                    contentAlignment = Alignment.Center
                                ) {
                                    if (isPlaying) {
                                        GlyphNowPlaying(color = accent, modifier = Modifier.size(18.dp))
                                    } else {
                                        Text(
                                            text = String.format("%02d", index + 1),
                                            color = Color.White.copy(alpha = 0.65f),
                                            fontFamily = TerminalFont,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Medium
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.width(14.dp))

                            // Track Metadata
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = trackTitle,
                                    color = if (isPlaying) accent else TerminalWhite,
                                    fontFamily = ModernSansFont,
                                    fontWeight = if (isPlaying) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 14.sp,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                if (trackArtist.isNotEmpty()) {
                                    Spacer(modifier = Modifier.height(2.dp))
                                    Text(
                                        text = trackArtist,
                                        color = if (isPlaying) accent.copy(alpha = 0.85f) else Color.White.copy(alpha = 0.55f),
                                        fontSize = 12.sp,
                                        fontFamily = ModernSansFont,
                                        fontWeight = FontWeight.Normal,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.width(8.dp))

                            // Format badge
                            val ext = file.extension.uppercase()
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(Color.White.copy(alpha = 0.08f))
                                    .padding(horizontal = 5.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = ext,
                                    color = if (isPlaying) accent else Color.White.copy(alpha = 0.60f),
                                    fontSize = 8.5.sp,
                                    fontFamily = TerminalFont,
                                    fontWeight = FontWeight.Bold
                                )
                            }

                            Spacer(modifier = Modifier.width(4.dp))

                            // More Options 3-dots
                            TactileBox(
                                onClick = {
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    onTrackLongPressed(file)
                                },
                                pressedScale = 0.85f,
                                modifier = Modifier.size(36.dp).clip(CircleShape)
                            ) {
                                GlyphMoreVert(color = Color.White.copy(alpha = 0.60f), modifier = Modifier.size(18.dp))
                            }
                        }
                    }
                }
            }
        }

        // 4. Signature M3 Squircle Floating Action Button (FAB) at bottom-end
        TactileBox(
            onClick = {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                onCreatePlaylistClick()
            },
            pressedScale = 0.90f,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 20.dp, bottom = 16.dp)
                .size(56.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(m3ActivePillContainer())
        ) {
            GlyphAdd(color = accent, modifier = Modifier.size(26.dp))
        }
    }
}
