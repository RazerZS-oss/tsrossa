package com.yuka.musicplayer.util

import androidx.compose.ui.graphics.Color
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ColorContrastHelperTest {

    @Test
    fun testDarkColorIsNormalizedForContrast() {
        val darkBrown = Color(0xFF2B1D0C) // Very dark brown
        val normalized = ColorContrastHelper.normalizeDynamicAccent(darkBrown)
        val luminance = ColorContrastHelper.calculateLuminance(normalized)
        assertTrue("Normalized color must have sufficient luminance for dark backgrounds, got $luminance", luminance >= 0.18f)
    }

    @Test
    fun testMonochromeColorIsInfusedWithTint() {
        val pureGrey = Color(0xFF404040)
        val fallback = Color(0xFFFF85A1)
        val normalized = ColorContrastHelper.normalizeDynamicAccent(pureGrey, fallback)
        assertTrue("Zero saturation colors should blend with fallback tint", normalized != pureGrey)
    }

    @Test
    fun testNullOrDefaultArtworkFallsBackToUserAccent() {
        val userAccent = Color(0xFFA259FF)
        val chosen = ColorContrastHelper.resolveAccent(
            accentMode = "DYNAMIC",
            trackDominantColor = null,
            userFixedColor = userAccent
        )
        assertEquals(userAccent, chosen)
    }
}
