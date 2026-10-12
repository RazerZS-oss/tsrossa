package com.yuka.musicplayer.ui.views.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.BuildConfig
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import com.yuka.musicplayer.update.UpdateCheckState

@Composable
fun SystemManualSection(
    onOpenHelp: () -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "DOCUMENTATION & MANUAL", tag = "HELP") {
        TactileBox(
            onClick = onOpenHelp,
            pressedScale = 0.96f,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(6.dp))
                .background(Color(0xFF070B14))
                .border(0.8.dp, Color.White.copy(alpha = 0.12f), RoundedCornerShape(6.dp))
                .padding(horizontal = 12.dp, vertical = 10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "[ ? ] USER GUIDE & SYSTEM MANUAL",
                        color = TerminalWhite,
                        fontFamily = TerminalFont,
                        fontWeight = FontWeight.Bold,
                        fontSize = 11.sp
                    )
                    Text(
                        text = "Audio engine specifications, bit-perfect UAC, & gestures",
                        color = TerminalGray,
                        fontFamily = TerminalFont,
                        fontSize = 9.sp
                    )
                }
                Text("→", color = accent, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 12.sp)
            }
        }

        Spacer(modifier = Modifier.height(10.dp))
        Text(
            text = "AUDIO SPECIFICATIONS & CODEC SUPPORT",
            color = TerminalGray,
            fontFamily = TerminalFont,
            fontSize = 9.5.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(3.dp))
        Text(
            text = "• FLAC / WAV: Direct Integer PCM 16/24/32-bit up to 384kHz (0 dBFS Bit-Perfect).\n• MQA: Bitstream passthrough rendering for MQA-certified USB DACs.\n• DSD (.dsf / .dff): Convert to 24-bit/192kHz or 24-bit/352.8kHz FLAC for bit-perfect output.",
            color = TerminalGray.copy(alpha = 0.85f),
            fontFamily = TerminalFont,
            fontSize = 8.5.sp,
            lineHeight = 12.sp
        )
    }
}

@Composable
fun ApplicationUpdatesSection(
    updateCheckState: UpdateCheckState,
    onOpenUpdateDialog: () -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "APPLICATION UPDATES", tag = "v${BuildConfig.VERSION_NAME}") {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(6.dp))
                .border(
                    0.8.dp,
                    if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676).copy(alpha = 0.6f) else Color.White.copy(alpha = 0.08f),
                    RoundedCornerShape(6.dp)
                )
                .background(Color(0xFF070B14))
                .clickable { onOpenUpdateDialog() }
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f).padding(end = 8.dp)) {
                Text(
                    text = "BUILD v${BuildConfig.VERSION_NAME}",
                    color = TerminalWhite,
                    fontFamily = TerminalFont,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
                val statusDesc = when (updateCheckState) {
                    is UpdateCheckState.Checking -> "Checking GitHub releases..."
                    is UpdateCheckState.UpToDate -> "Application is up to date"
                    is UpdateCheckState.UpdateAvailable -> "New version ${updateCheckState.release.tagName} available!"
                    is UpdateCheckState.Error -> "Check failed: ${updateCheckState.message}"
                    is UpdateCheckState.Idle -> "Tap to scan for updates"
                }
                Text(
                    text = statusDesc,
                    color = when (updateCheckState) {
                        is UpdateCheckState.UpdateAvailable -> Color(0xFF00E676)
                        is UpdateCheckState.Checking -> Color(0xFFFFD700)
                        is UpdateCheckState.Error -> Color.Red
                        else -> TerminalGray
                    },
                    fontFamily = TerminalFont,
                    fontSize = 9.5.sp
                )
            }

            TactileBox(
                onClick = onOpenUpdateDialog,
                pressedScale = 0.90f,
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .border(
                        0.8.dp,
                        if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676) else accent.copy(alpha = 0.5f),
                        RoundedCornerShape(6.dp)
                    )
                    .background(
                        if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676).copy(alpha = 0.15f) else Color.Transparent
                    )
                    .padding(horizontal = 10.dp, vertical = 6.dp)
            ) {
                Text(
                    text = if (updateCheckState is UpdateCheckState.UpdateAvailable) "VIEW" else "CHECK",
                    color = if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676) else accent,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold,
                    fontSize = 10.sp
                )
            }
        }
    }
}
