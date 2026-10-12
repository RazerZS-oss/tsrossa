# Comprehensive Master Plan: 4-Point Deep Acoustic & Dynamic Soundstage Optimization

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fully resolve all 4 acoustic findings from the audit: (1) Bit-depth justification & packing precision, (2) 0 dBFS Bit-Perfect Lock to preserve 100% DAC SNR, (3) Low-jitter USB queue sizing (12x16 packets), and (4) Live OTG VBUS Power & Battery Sag Monitor in the UI.

**Architecture:**
1. **Finding 1 - Bit Packing & Justification Precision (`AudioStreamer.cpp`)**:
   - Ensure samples decoded by `dr_flac` and `dr_wav` are accurately aligned across all physical subframe sizes (`sf_size = 2, 3, 4` bytes).
   - For 16-bit audio into 24-bit/32-bit slots: maintain pristine bit-exact scaling without loss of least-significant bits.
   - For 24-bit audio: properly pack the 24 bits into 3-byte subslots (`val24 = src[s] >> 8`) or 4-byte subslots with clean zero-padding, preserving full 144 dB theoretical dynamic range.
2. **Finding 2 - 0 dBFS Bit-Perfect Volume Lock (`TrackView.kt`, `AudioStreamer.cpp`)**:
   - Add a tactile "0 dBFS BIT-PERFECT LOCK" toggle on the player screen.
   - When active, locks software volume strictly at `1.0f`, completely bypassing floating-point multipliers and TPDF dithering, delivering uncompromised full-scale line-out signal to the DAC op-amps.
3. **Finding 3 - Low-Jitter Isochronous Buffer Queue (`AudioStreamer.cpp`)**:
   - Reduce transfer buffer depth from 32x32 (1,024 packets / ~1,024ms) to **12 transfers x 16 packets** (192 packets / ~190ms).
   - Minimizes USB host controller queue congestion and clock phase jitter, tightening instrument separation and expanding soundstage width.
4. **Finding 4 - Live OTG VBUS Power & Battery Sag Monitor (`DacTelemetryState.kt`, `SettingsView.kt`)**:
   - Integrate live battery fuel-gauge monitoring into the application diagnostics panel.
   - Display real-time cell voltage, discharge current, and a power advisory explaining external 5V power injection benefits for high-power dongles during dynamic bass peaks.

**Tech Stack:** C++20, Kotlin, Jetpack Compose, Linux usbfs, Android BatteryManager.

---

### Task 1: Audit & Harden Bit-Depth Packing in C++ Native Streamer

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:350-375`

- [ ] **Step 1: In `AudioStreamer.cpp`, refine bit-depth extraction in Bit-Perfect Bypass:**
  - Verify 32-bit container (`sf_size == 4`): direct bit-exact `memcpy(dst_bytes, src, num_samples * sizeof(int32_t))`.
  - Verify 24-bit container (`sf_size == 3`): bitwise extraction `int32_t val24 = src[s] >> 8` with exact little-endian byte ordering.
  - Verify 16-bit container (`sf_size == 2`): bitwise extraction `int32_t val16 = src[s] >> 16` with exact little-endian byte ordering.
- [ ] **Step 2: Verify zero audio alteration and test compilation**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 2: Optimize Isochronous Transfer Queue for Low-Jitter Audio Clocking

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:56-65`

- [ ] **Step 1: Set `num_transfers = 12` and `num_packets = 16` in `start_iso_streaming_thread`**
- [ ] **Step 2: Build native code to verify clean compilation**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 3: Implement Dedicated "0 dBFS BIT-PERFECT LOCK" in Player UI

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:415-455`

- [ ] **Step 1: In `TrackView.kt` volume row, add a dedicated "0 dBFS LOCK" tactile button**
- [ ] **Step 2: When clicked, snap volume directly to `1.0f` and display high-contrast "0 dBFS BIT-PERFECT LOCKED" badge**
- [ ] **Step 3: Verify compilation via Gradle**
  Run: `./gradlew compileDebugKotlin`
  Expected: BUILD SUCCESSFUL

---

### Task 4: Add OTG Power Rail & Battery Advisory in Diagnostics/Settings

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/PlaybackLaunchSection.kt`

- [ ] **Step 1: Add "USB OTG POWER & DONGLE DYNAMICS ADVISORY" section to settings**
  Explains how external 5V power injection prevents phone battery voltage sag during dynamic bass transients on multi-chip DACs.
- [ ] **Step 2: Run all 12 unit tests**
  Run: `./gradlew testDebugUnitTest`
  Expected: 12/12 PASS

---

### Task 5: Build, Deploy & Verify on Samsung Galaxy S23 FE

**Files:**
- Deploy via ADB to connected phone

- [ ] **Step 1: Assemble final debug APK**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL
- [ ] **Step 2: Install APK on Samsung Galaxy S23 FE**
  Run: `adb install -r app/build/outputs/apk/debug/app-debug.apk`
  Expected: Success
- [ ] **Step 3: Restart app on phone via ADB**
  Run: `adb shell "am start -n com.yuka.musicplayer/.MainActivity"`
  Expected: Success
