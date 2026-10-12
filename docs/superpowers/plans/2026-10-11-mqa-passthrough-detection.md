# MQA Bitstream Passthrough Detection & UI Badge Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Detect MQA-encoded FLAC/WAV tracks via metadata inspection and display an authentic `MQA PASSTHROUGH` badge in the player UI, confirming to users that untouched audio is being streamed to their MQA-capable hardware DAC for full unfolding.

**Architecture:**
1. In `MetadataExtractor.kt`, scan FLAC metadata blocks (VORBIS_COMMENT) and ID3 tags for `"MQAENCODER"`, `"MQA"`, or `"ORIGINALSAMPLERATE"` tags to identify MQA-encoded containers without decompressing audio.
2. In `TrackModels.kt`, add `val isMqa: Boolean = false` to `TrackInfo`.
3. In `TrackView.kt`, conditionally render an authentic `MQA PASSTHROUGH` badge alongside `DIRECT USB` and `BIT-PERFECT` in the audiophile spec strip when an MQA track is active.
4. Add JUnit test in `MetadataExtractorTest.kt` verifying MQA detection logic.

**Tech Stack:** Kotlin, Jetpack Compose, JUnit 4.

**Spec:** Audited findings on MQA bitstream pass-through detection.

## Global Constraints
- Zero CPU overhead in hot audio playback loops (metadata is parsed once when opening track).
- Zero audio alteration: pure bit-perfect pass-through to DAC.
- All unit tests must pass.

---

### Task 1: Add MQA Detection to `TrackInfo` and `MetadataExtractor.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/model/TrackModels.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/metadata/MetadataExtractor.kt`
- Modify: `app/src/test/java/com/yuka/musicplayer/metadata/MetadataExtractorTest.kt`

**Interfaces:**
- Produces: `TrackInfo.isMqa: Boolean`

- [ ] **Step 1: Write unit test in `MetadataExtractorTest.kt` asserting MQA tag detection**
- [ ] **Step 2: Add `val isMqa: Boolean = false` to `TrackInfo` in `TrackModels.kt`**
- [ ] **Step 3: Implement MQA metadata tag scanning in `MetadataExtractor.kt`**
- [ ] **Step 4: Run unit test via Gradle**
  Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.metadata.MetadataExtractorTest`
  Expected: PASS

---

### Task 2: Display `MQA PASSTHROUGH` Badge in `TrackView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt`

- [ ] **Step 1: In the Audiophile Spec Strip (`TrackView.kt:L343-380`), render `MQA PASSTHROUGH` when `track.isMqa` is true**
- [ ] **Step 2: Assemble debug build and verify compilation**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 3: Deploy and Verify on Samsung Galaxy S23 FE

**Files:**
- Deploy via ADB to connected phone

- [ ] **Step 1: Install updated APK on Galaxy S23 FE**
  Run: `adb install -r app/build/outputs/apk/debug/app-debug.apk`
  Expected: Success
- [ ] **Step 2: Restart application**
  Run: `adb shell "am start -n com.yuka.musicplayer/.MainActivity"`
  Expected: Success
