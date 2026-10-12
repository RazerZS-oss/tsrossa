# TactileBox Lambda Closure Stale State & Volume Pipe Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the volume stepper being stuck at 95% by using `rememberUpdatedState` inside `TactileBox` so gesture closures always invoke the latest `onClick` lambda across recompositions, and eliminate duplicate JNI volume dispatches in `MainActivity`.

**Architecture:** 
1. In `AudioGlyphs.kt`, update `TactileBox` to bind `onClick` through `val currentOnClick by rememberUpdatedState(onClick)`. This guarantees that when `currentVolume` changes and recomposes `TrackView`, clicking `-` or `+` executes the new volume value calculation rather than the stale initial lambda closure.
2. In `MainActivity.kt`, eliminate the duplicate `audioEngine.setSoftwareVolume(vol)` invocation inside `onVolumeChange` callback lambda, allowing the centralized `LaunchedEffect(currentVolume)` to handle persistence and native JNI volume dispatches without redundant lock contention.

**Tech Stack:** Jetpack Compose Runtime (`rememberUpdatedState`), Android JNI.

**Spec:** The 2 findings from `/ponytail:ponytail-audit`:
1. `currentVolume` captures stale initial value inside `TrackView`'s `onClick` lambda (`AudioGlyphs.kt:L44-85`, `TrackView.kt:L438`).
2. Redundant volume calls trigger duplicate JNI mutex acquisitions on single volume events (`MainActivity.kt:L474-477`, `MainActivity.kt:L1315-1318`).

## Global Constraints
- Tactile spring scale animations must remain smooth and responsive.
- Semantics for TalkBack screen reader (`Role.Button`, accessible click) must be preserved.
- 24/24 unit tests must pass.
- Debug APK must compile and deploy cleanly to the connected device.

## Review Focus
- Stepping volume down (`-`) decreases consecutively: 100% -> 95% -> 90% -> 85% -> ... down to 0%.
- Stepping volume up (`+`) increases consecutively up to 100%.
- Volume indicator pill and bit-perfect lock status update in real time with each tap.
- Device logcat confirms exactly one `SET_CUR Volume` transfer per volume step.

---

### Task 1: Fix Stale Lambda Capture in `TactileBox`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/AudioGlyphs.kt:L44-L85`

**Interfaces:**
- Consumes: Compose `rememberUpdatedState`.
- Produces: `TactileBox` that always invokes the freshest `onClick` lambda.

- [ ] **Step 1: Inspect `TactileBox` in `AudioGlyphs.kt`**
Currently:
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
                    onClick() // <-- Stale closure!
                }
            }
        },
...
```

- [ ] **Step 2: Update with `rememberUpdatedState`**
Wrap `onClick` in `val currentOnClick by rememberUpdatedState(onClick)` and call `currentOnClick()` in both semantics and gesture completion:
```kotlin
val currentOnClick by rememberUpdatedState(onClick)
...
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
    }
```

- [ ] **Step 3: Verify build**
Run `./gradlew compileDebugKotlin` to verify.

---

### Task 2: Eliminate Duplicate JNI Volume Dispatch in `MainActivity`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt:L1314-L1318`

**Interfaces:**
- Consumes: `currentVolume` state.
- Produces: Single dispatch pipeline via `LaunchedEffect(currentVolume)`.

- [ ] **Step 1: Inspect `onVolumeChange` in `MainActivity.kt`**
Locate lines 1314–1318:
```kotlin
currentVolume = currentVolume,
onVolumeChange = { vol ->
    currentVolume = vol
    audioEngine.setSoftwareVolume(vol)
},
```

- [ ] **Step 2: Remove duplicate `setSoftwareVolume(vol)`**
Change to:
```kotlin
currentVolume = currentVolume,
onVolumeChange = { vol ->
    currentVolume = vol
},
```
Note: `LaunchedEffect(currentVolume)` at line 474–477 already executes:
```kotlin
LaunchedEffect(currentVolume) {
    sharedPref.edit().putFloat("last_volume", currentVolume).apply()
    audioEngine.setSoftwareVolume(currentVolume)
}
```

- [ ] **Step 3: Run full verification build and deploy**
Run:
```bash
./gradlew testDebugUnitTest assembleDebug
adb -s 192.168.100.54:38771 install -r app/build/outputs/apk/debug/app-debug.apk
```
Expected: BUILD SUCCESSFUL, APK installs, logcat shows monotonic decrement on multiple volume taps.
