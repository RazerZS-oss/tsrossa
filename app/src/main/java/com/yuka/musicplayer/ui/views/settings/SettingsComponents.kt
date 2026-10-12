package com.yuka.musicplayer.ui.views.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.components.TactileBox
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite

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
            .background(Color(0xFF070B14), RoundedCornerShape(8.dp))
            .border(0.8.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(8.dp))
            .padding(3.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        items.forEach { (item, label) ->
            val isSelected = item == selectedItem
            TactileBox(
                onClick = { onItemSelected(item) },
                pressedScale = 0.95f,
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(6.dp))
                    .background(
                        if (isSelected) accent.copy(alpha = 0.18f) else Color.Transparent
                    )
                    .border(
                        0.8.dp,
                        if (isSelected) accent.copy(alpha = 0.6f) else Color.Transparent,
                        RoundedCornerShape(6.dp)
                    )
                    .padding(vertical = 7.dp, horizontal = 4.dp)
            ) {
                Text(
                    text = label,
                    color = if (isSelected) accent else TerminalGray,
                    fontFamily = TerminalFont,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                    fontSize = 10.sp,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

@Composable
fun SettingsCard(
    title: String,
    tag: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val accent = LocalAccentColor.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(Color(0xFF0D121F))
            .border(0.8.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(10.dp))
            .padding(14.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .background(accent, CircleShape)
                )
                Text(
                    text = title,
                    color = TerminalWhite,
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Bold,
                    fontSize = 11.sp,
                    letterSpacing = 0.5.sp
                )
            }
            if (tag != null) {
                Text(
                    text = tag,
                    color = accent.copy(alpha = 0.8f),
                    fontFamily = TerminalFont,
                    fontSize = 9.sp,
                    letterSpacing = 0.5.sp
                )
            }
        }
        content()
    }
}

@Composable
fun SettingsToggleRow(
    title: String,
    subtitle: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    val accent = LocalAccentColor.current
    TactileBox(
        onClick = { onCheckedChange(!isChecked) },
        pressedScale = 0.98f,
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(6.dp))
            .background(Color(0xFF070B14))
            .border(
                0.8.dp,
                if (isChecked) accent.copy(alpha = 0.35f) else Color.White.copy(alpha = 0.05f),
                RoundedCornerShape(6.dp)
            )
            .padding(horizontal = 12.dp, vertical = 9.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f).padding(end = 10.dp)) {
                Text(
                    text = title,
                    color = TerminalWhite,
                    fontFamily = TerminalFont,
                    fontSize = 10.5.sp,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    text = subtitle,
                    color = TerminalGray,
                    fontFamily = TerminalFont,
                    fontSize = 9.sp
                )
            }

            Box(
                modifier = Modifier
                    .size(width = 38.dp, height = 20.dp)
                    .background(
                        if (isChecked) accent.copy(alpha = 0.25f) else Color(0xFF141926),
                        RoundedCornerShape(10.dp)
                    )
                    .border(
                        0.8.dp,
                        if (isChecked) accent else Color.White.copy(alpha = 0.15f),
                        RoundedCornerShape(10.dp)
                    )
                    .padding(horizontal = 3.dp),
                contentAlignment = if (isChecked) Alignment.CenterEnd else Alignment.CenterStart
            ) {
                Box(
                    modifier = Modifier
                        .size(13.dp)
                        .background(
                            if (isChecked) accent else TerminalGray,
                            CircleShape
                        )
                )
            }
        }
    }
}
