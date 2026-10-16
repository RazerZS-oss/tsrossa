package com.yuka.musicplayer.ui.views

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.basicMarquee
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.systemGestureExclusion
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.ui.components.*
import com.yuka.musicplayer.ui.theme.LocalAccentColor
import com.yuka.musicplayer.ui.theme.ModernSansFont
import com.yuka.musicplayer.ui.theme.TerminalFont
import com.yuka.musicplayer.ui.theme.TerminalGray
import com.yuka.musicplayer.ui.theme.TerminalWhite
import com.yuka.musicplayer.ui.theme.m3ActivePillContainer
import com.yuka.musicplayer.ui.theme.m3SurfaceContainer
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerHigh
import com.yuka.musicplayer.ui.theme.m3SurfaceContainerLow
import kotlin.math.roundToInt
import kotlinx.coroutines.isActive

/**
 * Material 3 Precision Scrubber with smooth 60/120fps local time interpolation.
 * Clean, borderless Material You slider track with responsive dragging thumb.
 */
@Composable
fun PrecisionScrubber(
    playbackPosition: Double,
    durationSeconds: Double,
    isPlaying: Boolean,
    dynamicColor: Color,
    onSeekTo: (Double) -> Unit,
    modifier: Modifier = Modifier
) {
    var isDragging by remember { mutableStateOf(false) }
    var dragProgress by remember { mutableFloatStateOf(0f) }

    // Guard against snap-back: holds user's target seek position until JNI confirms playback arrived near it
    var pendingSeekTargetSec by remember { mutableStateOf<Double?>(null) }
    var pendingSeekTimeoutNanos by remember { mutableLongStateOf(0L) }

    // Real-time anchor tracking from hardware / JNI updates
    var anchorPosSec by remember { mutableDoubleStateOf(playbackPosition) }
    var anchorNanos by remember { mutableLongStateOf(System.nanoTime()) }

    // Synchronize anchor whenever playbackPosition updates from JNI or when seek finishes
    LaunchedEffect(playbackPosition) {
        val now = System.nanoTime()
        val target = pendingSeekTargetSec
        if (target != null) {
            // Clear pending seek guard if engine is within 1.5s of target, or if 500ms timeout expired
            val diff = kotlin.math.abs(playbackPosition - target)
            val timedOut = now > pendingSeekTimeoutNanos
            if (diff < 1.5 || timedOut) {
                pendingSeekTargetSec = null
                anchorPosSec = playbackPosition
                anchorNanos = now
            }
        } else if (!isDragging) {
            anchorPosSec = playbackPosition
            anchorNanos = now
        }
    }

    // Single unified 60/120fps continuous progress float dedicated ONLY for draw phase
    val smoothProgress = remember { Animatable(0f) }
    var displayPosSec by remember { mutableIntStateOf(playbackPosition.toInt()) }
    val durSecInt = remember(durationSeconds) { durationSeconds.toInt() }

    // Continuous glide loop synchronized with display refresh rate, paused when app is not resumed
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    LaunchedEffect(isPlaying, durationSeconds) {
        if (durationSeconds <= 0.0) return@LaunchedEffect
        while (isActive) {
            if (!lifecycleOwner.lifecycle.currentState.isAtLeast(androidx.lifecycle.Lifecycle.State.RESUMED)) {
                kotlinx.coroutines.delay(250L)
                continue
            }
            var targetFrac = 0f
            withFrameNanos { frameNanos ->
                if (!isDragging) {
                    val guardTarget = pendingSeekTargetSec
                    val currentPosSec = if (guardTarget != null) {
                        guardTarget
                    } else if (isPlaying) {
                        val elapsedSec = ((frameNanos - anchorNanos).coerceAtLeast(0L)) / 1_000_000_000.0
                        (anchorPosSec + elapsedSec).coerceIn(0.0, durationSeconds)
                    } else {
                        anchorPosSec.coerceIn(0.0, durationSeconds)
                    }

                    targetFrac = (currentPosSec / durationSeconds).toFloat().coerceIn(0f, 1f)

                    val secInt = currentPosSec.toInt()
                    if (secInt != displayPosSec) {
                        displayPosSec = secInt
                    }
                }
            }
            if (!isDragging) {
                smoothProgress.snapTo(targetFrac)
            }
        }
    }

    val curSecInt = if (isDragging) {
        (dragProgress * durationSeconds).toInt()
    } else if (pendingSeekTargetSec != null) {
        pendingSeekTargetSec!!.toInt()
    } else {
        displayPosSec
    }

    val posStr = remember(curSecInt) {
        val curMin = curSecInt / 60
        val curSec = curSecInt % 60
        String.format(java.util.Locale.US, "%02d:%02d", curMin, curSec)
    }

    val durStr = remember(durSecInt) {
        val dMin = durSecInt / 60
        val dSec = durSecInt % 60
        String.format(java.util.Locale.US, "%02d:%02d", dMin, dSec)
    }

    val animatedThumbRadius by animateFloatAsState(
        targetValue = if (isDragging) 7f else 5.5f,
        animationSpec = spring(dampingRatio = 0.6f, stiffness = 500f),
        label = "thumbRadius"
    )

    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .systemGestureExclusion()
    ) {
        val totalWidthPx = constraints.maxWidth.toFloat()
        val density = LocalDensity.current
        val trackStart = with(density) { 6.dp.toPx() }
        val trackEnd = totalWidthPx - trackStart
        val trackWidth = (trackEnd - trackStart).coerceAtLeast(1f)

        Column(modifier = Modifier.fillMaxWidth()) {
            Canvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(28.dp)
                    .pointerInput(durationSeconds) {
                        awaitEachGesture {
                            val down = awaitFirstDown(requireUnconsumed = false)
                            isDragging = true
                            dragProgress = ((down.position.x - trackStart) / trackWidth).coerceIn(0f, 1f)

                            while (true) {
                                val event = awaitPointerEvent()
                                val change = event.changes.firstOrNull { it.id == down.id } ?: break
                                if (!change.pressed) {
                                    change.consume()
                                    break
                                }
                                change.consume()
                                dragProgress = ((change.position.x - trackStart) / trackWidth).coerceIn(0f, 1f)
                            }

                            val finalSeekSec = dragProgress.toDouble() * durationSeconds
                            // Engage anti snap-back guard: keep thumb at seek target until JNI catches up
                            pendingSeekTargetSec = finalSeekSec
                            pendingSeekTimeoutNanos = System.nanoTime() + 600_000_000L // 600ms safety timeout
                            anchorPosSec = finalSeekSec
                            anchorNanos = System.nanoTime()
                            isDragging = false
                            onSeekTo(finalSeekSec)
                        }
                    }
            ) {
                val cy = size.height / 2f
                val trackStroke = 4.dp.toPx()
                val currentProgress = if (isDragging) {
                    dragProgress
                } else if (pendingSeekTargetSec != null && durationSeconds > 0.0) {
                    (pendingSeekTargetSec!! / durationSeconds).toFloat().coerceIn(0f, 1f)
                } else {
                    smoothProgress.value
                }
                val thumbXPx = trackStart + currentProgress * trackWidth
                val thumbR = with(density) { animatedThumbRadius.dp.toPx() }

                // M3 Inactive track rail
                drawLine(
                    color = Color.White.copy(alpha = 0.16f),
                    start = Offset(trackStart, cy),
                    end = Offset(trackEnd, cy),
                    strokeWidth = trackStroke,
                    cap = StrokeCap.Round
                )

                // M3 Active progress rail
                if (currentProgress > 0f) {
                    drawLine(
                        color = dynamicColor,
                        start = Offset(trackStart, cy),
                        end = Offset(thumbXPx, cy),
                        strokeWidth = trackStroke,
                        cap = StrokeCap.Round
                    )
                }

                // M3 Circular Thumb
                drawCircle(
                    color = dynamicColor,
                    radius = thumbR,
                    center = Offset(thumbXPx, cy)
                )
            }

            // Timestamps Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = posStr,
                    color = if (isDragging) dynamicColor else Color.White.copy(alpha = 0.75f),
                    fontFamily = TerminalFont,
                    fontWeight = FontWeight.Medium,
                    fontSize = 11.5.sp
                )
                Text(
                    text = durStr,
                    color = Color.White.copy(alpha = 0.60f),
                    fontFamily = TerminalFont,
                    fontSize = 11.5.sp
                )
            }
        }
    }
}

/**
 * Radical Material 3 (Material You) Now Playing Screen.
 */
@Composable
fun TrackView(
    track: TrackInfo?,
    playbackPosition: Double,
    isPlaying: Boolean,
    currentVolume: Float,
    isShuffleEnabled: Boolean,
    repeatMode: RepeatMode,
    priorityQueueSize: Int,
    onTogglePlay: () -> Unit,
    onVolumeChange: (Float) -> Unit,
    onPlayNext: () -> Unit,
    onPlayPrev: () -> Unit,
    onToggleShuffle: () -> Unit,
    onCycleRepeat: () -> Unit,
    onOpenQueue: () -> Unit,
    onSeekTo: (Double) -> Unit = {},
    isHardwareVolumeActive: Boolean = false,
    modifier: Modifier = Modifier
) {
    val dynamicColor = LocalAccentColor.current
    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 24.dp, vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        if (track == null) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 80.dp)
                    .clip(RoundedCornerShape(28.dp))
                    .background(Color.White.copy(alpha = 0.05f))
                    .padding(40.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    GlyphMusicNote(color = dynamicColor.copy(alpha = 0.5f), modifier = Modifier.size(48.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "No track selected",
                        color = Color.White.copy(alpha = 0.70f),
                        fontFamily = ModernSansFont,
                        fontWeight = FontWeight.Medium,
                        fontSize = 16.sp
                    )
                }
            }
            return
        }

        // 1. Hero Album Art Container (Square with clean 24.dp rounded corners, zero artificial radial glow)
        val albumScale by animateFloatAsState(
            targetValue = if (isPlaying) 1.0f else 0.95f,
            animationSpec = spring(dampingRatio = 0.80f, stiffness = 400f),
            label = "albumArtScale"
        )

        Box(
            modifier = Modifier
                .fillMaxWidth(0.88f)
                .aspectRatio(1f)
                .graphicsLayer {
                    scaleX = albumScale
                    scaleY = albumScale
                },
            contentAlignment = Alignment.Center
        ) {
            // Album art squircle surface with container fallback
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(24.dp))
                    .background(m3SurfaceContainerLow())
            ) {
                if (track.coverArt != null) {
                    Image(
                        bitmap = track.coverArt.asImageBitmap(),
                        contentDescription = "Album Art",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        GlyphMusicNote(
                            color = dynamicColor.copy(alpha = 0.6f),
                            modifier = Modifier.size(64.dp)
                        )
                    }
                }
            }
        }

        // 2. Left-Aligned Track Metadata (Bold Title & Subtle Artist/Album)
        Column(
            horizontalAlignment = Alignment.Start,
            modifier = Modifier.fillMaxWidth().padding(horizontal = 6.dp)
        ) {
            @OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
            Text(
                text = track.title,
                color = TerminalWhite,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = ModernSansFont,
                textAlign = TextAlign.Start,
                maxLines = 1,
                modifier = Modifier
                    .fillMaxWidth()
                    .basicMarquee(
                        iterations = Int.MAX_VALUE,
                        delayMillis = 1500,
                        velocity = 28.dp,
                        spacing = androidx.compose.foundation.MarqueeSpacing(36.dp)
                    )
            )

            Spacer(modifier = Modifier.height(4.dp))

            val artistText = if (track.album.isNotEmpty() && track.album != "Unknown Album") {
                "${track.artist}  •  ${track.album}"
            } else {
                track.artist
            }

            @OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
            Text(
                text = artistText,
                color = Color.White.copy(alpha = 0.72f),
                fontSize = 15.sp,
                fontFamily = ModernSansFont,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Start,
                maxLines = 1,
                modifier = Modifier
                    .fillMaxWidth()
                    .basicMarquee(
                        iterations = Int.MAX_VALUE,
                        delayMillis = 1500,
                        velocity = 24.dp,
                        spacing = androidx.compose.foundation.MarqueeSpacing(36.dp)
                    )
            )
        }


        // 3. M3 Precision Scrubber & Timecodes (direct beneath title/artist)
        PrecisionScrubber(
            playbackPosition = playbackPosition,
            durationSeconds = track.durationSeconds,
            isPlaying = isPlaying,
            dynamicColor = dynamicColor,
            onSeekTo = onSeekTo,
            modifier = Modifier.fillMaxWidth()
        )

        // 4. Centered Audiophile Telemetry String (Single-Line Dynamic Engine Readout with Tap-to-Cycle)
        var telemetryCycleIndex by remember { mutableIntStateOf(0) }
        val engineArchReadout = if (isHardwareVolumeActive) "32-BIT HARDWARE CHIP" else "64-BIT BIT-PERFECT DSP"
        val line1 = buildString {
            append(track.codec.uppercase())
            if (track.bitrateKbps > 0) append("  •  ${track.bitrateKbps} KBPS")
            append("  •  $engineArchReadout")
            if (track.isMqa) append("  •  MQA")
        }
        val line2 = buildString {
            append(engineArchReadout)
            append("  •  DIRECT USB  •  BIT-PERFECT")
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(8.dp))
                .clickable { telemetryCycleIndex++ }
                .padding(vertical = 4.dp),
            contentAlignment = Alignment.Center
        ) {
            AnimatedContent(
                targetState = if (telemetryCycleIndex % 2 == 0) line1 else line2,
                transitionSpec = { fadeIn(tween(200)) togetherWith fadeOut(tween(200)) },
                label = "telemetryCycle"
            ) { textToDisplay ->
                Text(
                    text = textToDisplay,
                    color = Color.White.copy(alpha = 0.72f),
                    fontFamily = TerminalFont,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Medium,
                    letterSpacing = 0.05.sp,
                    textAlign = TextAlign.Center
                )
            }
        }

        // 5. M3 Horizontal Transport Controls Row (Shuffle, Prev, Play/Pause Hero 68dp, Next, Repeat)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Shuffle Button
            TactileBox(
                onClick = onToggleShuffle,
                pressedScale = 0.88f,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(if (isShuffleEnabled) dynamicColor.copy(alpha = 0.22f) else Color.Transparent)
            ) {
                GlyphShuffle(
                    color = if (isShuffleEnabled) dynamicColor else Color.White.copy(alpha = 0.65f),
                    modifier = Modifier.size(18.dp)
                )
            }

            // Prev Button (permanently circular 48dp)
            TactileBox(
                onClick = onPlayPrev,
                pressedScale = 0.88f,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(m3SurfaceContainerHigh())
            ) {
                GlyphPrev(color = Color.White.copy(alpha = 0.90f), modifier = Modifier.size(20.dp))
            }

            // Hero Play/Pause Button (permanently circular 68dp)
            TactileBox(
                onClick = onTogglePlay,
                pressedScale = 0.92f,
                modifier = Modifier
                    .size(68.dp)
                    .clip(CircleShape)
                    .background(dynamicColor)
            ) {
                val iconColor = Color(0xFF0E0D13)
                if (isPlaying) {
                    GlyphPause(color = iconColor, modifier = Modifier.size(26.dp))
                } else {
                    Box(modifier = Modifier.padding(start = 3.dp)) {
                        GlyphPlay(color = iconColor, modifier = Modifier.size(26.dp))
                    }
                }
            }

            // Next Button (permanently circular 48dp)
            TactileBox(
                onClick = onPlayNext,
                pressedScale = 0.88f,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(m3SurfaceContainerHigh())
            ) {
                GlyphNext(color = Color.White.copy(alpha = 0.90f), modifier = Modifier.size(20.dp))
            }

            // Repeat Button
            val isRepeatActive = repeatMode != RepeatMode.OFF
            TactileBox(
                onClick = onCycleRepeat,
                pressedScale = 0.88f,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(if (isRepeatActive) dynamicColor.copy(alpha = 0.22f) else Color.Transparent)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    GlyphRepeat(
                        color = if (isRepeatActive) dynamicColor else Color.White.copy(alpha = 0.65f),
                        modifier = Modifier.size(18.dp)
                    )
                    if (repeatMode == RepeatMode.ONE) {
                        Text(
                            text = "1",
                            color = dynamicColor,
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Bold,
                            fontFamily = TerminalFont,
                            modifier = Modifier.padding(top = 1.dp)
                        )
                    }
                }
            }
        }

        // 6. Symmetrical Bottom Utility Action Row (Interactive Volume Fill Capsule & Queue Button)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Interactive Volume Pill with dynamic fill bar
            val isBitPerfect = currentVolume >= 0.999f
            val volPercent = (currentVolume * 100).roundToInt()

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(50.dp)
                    .clip(RoundedCornerShape(25.dp))
                    .background(m3SurfaceContainer())
            ) {
                // Background subtle fill tracking volume level
                Box(
                    modifier = Modifier
                        .fillMaxWidth(currentVolume.coerceIn(0f, 1f))
                        .fillMaxHeight()
                        .background(dynamicColor.copy(alpha = 0.16f))
                )

                // Foreground content with Steppers and Center Level
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 6.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TactileBox(
                        onClick = { onVolumeChange((currentVolume - 0.05f).coerceAtLeast(0.0f)) },
                        pressedScale = 0.85f,
                        modifier = Modifier
                            .size(38.dp)
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.06f))
                    ) {
                        Text("-", color = TerminalWhite, fontSize = 20.sp, fontWeight = FontWeight.Bold, fontFamily = ModernSansFont)
                    }

                    TactileBox(
                        onClick = { onVolumeChange(1.0f) },
                        pressedScale = 0.92f,
                        modifier = Modifier
                            .clip(RoundedCornerShape(50))
                            .padding(horizontal = 8.dp, vertical = 6.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            GlyphVolume(color = if (isBitPerfect) dynamicColor else TerminalWhite, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = if (isBitPerfect) "0 dBFS" else "$volPercent%",
                                color = if (isBitPerfect) dynamicColor else TerminalWhite,
                                fontFamily = TerminalFont,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }

                    TactileBox(
                        onClick = { onVolumeChange((currentVolume + 0.05f).coerceAtMost(1.0f)) },
                        pressedScale = 0.85f,
                        modifier = Modifier
                            .size(38.dp)
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.06f))
                    ) {
                        Text("+", color = TerminalWhite, fontSize = 20.sp, fontWeight = FontWeight.Bold, fontFamily = ModernSansFont)
                    }
                }
            }

            // Queue Button (50dp height aligned with Volume Pill)
            TactileBox(
                onClick = onOpenQueue,
                pressedScale = 0.90f,
                modifier = Modifier
                    .size(50.dp)
                    .clip(RoundedCornerShape(25.dp))
                    .background(m3SurfaceContainer())
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    GlyphQueue(color = dynamicColor, modifier = Modifier.size(20.dp))
                    if (priorityQueueSize > 0) {
                        Box(
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(6.dp)
                                .clip(CircleShape)
                                .background(dynamicColor)
                                .padding(horizontal = 5.dp, vertical = 1.dp)
                        ) {
                            Text(
                                text = "$priorityQueueSize",
                                color = Color(0xFF0E0D13),
                                fontSize = 9.sp,
                                fontFamily = TerminalFont,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }
        }
    }
}
