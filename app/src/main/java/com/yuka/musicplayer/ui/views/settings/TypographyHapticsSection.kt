package com.yuka.musicplayer.ui.views.settings

import android.content.SharedPreferences
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite

@Composable
fun TypographyHapticsSection(
    prefs: SharedPreferences,
    fontScale: Float,
    onFontScaleChange: (Float) -> Unit,
    hapticEnabled: Boolean,
    onHapticChange: (Boolean) -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "TYPOGRAPHY & HAPTICS", tag = "INTERFACE SCALE") {
        Text("GLOBAL FONT SCALE", color = TerminalGray, fontFamily = TerminalFont, fontSize = 10.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(5.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TactileBox(
                onClick = {
                    val newScale = (fontScale - 0.1f).coerceAtLeast(0.8f)
                    onFontScaleChange(newScale)
                    prefs.edit().putFloat("font_scale", newScale).apply()
                },
                pressedScale = 0.90f,
                modifier = Modifier
                    .size(width = 44.dp, height = 34.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xFF070B14))
                    .border(0.8.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(6.dp))
            ) {
                Text("-", color = accent, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 14.sp, modifier = Modifier.align(Alignment.Center))
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(34.dp)
                    .background(Color(0xFF070B14), RoundedCornerShape(6.dp))
                    .border(0.8.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(6.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "${String.format("%.1f", fontScale)}x SCALE",
                    color = TerminalWhite,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold,
                    fontSize = 11.sp
                )
            }

            TactileBox(
                onClick = {
                    val newScale = (fontScale + 0.1f).coerceAtMost(1.5f)
                    onFontScaleChange(newScale)
                    prefs.edit().putFloat("font_scale", newScale).apply()
                },
                pressedScale = 0.90f,
                modifier = Modifier
                    .size(width = 44.dp, height = 34.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xFF070B14))
                    .border(0.8.dp, accent.copy(alpha = 0.35f), RoundedCornerShape(6.dp))
            ) {
                Text("+", color = accent, fontFamily = TerminalFont, fontWeight = FontWeight.Bold, fontSize = 14.sp, modifier = Modifier.align(Alignment.Center))
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        SettingsToggleRow(
            title = "Haptic Tactile Feedback",
            subtitle = "Vibration ticks on button & transport interaction",
            isChecked = hapticEnabled,
            onCheckedChange = { enabled ->
                onHapticChange(enabled)
                prefs.edit().putBoolean("haptic_enabled", enabled).apply()
            }
        )
    }
}
