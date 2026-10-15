package com.yuka.musicplayer.ui.views

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.Playlist
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PlaylistView(
    playlists: List<Playlist>,
    selectedPlaylistId: String,
    activePlayingPlaylistId: String?,
    playingFile: File?,
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
    val currentPlaylist = remember(playlists, selectedPlaylistId) {
        playlists.firstOrNull { it.id == selectedPlaylistId } ?: playlists.firstOrNull()
    }
    val currentTracks = currentPlaylist?.trackPaths ?: emptyList()
    val isCurrentPlaying = currentPlaylist != null && currentPlaylist.id == activePlayingPlaylistId

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        // --- Playlists Tabs / Selector Bar ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier
                    .weight(1f)
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                playlists.forEach { playlist ->
                    val isSelected = playlist.id == currentPlaylist?.id
                    val isPlayingThis = playlist.id == activePlayingPlaylistId
                    Box(
                        modifier = Modifier
                            .background(
                                when {
                                    isSelected -> LocalAccentColor.current.copy(alpha = 0.20f)
                                    isPlayingThis -> LocalAccentColor.current.copy(alpha = 0.08f)
                                    else -> Color(0xFF090D18)
                                },
                                RoundedCornerShape(4.dp)
                            )
                            .border(
                                1.dp,
                                when {
                                    isSelected -> LocalAccentColor.current
                                    isPlayingThis -> LocalAccentColor.current.copy(alpha = 0.5f)
                                    else -> Color.White.copy(alpha = 0.08f)
                                },
                                RoundedCornerShape(4.dp)
                            )
                            .clickable {
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                onSelectPlaylistTab(playlist.id)
                            }
                            .padding(horizontal = 10.dp, vertical = 5.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = playlist.name,
                                color = if (isSelected || isPlayingThis) LocalAccentColor.current else TerminalWhite,
                                fontSize = 10.5.sp,
                                fontFamily = TerminalFont,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                            if (isPlayingThis) {
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("▶", color = LocalAccentColor.current, fontSize = 8.sp)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.width(6.dp))

            // Create New Playlist Button
            Box(
                modifier = Modifier
                    .background(LocalAccentColor.current.copy(alpha = 0.12f), RoundedCornerShape(4.dp))
                    .border(1.dp, LocalAccentColor.current.copy(alpha = 0.6f), RoundedCornerShape(4.dp))
                    .clickable {
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        onCreatePlaylistClick()
                    }
                    .padding(horizontal = 8.dp, vertical = 5.dp)
            ) {
                Text(
                    text = "+ NEW",
                    color = LocalAccentColor.current,
                    fontSize = 10.sp,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        // --- Active Playlist Header Banner ---
        if (currentPlaylist != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFF090D18), RoundedCornerShape(6.dp))
                    .border(0.8.dp, LocalAccentColor.current.copy(alpha = 0.25f), RoundedCornerShape(6.dp))
                    .padding(horizontal = 10.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = currentPlaylist.name,
                            color = TerminalWhite,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            fontFamily = TerminalFont,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        if (isCurrentPlaying) {
                            Box(
                                modifier = Modifier
                                    .background(LocalAccentColor.current.copy(alpha = 0.15f), RoundedCornerShape(3.dp))
                                    .border(0.5.dp, LocalAccentColor.current, RoundedCornerShape(3.dp))
                                    .padding(horizontal = 4.dp, vertical = 1.dp)
                            ) {
                                Text(
                                    text = "PLAYING NOW",
                                    color = LocalAccentColor.current,
                                    fontSize = 7.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    fontFamily = TerminalFont
                                )
                            }
                        }
                    }
                    Text(
                        text = "${currentTracks.size} TRACKS",
                        color = TerminalGray,
                        fontSize = 8.5.sp,
                        fontFamily = TerminalFont
                    )
                }

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Box(
                        modifier = Modifier
                            .border(0.8.dp, LocalAccentColor.current.copy(alpha = 0.5f), RoundedCornerShape(4.dp))
                            .clickable { onRenamePlaylistClick(currentPlaylist) }
                            .padding(horizontal = 6.dp, vertical = 3.dp)
                    ) {
                        Text("RENAME", color = LocalAccentColor.current, fontSize = 8.5.sp, fontFamily = TerminalFont, fontWeight = FontWeight.Bold)
                    }

                    Box(
                        modifier = Modifier
                            .border(0.8.dp, Color(0xFFFF5252).copy(alpha = 0.6f), RoundedCornerShape(4.dp))
                            .clickable { onDeletePlaylistClick(currentPlaylist) }
                            .padding(horizontal = 6.dp, vertical = 3.dp)
                    ) {
                        Text("DELETE", color = Color(0xFFFF5252), fontSize = 8.5.sp, fontFamily = TerminalFont, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(modifier = Modifier.height(6.dp))
        }

        // --- Playlist Quick Controls Row (Shuffle, Repeat, Queue) ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(32.dp)
                    .border(
                        1.dp,
                        if (isShuffleEnabled) LocalAccentColor.current else LocalAccentColor.current.copy(alpha = 0.25f),
                        RoundedCornerShape(4.dp)
                    )
                    .background(
                        if (isShuffleEnabled) LocalAccentColor.current.copy(alpha = 0.15f) else Color.Transparent,
                        RoundedCornerShape(4.dp)
                    )
                    .clickable { onToggleShuffle() },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = if (isShuffleEnabled) "⇄ SHUFFLE ON" else "⇄ SHUFFLE OFF",
                    color = if (isShuffleEnabled) LocalAccentColor.current else TerminalGray,
                    fontSize = 10.sp,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold
                )
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(32.dp)
                    .border(
                        1.dp,
                        if (repeatMode != RepeatMode.OFF) LocalAccentColor.current else LocalAccentColor.current.copy(alpha = 0.25f),
                        RoundedCornerShape(4.dp)
                    )
                    .background(
                        if (repeatMode != RepeatMode.OFF) LocalAccentColor.current.copy(alpha = 0.15f) else Color.Transparent,
                        RoundedCornerShape(4.dp)
                    )
                    .clickable { onCycleRepeat() },
                contentAlignment = Alignment.Center
            ) {
                val rText = when (repeatMode) {
                    RepeatMode.OFF -> "↻ REPEAT OFF"
                    RepeatMode.ALL -> "↻ REPEAT ALL"
                    RepeatMode.ONE -> "↻ REPEAT 1"
                }
                Text(
                    text = rText,
                    color = if (repeatMode != RepeatMode.OFF) LocalAccentColor.current else TerminalGray,
                    fontSize = 10.sp,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold
                )
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(32.dp)
                    .border(
                        1.dp,
                        if (priorityQueueSize > 0) LocalAccentColor.current else LocalAccentColor.current.copy(alpha = 0.25f),
                        RoundedCornerShape(4.dp)
                    )
                    .background(
                        if (priorityQueueSize > 0) LocalAccentColor.current.copy(alpha = 0.15f) else Color.Transparent,
                        RoundedCornerShape(4.dp)
                    )
                    .clickable { onOpenQueue() },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "☰ QUEUE ($priorityQueueSize)",
                    color = if (priorityQueueSize > 0) LocalAccentColor.current else TerminalWhite,
                    fontSize = 10.sp,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        
        if (playlists.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 40.dp)
                    .border(1.dp, TerminalGray.copy(alpha = 0.3f), RoundedCornerShape(6.dp))
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("[ NO PLAYLISTS CREATED ]", color = TerminalGray, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Tap '+ NEW' above to create your first playlist,\nor long-press any track in the Library.",
                        color = TerminalGray.copy(alpha = 0.7f),
                        fontFamily = TerminalFont,
                        fontSize = 10.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else if (currentTracks.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 40.dp)
                    .border(1.dp, TerminalGray.copy(alpha = 0.3f), RoundedCornerShape(6.dp))
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("[ PLAYLIST EMPTY ]", color = TerminalGray, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Long-press any audio track in Library\nto add it to this playlist.",
                        color = TerminalGray.copy(alpha = 0.7f),
                        fontFamily = TerminalFont,
                        fontSize = 10.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else {
            LazyColumn(modifier = Modifier.weight(1f).fillMaxWidth()) {
                items(currentTracks.mapIndexed { index, path -> index to path }, key = { it.second }) { (index, path) ->
                    val file = File(path)
                    val isPlaying = isCurrentPlaying && file.absolutePath == playingFile?.absolutePath
                    val displayName = file.nameWithoutExtension.ifEmpty { file.name }
                    
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 2.dp)
                            .background(
                                if (isPlaying) LocalAccentColor.current.copy(alpha = 0.10f) else Color(0xFF090D18),
                                RoundedCornerShape(8.dp)
                            )
                            .border(
                                width = 0.6.dp,
                                color = if (isPlaying) LocalAccentColor.current.copy(alpha = 0.40f) else Color.White.copy(alpha = 0.05f),
                                shape = RoundedCornerShape(8.dp)
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
                            .padding(horizontal = 10.dp, vertical = 9.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (isPlaying) {
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(1.5.dp),
                                verticalAlignment = Alignment.Bottom,
                                modifier = Modifier.height(12.dp)
                            ) {
                                Box(modifier = Modifier.width(2.dp).fillMaxHeight(0.6f).background(LocalAccentColor.current, RoundedCornerShape(1.dp)))
                                Box(modifier = Modifier.width(2.dp).fillMaxHeight(1.0f).background(LocalAccentColor.current, RoundedCornerShape(1.dp)))
                                Box(modifier = Modifier.width(2.dp).fillMaxHeight(0.4f).background(LocalAccentColor.current, RoundedCornerShape(1.dp)))
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                        } else {
                            Text(
                                text = String.format("%02d", index + 1),
                                color = TerminalGray.copy(alpha = 0.6f),
                                fontFamily = TerminalFont,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Normal
                            )
                            Spacer(modifier = Modifier.width(10.dp))
                        }

                        Text(
                            text = displayName,
                            color = if (isPlaying) LocalAccentColor.current else TerminalWhite,
                            fontFamily = TerminalFont,
                            fontWeight = if (isPlaying) FontWeight.Bold else FontWeight.Normal,
                            fontSize = 12.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f)
                        )

                        Spacer(modifier = Modifier.width(6.dp))

                        val ext = file.extension.uppercase()
                        Box(
                            modifier = Modifier
                                .background(Color(0xFF101626), RoundedCornerShape(4.dp))
                                .border(0.5.dp, if (isPlaying) LocalAccentColor.current.copy(alpha = 0.3f) else Color.White.copy(alpha = 0.08f), RoundedCornerShape(4.dp))
                                .padding(horizontal = 5.dp, vertical = 1.dp)
                        ) {
                            Text(
                                text = ext,
                                color = if (isPlaying) LocalAccentColor.current else TerminalGray,
                                fontSize = 8.5.sp,
                                fontFamily = TerminalFont,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        Spacer(modifier = Modifier.width(8.dp))

                        Box(
                            modifier = Modifier
                                .clickable {
                                    currentPlaylist?.let { onFileRemoved(path, it.id) }
                                }
                                .padding(4.dp)
                        ) {
                            Text(
                                "✕",
                                color = Color(0xFFFF5252).copy(alpha = 0.8f),
                                fontWeight = FontWeight.Bold,
                                fontFamily = TerminalFont,
                                fontSize = 11.sp
                            )
                        }
                    }
                }
            }
        }
    }
}
