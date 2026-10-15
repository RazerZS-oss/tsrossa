package com.yuka.musicplayer.ui.dialogs

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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

@Composable
fun CreatePlaylistDialog(
    visible: Boolean,
    onDismissRequest: () -> Unit,
    onConfirmCreate: (String) -> Unit
) {
    var playlistName by remember(visible) { mutableStateOf("") }

    CyberBottomSheet(
        visible = visible,
        onDismissRequest = onDismissRequest,
        maxHeightFraction = 0.40f,
        maxWidth = 400.dp,
        wrapHeight = true
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp)
        ) {
            Text(
                text = "— NEW PLAYLIST —",
                color = LocalAccentColor.current,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = TerminalFont
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Enter a name for your custom playlist.",
                color = TerminalGray,
                fontSize = 10.sp,
                fontFamily = TerminalFont
            )
            Spacer(modifier = Modifier.height(10.dp))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(36.dp)
                    .background(Color(0xFF090D18), RoundedCornerShape(4.dp))
                    .border(0.8.dp, LocalAccentColor.current.copy(alpha = 0.4f), RoundedCornerShape(4.dp))
                    .padding(horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                BasicTextField(
                    value = playlistName,
                    onValueChange = { playlistName = it },
                    modifier = Modifier.fillMaxWidth(),
                    textStyle = TextStyle(
                        color = TerminalWhite,
                        fontFamily = TerminalFont,
                        fontSize = 11.sp
                    ),
                    cursorBrush = SolidColor(LocalAccentColor.current),
                    singleLine = true,
                    decorationBox = { innerTextField ->
                        if (playlistName.isEmpty()) {
                            Text(
                                text = "PLAYLIST NAME...",
                                color = TerminalGray.copy(alpha = 0.5f),
                                fontSize = 11.sp,
                                fontFamily = TerminalFont
                            )
                        }
                        innerTextField()
                    }
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

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
                            if (playlistName.isNotBlank()) {
                                onConfirmCreate(playlistName.trim())
                            }
                        }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "CREATE",
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
