package com.yuka.musicplayer.util

import androidx.compose.ui.graphics.Color
import kotlin.math.max
import kotlin.math.min

/**
 * Ensures dynamic accent colors extracted from album art have sufficient luminance,
 * saturation, and contrast against dark UI backgrounds (#000000 / #070A12).
 */
object ColorContrastHelper {

    /**
     * Calculates WCAG relative luminance of a Compose Color.
     */
    fun calculateLuminance(color: Color): Float {
        fun channelLum(c: Float): Float {
            return if (c <= 0.03928f) c / 12.92f else Math.pow(((c + 0.055) / 1.055), 2.4).toFloat()
        }
        val r = channelLum(color.red)
        val g = channelLum(color.green)
        val b = channelLum(color.blue)
        return (0.2126f * r + 0.7152f * g + 0.0722f * b)
    }

    /**
     * Normalizes an extracted album art color:
     * - Clamps minimum luminance so text and button borders are never invisible against black.
     * - If saturation is near-zero (greyscale/monochrome art), infuses fallback tint.
     * - Clamps minimum brightness/lightness in HSV space.
     */
    fun normalizeDynamicAccent(
        color: Color,
        fallbackColor: Color = Color(0xFFFF85A1)
    ): Color {
        val r = color.red
        val g = color.green
        val b = color.blue

        val maxVal = max(r, max(g, b))
        val minVal = min(r, min(g, b))
        val delta = maxVal - minVal

        // Saturation calculation
        val sat = if (maxVal == 0f) 0f else delta / maxVal
        val lum = calculateLuminance(color)

        // Case 1: Near monochrome or black/white album art
        if (sat < 0.15f || (maxVal < 0.25f && delta < 0.05f)) {
            // Blend 40% extracted brightness with 60% fallback accent
            return Color(
                red = (fallbackColor.red * 0.75f + maxVal * 0.25f).coerceIn(0f, 1f),
                green = (fallbackColor.green * 0.75f + maxVal * 0.25f).coerceIn(0f, 1f),
                blue = (fallbackColor.blue * 0.75f + maxVal * 0.25f).coerceIn(0f, 1f),
                alpha = 1.0f
            )
        }

        // Case 2: Very dark color (e.g. dark navy, brown, dark metal art)
        var targetColor = color
        if (lum < 0.18f || maxVal < 0.55f) {
            val scale = if (maxVal > 0.05f) (0.65f / maxVal) else 3.0f
            val boostedR = (r * scale).coerceAtMost(1.0f)
            val boostedG = (g * scale).coerceAtMost(1.0f)
            val boostedB = (b * scale).coerceAtMost(1.0f)
            targetColor = Color(boostedR, boostedG, boostedB, 1.0f)
        }

        // Final check: if still below contrast floor, blend lightly with white
        val finalLum = calculateLuminance(targetColor)
        if (finalLum < 0.20f) {
            val blendFactor = (0.22f - finalLum) * 2.5f
            targetColor = Color(
                red = (targetColor.red + (1f - targetColor.red) * blendFactor).coerceIn(0f, 1f),
                green = (targetColor.green + (1f - targetColor.green) * blendFactor).coerceIn(0f, 1f),
                blue = (targetColor.blue + (1f - targetColor.blue) * blendFactor).coerceIn(0f, 1f),
                alpha = 1.0f
            )
        }

        return targetColor
    }

    /**
     * Resolves accent color considering user mode, missing art, and fallback.
     */
    fun resolveAccent(
        accentMode: String,
        trackDominantColor: Color?,
        userFixedColor: Color
    ): Color {
        if (accentMode == "FIXED") {
            return userFixedColor
        }
        if (trackDominantColor == null || trackDominantColor == Color(0xFF00FF00)) {
            return userFixedColor
        }
        return normalizeDynamicAccent(trackDominantColor, userFixedColor)
    }
}
