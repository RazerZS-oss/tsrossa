# Contributing to tsrossa

Want to help out with tsrossa? That's awesome.

We're trying to build a solid, bit-perfect music player that talks directly to USB and desktop DACs without the OS audio stack messing with the stream. Since devices and DACs behave differently depending on the kernel, USB controllers, and firmware, real-world testing and code contributions help a ton.

---

## What We Need Most Right Now

1. **Hardware testing & DAC compatibility:**
   - Plug in your USB dongles, desktop DACs, or headphone amps (Android USB-C OTG or macOS USB/Thunderbolt/3.5mm).
   - Let us know if playback works, if hardware volume control works, or if there are issues.
   - Mention your device model, OS version, and DAC name.

2. **Audio pipeline & stability:**
   - Bug reports for audio pops, stuttering, sample rate sync issues, or crashes.
   - Improvements to the C++ audio engines (`libusb`, threading, buffer management, CoreAudio HAL).

3. **UI/UX polish:**
   - Android: Jetpack Compose tweaks, responsiveness, or library browsing improvements.
   - macOS: SwiftUI layouts, keyboard navigation, and desktop ergonomics.

---

## Project Structure

tsrossa is split into two primary platform projects:
- **`android/`**: Android application built with Kotlin, Jetpack Compose, and native C++17 NDK (`libusb-1.0` direct streaming).
- **`mac/`**: macOS application built with Swift, SwiftUI, and native C++17 CoreAudio HAL in Exclusive Hog Mode.

---

## Local Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Sembir-Garage/tsrossa.git
cd tsrossa
```

### 2. Android Development
Prerequisites:
- Android Studio / Android SDK (compileSdk 34, minSdk 26)
- Android NDK (r25+) & CMake (3.22+)
- JDK 17

Build debug APK:
```bash
cd android
./gradlew assembleDebug
```

Run unit tests:
```bash
./gradlew test
```

### 3. macOS Development
Prerequisites:
- macOS 12.0+ (Apple Silicon or Intel)
- Xcode Command Line Tools (`xcode-select --install`)

Build macOS app bundle:
```bash
cd mac
chmod +x build_mac.sh package_dmg.sh
./build_mac.sh
```

Package DMG:
```bash
./package_dmg.sh
```

---

## Reporting Issues

If something sounds wrong or crashes, please open an issue on [GitHub Issues](https://github.com/Sembir-Garage/tsrossa/issues) and mention:
- **Device / Host:** e.g. Samsung Galaxy S23 (OneUI 6 / Android 14) or MacBook Pro M1 (macOS 14 Sonoma)
- **DAC:** e.g. Moondrop Dawn Pro, FiiO KA3, Snowsky Melody, Topping DX3 Pro+
- **Track info:** Format, sample rate, bit depth (e.g. FLAC 24-bit / 96 kHz)
- **What happened:** No sound, stuttering, noise, crash, etc.
- **Android Logs (via ADB):**
  ```bash
  adb logcat -s tsrossa:V native-lib:V UsbExclusive:V
  ```
- **macOS Logs:** Check Console.app filtering by process `tsrossa`.

---

## Submitting Changes

1. Fork the repo and make your changes on a separate branch.
2. Keep PRs focused. If you're fixing two unrelated things, use two separate PRs.
3. Keep commit messages straightforward and descriptive (e.g., `feat(audio): ...`, `fix(android): ...`, `chore(mac): ...`).
4. Make sure your changes compile cleanly before opening a PR:
   - For Android: `cd android && ./gradlew test assembleDebug`
   - For macOS: `cd mac && ./build_mac.sh`
5. Open your pull request against `main`.

---

## Notes on Code

- **C++:** We use C++17. The USB streaming thread and CoreAudio render callbacks run with real-time priority. Keep callbacks fast and avoid heap allocations, mutex deadlocks, or unbounded file I/O inside time-critical audio loops.
- **Kotlin:** Modern Jetpack Compose with Material 3. Keep UI state hoisting predictable and do not perform disk or decoding operations on the main thread.
- **Swift:** Native SwiftUI. Ensure proper memory management and thread confinement when interacting with the C++ audio bridge.
