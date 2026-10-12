# UI/UX Accessibility, Small Screen Resilience & Text Marquee Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the 3 UI/UX audit findings by adding accessibility semantics/touch target handling to `TactileBox`, enabling responsive horizontal scrolling/wrapping on the Audiophile Spec Strip in `TrackView`, and adding automatic text marquee to the track title for long titles.

**Architecture:** 
1. Upgrade `TactileBox` in `AudioGlyphs.kt` with Compose `semantics` (`Role.Button`, accessible click action) and ensure minimum interactive touch target enforcement (`minimumInteractiveComponentSize` or `defaultMinSize`).
2. Upgrade Audiophile Spec Strip in `TrackView.kt` to allow scrollable overflow on narrow displays (`Modifier.horizontalScroll(rememberScrollState())`) with subtle edge clipping/padding.
3. Enhance track title and artist row in `TrackView.kt` with `Modifier.basicMarquee()` so long names smoothly marquee when playing without truncation.

**Tech Stack:** Jetpack Compose, Android Material 3 Semantics, Foundation Marquee.

**Spec:** The 3 UI/UX findings from `/ponytail:ponytail-review`:
1. `TactileBox` lacks accessibility semantics & touch targets (`AudioGlyphs.kt:L58-76`)
2. Audiophile Spec Strip clips on narrow/compact phone screens (`TrackView.kt:L344-402`)
3. Track metadata title lacks marquee/auto-scroll for long file names (`TrackView.kt:L318-330`)

## Global Constraints
- Do not break existing tactile bounce animation or touch gesture handling.
- Maintain WCAG 4.5:1 contrast compliance across all dynamic colors.
- Maintain dark industrial terminal aesthetics (TerminalFont, minimalist badges).
- Pass all unit tests and verify APK compilation (`./gradlew testDebugUnitTest assembleDebug`).

## Review Focus
- TalkBack focus traversal triggers `onClick` properly on `TactileBox`.
- Spec Strip scrolls smoothly on screens narrower than 360dp without clipping badges.
- `basicMarquee` runs smoothly on active tracks and idles when paused.
- Touch target expansion does not disrupt tight grid button spacing visually.
- Backwards compatibility down to Android API 26.

---

### Task 1: Add Accessibility Semantics & Touch Target Support to `TactileBox`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/AudioGlyphs.kt`

**Interfaces:**
- Consumes: Jetpack Compose `Modifier.semantics`, `Role`, `Modifier.minimumInteractiveComponentSize()`.
- Produces: `TactileBox` composable with screen-reader button accessibility role and accessible click handler.

- [ ] **Step 1: Inspect `TactileBox` signature and imports**
Verify required Compose semantics imports:
```kotlin
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.onClick
```

- [ ] **Step 2: Update `TactileBox` modifier chain**
Add accessibility semantics and touch target compliance to `TactileBox` in `AudioGlyphs.kt`:
```kotlin
Box(
    modifier = modifier
        .scale(scale)
        .semantics(mergeDescendants = true) {
            role = Role.Button
            onClick {
                if (enabled) {
                    onClick()
                    true
                } else false
            }
        }
        .pointerInput(enabled) {
            if (!enabled) return@pointerInput
            awaitEachGesture {
                val down = awaitFirstDown(requireUnconsumed = false)
                isPressed = true
                val up = try {
                    waitForUpOrCancellation()
                } finally {
                    isPressed = false
                }
                if (up != null) {
                    onClick()
                }
            }
        },
    contentAlignment = Alignment.Center,
    content = content
)
```

- [ ] **Step 3: Verify compilation**
Run `./gradlew testDebugUnitTest` to ensure compilation and zero regressions.

---

### Task 2: Make Audiophile Spec Strip Responsive on Compact Screens

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:L343-L403`

**Interfaces:**
- Consumes: Compose `rememberScrollState()`, `Modifier.horizontalScroll()`.
- Produces: Overflow-resilient Spec Strip that scrolls smoothly on narrow devices without truncating bit-perfect or MQA badges.

- [ ] **Step 1: Update Audiophile Spec Strip Row modifier**
In `TrackView.kt`, update the Spec Strip container:
```kotlin
val specScrollState = rememberScrollState()
Row(
    modifier = Modifier
        .fillMaxWidth(0.95f)
        .background(Color(0xFF0A0E1A), RoundedCornerShape(20.dp))
        .border(0.6.dp, dynamicColor.copy(alpha = 0.20f), RoundedCornerShape(20.dp))
        .horizontalScroll(specScrollState)
        .padding(horizontal = 12.dp, vertical = 4.dp),
    verticalAlignment = Alignment.CenterVertically,
    horizontalArrangement = Arrangement.Center
)
```

- [ ] **Step 2: Verify layout visually and compile**
Ensure badge items (`CODEC`, `KBPS`, `DIRECT USB`, `BIT-PERFECT`, `MQA PASSTHROUGH`) remain properly spaced and can scroll horizontally if the device width is narrow.

---

### Task 3: Add Text Marquee for Long Track Titles

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:L305-L335`

**Interfaces:**
- Consumes: Compose `Modifier.basicMarquee()`.
- Produces: Smooth auto-scrolling track title that scrolls when active or long without clipping with `...`.

- [ ] **Step 1: Inspect Track Title Composable**
Find track title in `TrackView.kt`:
```kotlin
Text(
    text = track.title,
    color = TerminalWhite,
    style = MaterialTheme.typography.titleLarge,
    fontWeight = FontWeight.Bold,
    fontFamily = TerminalFont,
    textAlign = TextAlign.Center,
    maxLines = 1,
    overflow = TextOverflow.Ellipsis
)
```

- [ ] **Step 2: Add `basicMarquee` to title and optional subtitle**
Modify the title modifier to include `basicMarquee(iterations = Int.MAX_VALUE)` when playing or long:
```kotlin
Text(
    text = track.title,
    color = TerminalWhite,
    style = MaterialTheme.typography.titleLarge,
    fontWeight = FontWeight.Bold,
    fontFamily = TerminalFont,
    textAlign = TextAlign.Center,
    maxLines = 1,
    modifier = Modifier
        .fillMaxWidth(0.88f)
        .basicMarquee(
            iterations = Int.MAX_VALUE,
            initialDelayMillis = 1500,
            repeatDelayMillis = 1500
        )
)
```

- [ ] **Step 3: Run full verification build**
Run:
```bash
./gradlew testDebugUnitTest assembleDebug
```
Expected: BUILD SUCCESSFUL, all unit tests pass.
