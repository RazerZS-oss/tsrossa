package com.yuka.musicplayer.ui.dialogs

import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.PlaybackSource
import com.yuka.musicplayer.model.ViewState
import com.yuka.musicplayer.ui.components.CyberBottomSheet
import com.yuka.musicplayer.ui.components.GlyphClose
import com.yuka.musicplayer.ui.components.GlyphMusicNote
import com.yuka.musicplayer.ui.components.RetroActionItem
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File

/**
 * Bottom Sheet menu for individual audio track actions:
 * Play Now, Play Next, Add to Queue, Add/Remove from Playlist.
 */
@Composable
fun TrackOptionsBottomSheet(
    target: File?,
    onDismissRequest: () -> Unit,
    playlistSet: Set<String>,
    viewState: ViewState,
    onPlayTrack: (File, PlaybackSource) -> Unit,
    onPlayNextInQueue: (File) -> Unit,
    onAddToQueue: (File) -> Unit,
    onOpenAddToPlaylist: (File) -> Unit
) {
    val inPlaylist = if (target != null) playlistSet.contains(target.absolutePath) else false

    CyberBottomSheet(
        visible = target != null,
        onDismissRequest = onDismissRequest,
        maxHeightFraction = 0.50f,
        maxWidth = 420.dp,
        wrapHeight = true
    ) {
        if (target != null) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 6.dp)
            ) {
                // Header with squircle art & close button
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(46.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(m3SurfaceContainerHigh()),
                        contentAlignment = Alignment.Center
                    ) {
                        GlyphMusicNote(
                            color = LocalAccentColor.current,
                            modifier = Modifier.size(22.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = target.nameWithoutExtension.ifEmpty { target.name },
                            color = TerminalWhite,
                            fontSize = 14.sp,
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = target.extension.uppercase().ifEmpty { "AUDIO" },
                            color = LocalAccentColor.current,
                            fontSize = 10.sp,
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.06.sp
                        )
                    }

                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .clickable { onDismissRequest() },
                        contentAlignment = Alignment.Center
                    ) {
                        GlyphClose(color = TerminalGray, modifier = Modifier.size(18.dp))
                    }
                }

                RetroActionItem(
                    icon = "▶",
                    label = "Play now",
                    onClick = {
                        val targetSource = if (viewState == ViewState.PLAYLIST) {
                            PlaybackSource.PLAYLIST
                        } else if (viewState == ViewState.LIBRARY) {
                            PlaybackSource.LIBRARY
                        } else {
                            if (inPlaylist) PlaybackSource.PLAYLIST else PlaybackSource.LIBRARY
                        }
                        onDismissRequest()
                        onPlayTrack(target, targetSource)
                    }
                )
                RetroActionItem(
                    icon = "⏩",
                    label = "Play next (Top of queue)",
                    onClick = {
                        onDismissRequest()
                        onPlayNextInQueue(target)
                    }
                )
                RetroActionItem(
                    icon = "☰",
                    label = "Add to queue",
                    onClick = {
                        onDismissRequest()
                        onAddToQueue(target)
                    }
                )
                RetroActionItem(
                    icon = "★",
                    label = if (inPlaylist) "Manage in playlist" else "Add to playlist",
                    onClick = {
                        onDismissRequest()
                        onOpenAddToPlaylist(target)
                    }
                )
            }
        }
    }
}
