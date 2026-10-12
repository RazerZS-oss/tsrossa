# UI/UX Polish & Gesture Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate system gesture conflicts on edge scrubber seeks, optimize library search filtering to zero pair allocations for large music libraries, and enlarge button touch targets to meet mobile accessibility standards.

**Architecture:**
1. In `TrackView.kt`, attach `Modifier.systemGestureExclusion()` to `PrecisionScrubber` so dragging near the left/right screen edges does not trigger Android 10+ system back gesture navigation on phones like Samsung Galaxy S23 FE.
2. In `LibraryView.kt`, streamline `remember(filesInDir, searchQuery)` to filter directly instead of running `mapIndexed { index, file -> index to file }`, cutting heap allocations to zero intermediate wrapper objects per keystroke.
3. In `RetroComponents.kt`, add `defaultMinSize(minHeight = 44.dp)` or invisible touch padding to `RetroButton` to ensure comfortable one-handed taps without compromising the retro terminal typography.

**Tech Stack:** Jetpack Compose, Kotlin, Android System Gestures API.

**Spec:** UI/UX audit findings (findings #1, #2, #3).

## Global Constraints
- Preserve exact cyberpunk/terminal visual styling (font sizes, borders, colors).
- No breaking changes to existing callbacks.
- Must compile with zero errors and pass all existing unit tests.

## Review Focus
1. `systemGestureExclusion` is available on API 29+; ensure compatibility across API 26..34.
2. Memory profiling on 2,000-item folder filtering: zero `Pair<Int, File>` allocations.

---

### Task 1: Optimize Library Search Filtering in `LibraryView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/LibraryView.kt:55-60`

- [ ] **Step 1: Replace `mapIndexed` pair allocation with direct file filtering in `LibraryView.kt`**
  ```kotlin
  val filteredFiles = remember(filesInDir, searchQuery) {
      if (searchQuery.isEmpty()) filesInDir
      else filesInDir.filter { it.name.contains(searchQuery, ignoreCase = true) }
  }
  ```
- [ ] **Step 2: Update LazyColumn items to use direct `filteredFiles`**
- [ ] **Step 3: Verify clean build via Gradle**
  Run: `./gradlew compileDebugKotlin`
  Expected: BUILD SUCCESSFUL

---

### Task 2: Prevent System Back Gesture Conflict in `TrackView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:82-90`

- [ ] **Step 1: Add `systemGestureExclusion()` modifier to `PrecisionScrubber` BoxWithConstraints**
  Ensures edge touches (00:00 or song end) won't trigger Samsung gesture back navigation.
- [ ] **Step 2: Verify compilation and tests**
  Run: `./gradlew testDebugUnitTest`
  Expected: PASS

---

### Task 3: Improve Button Touch Targets in `RetroComponents.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/RetroComponents.kt:31-45`

- [ ] **Step 1: Add `defaultMinSize(minWidth = 44.dp, minHeight = 40.dp)` to `RetroButton`**
- [ ] **Step 2: Build and deploy updated APK to connected Galaxy S23 FE**
  Run: `./gradlew assembleDebug && adb install -r app/build/outputs/apk/debug/app-debug.apk`
  Expected: Success
