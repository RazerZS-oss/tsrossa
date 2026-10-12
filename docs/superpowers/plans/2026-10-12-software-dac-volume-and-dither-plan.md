# Software DAC Volume Initialization & High-Resolution Dither Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure USB DACs lacking hardware volume control immediately sync to the user's saved volume upon connection without blasting at 100% full scale, and optimize TPDF dither amplitude calculation across 16-bit, 24-bit, and 32-bit container slot sizes.

**Architecture:** 
1. In `UsbDacController.cpp::probeFeatureUnit()`, when hardware volume is inactive (no Feature Unit found or OS blocks AudioControl interface claiming), immediately calculate exponential software volume scaling from `g_audioState.rawLinearVolume` and store into `g_audioState.targetVolume`.
2. In `AudioStreamer.cpp::iso_callback()`, refine the TPDF dither half-LSB computation to explicitly match the subframe slot size (2-byte = 32768.0f, 3-byte = 128.0f, 4-byte = 1.0f) so 32-bit DAC containers avoid dither truncation.

**Tech Stack:** C++17, Android NDK, libusb-1.0, JNI.

**Spec:** The 2 findings from `/ponytail:ponytail-audit`:
1. DACs without hardware volume control stay at 1.0f on initial plug unless the volume slider is adjusted (`UsbDacController.cpp:L713-772`).
2. Dither amplitude static across bit depths during software volume attenuation (`AudioStreamer.cpp:L394-402`).

## Global Constraints
- Bit-perfect mode at $\ge 0.999f$ (0 dBFS) must remain completely direct integer with zero dither and zero float conversion.
- Software attenuation curve must strictly follow the human-hearing psychoacoustic curve: $(e^{4 \cdot vol} - 1) / (e^4 - 1)$.
- All existing unit tests (24/24) must pass.
- Clean build for debug and release APKs.

## Review Focus
- Hotplugging a DAC without hardware volume control immediately adopts the saved volume level without needing manual UI slider interaction.
- Attenuated 32-bit playback applies 1.0f half-LSB dither without numerical overflow.
- 16-bit (2-byte) and 24-bit (3-byte) dither amplitudes remain mathematically exact.

---

### Task 1: Initialize Software Volume on Non-Hardware USB DACs

**Files:**
- Modify: `app/src/main/cpp/UsbDacController.cpp:L713-L772`

**Interfaces:**
- Consumes: `g_audioState.rawLinearVolume`, `g_audioState.isHardwareVolumeActive`, `g_audioState.targetVolume`.
- Produces: Immediate volume sync for software-only DACs upon USB device probe.

- [ ] **Step 1: Inspect `probeFeatureUnit()` in `UsbDacController.cpp`**
Observe the block around line 717 where `isHardwareVolumeActive` is evaluated:
```cpp
  if (!g_audioState.isForceSoftwareVolume.load() && g_audioState.featureUnitId != -1 && acInterfaceClaimed) {
    g_audioState.isHardwareVolumeActive.store(true);
    g_audioState.targetVolume.store(1.0f); // Bit-Perfect
    ...
  }
```

- [ ] **Step 2: Add software volume fallback initialization**
Append the `else` block to synchronize saved volume when hardware volume cannot be activated:
```cpp
  } else {
    g_audioState.isHardwareVolumeActive.store(false);
    float vol = g_audioState.rawLinearVolume;
    float scaled_vol = vol;
    if (vol < 0.001f) {
      scaled_vol = 0.0f;
    } else {
      scaled_vol = (std::exp(vol * 4.0f) - 1.0f) / (std::exp(4.0f) - 1.0f);
    }
    g_audioState.targetVolume.store(scaled_vol);
  }
```

- [ ] **Step 3: Verify C++ build**
Run `./gradlew compileDebugSources` to ensure clean compilation.

---

### Task 2: Calibrate TPDF Dither Amplitude for 32-bit and 24-bit Containers

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:L394-L403`

**Interfaces:**
- Consumes: `sf_size` (subframe byte size: 2, 3, or 4), `fast_uniform_rand()`.
- Produces: Correct dither LSB scaling for 16-bit, 24-bit, and 32-bit DAC slots.

- [ ] **Step 1: Inspect TPDF dither logic in `AudioStreamer.cpp`**
Locate lines 394–402:
```cpp
  if (g_audioState.currentVolume < 0.999f) {
    float half_lsb = 128.0f;
    if (sf_size == 2) half_lsb = 32768.0f;
    else if (sf_size == 4) half_lsb = 0.5f;

    float randA = fast_uniform_rand() * half_lsb;
    float randB = fast_uniform_rand() * half_lsb;
    scaled += (randA - randB);
  }
```

- [ ] **Step 2: Calibrate `half_lsb` scaling**
For full 32-bit signed integers, 1 LSB is 1.0f (half-LSB = 0.5f to 1.0f in float representation, optimal TPDF peak-to-peak amplitude is 2 LSBs with $randA - randB$ where uniform rand is $[-1.0, 1.0]$ or $[0.0, 1.0]$). Ensure `fast_uniform_rand()` produces $[0.0, 1.0]$ and scale `half_lsb` accurately:
```cpp
  if (g_audioState.currentVolume < 0.999f) {
    float half_lsb = 128.0f; // 24-bit in 32-bit container (8-bit shift)
    if (sf_size == 2) {
      half_lsb = 32768.0f;   // 16-bit in 32-bit container (16-bit shift)
    } else if (sf_size == 4) {
      half_lsb = 1.0f;       // Native 32-bit slot
    }

    float randA = fast_uniform_rand() * half_lsb;
    float randB = fast_uniform_rand() * half_lsb;
    scaled += (randA - randB);
  }
```

- [ ] **Step 3: Run full verification build and tests**
Run:
```bash
./gradlew testDebugUnitTest assembleDebug
```
Expected: BUILD SUCCESSFUL, 24/24 unit tests pass.
