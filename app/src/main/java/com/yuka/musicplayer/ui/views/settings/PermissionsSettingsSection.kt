package com.yuka.musicplayer.ui.views.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.dialogs.PermissionStatusRow
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont

@Composable
fun PermissionsSettingsSection(
    isNotificationGranted: Boolean = true,
    isStorageGranted: Boolean = true,
    isDndGranted: Boolean = false,
    isBatteryOptimizationIgnored: Boolean = true,
    onRequestNotification: () -> Unit = {},
    onRequestStorage: () -> Unit = {},
    onRequestDnd: () -> Unit = {},
    onRequestBatteryOptimization: () -> Unit = {},
    onOpenPermissionDialog: () -> Unit = {}
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "PERMISSIONS & SYSTEM ACCESS", tag = "HARDWARE IO") {
        PermissionStatusRow(
            title = "NOTIFICATION PERMISSION",
            subtitle = "Lockscreen player & MediaStyle controls",
            isGranted = isNotificationGranted,
            grantedText = "ACTIVE (GRANTED)",
            deniedText = "DISABLED / RESTRICTED",
            onActionClick = onRequestNotification
        )

        Spacer(modifier = Modifier.height(6.dp))

        PermissionStatusRow(
            title = "AUDIO STORAGE ACCESS",
            subtitle = "Direct C++ fopen FLAC/WAV file read",
            isGranted = isStorageGranted,
            grantedText = "ACTIVE (ALL FILES ACCESS)",
            deniedText = "RESTRICTED",
            onActionClick = onRequestStorage
        )

        Spacer(modifier = Modifier.height(6.dp))

        PermissionStatusRow(
            title = "BACKGROUND POWER (ANTI-KILLER)",
            subtitle = "Prevent OEM kill on Xiaomi/Oppo/Vivo/Samsung",
            isGranted = isBatteryOptimizationIgnored,
            grantedText = "UNRESTRICTED (IMMUNE)",
            deniedText = "OPTIMIZED (RESTRICTED)",
            onActionClick = onRequestBatteryOptimization
        )

        Spacer(modifier = Modifier.height(6.dp))

        PermissionStatusRow(
            title = "DO NOT DISTURB (DND)",
            subtitle = "Auto-mute ringtones during playback",
            isGranted = isDndGranted,
            grantedText = "ACTIVE (GRANTED)",
            deniedText = "OPTIONAL (NOT GRANTED)",
            onActionClick = onRequestDnd
        )

        Spacer(modifier = Modifier.height(8.dp))

        TactileBox(
            onClick = onOpenPermissionDialog,
            pressedScale = 0.96f,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(6.dp))
                .background(Color(0xFF070B14))
                .border(0.8.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(6.dp))
                .padding(vertical = 9.dp)
        ) {
            Text(
                text = "RE-OPEN SETUP WIZARD",
                color = accent,
                fontFamily = TerminalFont,
                fontWeight = FontWeight.Bold,
                fontSize = 10.5.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
