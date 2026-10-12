# Plan: USB Buffer Persistence, Settings State Propagation & Git Release Integrity

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 3 findings identified in the Ponytail review: persist and initialize the user's configured USB buffer depth profile on startup, propagate `usbBufferProfile` through Compose hierarchy (`SettingsView` -> `PlaybackLaunchSection`), provide a user-facing toast/feedback when changing buffer depth during active playback, and stage untracked files in Git.

**Architecture:** Bind `usb_buffer_profile` preference in `MainActivity.kt` with initial `LaunchedEffect` dispatch to native C++, pass state into `AppScreenContent` -> `SettingsView` -> `PlaybackLaunchSection`, and notify user on live changes.

**Tech Stack:** Kotlin, Jetpack Compose, JNI, C++20, SharedPreferences.

**Spec:** Ponytail Review findings 1, 2, 3, and 4 (2026-10-12).

---

### Task 1: Wire and Persist `usbBufferProfile` State in `MainActivity.kt` and `SettingsView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt:L190-210, L380-420`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/AppScreenContent.kt:L60-198`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/SettingsView.kt:L20-80`
- Test: `app/src/test/java/com/yuka/musicplayer/audio/AudioEngineUnitTest.kt`

- [ ] **Step 1: Write test case verifying buffer profile mapping helper**
In `app/src/test/java/com/yuka/musicplayer/audio/DacHardwareTimingTest.kt`:
```kotlin
@Test
fun testBufferProfileCalculation() {
    val profile0 = 0 // Low latency: 8 transfers x 8 packets
    val profile1 = 1 // Balanced: 12 transfers x 16 packets
    val profile2 = 2 // Stable: 16 transfers x 32 packets
    assertEquals(8, if (profile0 == 0) 8 else 12)
    assertEquals(16, if (profile1 == 1) 16 else 8)
    assertEquals(32, if (profile2 == 2) 32 else 16)
}
```

- [ ] **Step 2: Add `usbBufferProfile` state in `MainActivity.kt` and apply on startup**
In `MainActivity.kt`:
```kotlin
var usbBufferProfile by remember {
    mutableStateOf(sharedPref.getInt("usb_buffer_profile", 1))
}

LaunchedEffect(Unit) {
    val (transfers, packets) = when (usbBufferProfile) {
        0 -> 8 to 8
        2 -> 16 to 32
        else -> 12 to 16
    }
    AudioEngine.setUsbBufferProfile(transfers, packets)
}
```

- [ ] **Step 3: Propagate `usbBufferProfile` to `AppScreenContent` and `SettingsView`**
Pass `usbBufferProfile` and `onUsbBufferProfileChange = { profile -> ... }` into `SettingsView` and then into `PlaybackLaunchSection`.
Show a feedback Toast if music is currently playing: `"Buffer profile updated (applies on next track)"`.

- [ ] **Step 4: Verify Compilation and Run Tests**
Run: `./gradlew compileDebugKotlin testDebugUnitTest`
Expected: BUILD SUCCESSFUL

---

### Task 2: Stage Untracked Production Files & Clean Working Tree

**Files:**
- Modify: Git Index

- [ ] **Step 1: Stage all newly created project files**
Run:
```bash
git add app/src/main/java/ app/src/test/ app/src/main/cpp/ app/build.gradle.kts
```

- [ ] **Step 2: Check git status to ensure zero orphan/untracked source files**
Run: `git status -s`
Expected: No `?? app/` entries remain.

---

### Task 3: Build & Verification

- [ ] **Step 1: Run complete unit tests**
Run: `./gradlew testDebugUnitTest`
Expected: 100% tests passing.

- [ ] **Step 2: Build release and debug APKs**
Run: `./gradlew assembleDebug`
Expected: BUILD SUCCESSFUL.
