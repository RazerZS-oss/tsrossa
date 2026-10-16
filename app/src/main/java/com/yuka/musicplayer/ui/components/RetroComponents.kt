package com.yuka.musicplayer.ui.components

import androidx.compose.foundation.background
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalWhite

@Composable
fun RetroButton(
    text: String,
    onClick: () -> Unit,
    color: Color = TerminalWhite,
    modifier: Modifier = Modifier,
    isSelected: Boolean = false
) {
    val isAccent = isSelected || color == LocalAccentColor.current
    TactileBox(
        onClick = onClick,
        pressedScale = 0.94f,
        modifier = modifier
            .defaultMinSize(minWidth = 44.dp, minHeight = 40.dp)
            .clip(RoundedCornerShape(50))
            .background(
                if (isAccent) LocalAccentColor.current.copy(alpha = 0.18f) else Color.White.copy(alpha = 0.08f)
            )
            .padding(horizontal = 14.dp, vertical = 8.dp)
    ) {
        Text(
            text = text,
            color = if (isAccent) LocalAccentColor.current else color,
            fontFamily = ModernSansFont,
            fontWeight = if (isAccent) FontWeight.SemiBold else FontWeight.Medium,
            fontSize = 12.sp,
            textAlign = TextAlign.Center
        )
    }
}

/**
 * Material 3 Action Item for Dialogs & Bottom Sheets:
 * Borderless tonal row with tactile press physics and modern sans typography.
 */
@Composable
fun RetroActionItem(
    icon: String,
    label: String,
    isDestructive: Boolean = false,
    onClick: () -> Unit
) {
    val accent = if (isDestructive) Color(0xFFFF5252) else LocalAccentColor.current
    TactileBox(
        onClick = onClick,
        pressedScale = 0.96f,
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 3.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(Color.White.copy(alpha = 0.05f))
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(accent.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = icon,
                    color = accent,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = ModernSansFont
                )
            }
            Spacer(modifier = Modifier.width(14.dp))
            Text(
                text = label,
                color = if (isDestructive) accent else TerminalWhite,
                fontSize = 13.5.sp,
                fontFamily = ModernSansFont,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

@Composable
fun RetroCircularButton(
    icon: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: androidx.compose.ui.unit.Dp = 28.dp,
    isActive: Boolean = false,
    activeColor: Color = LocalAccentColor.current
) {
    val bgColor = if (isActive) activeColor.copy(alpha = 0.22f) else Color.White.copy(alpha = 0.08f)
    val textColor = if (isActive) activeColor else TerminalWhite.copy(alpha = 0.85f)

    TactileBox(
        onClick = onClick,
        pressedScale = 0.88f,
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(bgColor)
    ) {
        Text(
            text = icon,
            color = textColor,
            fontSize = (size.value * 0.45f).sp,
            fontFamily = ModernSansFont,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
    }
}
