# tsrossa

Direct-to-DAC Bit-Perfect USB & CoreAudio Audio Player for macOS and Android.

tsrossa is an open-source, bit-perfect music player developed specifically for audiophiles and high-resolution hardware setups. It bypasses standard operating system mixers (Android AudioFlinger and macOS CoreAudio system mixer) to deliver bit-perfect, zero-jitter linear PCM directly to external USB DACs and high-fidelity output hardware.

---

## Supported Platforms

- **macOS**: Apple Silicon (M1/M2/M3/M4) and Intel (x86_64), macOS 12.0+
- **Android**: Android 8.0 (API 26) through Android 15+ (API 35) with USB Host OTG

---

## Core Engineering Features

### 1. Bit-Perfect Direct Audio Transport
- **macOS**: Direct CoreAudio HAL integration using Exclusive Hog Mode (`kAudioDevicePropertyHogMode`), bypassing the macOS system audio mixer and sample-rate converters. Supports dynamic hardware clock switching to match native file sampling rates (44.1 kHz up to 192 kHz / 384 kHz).
- **Android**: Direct kernel-level USB transport via `libusb-1.0` and Linux `usbfs`, bypassing `AudioTrack` and `AudioFlinger`. Communicates directly with USB Audio Class (UAC1 / UAC2) endpoints with asynchronous isochronous transfers.

### 2. POSIX Memory Pinning (mlock)
- Audio files (FLAC and WAV) are pre-decoded into 32-bit linear PCM memory buffers prior to playback.
- Employs POSIX `mlock()` to lock audio pages in physical RAM, preventing operating system paging, flash memory I/O spikes, and micro-stuttering.

### 3. Dynamic Play Queue & Playlist Management
- Google / Spotify style dynamic playback queue:
  - **Play Next**: Inserts a track at the top of the queue to play immediately after the active song.
  - **Add to Queue**: Appends tracks to the custom dynamic sequence.
  - **Queue Workspace (Tab 3)**: Interactive queue manager with Now Playing status, drag/button reordering, individual track removal, and bulk queue clearing.
  - **Save Queue as Playlist**: 1-click conversion of active playback queue into a permanent playlist.
  - **Smart Filter Playlists**: Create instant keyword-based or artist-based playlists (e.g. Polyphia).

### 4. Audiophile Filtering & Fast Binary Parsing
- Dedicated binary header parser (`MetadataScanner`) for instantaneous reading of FLAC `STREAMINFO` and WAV `fmt ` chunks without full-file I/O overhead.
- Multi-dimensional audiophile filter bar: 1-click filtering by format (FLAC, WAV), bit depth (24-bit, 16-bit, 8-bit), and sample rate (44.1k, 48k, 88.2k, 96k, 192k).
- Spotify-style typeahead search with instant `Enter`-to-play execution.

### 5. Hardware Diagnostics & Hot-Plug Detection
- Real-time CoreAudio hardware listener detecting 3.5mm headphone jack and external USB DAC connections on the fly, with automated fallback to internal speakers when unplugged.
- Comprehensive hardware telemetry modal (Cmd + D) reporting active sample rate, bit depth, buffer size, Hog Mode state, and RAM buffer allocation.

### 6. In-App Automated OTA Updates (macOS)
- Built-in GitHub Releases updater (`UpdateManager`).
- Checks for new versions on launch or on demand, downloads latest application archives, verifies integrity, and updates the installation in-place.

---

## Technical Specifications

| Parameter | Specification |
| :--- | :--- |
| **Supported Formats** | FLAC (.flac): 16-bit, 24-bit, 32-bit integer PCM (44.1 kHz to 384 kHz)<br/>WAV (.wav, .wave): 16-bit, 24-bit, 32-bit Linear PCM, and 32-bit IEEE Float |
| **macOS Output** | CoreAudio HAL Direct Output, External USB DACs, Built-in Headphone Jack, Internal Speakers |
| **Android Output** | External USB DACs via USB-C OTG (Dongles, Portable DAC/Amps, Desktop DACs) |
| **USB Audio Protocols** | USB Audio Class 1.0 (UAC1) and USB Audio Class 2.0 (UAC2) |
| **Memory Buffer** | POSIX mlock() RAM pinning, zero SSD page faults |
| **License** | Apache License 2.0 |

---

## Installation

### For End Users (Pre-Built Binaries)

End users do not need to clone the repository or install compilation toolchains.

#### macOS
1. Download the latest `tsrossa-*-macos.zip` from [GitHub Releases](https://github.com/RazerZS-oss/tsrossa/releases/latest).
2. Extract the archive to obtain `tsrossa.app`.
3. Drag `tsrossa.app` into your `/Applications` folder.
4. Launch `tsrossa`.
   - Subsequent updates can be installed directly from inside the app via the **Update** button in the top navigation bar.

#### Android
1. Download the latest `tsrossa-*.apk` from [GitHub Releases](https://github.com/RazerZS-oss/tsrossa/releases/latest).
2. Install the APK on your Android device (ensure "Install from unknown sources" is permitted for your browser/file manager).
3. Connect your USB DAC via OTG and grant USB permission when prompted.

---

### For Developers (Building from Source)

Prerequisites:
- macOS: Xcode Command Line Tools (`xcode-select --install`), macOS 12+, Apple Silicon or Intel Mac.
- Android: JDK 17, Android SDK (API 34/35), Android NDK (r25+), CMake 3.22+.

#### 1. Clone the Repository
```bash
git clone https://github.com/RazerZS-oss/tsrossa.git
cd tsrossa
```

#### 2. Build macOS Application Bundle
To compile the C++ CoreAudio audio engine, compile Swift sources, and assemble `/Applications`-ready `tsrossa.app`:

```bash
chmod +x desktop/build_mac.sh
./desktop/build_mac.sh
```

The resulting application and distribution archive will be located at:
- Application: `desktop/build/tsrossa.app`
- Distribution ZIP: `desktop/build/tsrossa-1.6.0-macos.zip`

To deploy locally to `/Applications`:
```bash
rm -rf /Applications/tsrossa.app
cp -R desktop/build/tsrossa.app /Applications/tsrossa.app
xattr -cr /Applications/tsrossa.app
codesign --force --deep -s - /Applications/tsrossa.app
open /Applications/tsrossa.app
```

#### 3. Build Android APK
To compile the native C++17 USB audio engine and assemble the Android APK:

```bash
./gradlew assembleRelease
```

The output APK will be located at:
- `app/build/outputs/apk/release/app-release.apk`

---

## User Interface Overview

- **Now Playing (Cmd + 1)**: Primary playback view featuring album artwork, lossless signal path inspector, audiophile format badges, and queue continuation cards.
- **Music Library (Cmd + 2)**: Library table browser with instant search, format filters (FLAC/WAV, 24-bit/16-bit/8-bit, kHz rates), and playlist navigation.
- **Play Queue (Cmd + 3)**: Dedicated queue workspace to manage Up Next tracks, reorder items, clear active sequences, and save queues to permanent playlists.
- **DAC & Settings (Cmd + 4)**: Hardware configuration panel for CoreAudio device selection, Exclusive Hog Mode toggle, Dynamic Clock Switching, and theme customization.
- **Hardware Telemetry (Cmd + D)**: Live diagnostic monitor detailing DAC hardware parameters, frame buffers, and bit-perfect lock status.

---

## Contributing

Pull requests, issue reports, and DAC compatibility logs are welcome. Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

## License

tsrossa is licensed under the [Apache License 2.0](LICENSE).
