# Comprehensive Multi-Device Stability, Accessibility & Split-Screen Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure universal stability across all Android phone models (Xiaomi, Oppo, Vivo, Samsung, Pixel), bulletproof MediaTek/older USB controller interface claiming, full Google TalkBack screen reader accessibility, and responsive split-screen multi-window playback layout.

**Architecture:**
1. **MediaTek & Older USB Controller -EBUSY Mitigation (`AudioStreamer.cpp`)**: In `playAudio`, ensure kernel driver detachment (`libusb_detach_kernel_driver` / `USBDEVFS_DISCONNECT_CLAIM`) is proactively verified before `libusb_set_interface_alt_setting` and `ioctl(USBDEVFS_SETINTERFACE)` to prevent `-EBUSY` on MediaTek and low-end USB host controllers.
2. **Multi-OEM Background Battery Killer Mitigation (`OemBatteryHelper.kt`)**: Detect device manufacturer (`Build.MANUFACTURER`) and provide one-tap intents for unrestricted battery access and OEM autostart menus (Xiaomi HyperOS, Oppo ColorOS, Vivo FuntouchOS, Samsung OneUI). Expose in `PermissionsSettingsSection.kt`.
3. **TalkBack Screen Reader Accessibility (`AudioGlyphs.kt`, `TrackView.kt`)**: Add `Modifier.semantics { contentDescription = "..." }` to every custom vector canvas audio glyph (Play, Pause, Previous, Next, Shuffle, Repeat, Volume, Scrubber) so visually impaired users hear clear spoken labels instead of "unlabelled button".
4. **Responsive Split-Screen & Landscape Layout (`TrackView.kt`)**: Wrap the main player column in `Modifier.verticalScroll(rememberScrollState())` and use responsive constraints so that when running in multi-window mode or on small height viewports (< 450dp), album art scales gracefully and playback controls never get clipped off-screen.

**Tech Stack:** C++20, Jetpack Compose, Kotlin, Android Accessibility Semantics, Android PowerManager.

**Spec:** Audited findings on multi-device stability, MediaTek USB controllers, TalkBack accessibility, and split-screen layouts.

## Global Constraints
- Target Android API 26..34.
- Zero visual changes to cyberpunk/terminal design on standard phone screens.
- Zero audio underruns or thread blocking.
- Must compile cleanly and pass all unit tests.

---

### Task 1: Fix MediaTek & Older USB Controller Interface Claiming in `AudioStreamer.cpp`

**Files:**
- Modify: `app/src/main/cpp/AudioStreamer.cpp:712-728`

**Interfaces:**
- Produces: Robust fallback claiming with `libusb_detach_kernel_driver` + `USBDEVFS_DISCONNECT_CLAIM` if `libusb_claim_interface` returns `LIBUSB_ERROR_BUSY`.

- [ ] **Step 1: In `AudioStreamer.cpp`, wrap `libusb_claim_interface` with `-EBUSY` recovery logic:**
  ```cpp
  int claim_res = libusb_claim_interface(g_audioState.usbHandle, selected_alt->interface_num);
  if (claim_res == LIBUSB_ERROR_BUSY) {
    libusb_detach_kernel_driver(g_audioState.usbHandle, selected_alt->interface_num);
    struct usbdevfs_disconnect_claim dc;
    memset(&dc, 0, sizeof(dc));
    dc.interface = (unsigned int)selected_alt->interface_num;
    dc.flags = 0;
    ioctl(g_audioState.usbFd, USBDEVFS_DISCONNECT_CLAIM, &dc);
    libusb_claim_interface(g_audioState.usbHandle, selected_alt->interface_num);
  }
  ```
- [ ] **Step 2: Build native C++ code to verify compilation**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 2: Add TalkBack Accessibility Semantics to Custom Canvas Audio Glyphs

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/components/AudioGlyphs.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt`

- [ ] **Step 1: Add `contentDescription` semantics to `GlyphPlay`, `GlyphPause`, `GlyphNext`, `GlyphPrev`, `GlyphShuffle`, and `GlyphRepeat`**
- [ ] **Step 2: Add semantic state description to Shuffle and Repeat buttons (e.g. "Repeat all", "Repeat one", "Shuffle on")**
- [ ] **Step 3: Verify compilation via Gradle**
  Run: `./gradlew compileDebugKotlin`
  Expected: BUILD SUCCESSFUL

---

### Task 3: Make `TrackView` Responsive in Split-Screen Multi-Window Mode

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt`

- [ ] **Step 1: Add `verticalScroll(rememberScrollState())` to the player `Column`**
- [ ] **Step 2: Add responsive height checking so album art scales down on viewports with height < 500dp**
- [ ] **Step 3: Verify compilation via Gradle**
  Run: `./gradlew compileDebugKotlin`
  Expected: BUILD SUCCESSFUL

---

### Task 4: Implement `OemBatteryHelper.kt` and Integrate with Settings UI

**Files:**
- Create: `app/src/main/java/com/yuka/musicplayer/util/OemBatteryHelper.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/PermissionsSettingsSection.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/SettingsView.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt`

- [ ] **Step 1: Create `OemBatteryHelper.kt` handling manufacturer-specific battery optimization intents**
- [ ] **Step 2: Add "BACKGROUND POWER & OEM BATTERY WHITELIST" row to `PermissionsSettingsSection.kt`**
- [ ] **Step 3: Connect click event to trigger unrestricted battery dialog / OEM settings**
- [ ] **Step 4: Run unit tests to verify no regressions**
  Run: `./gradlew testDebugUnitTest`
  Expected: 11/11 tests pass

---

### Task 5: Build, Deploy & Verify on Samsung Galaxy S23 FE

**Files:**
- Test live on connected phone via ADB

- [ ] **Step 1: Assemble debug APK**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL
- [ ] **Step 2: Install APK on Samsung Galaxy S23 FE**
  Run: `adb install -r app/build/outputs/apk/debug/app-debug.apk`
  Expected: Success
- [ ] **Step 3: Verify running process and battery whitelist status**
  Run: `adb shell "cmd deviceidle whitelist | grep com.yuka.musicplayer"`
  Expected: Whitelist confirmed
