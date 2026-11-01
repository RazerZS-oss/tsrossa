# tsrossa for macOS

Direct-to-DAC, bit-perfect audiophile player built specifically for macOS (macOS 12.0 Monterey through macOS 15+ Sequoia) on Apple Silicon (arm64) and Intel (x86_64).

tsrossa bypasses the macOS CoreAudio system mixer, volume scaling, and alert sound multiplexing by talking directly to hardware output devices in **Exclusive Hog Mode** (`kAudioDevicePropertyHogMode`) and dynamically switching physical DAC hardware clocks to match native file sampling rates from 44.1 kHz up to 384 kHz.

---

## Screenshot

<p align="center">
  <img src="../screenshots/desktop_01_studio_stage.png" alt="tsrossa macOS Studio Interface" width="100%"/>
  <br/>
  <em>Studio Stage: 3-column responsive workspace with live hero banner, animated equalizer bars, spinning vinyl player, collapsible right inspector (lyrics, FFT spectrum, queue), and floating mini-player mode.</em>
</p>

---

## Core Audio Architecture

- **Exclusive Hog Mode**: Takes exclusive lock over DAC hardware via `kAudioDevicePropertyHogMode`. Other apps cannot play audio through the DAC while tsrossa is active, preventing system alert mixing or sample rate conversions.
- **Dynamic Hardware Clock Switching**: Queries DAC nominal sample rate capabilities and switches physical clock crystals (44.1k, 48k, 88.2k, 96k, 176.4k, 192k, 384k) on the fly without software resampling.
- **Direct Memory Pinning (`mlock`)**: FLAC and WAV streams are preloaded into uncompressed 32-bit linear PCM buffers and locked in physical RAM via POSIX `mlock()`, eliminating flash storage read spikes and OS swap latency.
- **True Unity Gain**: Hardware volume scalar maps 100% directly to 0 dBFS bit-transparent pass-through.
- **Standalone Native Engine**: C++17 CoreAudio driver (`mac/cpp/`) is completely self-contained with bundled `dr_flac` and `dr_wav` decoders.

---

## Desktop Interface & Features

- **3-Column Responsive Workspace**:
  - **Sidebar**: Quick navigation for Now Playing, Hi-Res Masters (24-bit filter), Autoplay Radio, FLAC/WAV archives, playlists, and active DAC hardware indicator.
  - **Center Stage**: Hero showcase with cover art, mastering metadata, audiophile filter chips (FLAC/WAV/kHz/bit-depth), and multi-column tracklist with animated equalizer bars for the active track.
  - **Collapsible Right Inspector**: 3-tab panel featuring Time-Synced Lyrics (`.lrc` / embedded), live 32-band FFT Spectrum Visualizer & Signal Path Audit, and Up Next Queue. Auto-collapses on narrower screens (< 1060px) to keep the tracklist spacious.
- **Spinning Vinyl Transport Bar**: Realistic vinyl record disc with concentric grooves and center spindle that rotates smoothly during playback.
- **Floating Mini-Player**: 360x480 compact floating card with ambient artwork blur, live synced lyric line preview, mini scrubber, and transport controls.
- **Full-Screen Theater Mode (Cmd + F)**: Immersive large-format view designed for high-resolution displays.

---

## Project Structure

```text
mac/
├── cpp/                               # Self-contained native C++17 CoreAudio HAL Engine
│   ├── CoreAudioSink.cpp / .h         # Hardware HAL driver & Exclusive Hog Mode
│   ├── TsrossaAudioBridge.cpp / .h    # C bridge for Swift runtime
│   ├── MacAudioCommon.h               # Ring buffer and PCM audio structs
│   ├── MacAudioDecoder.h              # Decoder abstractions
│   ├── dr_flac.h / dr_wav.h           # Lossless FLAC & WAV single-header decoders
│   └── dr_impl.c                      # Decoder implementation unit
├── macos/
│   ├── Info.plist                     # Bundle metadata and audio permissions
│   └── Sources/                       # Modular SwiftUI Frontend
│       ├── main.swift                 # Entry point (@main NSApplication)
│       ├── MainAppView.swift          # Root layout router with GeometryReader responsiveness
│       ├── AppViewModel.swift         # Observable application state, queue, and theme
│       ├── AudioEngine.swift          # Swift interface to native CoreAudio HAL
│       ├── LyricsManager.swift        # Synchronized LRC and ID3/Vorbis parser
│       ├── MetadataScanner.swift      # Concurrent lossless metadata reader
│       ├── Theme.swift                # Monet-inspired Material You tonal palettes
│       ├── UpdateManager.swift        # OTA update engine via GitHub Releases
│       ├── Components/                # Modular reusable UI widgets
│       │   ├── SidebarView.swift      # Navigation and playlist sidebar
│       │   ├── TopBarView.swift       # Command search, DAC pill, and view actions
│       │   ├── TransportBarView.swift # Player controls, scrubber, and volume attenuator
│       │   ├── TrackTableRowView.swift# Multi-column track rows with animated EQ bars
│       │   ├── SpinningVinylView.swift# Smooth rotating vinyl record disc
│       │   └── EqualizerBarsView.swift# 3-bar dancing spectrum indicator
│       ├── Views/                     # Full workspace views
│       │   ├── LibraryView.swift      # Hero banner, filter chips, and tracklist
│       │   ├── NowPlayingView.swift   # Large cover showcase and signal path audit
│       │   ├── QueueView.swift        # Up Next queue manager
│       │   ├── LyricsView.swift       # Time-synced karaoke lyrics
│       │   ├── TheaterView.swift      # Immersive full-screen theater mode
│       │   ├── InspectorView.swift    # 3-tab right inspector (lyrics, FFT, queue)
│       │   ├── MiniPlayerView.swift   # Compact floating mini-player card
│       │   └── SettingsView.swift     # CoreAudio hardware preferences
│       └── Modals/
│           ├── PlaylistModals.swift   # New playlist and queue-saving dialogs
│           └── TelemetryModalView.swift # Signal path and DAC diagnostics modal
├── build_mac.sh                       # Shell script compiling dylib and packaging tsrossa.app
├── package_dmg.sh                     # Disk image (.dmg) packaging script
└── README.md                          # macOS subproject documentation
```

---

## Building from Source

No full Xcode IDE installation is required. Everything compiles directly using standard command line tools (`clang++` and `swiftc`).

### Requirements
- macOS 12.0 (Monterey) or later (tested up to macOS 15+ Sequoia).
- Apple Silicon (`arm64`) or Intel (`x86_64`).
- Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

### Build Commands

```bash
cd mac
chmod +x build_mac.sh package_dmg.sh

# 1. Build and install directly to /Applications/tsrossa.app
./build_mac.sh --install

# 2. Or build locally in the workspace (for testing without modifying /Applications)
./build_mac.sh

# 3. Create a distributable disk image (.dmg)
./package_dmg.sh
```

---

## Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Space` | Play / Pause |
| `Cmd + 1` | Switch to Now Playing Screen |
| `Cmd + 2` | Switch to Music Library |
| `Cmd + 4` | Open Settings & CoreAudio Configuration |
| `Cmd + F` | Toggle Theater Mode |
| `Cmd + K` | Focus Global Search Bar |
| `Cmd + N` | Create New Playlist |
| `Cmd + R` | Rescan Music Library |
| `Cmd + D` | Open Hardware Signal Path Telemetry |
| `Cmd + [` / `Cmd + ]` | Previous / Next Track |
| `Cmd + Up` / `Cmd + Down` | Volume Up / Down (Scalar Control) |

---

## Troubleshooting

### LaunchServices Error -54 ("The application cannot be opened")
If macOS quarantine flags locally compiled binaries, clear the quarantine extended attribute:
```bash
xattr -cr /Applications/tsrossa.app
codesign --force --deep -s - /Applications/tsrossa.app
```

### Exclusive Hog Mode Conflict
If another audio app or DAW (Logic Pro, Ableton, Tidal) holds exclusive ownership of your DAC, close that application or toggle Hog Mode off in tsrossa settings (`Cmd + 4`).
