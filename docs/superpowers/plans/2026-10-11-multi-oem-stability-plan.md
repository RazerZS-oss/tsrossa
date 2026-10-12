# Multi-OEM Stability & Battery Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure 100% uninterrupted playback and hardware compatibility on Chinese OEM smartphones (Xiaomi/HyperOS, Oppo/ColorOS, Vivo/Funtouch, Huawei) by adding an OEM Battery Killer Mitigation helper in Settings, and verifying kernel driver detachment on all media hardware chips.

**Architecture:**
1. In `PermissionsSettingsSection.kt`, add an "UNRESTRICTED BATTERY ACCESS" action row and OEM whitelist launcher that triggers `Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` with intent fallbacks to OEM autostart managers (Xiaomi Auto-start, Oppo Startup Manager, Vivo High Background Power Consumption).
2. Add a helper function `OemBatteryHelper.kt` detecting device manufacturer (`Build.MANUFACTURER`) and providing tailored user instructions or deep-links directly to manufacturer battery killer whitelist screens.
3. Validate MediaTek/Snapdragon `usbfs` interface detachment in `UsbDacController.cpp` to ensure robust recovery under `-EBUSY`.

**Tech Stack:** Kotlin, Android Intents (`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`), Android NDK C++.

**Spec:** Multi-device stability audit findings.

## Global Constraints
- Target Android API 26..34.
- Must not crash on non-OEM clean Android devices (Pixel, Motorola).
- All unit tests must pass.

---

### Task 1: Create `OemBatteryHelper.kt` for OEM Background Power Whitelisting

**Files:**
- Create: `app/src/main/java/com/yuka/musicplayer/util/OemBatteryHelper.kt`

**Interfaces:**
- Produces: `object OemBatteryHelper { fun isBatteryOptimizationIgnored(context: Context): Boolean; fun openBatteryOptimizationSettings(context: Context) }`

- [ ] **Step 1: Write `OemBatteryHelper.kt` with standard PowerManager check and OEM intent fallbacks**
- [ ] **Step 2: Add battery optimization status check in `MainActivity.kt`**

---

### Task 2: Add Battery Whitelist Row to `PermissionsSettingsSection.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/PermissionsSettingsSection.kt`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/SettingsView.kt`

- [ ] **Step 1: Add "BACKGROUND BATTERY (DON'T KILL MY APP)" row to `PermissionsSettingsSection`**
- [ ] **Step 2: Wire click action to `OemBatteryHelper.openBatteryOptimizationSettings(context)`**
- [ ] **Step 3: Verify build via Gradle**
  Run: `./gradlew assembleDebug`
  Expected: BUILD SUCCESSFUL

---

### Task 3: Deploy and Verify on Samsung Galaxy S23 FE

**Files:**
- Test on device via ADB

- [ ] **Step 1: Run unit test suite**
  Run: `./gradlew testDebugUnitTest`
  Expected: 11/11 tests pass
- [ ] **Step 2: Install APK and verify battery whitelist status over ADB**
  Run: `adb install -r app/build/outputs/apk/debug/app-debug.apk`
  Expected: Success
