package com.yuka.musicplayer.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

import androidx.compose.runtime.compositionLocalOf

import androidx.compose.ui.text.font.Font
import com.yuka.musicplayer.R

val LocalAccentColor = compositionLocalOf { Color(0xFF00FF00) }
val TerminalFont = FontFamily(Font(R.font.fantasquesans_regular))
val ModernSansFont = FontFamily.SansSerif

fun Color.blendWithWhite(ratio: Float): Color {
    return Color(
        red = this.red + (1f - this.red) * ratio,
        green = this.green + (1f - this.green) * ratio,
        blue = this.blue + (1f - this.blue) * ratio,
        alpha = this.alpha
    )
}

val TrueBlack = Color(0xFF000000)
val TerminalGreen = Color(0xFF00FF00)
val TerminalWhite = Color(0xFFF5F5F5)
val TerminalGray = Color(0xFF888888)

// Tsrossa Signature Precision Surface Architecture
val SignatureDeepNavy = Color(0xFF070A12)
val SignatureSurfaceNavy = Color(0xFF101626)
val SurfaceContainerLow = Color(0xFF0A0D14)
val SurfaceContainerHigh = Color(0xFF131926)
val TrueBlackContainerLow = Color(0xFF09090B)
val TrueBlackContainerHigh = Color(0xFF121215)
val CardBorderSubtle = Color(0x0DFFFFFF) // Color.White.copy(alpha = 0.05f)
val BadgeBorderSubtle = Color(0x14FFFFFF) // Color.White.copy(alpha = 0.08f)

// Refined Palette Tokens
val SakuraPink = Color(0xFFFF85A1)
val VividViolet = Color(0xFFA259FF)
val SubtleMint = Color(0xFF64FFDA)
val PastelPurple = Color(0xFFB388FF)
val AudiophileAmber = Color(0xFFFFB300)
val AudiophileCyan = Color(0xFF00E5FF)

private val DarkColorScheme = darkColorScheme(
    primary = TerminalGreen,
    secondary = TerminalWhite,
    tertiary = TerminalGray,
    background = TrueBlack,
    surface = SurfaceContainerLow,
    onPrimary = TrueBlack,
    onSecondary = TrueBlack,
    onTertiary = TrueBlack,
    onBackground = TerminalWhite,
    onSurface = TerminalWhite,
)

val ModernTypography = androidx.compose.material3.Typography(
    titleLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 20.sp,
        lineHeight = 26.sp,
        letterSpacing = (-0.01).sp
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        letterSpacing = (-0.01).sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 13.sp,
        lineHeight = 18.sp
    ),
    labelSmall = TextStyle(
        fontFamily = TerminalFont,
        fontWeight = FontWeight.Medium,
        fontSize = 10.sp,
        lineHeight = 14.sp,
        letterSpacing = 0.5.sp
    )
)

@Composable
fun KewMobileTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = ModernTypography,
        content = content
    )
}
