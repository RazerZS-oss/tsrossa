package com.yuka.musicplayer.ui.views

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.Image
import androidx.compose.ui.graphics.asImageBitmap
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.ScannedMusicItem
import com.yuka.musicplayer.ui.components.*
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.M3SurfaceContainerHigh
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Material 3 Library Screen:
 * - Pill-shaped search bar with directory change & refresh actions.
 * - Assist/Filter chip for sorting & track counter.
 * - Flat borderless track rows with squircle artwork placeholders and trailing 3-dot options button.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun LibraryView(
    musicRootDirectory: File,
    scannedItems: List<ScannedMusicItem>,
    isScanning: Boolean,
    currentTrack: TrackInfo?,
    playlistSet: Set<String>,
    searchQuery: String,
    sortMode: LibrarySortMode,
    onCycleSort: () -> Unit,
    onRefresh: () -> Unit,
    onChangeDirectory: () -> Unit,
    onSearchChange: (String) -> Unit,
    onTrackSelected: (ScannedMusicItem) -> Unit,
    onTrackLongPressed: (File) -> Unit,
    modifier: Modifier = Modifier
) {
    val haptic = LocalHapticFeedback.current
    val accent = LocalAccentColor.current
    val filteredItems = remember(scannedItems, searchQuery) {
        if (searchQuery.isEmpty()) {
            scannedItems
        } else {
            scannedItems.filter { item ->
                item.file.name.contains(searchQuery, ignoreCase = true) ||
                item.breadcrumb.contains(searchQuery, ignoreCase = true) ||
                item.formatLabel.contains(searchQuery, ignoreCase = true)
            }
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 6.dp)
    ) {
        // 1. M3 Pill Search Bar (52dp height, RoundedCornerShape(28.dp), borderless tonal)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp)
                .clip(RoundedCornerShape(28.dp))
                .background(Color.White.copy(alpha = 0.08f))
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            GlyphSearch(color = accent, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(12.dp))

            Box(modifier = Modifier.weight(1f)) {
                if (searchQuery.isEmpty()) {
                    Text(
                        text = "Search your music...",
                        color = Color.White.copy(alpha = 0.45f),
                        fontSize = 14.sp,
                        fontFamily = ModernSansFont
                    )
                }
                BasicTextField(
                    value = searchQuery,
                    onValueChange = onSearchChange,
                    modifier = Modifier.fillMaxWidth(),
                    textStyle = TextStyle(
                        color = TerminalWhite,
                        fontSize = 14.sp,
                        fontFamily = ModernSansFont
                    ),
                    singleLine = true,
                    cursorBrush = SolidColor(accent)
                )
            }

            if (searchQuery.isNotEmpty()) {
                TactileBox(
                    onClick = { onSearchChange("") },
                    pressedScale = 0.85f,
                    modifier = Modifier.size(30.dp).clip(CircleShape)
                ) {
                    GlyphClose(color = Color.White.copy(alpha = 0.60f), modifier = Modifier.size(16.dp))
                }
                Spacer(modifier = Modifier.width(6.dp))
            }

            // Folder Picker Icon Button
            TactileBox(
                onClick = onChangeDirectory,
                pressedScale = 0.88f,
                modifier = Modifier.size(34.dp).clip(CircleShape)
            ) {
                GlyphFolder(color = accent, modifier = Modifier.size(18.dp))
            }

            Spacer(modifier = Modifier.width(4.dp))

            // Refresh Icon Button
            TactileBox(
                onClick = onRefresh,
                pressedScale = 0.88f,
                modifier = Modifier.size(34.dp).clip(CircleShape)
            ) {
                GlyphRefresh(color = accent, modifier = Modifier.size(18.dp))
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // 2. M3 Sub-Header Strip (Sort FilterChip + Summary Count)
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Sort FilterChip
            TactileBox(
                onClick = {
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    onCycleSort()
                },
                pressedScale = 0.92f,
                modifier = Modifier
                    .clip(RoundedCornerShape(50))
                    .background(Color.White.copy(alpha = 0.08f))
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    GlyphSort(color = accent, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = sortMode.label,
                        color = TerminalWhite,
                        fontSize = 11.5.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            // Track Count & Active Root Directory Badge
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (isScanning) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(12.dp),
                        strokeWidth = 1.5.dp,
                        color = accent
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                }
                Text(
                    text = "${musicRootDirectory.name.ifEmpty { "Music" }} • ${filteredItems.size} tracks",
                    color = Color.White.copy(alpha = 0.50f),
                    fontSize = 11.5.sp,
                    fontFamily = ModernSansFont
                )
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        // 3. Flat Borderless M3 Track Rows (LazyColumn)
        if (filteredItems.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    GlyphMusicNote(color = Color.White.copy(alpha = 0.30f), modifier = Modifier.size(48.dp))
                    Spacer(modifier = Modifier.height(10.dp))
                    Text(
                        text = if (searchQuery.isNotEmpty()) "No matching tracks found" else "No music files found",
                        color = Color.White.copy(alpha = 0.60f),
                        fontSize = 14.sp,
                        fontFamily = ModernSansFont
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxWidth().weight(1f),
                contentPadding = PaddingValues(bottom = 168.dp)
            ) {
                items(filteredItems, key = { it.file.absolutePath }) { item ->
                    val file = item.file
                    val isSupported = item.isSupported
                    val isPlaying = file.absolutePath == currentTrack?.file?.absolutePath
                    val inPlaylist = playlistSet.contains(file.absolutePath)
                    val displayName = file.nameWithoutExtension.ifEmpty { file.name }
                    val itemAlpha = if (isSupported) 1f else 0.42f

                    val (trackTitle, trackArtist) = remember(displayName) {
                        com.yuka.musicplayer.util.TrackTitleParser.parse(displayName)
                    }

                    // Flat M3 Row with ripple / tactile touch
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .alpha(itemAlpha)
                            .clip(RoundedCornerShape(14.dp))
                            .background(
                                if (isPlaying) accent.copy(alpha = 0.12f) else Color.Transparent
                            )
                            .combinedClickable(
                                onClick = { onTrackSelected(item) },
                                onLongClick = {
                                    if (isSupported) {
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        onTrackLongPressed(file)
                                    }
                                }
                            )
                            .padding(horizontal = 8.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Leading Artwork Squircle (46dp, RoundedCornerShape(12.dp))
                        com.yuka.musicplayer.util.TrackAlbumThumbnail(
                            filePath = file.absolutePath,
                            isCurrentTrack = isPlaying,
                            currentTrackArt = currentTrack?.coverArt,
                            modifier = Modifier.size(46.dp),
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
                                    GlyphNowPlaying(color = accent, modifier = Modifier.size(20.dp))
                                } else {
                                    GlyphMusicNote(
                                        color = if (isSupported) Color.White.copy(alpha = 0.70f) else Color(0xFFFF5252),
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.width(14.dp))

                        // Center Track Metadata Column
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = trackTitle,
                                color = when {
                                    isPlaying -> accent
                                    isSupported -> TerminalWhite
                                    else -> Color.White.copy(alpha = 0.50f)
                                },
                                fontFamily = ModernSansFont,
                                fontWeight = if (isPlaying) FontWeight.Bold else FontWeight.Medium,
                                fontSize = 14.sp,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            val secondaryMetadata = buildString {
                                if (trackArtist.isNotEmpty()) append(trackArtist)
                                if (item.breadcrumb.isNotEmpty()) {
                                    if (isNotEmpty()) append("  •  ")
                                    append(item.breadcrumb)
                                }
                                if (isNotEmpty()) append("  •  ")
                                append(item.formatLabel)
                            }
                            Text(
                                text = secondaryMetadata,
                                color = if (isPlaying) accent.copy(alpha = 0.80f) else Color.White.copy(alpha = 0.55f),
                                fontSize = 12.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Normal,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }

                        // Trailing Bookmark / More Options 3-dots
                        if (inPlaylist && isSupported) {
                            Text(text = "★", color = accent, fontSize = 12.sp)
                            Spacer(modifier = Modifier.width(6.dp))
                        }

                        TactileBox(
                            onClick = {
                                if (isSupported) {
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    onTrackLongPressed(file)
                                }
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
}
