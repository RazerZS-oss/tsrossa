package com.yuka.musicplayer.ui.dialogs

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.Playlist
import com.yuka.musicplayer.ui.components.CyberBottomSheet
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File

@Composable
fun SelectPlaylistDialog(
    visible: Boolean,
    targetTrack: File?,
    playlists: List<Playlist>,
    onDismissRequest: () -> Unit,
    onSelectPlaylist: (Playlist) -> Unit,
    onCreateNewPlaylist: () -> Unit
) {
    CyberBottomSheet(
        visible = visible,
        onDismissRequest = onDismissRequest,
        maxHeightFraction = 0.55f,
        maxWidth = 420.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "— ADD TO PLAYLIST —",
                    color = LocalAccentColor.current,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = TerminalFont
                )
                Text(
                    text = "✕",
                    color = TerminalGray,
                    fontSize = 12.sp,
                    fontFamily = TerminalFont,
                    modifier = Modifier.clickable { onDismissRequest() }.padding(4.dp)
                )
            }

            if (targetTrack != null) {
                Text(
                    text = targetTrack.nameWithoutExtension.ifEmpty { targetTrack.name },
                    color = TerminalWhite,
                    fontSize = 11.sp,
                    fontFamily = TerminalFont,
                    modifier = Modifier.padding(top = 2.dp, bottom = 8.dp)
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Quick Create New Playlist row
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(LocalAccentColor.current.copy(alpha = 0.12f), RoundedCornerShape(6.dp))
                    .border(1.dp, LocalAccentColor.current.copy(alpha = 0.6f), RoundedCornerShape(6.dp))
                    .clickable {
                        onDismissRequest()
                        onCreateNewPlaylist()
                    }
                    .padding(horizontal = 12.dp, vertical = 9.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "+ CREATE NEW PLAYLIST",
                    color = LocalAccentColor.current,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = TerminalFont
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            if (playlists.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "NO PLAYLISTS YET",
                        color = TerminalGray,
                        fontSize = 10.sp,
                        fontFamily = TerminalFont
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                ) {
                    items(playlists) { playlist ->
                        val containsTrack = targetTrack != null && playlist.trackPaths.contains(targetTrack.absolutePath)
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 3.dp)
                                .background(Color(0xFF090D18), RoundedCornerShape(6.dp))
                                .border(
                                    0.5.dp,
                                    if (containsTrack) LocalAccentColor.current.copy(alpha = 0.5f) else Color.White.copy(alpha = 0.05f),
                                    RoundedCornerShape(6.dp)
                                )
                                .clickable {
                                    onSelectPlaylist(playlist)
                                }
                                .padding(horizontal = 12.dp, vertical = 10.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(
                                    text = playlist.name,
                                    color = if (containsTrack) LocalAccentColor.current else TerminalWhite,
                                    fontSize = 12.sp,
                                    fontFamily = TerminalFont,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = "${playlist.trackPaths.size} tracks",
                                    color = TerminalGray,
                                    fontSize = 9.5.sp,
                                    fontFamily = TerminalFont
                                )
                            }
                            if (containsTrack) {
                                Text(
                                    text = "ADDED ✓",
                                    color = LocalAccentColor.current,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    fontFamily = TerminalFont
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
