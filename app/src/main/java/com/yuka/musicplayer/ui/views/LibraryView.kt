package com.yuka.musicplayer.ui.views

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.ScannedMusicItem
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun LibraryView(
    musicRootDirectory: File,
    scannedItems: List<ScannedMusicItem>,
    isScanning: Boolean,
    playingFile: File?,
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

    val playableCount = remember(scannedItems) { scannedItems.count { it.isSupported } }
    val unsupportedCount = remember(scannedItems) { scannedItems.count { !it.isSupported } }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 14.dp, vertical = 6.dp)
    ) {
        // --- Root Music Directory Terminal Banner ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF090D18), RoundedCornerShape(8.dp))
                .border(0.8.dp, accent.copy(alpha = 0.22f), RoundedCornerShape(8.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "ROOT: ",
                        color = accent,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = TerminalFont
                    )
                    Text(
                        text = musicRootDirectory.absolutePath,
                        color = TerminalWhite,
                        fontSize = 9.sp,
                        fontFamily = TerminalFont,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
                Spacer(modifier = Modifier.height(2.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    if (isScanning) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(8.dp),
                            strokeWidth = 1.5.dp,
                            color = accent
                        )
                        Text(
                            text = "SCANNING DIRECTORY...",
                            color = accent,
                            fontSize = 8.5.sp,
                            fontFamily = TerminalFont,
                            fontWeight = FontWeight.Bold
                        )
                    } else {
                        Text(
                            text = "$playableCount PLAYABLE",
                            color = accent,
                            fontSize = 8.5.sp,
                            fontFamily = TerminalFont,
                            fontWeight = FontWeight.Bold
                        )
                        if (unsupportedCount > 0) {
                            Text(
                                text = "·  $unsupportedCount UNSUPPORTED",
                                color = Color(0xFFFF5252),
                                fontSize = 8.5.sp,
                                fontFamily = TerminalFont,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.width(8.dp))

            Box(
                modifier = Modifier
                    .border(0.8.dp, accent.copy(alpha = 0.5f), RoundedCornerShape(5.dp))
                    .background(accent.copy(alpha = 0.12f), RoundedCornerShape(5.dp))
                    .clickable {
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        onChangeDirectory()
                    }
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = "CHANGE",
                    color = accent,
                    fontSize = 8.5.sp,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        // --- Library Control Bar (Title, Sort, Refresh) ---
        Row(
            modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "STORAGE (${filteredItems.size})",
                color = TerminalWhite,
                fontSize = 11.sp,
                letterSpacing = 0.8.sp,
                fontFamily = ModernSansFont,
                fontWeight = FontWeight.Bold
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Sort Toggle Button
                Box(
                    modifier = Modifier
                        .border(0.8.dp, accent.copy(alpha = 0.40f), RoundedCornerShape(5.dp))
                        .background(accent.copy(alpha = 0.08f), RoundedCornerShape(5.dp))
                        .clickable {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            onCycleSort()
                        }
                        .padding(horizontal = 7.dp, vertical = 3.dp)
                ) {
                    Text(
                        text = "⇵ ${sortMode.shortLabel}",
                        color = accent,
                        fontSize = 8.5.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.SemiBold,
                        letterSpacing = 0.5.sp
                    )
                }

                // Refresh Button
                Box(
                    modifier = Modifier
                        .border(0.8.dp, accent.copy(alpha = 0.40f), RoundedCornerShape(5.dp))
                        .background(accent.copy(alpha = 0.08f), RoundedCornerShape(5.dp))
                        .clickable {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            onRefresh()
                        }
                        .padding(horizontal = 7.dp, vertical = 3.dp)
                ) {
                    Text(
                        text = "⟳ REFRESH",
                        color = accent,
                        fontSize = 8.5.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.SemiBold,
                        letterSpacing = 0.5.sp
                    )
                }
            }
        }

        // --- Search Box ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(34.dp)
                .border(0.8.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(6.dp))
                .background(Color(0xFF0B101D), RoundedCornerShape(6.dp))
                .padding(horizontal = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(">", color = accent, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 12.sp)
            Spacer(modifier = Modifier.width(8.dp))
            BasicTextField(
                value = searchQuery,
                onValueChange = onSearchChange,
                modifier = Modifier.weight(1f),
                textStyle = TextStyle(color = TerminalWhite, fontFamily = ModernSansFont, fontSize = 11.5.sp),
                cursorBrush = SolidColor(accent),
                singleLine = true,
                decorationBox = { innerTextField ->
                    Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        if (searchQuery.isEmpty()) {
                            Text(
                                "SEARCH ALL TRACKS & FOLDERS...",
                                color = TerminalGray.copy(alpha = 0.6f),
                                fontFamily = ModernSansFont,
                                fontSize = 11.sp
                            )
                        }
                        innerTextField()
                    }
                }
            )
            if (searchQuery.isNotEmpty()) {
                Text(
                    "✕",
                    color = TerminalGray,
                    fontSize = 12.sp,
                    fontFamily = TerminalFont,
                    modifier = Modifier.clickable { onSearchChange("") }.padding(4.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        // --- Scanned Tracks List ---
        LazyColumn(modifier = Modifier.weight(1f).fillMaxWidth()) {
            items(filteredItems, key = { it.file.absolutePath }) { item ->
                val file = item.file
                val isSupported = item.isSupported
                val isPlaying = file.absolutePath == playingFile?.absolutePath
                val inPlaylist = playlistSet.contains(file.absolutePath)
                val displayName = file.nameWithoutExtension.ifEmpty { file.name }
                val itemAlpha = if (isSupported) 1f else 0.42f

                val (trackTitle, trackArtist) = remember(displayName) {
                    com.yuka.musicplayer.util.TrackTitleParser.parse(displayName)
                }

                val dateFormatted = remember(file.lastModified()) {
                    SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(file.lastModified()))
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 2.dp)
                        .alpha(itemAlpha)
                        .background(
                            if (isPlaying) accent.copy(alpha = 0.12f) else Color(0xFF090D18),
                            RoundedCornerShape(8.dp)
                        )
                        .border(
                            width = if (isPlaying) 1.dp else 0.7.dp,
                            color = when {
                                isPlaying -> accent.copy(alpha = 0.65f)
                                !isSupported -> Color(0xFFFF5252).copy(alpha = 0.15f)
                                else -> com.yuka.musicplayer.ui.theme.CardBorderSubtle
                            },
                            shape = RoundedCornerShape(8.dp)
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
                        .padding(horizontal = 10.dp, vertical = 7.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (isPlaying) {
                        // Left vertical accent indicator bar
                        Box(
                            modifier = Modifier
                                .width(3.dp)
                                .height(22.dp)
                                .background(accent, RoundedCornerShape(1.5.dp))
                        )
                        Spacer(modifier = Modifier.width(7.dp))

                        // Playing Wave Bars Indicator
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(1.5.dp),
                            verticalAlignment = Alignment.Bottom,
                            modifier = Modifier.height(12.dp)
                        ) {
                            Box(modifier = Modifier.width(2.dp).fillMaxHeight(0.6f).background(accent, RoundedCornerShape(1.dp)))
                            Box(modifier = Modifier.width(2.dp).fillMaxHeight(1.0f).background(accent, RoundedCornerShape(1.dp)))
                            Box(modifier = Modifier.width(2.dp).fillMaxHeight(0.4f).background(accent, RoundedCornerShape(1.dp)))
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                    }

                    // Two-line Track Hierarchy: Line 1 Title, Line 2 Artist & Metadata
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = trackTitle,
                            color = when {
                                isPlaying -> accent
                                isSupported -> TerminalWhite
                                else -> TerminalGray
                            },
                            fontFamily = ModernSansFont,
                            fontWeight = if (isPlaying) FontWeight.Bold else FontWeight.SemiBold,
                            fontSize = 12.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Spacer(modifier = Modifier.height(1.dp))
                        val secondaryMetadata = buildString {
                            if (trackArtist.isNotEmpty()) append(trackArtist)
                            if (item.breadcrumb.isNotEmpty()) {
                                if (isNotEmpty()) append(" · ")
                                append(item.breadcrumb)
                            }
                            if (sortMode == LibrarySortMode.DATE_DESC || sortMode == LibrarySortMode.DATE_ASC) {
                                if (isNotEmpty()) append(" · ")
                                append(dateFormatted)
                            }
                        }
                        if (secondaryMetadata.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(1.5.dp))
                            Text(
                                text = secondaryMetadata,
                                color = if (!isSupported) {
                                    TerminalGray.copy(alpha = 0.5f)
                                } else if (isPlaying) {
                                    accent.copy(alpha = 0.85f)
                                } else {
                                    Color.White.copy(alpha = 0.68f)
                                },
                                fontSize = 11.5.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Normal,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    // Format Badge: Supported vs Option B Warning Badge
                    if (isSupported) {
                        Box(
                            modifier = Modifier
                                .background(Color(0xFF101626), RoundedCornerShape(4.dp))
                                .border(
                                    0.5.dp,
                                    if (isPlaying) accent.copy(alpha = 0.35f) else com.yuka.musicplayer.ui.theme.BadgeBorderSubtle,
                                    RoundedCornerShape(4.dp)
                                )
                                .padding(horizontal = 5.dp, vertical = 1.5.dp)
                        ) {
                            Text(
                                text = item.formatLabel,
                                color = if (isPlaying) accent else TerminalGray,
                                fontSize = 8.sp,
                                fontFamily = TerminalFont,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    } else {
                        Box(
                            modifier = Modifier
                                .background(Color(0xFF2C1318), RoundedCornerShape(4.dp))
                                .border(0.6.dp, Color(0xFFFF5252).copy(alpha = 0.45f), RoundedCornerShape(4.dp))
                                .padding(horizontal = 5.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = "${item.formatLabel} · UNSUPPORTED",
                                color = Color(0xFFFF5252),
                                fontSize = 7.5.sp,
                                fontWeight = FontWeight.Bold,
                                fontFamily = TerminalFont
                            )
                        }
                    }

                    if (inPlaylist && isSupported) {
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "★",
                            color = accent,
                            fontSize = 10.sp,
                            fontFamily = TerminalFont
                        )
                    }
                }
            }
        }
    }
}
