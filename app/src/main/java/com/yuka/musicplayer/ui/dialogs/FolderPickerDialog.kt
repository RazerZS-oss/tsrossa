package com.yuka.musicplayer.ui.dialogs

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.components.CyberBottomSheet
import com.yuka.musicplayer.ui.components.GlyphFolder
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import java.io.File

@Composable
fun FolderPickerDialog(
    visible: Boolean,
    currentPath: File,
    onDismissRequest: () -> Unit,
    onSelectDirectory: (File) -> Unit
) {
    var browsingDir by remember(visible, currentPath) {
        mutableStateOf(if (currentPath.exists() && currentPath.isDirectory) currentPath else File("/sdcard"))
    }
    var manualPathInput by remember(browsingDir) {
        mutableStateOf(browsingDir.absolutePath)
    }

    val subdirectories = remember(browsingDir) {
        runCatching {
            if (browsingDir.exists() && browsingDir.canRead() && browsingDir.isDirectory) {
                browsingDir.listFiles { file ->
                    file.isDirectory && !file.name.startsWith(".") && file.canRead()
                }?.sortedBy { it.name.lowercase() } ?: emptyList()
            } else {
                emptyList()
            }
        }.getOrDefault(emptyList())
    }

    CyberBottomSheet(
        visible = visible,
        onDismissRequest = onDismissRequest,
        maxHeightFraction = 0.85f,
        maxWidth = 440.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp)
        ) {
            Text(
                text = "Select Root Music Folder",
                color = TerminalWhite,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = ModernSansFont
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Recursively scans audio files within this folder and all subfolders.",
                color = Color.White.copy(alpha = 0.65f),
                fontSize = 12.sp,
                fontFamily = ModernSansFont
            )

            Spacer(modifier = Modifier.height(14.dp))

            // M3 Tonal Path Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(m3SurfaceContainerHigh())
                    .padding(horizontal = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                GlyphFolder(color = LocalAccentColor.current, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                BasicTextField(
                    value = manualPathInput,
                    onValueChange = { manualPathInput = it },
                    modifier = Modifier.weight(1f),
                    textStyle = TextStyle(
                        color = TerminalWhite,
                        fontFamily = TerminalFont,
                        fontSize = 12.sp
                    ),
                    cursorBrush = SolidColor(LocalAccentColor.current),
                    singleLine = true
                )
                Spacer(modifier = Modifier.width(6.dp))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(10.dp))
                        .background(LocalAccentColor.current.copy(alpha = 0.18f))
                        .clickable {
                            val target = File(manualPathInput.trim())
                            if (target.exists() && target.isDirectory && target.canRead()) {
                                browsingDir = target
                            }
                        }
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = "Go",
                        color = LocalAccentColor.current,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = ModernSansFont
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Subdirectories list
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                // Parent navigation
                browsingDir.parentFile?.let { parent ->
                    item {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(m3SurfaceContainerHigh())
                                .clickable {
                                    browsingDir = parent
                                    manualPathInput = parent.absolutePath
                                }
                                .padding(horizontal = 14.dp, vertical = 11.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            GlyphFolder(color = LocalAccentColor.current, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(
                                text = ".. (Parent Folder)",
                                color = LocalAccentColor.current,
                                fontSize = 13.sp,
                                fontFamily = ModernSansFont,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }

                items(subdirectories) { dir ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(m3SurfaceContainerHigh())
                            .clickable {
                                browsingDir = dir
                                manualPathInput = dir.absolutePath
                            }
                            .padding(horizontal = 14.dp, vertical = 11.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        GlyphFolder(color = Color.White.copy(alpha = 0.5f), modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(12.dp))
                        Text(
                            text = dir.name,
                            color = TerminalWhite,
                            fontSize = 13.sp,
                            fontFamily = ModernSansFont,
                            maxLines = 1
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp)
                        .clip(RoundedCornerShape(22.dp))
                        .background(m3SurfaceContainerHigh())
                        .clickable { onDismissRequest() },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Cancel",
                        color = Color.White.copy(alpha = 0.8f),
                        fontSize = 13.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.Medium
                    )
                }

                Box(
                    modifier = Modifier
                        .weight(1.5f)
                        .height(44.dp)
                        .clip(RoundedCornerShape(22.dp))
                        .background(LocalAccentColor.current)
                        .clickable {
                            val chosen = File(manualPathInput.trim())
                            val finalDir = if (chosen.exists() && chosen.isDirectory && chosen.canRead()) chosen else browsingDir
                            if (finalDir.exists() && finalDir.isDirectory && finalDir.canRead()) {
                                onSelectDirectory(finalDir)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Select This Folder",
                        color = Color.Black,
                        fontSize = 13.sp,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}
