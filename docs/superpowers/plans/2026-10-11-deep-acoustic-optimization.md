# Deep Acoustic Optimization & Dynamic Soundstage Enhancement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore maximum dynamic headroom, transient impact, holographic soundstage width, and micro-detail resolution by optimizing bit-depth alignment, low-jitter USB queue sizing, and adding a 0 dBFS Bit-Perfect Lock.

**Architecture:**
1. **Accurate Bit-Depth Subslot Justification (`AudioStreamer.cpp`)**:
   - In 32-bit subslot mode (`sf_size == 4`), verify source bit-depth alignment. Standard UAC Type I PCM uses 32-bit slots with audio data left-justified. Dr_flac shifts `32 - bitsPerSample`, producing accurate full-scale 32-bit words. Ensure bit-exact reproduction without truncation.
   - For 24-bit files streamed into 24-bit physical containers (`sf_size == 3`), extract exact top 24 bits (`val32 >> 8`) in full scale.
2. **Low-Latency, Low-Jitter Isochronous Transfer Queue (`AudioStreamer.cpp`)**:
   - Reduce transfer buffering depth from 32 transfers x 32 packets (1,024 packets, >1,000ms delay causing queue congestion and micro-timing jitter) to an audiophile low-jitter queue of **8 transfers x 16 packets** (128 packets, ~128ms).
   - This keeps USB host controller buffers lean, tightens clock synchronization with the DAC's internal oscillator, and eliminates soundstage blurring caused by buffer latency drift.
3. **Dedicated 0 dBFS / Bit-Perfect Lock UI Button (`TrackView.kt`)**:
   - Add a tactile "100% BIT-PERFECT LOCK" button next to the volume stepper in `TrackView.kt`.
   - Clicking this snaps volume directly to 1.0 (0 dBFS), immediately bypassing all floating-point math, TPDF dithering, and digital attenuation. All volume attenuation is offloaded to the DAC's analog amplifier / hardware volume chip, preserving 100% of the DAC's native signal-to-noise ratio (SNR) and dynamic range.
4. **Hardware Diagnostic Advisory in Settings (`PlaybackLaunchSection.kt` or `DacTelemetryState.kt`)**:
   - Display a clean advisory note explaining that for power-hungry multi-chip dongle DACs, using a powered USB-C splitter eliminates battery rail voltage sag during heavy bass transients.

**Tech Stack:** C++20 (libusb, SCHED_FIFO), Kotlin, Jetpack Compose, JUnit 4.

**Spec:** Deep acoustic audit on power, dynamics, and soundstage resolution.

## Global Constraints
- Target Android API 26..34.
- Zero audio buffer underruns (xruns) even on 192kHz/768kHz high-res files.
- All 12 existing unit tests must pass.

---

### Task 1: Optimize Isochronous Transfer Queue for Low-Jitter Audio Clocking

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:56-65`

- [ ] **Step 1: Tune transfer queue depth in `start_iso_streaming_thread`:**
  Change `num_transfers = 12`, `num_packets = 16` (192 packets total buffer, low micro-timing wander while preserving dropout resistance).
- [ ] **Step 2: Verify native C++ compilation via Gradle**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 2: Implement "0 dBFS / BIT-PERFECT LOCK" Button in `TrackView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:420-440`

- [ ] **Step 1: In `TrackView.kt` volume row, add a clickable Bit-Perfect Lock badge:**
  Clicking the "VOL: X%" box when below 100% instantly resets volume to `1.0f` (100% BIT-PERFECT), triggering green "0 dBFS LOCKED" indicator.
- [ ] **Step 2: Add visual badge "0 dBFS PURE LINE-OUT" when volume == 1.0f**
- [ ] **Step 3: Verify compilation via Gradle**
  Run: `./gradlew compileDebugKotlin`
  Expected: BUILD SUCCESSFUL

---

### Task 3: Run Full Test Suite & Verify APK Deployment

**Files:**
- Deploy via ADB to connected Samsung Galaxy S23 FE

- [ ] **Step 1: Run all unit tests**
  Run: `./gradlew testDebugUnitTest`
  Expected: 12/12 tests pass
- [ ] **Step 2: Install APK and launch player on phone**
  Run: `adb install -r app/build/outputs/apk/debug/app-debug.apk && adb shell "am start -n com.yuka.musicplayer/.MainActivity"`
  Expected: Success
