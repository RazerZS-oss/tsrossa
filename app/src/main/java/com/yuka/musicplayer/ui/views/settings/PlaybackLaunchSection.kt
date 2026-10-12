package com.yuka.musicplayer.ui.views.settings

import android.content.SharedPreferences
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray

@Composable
fun PlaybackLaunchSection(
    prefs: SharedPreferences,
    keepAwake: Boolean,
    onKeepAwakeChange: (Boolean) -> Unit,
    defaultScreen: String,
    onDefaultScreenChange: (String) -> Unit,
    usbBufferProfile: Int = 1,
    onUsbBufferProfileChange: (Int) -> Unit = {}
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    val isSamsung = remember { com.yuka.musicplayer.util.SamsungAudioEffectHelper.isSamsungDevice() }

    SettingsCard(title = "PLAYBACK & AUDIOPHILE TUNING", tag = "AUDIO ENGINE") {
        SettingsToggleRow(
            title = "Keep Screen Awake",
            subtitle = "Prevent display timeout when audio is actively playing",
            isChecked = keepAwake,
            onCheckedChange = { awake ->
                onKeepAwakeChange(awake)
                prefs.edit().putBoolean("keep_awake", awake).apply()
            }
        )

        Spacer(modifier = Modifier.height(10.dp))
        Text("DEFAULT SCREEN ON LAUNCH", color = TerminalGray, fontFamily = TerminalFont, fontSize = 10.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(5.dp))

        val screens = listOf(
            "LIBRARY" to "LIBRARY",
            "PLAYLIST" to "PLAYLIST",
            "TRACK" to "NOW PLAYING"
        )
        SettingsSegmentedControl(
            items = screens,
            selectedItem = defaultScreen,
            onItemSelected = { screen ->
                onDefaultScreenChange(screen)
                prefs.edit().putString("default_screen", screen).apply()
            }
        )

        Spacer(modifier = Modifier.height(12.dp))
        Text("USB BUFFER DEPTH (JITTER PROFILE)", color = TerminalGray, fontFamily = TerminalFont, fontSize = 10.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(5.dp))

        val bufferProfiles = listOf(
            0 to "64ms (LOW LATENCY)",
            1 to "192ms (LOW JITTER)",
            2 to "500ms (MAX STABLE)"
        )
        SettingsSegmentedControl(
            items = bufferProfiles,
            selectedItem = usbBufferProfile,
            onItemSelected = { profile ->
                onUsbBufferProfileChange(profile)
                prefs.edit().putInt("usb_buffer_profile", profile).apply()
                val (transfers, packets) = when (profile) {
                    0 -> 8 to 8
                    2 -> 16 to 32
                    else -> 12 to 16
                }
                com.yuka.musicplayer.audio.AudioEngine.setUsbBufferProfile(transfers, packets)
            }
        )

        if (isSamsung) {
            Spacer(modifier = Modifier.height(14.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFF2A1B00), androidx.compose.foundation.shape.RoundedCornerShape(6.dp))
                    .border(0.8.dp, Color(0xFFFFB300).copy(alpha = 0.6f), androidx.compose.foundation.shape.RoundedCornerShape(6.dp))
                    .padding(8.dp),
                verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "⚠️ SAMSUNG DOLBY ATMOS BYPASS",
                        color = Color(0xFFFFB300),
                        fontFamily = TerminalFont,
                        fontSize = 9.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "Samsung One UI forces Dolby Atmos DSP on USB. For pure bit-perfect imaging & wide soundstage, turn Dolby Atmos and Equalizer OFF.",
                        color = TerminalGray,
                        fontFamily = TerminalFont,
                        fontSize = 8.5.sp,
                        lineHeight = 12.sp
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                com.yuka.musicplayer.ui.components.RetroButton(
                    text = "SETTINGS",
                    onClick = {
                        com.yuka.musicplayer.util.SamsungAudioEffectHelper.openSoundQualitySettings(context)
                    },
                    modifier = Modifier.height(28.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "⚡ USB OTG 5V VBUS HEADROOM & IMPEDANCE ADVISORY",
            color = Color(0xFFFF9100),
            fontFamily = TerminalFont,
            fontSize = 9.5.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(3.dp))
        Text(
            text = "Phone USB-C OTG ports deliver at most ~500mA (2.5W). High-current planar or high-impedance headphones can sag the 5V rail during bass transients, causing dynamic compression. For deep bass authority and maximum soundstage, use a dual-plug power injection OTG cable.",
            color = TerminalGray.copy(alpha = 0.85f),
            fontFamily = TerminalFont,
            fontSize = 9.sp,
            lineHeight = 13.sp
        )
    }
}
