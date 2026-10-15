package com.yuka.musicplayer.ui.dialogs

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.components.CyberBottomSheet
import com.yuka.musicplayer.ui.theme.LocalAccentColor
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
        maxHeightFraction = 0.85f
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp)
        ) {
            Text(
                text = "— SELECT ROOT MUSIC DIRECTORY —",
                color = LocalAccentColor.current,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = TerminalFont
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "The player will recursively scan all audio files within this folder and all its subfolders.",
                color = TerminalGray,
                fontSize = 10.sp,
                fontFamily = TerminalFont
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Manual path entry box
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(36.dp)
                    .background(Color(0xFF090D18), RoundedCornerShape(4.dp))
                    .border(0.8.dp, LocalAccentColor.current.copy(alpha = 0.4f), RoundedCornerShape(4.dp))
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "DIR: ",
                    color = LocalAccentColor.current,
                    fontFamily = TerminalFont,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
                BasicTextField(
                    value = manualPathInput,
                    onValueChange = { manualPathInput = it },
                    modifier = Modifier.weight(1f),
                    textStyle = TextStyle(
                        color = TerminalWhite,
                        fontFamily = TerminalFont,
                        fontSize = 10.sp
                    ),
                    cursorBrush = SolidColor(LocalAccentColor.current),
                    singleLine = true
                )
                Spacer(modifier = Modifier.width(6.dp))
                Box(
                    modifier = Modifier
                        .background(LocalAccentColor.current.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                        .border(0.6.dp, LocalAccentColor.current, RoundedCornerShape(4.dp))
                        .clickable {
                            val target = File(manualPathInput.trim())
                            if (target.exists() && target.isDirectory && target.canRead()) {
                                browsingDir = target
                            }
                        }
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = "GO",
                        color = LocalAccentColor.current,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = TerminalFont
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Subdirectories list
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                // Parent navigation
                browsingDir.parentFile?.let { parent ->
                    item {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 3.dp)
                                .background(Color(0xFF0D1322), RoundedCornerShape(6.dp))
                                .clickable {
                                    browsingDir = parent
                                    manualPathInput = parent.absolutePath
                                }
                                .padding(horizontal = 10.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("📁  .. (Parent Folder)", color = LocalAccentColor.current, fontSize = 11.sp, fontFamily = TerminalFont)
                        }
                    }
                }

                items(subdirectories) { dir ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 2.dp)
                            .background(Color(0xFF090D18), RoundedCornerShape(6.dp))
                            .border(0.5.dp, Color.White.copy(alpha = 0.05f), RoundedCornerShape(6.dp))
                            .clickable {
                                browsingDir = dir
                                manualPathInput = dir.absolutePath
                            }
                            .padding(horizontal = 10.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "📁  ${dir.name}",
                            color = TerminalWhite,
                            fontSize = 11.5.sp,
                            fontFamily = TerminalFont,
                            maxLines = 1
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(Color(0xFF141923), RoundedCornerShape(6.dp))
                        .border(0.8.dp, TerminalGray.copy(alpha = 0.3f), RoundedCornerShape(6.dp))
                        .clickable { onDismissRequest() }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "CANCEL",
                        color = TerminalGray,
                        fontSize = 11.sp,
                        fontFamily = TerminalFont,
                        fontWeight = FontWeight.Bold
                    )
                }

                Box(
                    modifier = Modifier
                        .weight(1.5f)
                        .background(LocalAccentColor.current.copy(alpha = 0.2f), RoundedCornerShape(6.dp))
                        .border(1.dp, LocalAccentColor.current, RoundedCornerShape(6.dp))
                        .clickable {
                            val chosen = File(manualPathInput.trim())
                            val finalDir = if (chosen.exists() && chosen.isDirectory && chosen.canRead()) chosen else browsingDir
                            if (finalDir.exists() && finalDir.isDirectory && finalDir.canRead()) {
                                onSelectDirectory(finalDir)
                            }
                        }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "SELECT THIS FOLDER",
                        color = LocalAccentColor.current,
                        fontSize = 11.sp,
                        fontFamily = TerminalFont,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}
