package com.yuka.musicplayer.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.M3SurfaceContainerLow
import com.yuka.musicplayer.ui.theme.resolveM3TonalSurface

/**
 * Authentic Material 3 Modal Bottom Sheet Container:
 * - Rounded top corners (28.dp).
 * - Zero border stroke (clean borderless tonal elevation).
 * - M3 SurfaceContainerLow tonal surface.
 * - Standard M3 drag handle pill (32.dp x 4.dp).
 */
@Composable
fun CyberBottomSheet(
    visible: Boolean,
    onDismissRequest: () -> Unit,
    modifier: Modifier = Modifier,
    maxHeightFraction: Float = 0.88f,
    maxWidth: Dp = 600.dp,
    wrapHeight: Boolean = false,
    content: @Composable ColumnScope.() -> Unit
) {
    if (visible) {
        val sheetSurface = com.yuka.musicplayer.ui.theme.m3SurfaceBase()

        Popup(
            alignment = Alignment.BottomCenter,
            onDismissRequest = onDismissRequest,
            properties = PopupProperties(focusable = true)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.65f))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null
                    ) { onDismissRequest() },
                contentAlignment = Alignment.BottomCenter
            ) {
                val boxMod = Modifier
                    .widthIn(max = maxWidth)
                    .fillMaxWidth()
                    .then(
                        if (wrapHeight) {
                            Modifier.fillMaxHeight(maxHeightFraction).wrapContentHeight(Alignment.Bottom)
                        } else {
                            Modifier.fillMaxHeight(maxHeightFraction)
                        }
                    )
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null
                    ) {} // consume touch inside sheet
                    .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                    .background(sheetSurface)

                Box(modifier = boxMod) {
                    Column(
                        modifier = modifier
                            .fillMaxWidth()
                            .then(if (wrapHeight) Modifier.wrapContentHeight() else Modifier.fillMaxHeight())
                            .padding(horizontal = 16.dp, vertical = 10.dp)
                    ) {
                        // Material 3 Centered Drag Handle Pill
                        Box(
                            modifier = Modifier
                                .align(Alignment.CenterHorizontally)
                                .padding(bottom = 12.dp)
                                .size(width = 32.dp, height = 4.dp)
                                .background(Color.White.copy(alpha = 0.25f), RoundedCornerShape(50))
                        )

                        content()
                    }
                }
            }
        }
    }
}
