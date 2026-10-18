package com.yuka.musicplayer.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
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
import kotlinx.coroutines.launch

/**
 * Tactile touch wrapper providing a bouncy spring scale feedback when pressed on RenderThread.
 */
@Composable
fun TactileBox(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    pressedScale: Float = 0.80f,
    onLongClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit
) {
    val currentOnClick by rememberUpdatedState(onClick)
    val currentOnLongClick by rememberUpdatedState(onLongClick)
    val scope = rememberCoroutineScope()
    val accent = LocalAccentColor.current
    val haptic = LocalHapticFeedback.current
    var isPressed by remember { mutableStateOf(false) }
    var releaseJob by remember { mutableStateOf<kotlinx.coroutines.Job?>(null) }

    // Effective scale: make every press clearly visible (at most 0.84f even if caller passed 0.90f)
    val effectivePressedScale = pressedScale.coerceAtMost(0.84f)

    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) effectivePressedScale else 1f,
        animationSpec = spring(
            dampingRatio = if (isPressed) 0.65f else 0.42f,
            stiffness = if (isPressed) 900f else 520f
        ),
        label = "tactileScale"
    )
    val animatedPressAlpha by animateFloatAsState(
        targetValue = if (isPressed) 0.32f else 0f,
        animationSpec = tween(durationMillis = if (isPressed) 60 else 240),
        label = "tactileHalo"
    )
    val animatedRingScale by animateFloatAsState(
        targetValue = if (isPressed) 1.05f else 0.65f,
        animationSpec = spring(dampingRatio = 0.60f, stiffness = 550f),
        label = "tactileRing"
    )

    Box(
        modifier = Modifier
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .then(modifier)
            .drawWithContent {
                drawContent()
                if (animatedPressAlpha > 0.01f) {
                    val radius = (size.minDimension * 0.5f) * animatedRingScale
                    drawCircle(
                        color = accent.copy(alpha = animatedPressAlpha * 0.75f),
                        radius = radius
                    )
                    drawCircle(
                        color = accent.copy(alpha = animatedPressAlpha),
                        radius = radius,
                        style = Stroke(width = 1.8.dp.toPx())
                    )
                }
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
            .pointerInput(enabled, currentOnLongClick != null) {
                if (!enabled) return@pointerInput
                detectTapGestures(
                    onPress = {
                        releaseJob?.cancel()
                        isPressed = true
                        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        val downTime = System.currentTimeMillis()
                        try {
                            tryAwaitRelease()
                        } finally {
                            val elapsed = System.currentTimeMillis() - downTime
                            val remaining = (150L - elapsed).coerceAtLeast(0L)
                            releaseJob = scope.launch {
                                if (remaining > 0L) kotlinx.coroutines.delay(remaining)
                                isPressed = false
                            }
                        }
                    },
                    onLongPress = if (currentOnLongClick != null) {
                        {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            currentOnLongClick?.invoke()
                        }
                    } else null,
                    onTap = {
                        scope.launch {
                            // Brief 45ms visual beat so the user clearly sees the squish/glow before any modal opens
                            kotlinx.coroutines.delay(45L)
                            currentOnClick()
                        }
                    }
                )
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

// ==========================================
// MATERIAL 3 EXPANDED VECTOR GLYPHS (24dp)
// ==========================================

@Composable
fun GlyphSearch(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Search" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        drawCircle(
            color = color,
            radius = w * 0.30f,
            center = Offset(w * 0.42f, h * 0.42f),
            style = Stroke(width = stroke)
        )
        drawLine(
            color = color,
            start = Offset(w * 0.64f, h * 0.64f),
            end = Offset(w * 0.86f, h * 0.86f),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
    }
}

@Composable
fun GlyphMoreVert(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "More Options" }) {
        val w = size.width
        val h = size.height
        val r = 1.8.dp.toPx()

        drawCircle(color = color, radius = r, center = Offset(w * 0.5f, h * 0.25f))
        drawCircle(color = color, radius = r, center = Offset(w * 0.5f, h * 0.50f))
        drawCircle(color = color, radius = r, center = Offset(w * 0.5f, h * 0.75f))
    }
}

@Composable
fun GlyphFolder(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Folder" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        val folderPath = Path().apply {
            moveTo(w * 0.12f, h * 0.25f)
            lineTo(w * 0.40f, h * 0.25f)
            lineTo(w * 0.48f, h * 0.35f)
            lineTo(w * 0.88f, h * 0.35f)
            cubicTo(w * 0.92f, h * 0.35f, w * 0.92f, h * 0.40f, w * 0.92f, h * 0.45f)
            lineTo(w * 0.92f, h * 0.75f)
            cubicTo(w * 0.92f, h * 0.80f, w * 0.88f, h * 0.82f, w * 0.84f, h * 0.82f)
            lineTo(w * 0.16f, h * 0.82f)
            cubicTo(w * 0.12f, h * 0.82f, w * 0.08f, h * 0.80f, w * 0.08f, h * 0.75f)
            lineTo(w * 0.08f, h * 0.32f)
            cubicTo(w * 0.08f, h * 0.25f, w * 0.12f, h * 0.25f, w * 0.12f, h * 0.25f)
            close()
        }
        drawPath(folderPath, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphRefresh(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Refresh" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        val arcRect = androidx.compose.ui.geometry.Rect(w * 0.18f, h * 0.18f, w * 0.82f, h * 0.82f)
        drawArc(
            color = color,
            startAngle = -35f,
            sweepAngle = 280f,
            useCenter = false,
            topLeft = arcRect.topLeft,
            size = arcRect.size,
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )
        // Arrow head
        val arrow = Path().apply {
            moveTo(w * 0.80f, h * 0.14f)
            lineTo(w * 0.88f, h * 0.32f)
            lineTo(w * 0.68f, h * 0.32f)
            close()
        }
        drawPath(arrow, color = color, style = Fill)
    }
}

@Composable
fun GlyphSort(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Sort" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Down arrow on left
        drawLine(color = color, start = Offset(w * 0.32f, h * 0.20f), end = Offset(w * 0.32f, h * 0.78f), strokeWidth = stroke, cap = StrokeCap.Round)
        val downHead = Path().apply {
            moveTo(w * 0.20f, h * 0.64f)
            lineTo(w * 0.32f, h * 0.82f)
            lineTo(w * 0.44f, h * 0.64f)
        }
        drawPath(downHead, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Up arrow on right
        drawLine(color = color, start = Offset(w * 0.68f, h * 0.22f), end = Offset(w * 0.68f, h * 0.80f), strokeWidth = stroke, cap = StrokeCap.Round)
        val upHead = Path().apply {
            moveTo(w * 0.56f, h * 0.36f)
            lineTo(w * 0.68f, h * 0.18f)
            lineTo(w * 0.80f, h * 0.36f)
        }
        drawPath(upHead, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphQueue(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Queue" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        drawLine(color = color, start = Offset(w * 0.15f, h * 0.26f), end = Offset(w * 0.85f, h * 0.26f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.15f, h * 0.50f), end = Offset(w * 0.55f, h * 0.50f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.15f, h * 0.74f), end = Offset(w * 0.55f, h * 0.74f), strokeWidth = stroke, cap = StrokeCap.Round)

        // Small play triangle on right
        val tri = Path().apply {
            moveTo(w * 0.68f, h * 0.48f)
            lineTo(w * 0.88f, h * 0.62f)
            lineTo(w * 0.68f, h * 0.76f)
            close()
        }
        drawPath(tri, color = color, style = Fill)
    }
}

@Composable
fun GlyphAdd(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Add" }) {
        val w = size.width
        val h = size.height
        val stroke = 2.0.dp.toPx()

        drawLine(color = color, start = Offset(w * 0.5f, h * 0.20f), end = Offset(w * 0.5f, h * 0.80f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.20f, h * 0.5f), end = Offset(w * 0.80f, h * 0.5f), strokeWidth = stroke, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphDelete(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Delete" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Can body
        val binPath = Path().apply {
            moveTo(w * 0.24f, h * 0.34f)
            lineTo(w * 0.30f, h * 0.82f)
            cubicTo(w * 0.30f, h * 0.86f, w * 0.34f, h * 0.88f, w * 0.38f, h * 0.88f)
            lineTo(w * 0.62f, h * 0.88f)
            cubicTo(w * 0.66f, h * 0.88f, w * 0.70f, h * 0.86f, w * 0.70f, h * 0.82f)
            lineTo(w * 0.76f, h * 0.34f)
        }
        drawPath(binPath, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Lid horizontal
        drawLine(color = color, start = Offset(w * 0.16f, h * 0.34f), end = Offset(w * 0.84f, h * 0.34f), strokeWidth = stroke, cap = StrokeCap.Round)
        // Handle
        val handle = Path().apply {
            moveTo(w * 0.38f, h * 0.34f)
            lineTo(w * 0.38f, h * 0.22f)
            lineTo(w * 0.62f, h * 0.22f)
            lineTo(w * 0.62f, h * 0.34f)
        }
        drawPath(handle, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphClose(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Close" }) {
        val w = size.width
        val h = size.height
        val stroke = 2.0.dp.toPx()

        drawLine(color = color, start = Offset(w * 0.24f, h * 0.24f), end = Offset(w * 0.76f, h * 0.76f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.76f, h * 0.24f), end = Offset(w * 0.24f, h * 0.76f), strokeWidth = stroke, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphMusicNote(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Music" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Double musical note
        drawCircle(color = color, radius = w * 0.15f, center = Offset(w * 0.30f, h * 0.72f))
        drawCircle(color = color, radius = w * 0.15f, center = Offset(w * 0.72f, h * 0.60f))

        drawLine(color = color, start = Offset(w * 0.42f, h * 0.72f), end = Offset(w * 0.42f, h * 0.22f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.84f, h * 0.60f), end = Offset(w * 0.84f, h * 0.14f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.42f, h * 0.22f), end = Offset(w * 0.84f, h * 0.14f), strokeWidth = stroke * 1.8f, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphAlbum(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Album" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        drawCircle(color = color, radius = w * 0.40f, center = Offset(w * 0.5f, h * 0.5f), style = Stroke(width = stroke))
        drawCircle(color = color, radius = w * 0.18f, center = Offset(w * 0.5f, h * 0.5f), style = Stroke(width = stroke * 0.8f))
        drawCircle(color = color, radius = w * 0.06f, center = Offset(w * 0.5f, h * 0.5f), style = Fill)
    }
}

// Navigation M3 Specific Icons
@Composable
fun GlyphLibrary(
    color: Color,
    modifier: Modifier = Modifier.size(22.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Library" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // 3 Books or Shelf storage
        drawRoundRect(color = color, topLeft = Offset(w * 0.14f, h * 0.22f), size = androidx.compose.ui.geometry.Size(w * 0.18f, h * 0.62f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx()), style = Stroke(width = stroke))
        drawRoundRect(color = color, topLeft = Offset(w * 0.41f, h * 0.16f), size = androidx.compose.ui.geometry.Size(w * 0.18f, h * 0.68f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(2.dp.toPx()), style = Stroke(width = stroke))
        
        // Leaning book on right
        val slant = Path().apply {
            moveTo(w * 0.68f, h * 0.22f)
            lineTo(w * 0.84f, h * 0.26f)
            lineTo(w * 0.72f, h * 0.84f)
            lineTo(w * 0.56f, h * 0.80f)
            close()
        }
        drawPath(slant, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphPlaylists(
    color: Color,
    modifier: Modifier = Modifier.size(22.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Playlists" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        drawLine(color = color, start = Offset(w * 0.18f, h * 0.26f), end = Offset(w * 0.82f, h * 0.26f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.18f, h * 0.46f), end = Offset(w * 0.82f, h * 0.46f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.18f, h * 0.66f), end = Offset(w * 0.52f, h * 0.66f), strokeWidth = stroke, cap = StrokeCap.Round)

        // Musical note glyph on bottom right
        drawCircle(color = color, radius = w * 0.11f, center = Offset(w * 0.70f, h * 0.74f))
        drawLine(color = color, start = Offset(w * 0.79f, h * 0.74f), end = Offset(w * 0.79f, h * 0.56f), strokeWidth = stroke)
        drawLine(color = color, start = Offset(w * 0.79f, h * 0.56f), end = Offset(w * 0.88f, h * 0.60f), strokeWidth = stroke, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphNowPlaying(
    color: Color,
    modifier: Modifier = Modifier.size(22.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Now Playing" }) {
        val w = size.width
        val h = size.height
        val stroke = 2.0.dp.toPx()

        // Equalizer sound waves
        drawLine(color = color, start = Offset(w * 0.20f, h * 0.35f), end = Offset(w * 0.20f, h * 0.75f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.40f, h * 0.16f), end = Offset(w * 0.40f, h * 0.84f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.60f, h * 0.28f), end = Offset(w * 0.60f, h * 0.80f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.80f, h * 0.42f), end = Offset(w * 0.80f, h * 0.68f), strokeWidth = stroke, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphSettings(
    color: Color,
    modifier: Modifier = Modifier.size(22.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Settings" }) {
        val w = size.width
        val h = size.height
        val cx = w * 0.5f
        val cy = h * 0.5f
        val stroke = 1.8.dp.toPx()

        // Authentic M3 6-tooth Gear Wheel
        val outerR = w * 0.38f
        val innerR = w * 0.28f
        val holeR = w * 0.12f

        // Central hub ring
        drawCircle(color = color, radius = innerR, center = Offset(cx, cy), style = Stroke(width = stroke))
        // Center hollow hole
        drawCircle(color = color, radius = holeR, center = Offset(cx, cy), style = Stroke(width = stroke * 0.9f))

        // 6 Radial Cog Teeth evenly spaced at 60 deg
        for (i in 0 until 6) {
            val angleDeg = i * 60.0
            val rad = Math.toRadians(angleDeg)
            val cos = Math.cos(rad).toFloat()
            val sin = Math.sin(rad).toFloat()

            val p1 = Offset(cx + innerR * cos, cy + innerR * sin)
            val p2 = Offset(cx + outerR * cos, cy + outerR * sin)
            drawLine(color = color, start = p1, end = p2, strokeWidth = stroke * 1.8f, cap = StrokeCap.Round)
        }
    }
}

@Composable
fun GlyphDiagnostics(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Diagnostics" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // EKG / Pulse Activity Wave
        val path = Path().apply {
            moveTo(w * 0.12f, h * 0.50f)
            lineTo(w * 0.32f, h * 0.50f)
            lineTo(w * 0.42f, h * 0.22f)
            lineTo(w * 0.58f, h * 0.78f)
            lineTo(w * 0.68f, h * 0.38f)
            lineTo(w * 0.76f, h * 0.50f)
            lineTo(w * 0.88f, h * 0.50f)
        }
        drawPath(path, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphUpdate(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Update" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Clean M3 Downward Arrow inside Circular Arc
        val arcRect = androidx.compose.ui.geometry.Rect(w * 0.14f, h * 0.14f, w * 0.86f, h * 0.86f)
        drawArc(
            color = color,
            startAngle = 30f,
            sweepAngle = 300f,
            useCenter = false,
            topLeft = arcRect.topLeft,
            size = arcRect.size,
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )

        // Centered downward arrow shaft & point
        drawLine(color = color, start = Offset(w * 0.50f, h * 0.28f), end = Offset(w * 0.50f, h * 0.68f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.36f, h * 0.54f), end = Offset(w * 0.50f, h * 0.68f), strokeWidth = stroke, cap = StrokeCap.Round)
        drawLine(color = color, start = Offset(w * 0.64f, h * 0.54f), end = Offset(w * 0.50f, h * 0.68f), strokeWidth = stroke, cap = StrokeCap.Round)
    }
}

@Composable
fun GlyphVolume(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Volume" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        val speaker = Path().apply {
            moveTo(w * 0.16f, h * 0.36f)
            lineTo(w * 0.34f, h * 0.36f)
            lineTo(w * 0.56f, h * 0.20f)
            lineTo(w * 0.56f, h * 0.80f)
            lineTo(w * 0.34f, h * 0.64f)
            lineTo(w * 0.16f, h * 0.64f)
            close()
        }
        drawPath(speaker, color = color, style = Fill)

        // Arc sound wave
        val arcRect = androidx.compose.ui.geometry.Rect(w * 0.40f, h * 0.30f, w * 0.85f, h * 0.70f)
        drawArc(
            color = color,
            startAngle = -45f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = arcRect.topLeft,
            size = arcRect.size,
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )
    }
}

@Composable
fun GlyphBitPerfect(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Bit-Perfect" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Shield contour
        val shield = Path().apply {
            moveTo(w * 0.50f, h * 0.15f)
            lineTo(w * 0.82f, h * 0.25f)
            lineTo(w * 0.82f, h * 0.55f)
            cubicTo(w * 0.82f, h * 0.75f, w * 0.50f, h * 0.88f, w * 0.50f, h * 0.88f)
            cubicTo(w * 0.50f, h * 0.88f, w * 0.18f, h * 0.75f, w * 0.18f, h * 0.55f)
            lineTo(w * 0.18f, h * 0.25f)
            close()
        }
        drawPath(shield, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Checkmark inside
        val check = Path().apply {
            moveTo(w * 0.34f, h * 0.50f)
            lineTo(w * 0.46f, h * 0.62f)
            lineTo(w * 0.66f, h * 0.38f)
        }
        drawPath(check, color = color, style = Stroke(width = stroke * 1.1f, cap = StrokeCap.Round))
    }
}

@Composable
fun GlyphCheck(
    color: Color,
    modifier: Modifier = Modifier.size(16.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Check" }) {
        val w = size.width
        val h = size.height
        val stroke = 2.0.dp.toPx()
        val path = Path().apply {
            moveTo(w * 0.20f, h * 0.52f)
            lineTo(w * 0.42f, h * 0.74f)
            lineTo(w * 0.82f, h * 0.28f)
        }
        drawPath(path, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round, join = androidx.compose.ui.graphics.StrokeJoin.Round))
    }
}

@Composable
fun GlyphNotification(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Notification" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Bell outline
        val bell = Path().apply {
            moveTo(w * 0.50f, h * 0.15f)
            cubicTo(w * 0.38f, h * 0.15f, w * 0.28f, h * 0.28f, w * 0.28f, h * 0.45f)
            lineTo(w * 0.28f, h * 0.65f)
            lineTo(w * 0.18f, h * 0.75f)
            lineTo(w * 0.82f, h * 0.75f)
            lineTo(w * 0.72f, h * 0.65f)
            lineTo(w * 0.72f, h * 0.45f)
            cubicTo(w * 0.72f, h * 0.28f, w * 0.62f, h * 0.15f, w * 0.50f, h * 0.15f)
            close()
        }
        drawPath(bell, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Clapper arc
        drawArc(
            color = color,
            startAngle = 0f,
            sweepAngle = 180f,
            useCenter = false,
            topLeft = Offset(w * 0.40f, h * 0.75f),
            size = androidx.compose.ui.geometry.Size(w * 0.20f, h * 0.14f),
            style = Stroke(width = stroke, cap = StrokeCap.Round)
        )
    }
}

@Composable
fun GlyphDoNotDisturb(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Do Not Disturb" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Bell outline
        val bell = Path().apply {
            moveTo(w * 0.50f, h * 0.18f)
            cubicTo(w * 0.40f, h * 0.18f, w * 0.30f, h * 0.28f, w * 0.30f, h * 0.45f)
            lineTo(w * 0.30f, h * 0.65f)
            lineTo(w * 0.22f, h * 0.75f)
            lineTo(w * 0.78f, h * 0.75f)
            lineTo(w * 0.70f, h * 0.65f)
            lineTo(w * 0.70f, h * 0.45f)
            cubicTo(w * 0.70f, h * 0.28f, w * 0.60f, h * 0.18f, w * 0.50f, h * 0.18f)
        }
        drawPath(bell, color = color, style = Stroke(width = stroke, cap = StrokeCap.Round))

        // Slash through bell
        drawLine(
            color = color,
            start = Offset(w * 0.20f, h * 0.20f),
            end = Offset(w * 0.80f, h * 0.80f),
            strokeWidth = stroke * 1.1f,
            cap = StrokeCap.Round
        )
    }
}

@Composable
fun GlyphInfo(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Info" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Outer circle
        drawCircle(
            color = color,
            radius = w * 0.40f,
            center = Offset(w * 0.5f, h * 0.5f),
            style = Stroke(width = stroke)
        )

        // Upper dot
        drawCircle(
            color = color,
            radius = stroke * 0.75f,
            center = Offset(w * 0.5f, h * 0.35f)
        )

        // Vertical line
        drawLine(
            color = color,
            start = Offset(w * 0.5f, h * 0.48f),
            end = Offset(w * 0.5f, h * 0.68f),
            strokeWidth = stroke * 1.1f,
            cap = StrokeCap.Round
        )
    }
}

@Composable
fun GlyphLyrics(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Lyrics" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Outer rounded rect note card
        drawRoundRect(
            color = color,
            topLeft = Offset(w * 0.16f, h * 0.14f),
            size = androidx.compose.ui.geometry.Size(w * 0.68f, h * 0.72f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(3.dp.toPx(), 3.dp.toPx()),
            style = Stroke(width = stroke)
        )

        // 3 horizontal lyric lines
        drawLine(
            color = color,
            start = Offset(w * 0.30f, h * 0.35f),
            end = Offset(w * 0.70f, h * 0.35f),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
        drawLine(
            color = color,
            start = Offset(w * 0.30f, h * 0.50f),
            end = Offset(w * 0.62f, h * 0.50f),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
        drawLine(
            color = color,
            start = Offset(w * 0.30f, h * 0.65f),
            end = Offset(w * 0.52f, h * 0.65f),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
    }
}

@Composable
fun GlyphArrowBack(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Back" }) {
        val w = size.width
        val h = size.height
        val stroke = 2.dp.toPx()
        val centerY = h / 2f

        // Horizontal stem: exactly centered
        drawLine(
            color = color,
            start = Offset(w * 0.22f, centerY),
            end = Offset(w * 0.78f, centerY),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
        // Left arrow head: upper wing
        drawLine(
            color = color,
            start = Offset(w * 0.46f, centerY - h * 0.24f),
            end = Offset(w * 0.22f, centerY),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
        // Left arrow head: lower wing
        drawLine(
            color = color,
            start = Offset(w * 0.46f, centerY + h * 0.24f),
            end = Offset(w * 0.22f, centerY),
            strokeWidth = stroke,
            cap = StrokeCap.Round
        )
    }
}

@Composable
fun GlyphFilter(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Filter" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.8.dp.toPx()

        // Funnel path
        val path = Path().apply {
            moveTo(w * 0.16f, h * 0.22f)
            lineTo(w * 0.84f, h * 0.22f)
            lineTo(w * 0.58f, h * 0.52f)
            lineTo(w * 0.58f, h * 0.80f)
            lineTo(w * 0.42f, h * 0.72f)
            lineTo(w * 0.42f, h * 0.52f)
            close()
        }
        drawPath(
            path = path,
            color = color,
            style = Stroke(width = stroke, cap = StrokeCap.Round, join = StrokeJoin.Round)
        )
    }
}

@Composable
fun GlyphPin(
    color: Color,
    modifier: Modifier = Modifier.size(20.dp)
) {
    Canvas(modifier = modifier.semantics { contentDescription = "Pin" }) {
        val w = size.width
        val h = size.height
        val stroke = 1.6.dp.toPx()

        val pinPath = Path().apply {
            moveTo(w * 0.65f, h * 0.15f)
            lineTo(w * 0.85f, h * 0.35f)
            lineTo(w * 0.72f, h * 0.48f)
            lineTo(w * 0.62f, h * 0.38f)
            lineTo(w * 0.42f, h * 0.58f)
            lineTo(w * 0.48f, h * 0.68f)
            lineTo(w * 0.38f, h * 0.72f)
            lineTo(w * 0.28f, h * 0.62f)
            lineTo(w * 0.32f, h * 0.52f)
            lineTo(w * 0.42f, h * 0.58f)
            lineTo(w * 0.62f, h * 0.38f)
            close()
        }
        drawPath(
            path = pinPath,
            color = color,
            style = Stroke(width = stroke, cap = StrokeCap.Round, join = StrokeJoin.Round)
        )
        drawLine(
            color = color,
            start = Offset(w * 0.33f, h * 0.67f),
            end = Offset(w * 0.15f, h * 0.85f),
            strokeWidth = stroke * 1.1f,
            cap = StrokeCap.Round
        )
    }
}

