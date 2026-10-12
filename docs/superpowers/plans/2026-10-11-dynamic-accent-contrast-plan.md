# Dynamic Accent Color Legibility & Contrast Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure 100% clarity, contrast, and visual consistency for all UI/UX buttons, sliders, borders, and glyphs when dynamic accent color adapts to album artwork across all cover types (dark, low-saturation, monochrome, or missing art).

**Architecture:** Implement an audiophile/designer-grade dynamic color normalization engine in `ColorUtils`/`Theme.kt` using HSL/HSV color science and WCAG 4.5:1 relative luminance clamping against dark backgrounds (`#000000` / `#070A12`), reinforce button border/container contrast floors across `RetroComponents.kt` and `TrackView.kt`, provide smooth crossfade color animations via `animateColorAsState`, and elegantly fall back to the user's configured accent when art is absent.

**Tech Stack:** Kotlin, Jetpack Compose Animation, Android Color Math, JUnit4.

**Spec:** Ponytail UI/UX dynamic accent audit findings 1-4 (2026-10-11).

## Global Constraints
- Preserve retro-terminal aesthetic: don't wash out bright vibrant colors, only lift and normalize dark/muddy ones.
- Zero performance overhead: pure in-memory math, no heavy image passes on the main UI thread.
- Minimum WCAG contrast: any dynamic accent applied to text or interactive glyphs on black background must achieve at least 4.5:1 contrast ratio (luminance >= 0.22, lightness clamped to >= 0.58).

## Review Focus
1. Very dark album art (e.g. black metal covers with RGB near `#111111` or `#1E2022`).
2. Very low saturation/greyscale album art (e.g. black-and-white portraits where saturation = 0).
3. Missing artwork tracks (must smoothly fall back to user's selected accent rather than jarring `#00FF00`).
4. Rapid track switching (animated color crossfade must cancel/retarget smoothly without visual jitter).
5. Button outline clarity when button is unselected/inactive.

---

### Task 1: Color Normalization Engine (Luminance & Lightness Clamping)

**Files:**
- Create: `app/src/main/java/com/yuka/musicplayer/util/ColorContrastHelper.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/theme/Theme.kt`
- Test: `app/src/test/java/com/yuka/musicplayer/util/ColorContrastHelperTest.kt`

**Interfaces:**
- Produces: `ColorContrastHelper.normalizeDynamicAccent(color: Color, fallback: Color): Color`

- [ ] **Step 1: Write unit tests for color normalization**

In `app/src/test/java/com/yuka/musicplayer/util/ColorContrastHelperTest.kt`:
```kotlin
@Test
fun testDarkColorIsNormalizedForContrast() {
    val darkBrown = Color(0xFF2B1D0C) // Very dark brown
    val normalized = ColorContrastHelper.normalizeDynamicAccent(darkBrown)
    val luminance = ColorContrastHelper.calculateLuminance(normalized)
    assertTrue("Normalized color must have sufficient luminance for dark backgrounds", luminance >= 0.20f)
}

@Test
fun testMonochromeColorIsInfusedWithTint() {
    val pureGrey = Color(0xFF404040)
    val fallback = Color(0xFFFF85A1)
    val normalized = ColorContrastHelper.normalizeDynamicAccent(pureGrey, fallback)
    assertTrue("Zero saturation colors should blend with fallback tint", normalized != pureGrey)
}
```

- [ ] **Step 2: Run test to verify it fails before helper creation**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.util.ColorContrastHelperTest`
Expected: FAIL (class not found)

- [ ] **Step 3: Implement `ColorContrastHelper.kt`**

- Calculate relative luminance: `0.2126 * R + 0.7152 * G + 0.0722 * B`.
- Convert to HSV: if `Value < 0.65f`, boost `Value` to at least `0.70f`.
- If `Saturation < 0.20f` (near monochrome/grey), blend with `fallbackColor` to introduce clean legible tint.
- Clamp minimum lightness in HSL to `0.55f - 0.75f` range so text and outlines pop crisply against deep navy/black backgrounds.

- [ ] **Step 4: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.util.ColorContrastHelperTest`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/com/yuka/musicplayer/util/ColorContrastHelper.kt app/src/test/java/com/yuka/musicplayer/util/ColorContrastHelperTest.kt
git commit -m "feat(ui): add ColorContrastHelper to normalize dynamic accent colors for dark backgrounds"
```

---

### Task 2: Smooth Color Crossfade & Fallback to User Accent

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt:L345-360`
- Test: `app/src/test/java/com/yuka/musicplayer/util/ColorContrastHelperTest.kt`

**Interfaces:**
- Consumes: `ColorContrastHelper.normalizeDynamicAccent`, `accentMode`, `accentFixedColor`
- Produces: `currentAccentColor` with animated transition (`animateColorAsState`)

- [ ] **Step 1: Write test validating fallback to user accent**

In `app/src/test/java/com/yuka/musicplayer/util/ColorContrastHelperTest.kt`:
```kotlin
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
```

- [ ] **Step 2: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.util.ColorContrastHelperTest.testNullOrDefaultArtworkFallsBackToUserAccent`
Expected: PASS

- [ ] **Step 3: Implement animated accent resolution in `MainActivity.kt`**

- Replace static color picking with:
  ```kotlin
  val rawDynamic = currentTrack?.dominantColor
  val targetAccent = if (accentMode == "FIXED") {
      accentFixedColor
  } else {
      if (rawDynamic == null || rawDynamic == Color(0xFF00FF00)) {
          accentFixedColor // User's chosen theme instead of harsh hardcoded green
      } else {
          ColorContrastHelper.normalizeDynamicAccent(rawDynamic, accentFixedColor)
      }
  }
  val currentAccentColor by animateColorAsState(
      targetValue = targetAccent,
      animationSpec = tween(durationMillis = 400, easing = LinearEasing),
      label = "accentCrossfade"
  )
  ```

- [ ] **Step 4: Verify compilation and tests**

Run: `./gradlew compileDebugKotlin`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/com/yuka/musicplayer/MainActivity.kt
git commit -m "feat(ui): animate dynamic accent color changes and fall back to user accent"
```

---

### Task 3: Reinforce Button Outline & Background Floor Alphas

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/RetroComponents.kt:L60-120`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:L400-475`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/NavigationComponents.kt:L270-340`

**Interfaces:**
- Produces: Dual-layer or high-contrast borders for all interactive buttons and chips.

- [ ] **Step 1: Update `RetroActionItem`, `RetroCircularButton`, and `TactileBox` border styling**

- In `RetroComponents.kt`: ensure borders have a solid baseline contrast by compounding:
  `border(0.8.dp, accent.copy(alpha = 0.50f).compositeOver(Color.White.copy(alpha = 0.15f)), ...)`
- In `TrackView.kt`: ensure the volume `-`, `+`, `MAX`, and `0 dBFS BIT-PERFECT` buttons have a minimum border alpha of `0.40f` and dark background surface (`Color(0xFF0C101D)`), so buttons never look washed out or invisible.
- In `NavigationComponents.kt`: ensure the mini player and bottom tab bar active indicators remain sharp.

- [ ] **Step 2: Verify Compose UI compilation**

Run: `./gradlew compileDebugSources`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add app/src/main/java/com/yuka/musicplayer/ui/components/RetroComponents.kt app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt
git commit -m "feat(ui): reinforce button outlines and baseline contrast floors for dynamic accents"
```

---

### Task 4: Full Test Suite, Build Verification & Device Deployment

**Files:**
- Test: Full unit test suite (`app/src/test/`)
- Build: Debug APK assemble & install

- [ ] **Step 1: Run all unit tests**

Run: `./gradlew testDebugUnitTest`
Expected: 100% tests passing

- [ ] **Step 2: Assemble debug APK**

Run: `./gradlew assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Install and test on connected Samsung Galaxy S23 FE**

Run: `adb -s RRCWA04DRQW install -r app/build/outputs/apk/debug/app-debug.apk`
Expected: Success

- [ ] **Step 4: Launch application and verify PID**

Run: `adb -s RRCWA04DRQW shell am start -n com.yuka.musicplayer/.MainActivity`
Expected: App running smoothly
