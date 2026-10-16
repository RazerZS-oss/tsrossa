package com.yuka.musicplayer.ui.views.settings

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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.BuildConfig
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalWhite
import com.yuka.musicplayer.update.UpdateCheckState

@Composable
fun SystemManualSection(
    onOpenHelp: () -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "Documentation & Manual") {
        TactileBox(
            onClick = onOpenHelp,
            pressedScale = 0.96f,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(Color.White.copy(alpha = 0.04f))
                .padding(horizontal = 14.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f).padding(end = 8.dp)) {
                    Text(
                        text = "User Guide & System Architecture",
                        color = TerminalWhite,
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 13.5.sp
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "Bit-perfect UAC, FIFO timing, and gestures",
                        color = Color.White.copy(alpha = 0.55f),
                        fontFamily = ModernSansFont,
                        fontSize = 11.5.sp
                    )
                }
                Text("→", color = accent, fontFamily = ModernSansFont, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))
        Text(
            text = "Audio specifications",
            color = Color.White.copy(alpha = 0.70f),
            fontFamily = ModernSansFont,
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "• FLAC / WAV: Direct Integer PCM 16/24/32-bit up to 384kHz (0 dBFS Bit-Perfect).\n• MQA: Bitstream passthrough rendering for MQA-certified USB DACs.\n• DSD (.dsf / .dff): Convert to 24-bit/192kHz or 24-bit/352.8kHz FLAC for bit-perfect output.",
            color = Color.White.copy(alpha = 0.60f),
            fontFamily = ModernSansFont,
            fontSize = 11.5.sp,
            lineHeight = 16.sp
        )
    }
}

@Composable
fun ApplicationUpdatesSection(
    updateCheckState: UpdateCheckState,
    onOpenUpdateDialog: () -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "Application Updates") {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(Color.White.copy(alpha = 0.04f))
                .clickable { onOpenUpdateDialog() }
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f).padding(end = 10.dp)) {
                Text(
                    text = "Release v${BuildConfig.VERSION_NAME}",
                    color = TerminalWhite,
                    fontFamily = ModernSansFont,
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(2.dp))
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
                        else -> Color.White.copy(alpha = 0.55f)
                    },
                    fontFamily = ModernSansFont,
                    fontSize = 11.5.sp
                )
            }

            TactileBox(
                onClick = onOpenUpdateDialog,
                pressedScale = 0.90f,
                modifier = Modifier
                    .clip(RoundedCornerShape(50))
                    .background(
                        if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676).copy(alpha = 0.20f)
                        else accent.copy(alpha = 0.16f)
                    )
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Text(
                    text = if (updateCheckState is UpdateCheckState.UpdateAvailable) "VIEW" else "CHECK",
                    color = if (updateCheckState is UpdateCheckState.UpdateAvailable) Color(0xFF00E676) else accent,
                    fontFamily = ModernSansFont,
                    fontWeight = FontWeight.Bold,
                    fontSize = 11.sp
                )
            }
        }
    }
}
