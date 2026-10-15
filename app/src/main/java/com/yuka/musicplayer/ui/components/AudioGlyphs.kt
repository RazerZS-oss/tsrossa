package com.yuka.musicplayer.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite

import androidx.compose.ui.graphics.graphicsLayer

/**
 * Tactile touch wrapper providing a bouncy spring scale feedback when pressed on RenderThread.
 */
@Composable
fun TactileBox(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    pressedScale: Float = 0.92f,
    content: @Composable BoxScope.() -> Unit
) {
    val currentOnClick by rememberUpdatedState(onClick)
    var isPressed by remember { mutableStateOf(false) }
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) pressedScale else 1f,
        animationSpec = spring(dampingRatio = 0.65f, stiffness = 600f),
        label = "tactileScale"
    )

    Box(
        modifier = modifier
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .semantics(mergeDescendants = true) {
                role = Role.Button
                onClick {
                    if (enabled) {
                        currentOnClick()
                        true
                    } else false
                }
            }
            .pointerInput(enabled) {
                if (!enabled) return@pointerInput
                awaitEachGesture {
                    awaitFirstDown(requireUnconsumed = false)
                    isPressed = true
                    val up = try {
                        waitForUpOrCancellation()
                    } finally {
                        isPressed = false
                    }
                    if (up != null) {
                        currentOnClick()
                    }
                }
            },
        contentAlignment = Alignment.Center,
        content = content
    )
}

/**
 * Precision geometric Canvas glyphs for player controls.
 */
@Composable
fun GlyphPlay(
    color: Color,
    modifier: Modifier = Modifier.size(18.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Play" }) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.22f, h * 0.12f)
            lineTo(w * 0.88f, h * 0.50f)
            lineTo(w * 0.22f, h * 0.88f)
            close()
        }
        drawPath(path, color, style = Fill)
    }
}

@Composable
fun GlyphPause(
    color: Color,
    modifier: Modifier = Modifier.size(18.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Pause" }) {
        val w = size.width
        val h = size.height
        val barWidth = w * 0.26f
        val gap = w * 0.24f
        val barHeight = h * 0.76f
        val top = (h - barHeight) / 2f

        // Left bar
        drawRoundRect(
            color = color,
            topLeft = Offset((w - (barWidth * 2 + gap)) / 2f, top),
            size = androidx.compose.ui.geometry.Size(barWidth, barHeight),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx(), 2.dp.toPx())
        )
        // Right bar
        drawRoundRect(
            color = color,
            topLeft = Offset((w - (barWidth * 2 + gap)) / 2f + barWidth + gap, top),
            size = androidx.compose.ui.geometry.Size(barWidth, barHeight),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx(), 2.dp.toPx())
        )
    }
}

@Composable
fun GlyphPrev(
    color: Color,
    modifier: Modifier = Modifier.size(18.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Previous Track" }) {
        val w = size.width
        val h = size.height
        val barW = w * 0.12f

        // Left vertical stopper bar
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.12f, h * 0.18f),
            size = androidx.compose.ui.geometry.Size(barW, h * 0.64f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(1.dp.toPx(), 1.dp.toPx())
        )

        // Triangle pointing left
        val triPath = Path().apply {
            moveTo(w * 0.88f, h * 0.18f)
            lineTo(w * 0.28f, h * 0.50f)
            lineTo(w * 0.88f, h * 0.82f)
            close()
        }
        drawPath(triPath, color, style = Fill)
    }
}

@Composable
fun GlyphNext(
    color: Color,
    modifier: Modifier = Modifier.size(18.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Next Track" }) {
        val w = size.width
        val h = size.height
        val barW = w * 0.12f

        // Triangle pointing right
        val triPath = Path().apply {
            moveTo(w * 0.12f, h * 0.18f)
            lineTo(w * 0.72f, h * 0.50f)
            lineTo(w * 0.12f, h * 0.82f)
            close()
        }
        drawPath(triPath, color, style = Fill)

        // Right vertical stopper bar
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.76f, h * 0.18f),
            size = androidx.compose.ui.geometry.Size(barW, h * 0.64f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(1.dp.toPx(), 1.dp.toPx())
        )
    }
}

@Composable
fun GlyphShuffle(
    color: Color,
    modifier: Modifier = Modifier.size(16.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Toggle Shuffle" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Upper to lower crossover
        val path1 = Path().apply {
            moveTo(w * 0.15f, h * 0.25f)
            cubicTo(w * 0.45f, h * 0.25f, w * 0.55f, h * 0.75f, w * 0.85f, h * 0.75f)
        }
        drawPath(path1, color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Lower to upper crossover
        val path2 = Path().apply {
            moveTo(w * 0.15f, h * 0.75f)
            cubicTo(w * 0.45f, h * 0.75f, w * 0.55f, h * 0.25f, w * 0.85f, h * 0.25f)
        }
        drawPath(path2, color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Arrows at ends
        drawPath(
            Path().apply {
                moveTo(w * 0.70f, h * 0.12f)
                lineTo(w * 0.88f, h * 0.25f)
                lineTo(w * 0.70f, h * 0.38f)
            },
            color,
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )
        drawPath(
            Path().apply {
                moveTo(w * 0.70f, h * 0.62f)
                lineTo(w * 0.88f, h * 0.75f)
                lineTo(w * 0.70f, h * 0.88f)
            },
            color,
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )
    }
}

@Composable
fun GlyphRepeat(
    color: Color,
    modifier: Modifier = Modifier.size(16.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Toggle Repeat" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Rounded loop rectangle path
        val loopPath = Path().apply {
            moveTo(w * 0.85f, h * 0.45f)
            lineTo(w * 0.85f, h * 0.68f)
            cubicTo(w * 0.85f, h * 0.82f, w * 0.78f, h * 0.85f, w * 0.68f, h * 0.85f)
            lineTo(w * 0.32f, h * 0.85f)
            cubicTo(w * 0.22f, h * 0.85f, w * 0.15f, h * 0.78f, w * 0.15f, h * 0.68f)
            lineTo(w * 0.15f, h * 0.32f)
            cubicTo(w * 0.15f, h * 0.22f, w * 0.22f, h * 0.15f, w * 0.32f, h * 0.15f)
            lineTo(w * 0.85f, h * 0.15f)
        }
        drawPath(loopPath, color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Loop Arrow head at top-right
        val arrowPath = Path().apply {
            moveTo(w * 0.70f, h * 0.02f)
            lineTo(w * 0.88f, h * 0.15f)
            lineTo(w * 0.70f, h * 0.28f)
        }
        drawPath(arrowPath, color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

/**
 * Premium Hero Play/Pause button with luminous ambient bloom and tactile scale.
 */
@Composable
fun HeroPlayButton(
    isPlaying: Boolean,
    accentColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: Dp = 64.dp
) {
    TactileBox(
        onClick = onClick,
        modifier = modifier
            .size(size)
            .background(
                color = accentColor,
                shape = CircleShape
            )
            .shadow(
                elevation = 8.dp,
                shape = CircleShape,
                ambientColor = accentColor,
                spotColor = accentColor
            )
    ) {
        val iconColor = Color(0xFF070A12) // Deep navy on neon hero background
        if (isPlaying) {
            GlyphPause(color = iconColor, modifier = Modifier.size(24.dp))
        } else {
            // Slight offset for visual optical balance on play triangle
            Box(modifier = Modifier.padding(start = 3.dp)) {
                GlyphPlay(color = iconColor, modifier = Modifier.size(24.dp))
            }
        }
    }
}

/**
 * Secondary circular tactile transport button (Prev / Next).
 */
@Composable
fun SecondaryTransportButton(
    onClick: () -> Unit,
    accentColor: Color,
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    content: @Composable () -> Unit
) {
    TactileBox(
        onClick = onClick,
        modifier = modifier
            .size(size)
            .background(
                color = Color(0xFF101626),
                shape = CircleShape
            )
            .border(
                width = 0.8.dp,
                color = accentColor.copy(alpha = 0.25f),
                shape = CircleShape
            )
    ) {
        content()
    }
}

/**
 * Modern pill chip with micro-LED status dot for mode toggles.
 */
@Composable
fun ModePillChip(
    label: String,
    isActive: Boolean,
    accentColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null
) {
    TactileBox(
        onClick = onClick,
        pressedScale = 0.94f,
        modifier = modifier
            .height(34.dp)
            .background(
                color = if (isActive) accentColor.copy(alpha = 0.12f) else Color(0xFF0D121F),
                shape = RoundedCornerShape(17.dp)
            )
            .border(
                width = 0.8.dp,
                color = if (isActive) accentColor.copy(alpha = 0.5f) else Color.White.copy(alpha = 0.08f),
                shape = RoundedCornerShape(17.dp)
            )
            .padding(horizontal = 10.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (icon != null) {
                icon()
                Spacer(modifier = Modifier.width(6.dp))
            }

            // Micro LED status dot
            Box(
                modifier = Modifier
                    .size(5.dp)
                    .background(
                        color = if (isActive) accentColor else Color(0xFF444444),
                        shape = CircleShape
                    )
            )

            Spacer(modifier = Modifier.width(6.dp))

            Text(
                text = label,
                color = if (isActive) accentColor else TerminalWhite.copy(alpha = 0.75f),
                fontFamily = com.yuka.musicplayer.ui.theme.ModernSansFont,
                fontWeight = FontWeight.SemiBold,
                fontSize = 10.sp,
                letterSpacing = 0.6.sp,
                maxLines = 1
            )
        }
    }
}

/**
 * Geometric vector glyphs for monochrome hardware aesthetic (replaces system emojis).
 */
@Composable
fun GlyphBolt(
    color: Color,
    modifier: Modifier = Modifier.size(14.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Warmup / Power" }) {
        val w = size.width
        val h = size.height
        val boltPath = Path().apply {
            moveTo(w * 0.55f, h * 0.05f)
            lineTo(w * 0.20f, h * 0.55f)
            lineTo(w * 0.48f, h * 0.55f)
            lineTo(w * 0.40f, h * 0.95f)
            lineTo(w * 0.80f, h * 0.45f)
            lineTo(w * 0.52f, h * 0.45f)
            close()
        }
        drawPath(boltPath, color = color, style = Fill)
    }
}

@Composable
fun GlyphLock(
    color: Color,
    modifier: Modifier = Modifier.size(13.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Locked" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.6.dp.toPx()

        // Shackle (arched top)
        val shacklePath = Path().apply {
            moveTo(w * 0.28f, h * 0.45f)
            lineTo(w * 0.28f, h * 0.28f)
            cubicTo(w * 0.28f, h * 0.10f, w * 0.72f, h * 0.10f, w * 0.72f, h * 0.28f)
            lineTo(w * 0.72f, h * 0.45f)
        }
        drawPath(shacklePath, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Body (solid rounded rect)
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.16f, h * 0.45f),
            size = androidx.compose.ui.geometry.Size(w * 0.68f, h * 0.50f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx(), 2.dp.toPx())
        )

        // Keyhole dot
        drawCircle(
            color = Color(0xFF070A12),
            radius = 1.2.dp.toPx(),
            center = Offset(w * 0.50f, h * 0.66f)
        )
    }
}

@Composable
fun GlyphUnlock(
    color: Color,
    modifier: Modifier = Modifier.size(13.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Unlocked" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.6.dp.toPx()

        // Open shackle (tilted/lifted top)
        val shacklePath = Path().apply {
            moveTo(w * 0.28f, h * 0.45f)
            lineTo(w * 0.28f, h * 0.24f)
            cubicTo(w * 0.28f, h * 0.06f, w * 0.72f, h * 0.06f, w * 0.72f, h * 0.24f)
            lineTo(w * 0.72f, h * 0.32f)
        }
        drawPath(shacklePath, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Body
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.16f, h * 0.45f),
            size = androidx.compose.ui.geometry.Size(w * 0.68f, h * 0.50f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx(), 2.dp.toPx())
        )

        // Keyhole dot
        drawCircle(
            color = Color(0xFF070A12),
            radius = 1.2.dp.toPx(),
            center = Offset(w * 0.50f, h * 0.66f)
        )
    }
}

@Composable
fun GlyphClipboard(
    color: Color,
    modifier: Modifier = Modifier.size(13.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Clipboard" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.4.dp.toPx()

        // Board outline
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.18f, h * 0.22f),
            size = androidx.compose.ui.geometry.Size(w * 0.64f, h * 0.72f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(1.5.dp.toPx(), 1.5.dp.toPx()),
            style = Stroke(width = stroke)
        )

        // Top clip
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.34f, h * 0.10f),
            size = androidx.compose.ui.geometry.Size(w * 0.32f, h * 0.18f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(1.dp.toPx(), 1.dp.toPx())
        )

        // Text lines inside board
        drawLine(color = color, start = Offset(w * 0.30f, h * 0.46f), end = Offset(w * 0.70f, h * 0.46f), strokeWidth = stroke)
        drawLine(color = color, start = Offset(w * 0.30f, h * 0.62f), end = Offset(w * 0.64f, h * 0.62f), strokeWidth = stroke)
        drawLine(color = color, start = Offset(w * 0.30f, h * 0.76f), end = Offset(w * 0.55f, h * 0.76f), strokeWidth = stroke)
    }
}

@Composable
fun GlyphWarning(
    color: Color,
    modifier: Modifier = Modifier.size(13.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Warning" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.5.dp.toPx()

        // Equilateral triangle outline with rounded corners
        val triPath = Path().apply {
            moveTo(w * 0.50f, h * 0.12f)
            lineTo(w * 0.90f, h * 0.86f)
            lineTo(w * 0.10f, h * 0.86f)
            close()
        }
        drawPath(triPath, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Exclamation vertical line
        drawLine(
            color = color,
            start = Offset(w * 0.50f, h * 0.38f),
            end = Offset(w * 0.50f, h * 0.62f),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )

        // Exclamation dot
        drawCircle(
            color = color,
            radius = stroke * 0.6f,
            center = Offset(w * 0.50f, h * 0.75f)
        )
    }
}
