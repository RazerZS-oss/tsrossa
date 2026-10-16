package com.yuka.musicplayer.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.text.font.Font
import com.yuka.musicplayer.R

val LocalAccentColor = compositionLocalOf { Color(0xFF00FF00) }
val LocalBgMode = compositionLocalOf { "SIGNATURE" }
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

// ==========================================
// MATERIAL 3 (MATERIAL YOU) TONAL ELEVATIONS
// ==========================================

val TrueBlack = Color(0xFF000000)
val TerminalGreen = Color(0xFF00FF00)
val TerminalWhite = Color(0xFFF5F5F5)
val TerminalGray = Color(0xFF8E8E93)

// Base M3 Dark Surface Scale
val M3Surface = Color(0xFF0E0D13)
val M3SurfaceContainerLowest = Color(0xFF09080C)
val M3SurfaceContainerLow = Color(0xFF14121A)
val M3SurfaceContainer = Color(0xFF1B1822)
val M3SurfaceContainerHigh = Color(0xFF24212D)
val M3SurfaceContainerHighest = Color(0xFF2F2B3B)

// Preserved aliases for backwards compatibility with existing views
val SignatureDeepNavy = Color(0xFF0E0D13)
val SignatureSurfaceNavy = Color(0xFF1B1822)
val SurfaceContainerLow = M3SurfaceContainerLow
val SurfaceContainerHigh = M3SurfaceContainerHigh
val TrueBlackContainerLow = Color(0xFF0A0A0C)
val TrueBlackContainerHigh = Color(0xFF141418)

// Hairline border tokens (soft tonal borders for backwards-compatible callers)
val CardBorderSubtle = Color(0x00FFFFFF) // 100% borderless in M3 by default
val BadgeBorderSubtle = Color(0x14FFFFFF)

// Refined Palette Tokens
val SakuraPink = Color(0xFFFF85A1)
val VividViolet = Color(0xFFA259FF)
val SubtleMint = Color(0xFF64FFDA)
val PastelPurple = Color(0xFFB388FF)
val AudiophileAmber = Color(0xFFFFB300)
val AudiophileCyan = Color(0xFF00E5FF)

/**
 * Tonal container color resolver:
 * Calculates a smooth Material 3 tonal elevation by blending [LocalAccentColor]
 * into the active base surface at a specified tone ratio (typically 8% - 18%).
 */
fun resolveM3TonalSurface(
    baseSurface: Color,
    accent: Color,
    tintRatio: Float = 0.10f
): Color {
    return Color(
        red = (baseSurface.red * (1f - tintRatio) + accent.red * tintRatio).coerceIn(0f, 1f),
        green = (baseSurface.green * (1f - tintRatio) + accent.green * tintRatio).coerceIn(0f, 1f),
        blue = (baseSurface.blue * (1f - tintRatio) + accent.blue * tintRatio).coerceIn(0f, 1f),
        alpha = 1.0f
    )
}

/**
 * Convenience helper to get tonal container for a given bgMode.
 */
fun getM3ContainerColor(
    bgMode: String,
    accent: Color,
    level: Int = 1 // 0=lowest, 1=container, 2=high, 3=highest
): Color {
    val base = when (bgMode) {
        "BLACK" -> when (level) {
            0 -> Color(0xFF050505)
            1 -> Color(0xFF0E0E12)
            2 -> Color(0xFF16161C)
            else -> Color(0xFF202028)
        }
        else -> when (level) {
            0 -> M3SurfaceContainerLowest
            1 -> M3SurfaceContainer
            2 -> M3SurfaceContainerHigh
            else -> M3SurfaceContainerHighest
        }
    }
    val tint = when (level) {
        0 -> 0.05f
        1 -> 0.09f
        2 -> 0.14f
        else -> 0.18f
    }
    return resolveM3TonalSurface(base, accent, tint)
}

// Central dynamic M3 surface resolvers reading active LocalBgMode & LocalAccentColor
@Composable
@ReadOnlyComposable
fun m3SurfaceBase(): Color {
    val bgMode = LocalBgMode.current
    val accent = LocalAccentColor.current
    return if (bgMode == "BLACK") {
        resolveM3TonalSurface(Color(0xFF070709), accent, 0.05f)
    } else {
        resolveM3TonalSurface(Color(0xFF0A0A0C), accent, 0.07f)
    }
}

@Composable
@ReadOnlyComposable
fun m3SurfaceContainerLow(): Color {
    val bgMode = LocalBgMode.current
    val accent = LocalAccentColor.current
    return if (bgMode == "BLACK") {
        resolveM3TonalSurface(Color(0xFF08080A), accent, 0.06f)
    } else {
        resolveM3TonalSurface(Color(0xFF111114), accent, 0.10f)
    }
}

@Composable
@ReadOnlyComposable
fun m3SurfaceContainer(): Color {
    val bgMode = LocalBgMode.current
    val accent = LocalAccentColor.current
    return if (bgMode == "BLACK") {
        resolveM3TonalSurface(Color(0xFF0E0E11), accent, 0.09f)
    } else {
        resolveM3TonalSurface(Color(0xFF16161A), accent, 0.14f)
    }
}

@Composable
@ReadOnlyComposable
fun m3SurfaceContainerHigh(): Color {
    val bgMode = LocalBgMode.current
    val accent = LocalAccentColor.current
    return if (bgMode == "BLACK") {
        resolveM3TonalSurface(Color(0xFF141418), accent, 0.13f)
    } else {
        resolveM3TonalSurface(Color(0xFF1C1C21), accent, 0.18f)
    }
}

@Composable
@ReadOnlyComposable
fun m3ActivePillContainer(): Color {
    val accent = LocalAccentColor.current
    return accent.copy(alpha = 0.28f)
}

private val DarkColorScheme = darkColorScheme(
    primary = TerminalGreen,
    secondary = TerminalWhite,
    tertiary = TerminalGray,
    background = TrueBlack,
    surface = M3Surface,
    surfaceVariant = M3SurfaceContainerHigh,
    onPrimary = TrueBlack,
    onSecondary = TrueBlack,
    onTertiary = TrueBlack,
    onBackground = TerminalWhite,
    onSurface = TerminalWhite,
    onSurfaceVariant = Color(0xFFCAC4D0)
)

val ModernTypography = androidx.compose.material3.Typography(
    headlineSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Bold,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp
    ),
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
        letterSpacing = 0.sp
    ),
    titleSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
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
    bodySmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.2.sp
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.3.sp
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
