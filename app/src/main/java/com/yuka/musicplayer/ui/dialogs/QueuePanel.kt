package com.yuka.musicplayer.ui.dialogs

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.ui.components.GlyphClose
import com.yuka.musicplayer.ui.components.GlyphNowPlaying
import com.yuka.musicplayer.ui.components.GlyphQueue
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File
import androidx.compose.foundation.Image
import androidx.compose.ui.graphics.asImageBitmap
import com.yuka.musicplayer.ui.theme.m3SurfaceContainer
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh

@Composable
fun QueuePanel(
    currentTrack: TrackInfo?,
    priorityQueue: List<File>,
    upcomingTracks: List<File>,
    onRemoveFromQueue: (Int) -> Unit,
    onClearQueue: () -> Unit,
    onSelectTrack: (File) -> Unit,
    onClose: () -> Unit
) {
    val accent = LocalAccentColor.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 4.dp, vertical = 2.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.weight(1f, fill = false)
            ) {
                GlyphQueue(color = accent, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "Play Queue & Up Next (${priorityQueue.size})",
                    color = TerminalWhite,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = ModernSansFont,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (priorityQueue.isNotEmpty()) {
                    TactileBox(
                        onClick = onClearQueue,
                        pressedScale = 0.88f,
                        modifier = Modifier
                            .clip(RoundedCornerShape(50))
                            .background(Color(0xFFFF5252).copy(alpha = 0.15f))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text("Clear", color = Color(0xFFFF5252), fontSize = 11.sp, fontFamily = ModernSansFont, fontWeight = FontWeight.SemiBold)
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                }
                TactileBox(
                    onClick = onClose,
                    pressedScale = 0.88f,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(m3SurfaceContainerHigh())
                ) {
                    GlyphClose(color = Color.White.copy(alpha = 0.80f), modifier = Modifier.size(18.dp))
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        LazyColumn(modifier = Modifier.weight(1f).fillMaxWidth()) {
            item {
                Text(
                    text = "Now Playing",
                    color = accent,
                    fontFamily = ModernSansFont,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(8.dp))
                if (currentTrack != null) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(16.dp))
                            .background(m3SurfaceContainer())
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (currentTrack.coverArt != null) {
                            Image(
                                bitmap = currentTrack.coverArt.asImageBitmap(),
                                contentDescription = "Artwork",
                                contentScale = androidx.compose.ui.layout.ContentScale.Crop,
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(RoundedCornerShape(10.dp))
                            )
                        } else {
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(accent.copy(alpha = 0.18f)),
                                contentAlignment = Alignment.Center
                            ) {
                                GlyphNowPlaying(color = accent, modifier = Modifier.size(20.dp))
                            }
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                currentTrack.title,
                                color = TerminalWhite,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                fontFamily = ModernSansFont,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                currentTrack.artist,
                                color = accent,
                                fontSize = 12.sp,
                                fontFamily = ModernSansFont,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }
                } else {
                    Text("No track actively playing", color = Color.White.copy(alpha = 0.50f), fontFamily = ModernSansFont, fontSize = 12.sp)
                }
                Spacer(modifier = Modifier.height(18.dp))
            }

            item {
                Text(
                    text = "Priority Queue (${priorityQueue.size})",
                    color = Color.White.copy(alpha = 0.75f),
                    fontFamily = ModernSansFont,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(8.dp))
            }

            if (priorityQueue.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(14.dp))
                            .background(m3SurfaceContainer())
                            .padding(18.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "Priority queue is empty.\nLong-press any track to 'Play Next' or 'Add to Queue'.",
                            color = Color.White.copy(alpha = 0.50f),
                            fontFamily = ModernSansFont,
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center
                        )
                    }
                    Spacer(modifier = Modifier.height(16.dp))
                }
            } else {
                items(priorityQueue.mapIndexed { idx, f -> idx to f }, key = { it.second.absolutePath + it.first }) { (idx, file) ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 3.dp)
                            .clip(RoundedCornerShape(14.dp))
                            .background(m3SurfaceContainer())
                            .clickable { onSelectTrack(file) }
                            .padding(horizontal = 12.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(accent.copy(alpha = 0.16f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = String.format("%02d", idx + 1),
                                color = accent,
                                fontFamily = TerminalFont,
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(
                            text = file.nameWithoutExtension.ifEmpty { file.name },
                            color = TerminalWhite,
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.Medium,
                            fontSize = 13.5.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f)
                        )
                        TactileBox(
                            onClick = { onRemoveFromQueue(idx) },
                            pressedScale = 0.85f,
                            modifier = Modifier.size(32.dp).clip(CircleShape)
                        ) {
                            GlyphClose(color = Color(0xFFFF5252).copy(alpha = 0.80f), modifier = Modifier.size(14.dp))
                        }
                    }
                }
                item { Spacer(modifier = Modifier.height(16.dp)) }
            }

            if (upcomingTracks.isNotEmpty()) {
                item {
                    Text(
                        text = "Upcoming in Playlist / Folder",
                        color = Color.White.copy(alpha = 0.65f),
                        fontFamily = ModernSansFont,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                }
                items(upcomingTracks.take(12).mapIndexed { idx, f -> idx to f }) { (idx, file) ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 2.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .clickable { onSelectTrack(file) }
                            .padding(horizontal = 10.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(28.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color.White.copy(alpha = 0.05f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "${idx + 1}",
                                color = Color.White.copy(alpha = 0.50f),
                                fontFamily = TerminalFont,
                                fontSize = 11.sp
                            )
                        }
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = file.nameWithoutExtension.ifEmpty { file.name },
                            color = Color.White.copy(alpha = 0.70f),
                            fontFamily = ModernSansFont,
                            fontWeight = FontWeight.Normal,
                            fontSize = 13.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }
    }
}
