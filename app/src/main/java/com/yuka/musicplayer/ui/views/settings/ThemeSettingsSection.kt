package com.yuka.musicplayer.ui.views.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
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
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.SakuraPink
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite

@Composable
fun ThemeSettingsSection(
    bgMode: String,
    onBgModeChange: (String) -> Unit,
    accentMode: String,
    onAccentModeChange: (String) -> Unit,
    accentFixedColorStr: String,
    onAccentFixedColorChange: (String) -> Unit
) {
    val accent = LocalAccentColor.current

    SettingsCard(title = "THEME & DISPLAY", tag = "VISUAL ENGINE") {
        Text(
            text = "BACKGROUND CANVAS",
            color = TerminalGray,
            fontFamily = TerminalFont,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(5.dp))

        val bgModes = listOf(
            "BLACK" to "TRUE BLACK",
            "SIGNATURE" to "NEON BLUE",
            "BLUR" to "WALLPAPER"
        )
        SettingsSegmentedControl(
            items = bgModes,
            selectedItem = bgMode,
            onItemSelected = onBgModeChange
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = "ACCENT COLOR MODE",
            color = TerminalGray,
            fontFamily = TerminalFont,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(5.dp))

        val accentModes = listOf(
            "DYNAMIC" to "DYNAMIC",
            "FIXED" to "FIXED COLOR"
        )
        SettingsSegmentedControl(
            items = accentModes,
            selectedItem = accentMode,
            onItemSelected = onAccentModeChange
        )

        if (accentMode == "FIXED") {
            Spacer(modifier = Modifier.height(10.dp))
            Text(
                text = "PALETTE SELECTION",
                color = TerminalGray,
                fontFamily = TerminalFont,
                fontSize = 9.5.sp,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(6.dp))

            val fixedColors = listOf(
                "#00FF00" to "NEON GREEN",
                "#00E5FF" to "CYAN",
                "#FFD700" to "AMBER",
                "#FF4081" to "PINK",
                "#B388FF" to "PURPLE"
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                fixedColors.forEach { (hex, _) ->
                    val color = Color(android.graphics.Color.parseColor(hex))
                    val isSelected = accentFixedColorStr.equals(hex, ignoreCase = true)
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(30.dp)
                            .clip(RoundedCornerShape(6.dp))
                            .background(color.copy(alpha = 0.25f))
                            .border(
                                width = if (isSelected) 1.5.dp else 0.8.dp,
                                color = if (isSelected) color else Color.White.copy(alpha = 0.1f),
                                shape = RoundedCornerShape(6.dp)
                            )
                            .clickable { onAccentFixedColorChange(hex) },
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .size(10.dp)
                                .background(color, CircleShape)
                        )
                    }
                }
            }
        }
    }
}
