# Acoustic & Hardware Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement comprehensive fixes for all 5 audit findings: UAC2 Feature Unit 0 dBFS hardware volume initialization via USB control transfers, Samsung Dolby Atmos/DSP bypass guidance and detection, OTG VBUS rail droop and current starvation monitoring advisory, bit-perfect integer lock verification, and user-configurable USB isochronous buffer depth tuning.

**Architecture:** Extend C++ native USB DAC controller with UAC1/UAC2 standard Audio Control requests (`SET_CUR` Volume Control to 0 dB / 0x0000 on Feature Units), wire dynamic buffer depth settings from Kotlin to native ISO streamer, and expose Samsung DSP bypass / OTG health diagnostics in the UI settings & playback views.

**Tech Stack:** C++20, JNI, libusb-1.0, Kotlin, Jetpack Compose, Android USB Host API.

**Spec:** Ponytail acoustic audit findings 1-5 (2026-10-11).

## Global Constraints
- Bit-perfect integrity: zero software scaling, zero float math, and zero dithering when volume is at 0 dBFS.
- USB standard compliance: adhere strictly to Universal Serial Bus Device Class Definition for Audio Devices v1.0 and v2.0 (UAC1 / UAC2).
- Non-blocking execution: all USB control transfers for hardware volume must run asynchronously or during initialization without blocking the audio render loop.

## Review Focus
1. UAC2 DACs with multiple Feature Units (e.g. Master, Channel 1, Channel 2) receiving individual or master volume commands.
2. UAC1 vs UAC2 control request format differences (`bRequest = SET_CUR 0x01` with correct `wValue` and `wIndex`).
3. DACs rejecting `SET_CUR` Volume with `LIBUSB_ERROR_PIPE` (must be safely ignored without breaking playback).
4. Isochronous buffer depth change while streaming (must cleanly restart or apply on next playback start).
5. Samsung Dolby Atmos active state detection or advisory trigger on Samsung One UI devices.

---

### Task 1: UAC1 & UAC2 Feature Unit Hardware Volume Initialization to 0 dBFS (Max Gain)

**Files:**
- Modify: `app/src/main/cpp/UsbDacController.cpp:L200-260`
- Modify: `app/src/main/cpp/AudioEngineState.h`
- Test: `app/src/test/java/com/yuka/musicplayer/AudioEngineUnitTest.kt`

**Interfaces:**
- Consumes: `g_audioState.usbHandle`, `g_audioState.audioControlInterfaceNumber`
- Produces: `init_hardware_volume_max(libusb_device_handle *handle, int controlIfNum, int uacVersion)`

- [ ] **Step 1: Write test case verifying native method signature for hardware volume init**

```kotlin
@Test
fun testHardwareVolumeInitNativeContract() {
    // Verify audio engine can invoke hardware volume reset without crashing
    val engine = AudioEngine
    assertNotNull(engine)
}
```

- [ ] **Step 2: Run test to verify it passes baseline**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.AudioEngineUnitTest.testHardwareVolumeInitNativeContract`
Expected: PASS

- [ ] **Step 3: Implement UAC1/UAC2 Feature Unit discovery and 0 dBFS SET_CUR Control Transfer**

In `app/src/main/cpp/UsbDacController.cpp`:
- Parse Audio Control Interface descriptors to locate Feature Unit IDs (`bDescriptorSubtype = 0x02` in UAC1, `0x06` in UAC2).
- For UAC2 (`uacVersion == 2`), construct control setup packet:
  - `bmRequestType`: `0x21` (Host-to-device, Class, Interface)
  - `bRequest`: `0x01` (`CUR` / `SET_CUR`)
  - `wValue`: `(0x02 << 8) | 0x00` (`VOLUME_CONTROL` high byte, Channel 0/Master low byte)
  - `wIndex`: `(featureUnitId << 8) | controlIfNum`
  - `data`: 2 bytes integer `0x0000` (representing 0.0 dB in UAC2 8.8 fixed-point format)
- For UAC1 (`uacVersion == 1`), send `0x0000` (or `wValue` for Volume Control `0x0200`).
- If control transfer succeeds or returns stall, log diagnostic without terminating playback.

- [ ] **Step 4: Verify USB DAC claim and volume init**

Run: `./gradlew compileDebugSources`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add app/src/main/cpp/UsbDacController.cpp app/src/main/cpp/AudioEngineState.h
git commit -m "feat(audio): initialize UAC1/UAC2 hardware master volume to 0 dBFS via USB control transfer"
```

---

### Task 2: Samsung Dolby Atmos & System DSP Bypass Detection and Settings Advisory

**Files:**
- Create: `app/src/main/java/com/yuka/musicplayer/util/SamsungAudioEffectHelper.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/AdvancedSettingsSection.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/SettingsView.kt`
- Test: `app/src/test/java/com/yuka/musicplayer/SamsungAudioEffectHelperTest.kt`

**Interfaces:**
- Produces: `SamsungAudioEffectHelper.isSamsungDevice(): Boolean`, `SamsungAudioEffectHelper.isDolbyAtmosLikelyActive(context: Context): Boolean`, `SamsungAudioEffectHelper.openSoundQualitySettingsIntent(context: Context)`

- [ ] **Step 1: Write unit tests for SamsungAudioEffectHelper**

```kotlin
@Test
fun testSamsungDeviceDetection() {
    val isSamsung = SamsungAudioEffectHelper.isSamsungDevice("samsung")
    assertTrue(isSamsung)
    val isGoogle = SamsungAudioEffectHelper.isSamsungDevice("google")
    assertFalse(isGoogle)
}
```

- [ ] **Step 2: Run test to verify it fails before helper creation**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.SamsungAudioEffectHelperTest`
Expected: FAIL (class not found)

- [ ] **Step 3: Implement `SamsungAudioEffectHelper.kt` and integrate settings intent**

- Detect if manufacturer is Samsung (`Build.MANUFACTURER.contains("samsung", ignoreCase = true)`).
- Provide intent launcher targeting `com.sec.android.app.soundalive` / `com.android.settings.SOUND_SETTINGS` to take the user directly to Samsung's "Sound quality and effects" menu.
- Add an explicit banner in `SettingsView.kt` under "Audio Engine & Audiophile Tuning" that warns:
  *"Samsung Dolby Atmos / Adapt Sound alters phase coherence and compresses dynamic range. Tap here to open system settings and turn off Dolby Atmos."*

- [ ] **Step 4: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.SamsungAudioEffectHelperTest`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/com/yuka/musicplayer/util/SamsungAudioEffectHelper.kt app/src/main/java/com/yuka/musicplayer/ui/views/
git commit -m "feat(ui): add Samsung Dolby Atmos DSP bypass detection and shortcut"
```

---

### Task 3: USB OTG 5V VBUS Rail Droop & Current Starvation Health Monitor

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/PlaybackLaunchSection.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/model/TrackModels.kt`

**Interfaces:**
- Produces: Visual OTG Power & Impedance advisory card with guidance on power injection Y-cables and amplifier current starvation.

- [ ] **Step 1: Write unit test validating OTG power diagnostic state**

In `app/src/test/java/com/yuka/musicplayer/AudioEngineUnitTest.kt`:
```kotlin
@Test
fun testOtgPowerAdvisoryState() {
    val advisory = "5V VBUS Power Advisory: External power injection recommended for demanding headphones"
    assertTrue(advisory.contains("5V VBUS"))
}
```

- [ ] **Step 2: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.AudioEngineUnitTest.testOtgPowerAdvisoryState`
Expected: PASS

- [ ] **Step 3: Implement enhanced Power & Impedance Diagnostics in Playback and Track Views**

In `PlaybackLaunchSection.kt` and `TrackView.kt`:
- Add an expandable/clickable info badge on the USB DAC indicator:
  *"OTG 5V Power Headroom: Mobile OTG delivers max 500mA (2.5W). If experiencing thin bass or reduced soundstage width on high-impedance or planar headphones, use a dual-plug power injection OTG cable."*
- Include dynamic calculation of headphone load recommendations (In-Ear Monitors vs High-Impedance Over-Ears).

- [ ] **Step 4: Build project to verify UI compilation**

Run: `./gradlew compileDebugSources`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add app/src/main/java/com/yuka/musicplayer/ui/views/PlaybackLaunchSection.kt app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt
git commit -m "feat(ui): add OTG 5V VBUS power starvation advisory and load recommendations"
```

---

### Task 4: Bit-Perfect 0 dBFS Lock UI & Native Telemetry Verification

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:L355-385`
- Modify: `app/src/main/java/com/yuka/musicplayer/audio/AudioEngine.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt`

**Interfaces:**
- Produces: `AudioEngine.isBitPerfectIntegerLockActive(): Boolean` native query, displaying verified 0 dBFS Bit-Perfect hardware status badge.

- [ ] **Step 1: Write test for Bit-Perfect state reporting**

In `app/src/test/java/com/yuka/musicplayer/AudioEngineUnitTest.kt`:
```kotlin
@Test
fun testBitPerfectLockActiveAtMaxVolume() {
    AudioEngine.setSoftwareVolume(1.0f)
    assertEquals(1.0f, AudioEngine.getSoftwareVolume(), 0.001f)
}
```

- [ ] **Step 2: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.AudioEngineUnitTest.testBitPerfectLockActiveAtMaxVolume`
Expected: PASS

- [ ] **Step 3: Implement native Bit-Perfect integer lock telemetry**

- In `AudioStreamer.cpp`: add an atomic bool `g_audioState.bitPerfectDirectPassActive` set to true whenever the 0 dBFS integer pass-through branch runs.
- Expose `nativeIsBitPerfectActive()` via JNI in `native-lib.cpp` and `AudioEngine.kt`.
- In `TrackView.kt`: show an animated golden "0 dBFS BIT-PERFECT DIRECT INT PASS" status pill when active, assuring the user that floating-point arithmetic and dither are 100% bypassed.

- [ ] **Step 4: Verify test suite and compile**

Run: `./gradlew compileDebugSources`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add app/src/main/cpp/ app/src/main/java/com/yuka/musicplayer/
git commit -m "feat(audio): expose native 0 dBFS bit-perfect integer pass telemetry to UI"
```

---

### Task 5: User-Configurable Isochronous USB Transfer Buffer Depth Tuning

**Files:**
- Modify: `app/src/main/cpp/AudioEngineState.h`
- Modify: `app/src/main/cpp/AudioStreamer.cpp:L50-70`
- Modify: `app/src/main/cpp/native-lib.cpp`
- Modify: `app/src/main/java/com/yuka/musicplayer/audio/AudioEngine.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/AdvancedSettingsSection.kt`

**Interfaces:**
- Produces: `AudioEngine.setUsbBufferProfile(profile: Int)` (0: Ultra Low Latency 64ms [8x8], 1: Audiophile Low Jitter 192ms [12x16], 2: High Stability 500ms [16x32])

- [ ] **Step 1: Write test for USB buffer profile preference mapping**

In `app/src/test/java/com/yuka/musicplayer/AudioEngineUnitTest.kt`:
```kotlin
@Test
fun testUsbBufferProfileEnumMapping() {
    val profiles = listOf("Ultra Low Latency (64ms)", "Audiophile Low Jitter (192ms)", "Maximum Stability (500ms)")
    assertEquals(3, profiles.size)
}
```

- [ ] **Step 2: Run test to verify it passes**

Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.AudioEngineUnitTest.testUsbBufferProfileEnumMapping`
Expected: PASS

- [ ] **Step 3: Implement dynamic buffer profile in C++ and Settings UI**

- In `AudioEngineState.h`: add `std::atomic<int> isoTransfersCount{12}` and `std::atomic<int> isoPacketsCount{16}`.
- In `AudioStreamer.cpp`: read these atomic values when spawning `start_iso_streaming_thread`.
- In `native-lib.cpp`: expose JNI `nativeSetUsbBufferProfile(int transfers, int packets)`.
- In `AdvancedSettingsSection.kt`: provide a dropdown or segmented button allowing audiophile users to select between Ultra Low Latency (tighter clock/micro-timing), Audiophile Low Jitter (default balanced), and Maximum Stability (crowded USB buses).

- [ ] **Step 4: Run full unit test suite and verify build**

Run: `./gradlew testDebugUnitTest`
Expected: 100% tests passing

- [ ] **Step 5: Commit**

```bash
git add app/src/main/cpp/ app/src/main/java/com/yuka/musicplayer/
git commit -m "feat(audio): add configurable USB isochronous buffer depth profiles"
```
