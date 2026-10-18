package com.yuka.musicplayer.ui.views.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalWhite

/**
 * Material 3 Segmented Pill Selector:
 * Container filled with tonal surface, active segment highlighted with LocalAccentColor pill.
 */
@Composable
fun <T> SettingsSegmentedControl(
    items: List<Pair<T, String>>,
    selectedItem: T,
    onItemSelected: (T) -> Unit,
    modifier: Modifier = Modifier
) {
    val accent = LocalAccentColor.current
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(50))
            .background(com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh())
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        items.forEach { (item, label) ->
            val isSelected = item == selectedItem
            TactileBox(
                onClick = { onItemSelected(item) },
                pressedScale = 0.95f,
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(50))
                    .background(
                        if (isSelected) com.yuka.musicplayer.ui.theme.m3ActivePillContainer() else Color.Transparent
                    )
                    .padding(vertical = 8.dp, horizontal = 4.dp)
            ) {
                Text(
                    text = label,
                    color = if (isSelected) accent else com.yuka.musicplayer.ui.theme.m3OnSurfaceVariant(),
                    fontFamily = ModernSansFont,
                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium,
                    fontSize = 11.5.sp,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

/**
 * Material 3 Grouped Settings Card:
 * Borderless dynamic tonal container (RoundedCornerShape(24.dp)) with generous internal padding.
 */
@Composable
fun SettingsCard(
    title: String,
    tag: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val accent = LocalAccentColor.current
    val containerBg = com.yuka.musicplayer.ui.theme.m3SurfaceContainerLow()

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(containerBg)
            .padding(18.dp)
    ) {
        Text(
            text = title,
            color = accent,
            fontFamily = ModernSansFont,
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp,
            letterSpacing = 0.1.sp,
            modifier = Modifier.padding(bottom = 12.dp)
        )
        content()
    }
}

/**
 * Material 3 Toggle Row with authentic M3 Switch.
 */
@Composable
fun SettingsToggleRow(
    title: String,
    subtitle: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    val accent = LocalAccentColor.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(com.yuka.musicplayer.ui.theme.m3SubtleFill(alpha = 0.06f))
            .clickable { onCheckedChange(!isChecked) }
            .padding(horizontal = 14.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f).padding(end = 12.dp)) {
            Text(
                text = title,
                color = com.yuka.musicplayer.ui.theme.m3OnSurface(),
                fontFamily = ModernSansFont,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.Medium
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = subtitle,
                color = com.yuka.musicplayer.ui.theme.m3OnSurfaceVariant(),
                fontFamily = ModernSansFont,
                fontSize = 11.5.sp
            )
        }

        Switch(
            checked = isChecked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = if (com.yuka.musicplayer.util.ColorContrastHelper.calculateLuminance(accent) > 0.45f) Color(0xFF0E0D13) else Color.White,
                checkedTrackColor = accent,
                uncheckedThumbColor = com.yuka.musicplayer.ui.theme.m3OnSurfaceVariant(),
                uncheckedTrackColor = com.yuka.musicplayer.ui.theme.m3SubtleFill(alpha = 0.12f)
            )
        )
    }
}

enum class SettingsSubPage(val title: String) {
    ROOT("Settings"),
    APPEARANCE("Appearance"),
    PLAYBACK_AUDIO("Playback & Audio"),
    SETUP("Setup & Permissions"),
    UPDATES("Updates"),
    ABOUT("About")
}

@Composable
fun SettingsMenuCard(
    title: String,
    subtitle: String,
    icon: @Composable () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val accent = LocalAccentColor.current
    val containerBg = com.yuka.musicplayer.ui.theme.m3SurfaceContainerLow()

    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(containerBg)
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(14.dp))
                .background(accent.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            icon()
        }

        Spacer(modifier = Modifier.width(14.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = com.yuka.musicplayer.ui.theme.m3OnSurface(),
                fontSize = 15.sp,
                fontFamily = ModernSansFont,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = subtitle,
                color = com.yuka.musicplayer.ui.theme.m3OnSurfaceVariant(),
                fontSize = 12.sp,
                fontFamily = ModernSansFont,
                lineHeight = 16.sp
            )
        }

        Spacer(modifier = Modifier.width(8.dp))

        Text(
            text = "›",
            color = com.yuka.musicplayer.ui.theme.m3OnSurfaceVariant(),
            fontSize = 20.sp,
            fontWeight = FontWeight.Light
        )
    }
}

