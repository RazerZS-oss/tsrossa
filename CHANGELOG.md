# Changelog

All notable changes to the **tsrossa** Audiophile Direct USB Bit-Perfect Music Player are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.6.0-BETA] - 2026-10-18

### Added
- **Material 3 (Material You) Glassmorphic UI Overhaul:**
  - Dynamic tonal elevation surface tokens (`m3SurfaceBase`, `m3SurfaceContainerLow`, `m3SurfaceContainer`, `m3SurfaceContainerHigh`, `m3OnSurface`, `m3OnSurfaceVariant`).
  - `AnimatedM3Palette` root-level color provider with 500ms smooth cross-palette transitions, eliminating abrupt theme snaps when switching songs or theme modes without per-item animation overhead.
  - `AppBackgroundContainer` supporting OLED Black, Signature M3 Glow, and Blurred Album Artwork with hardware-accelerated 550ms `Crossfade`.
  - `BackdropBlur` system with `LocalModalBlurCount` applying an 8.dp background blur behind active bottom sheets and dialogs.
- **Now Playing Screen Enhancements:**
  - Coherent and 100% opaque background canvas matching the App UI (Album Artwork, Tonal, OLED), eliminating see-through bleeding into underlying library views.
  - Synchronized LRC and embedded lyrics engine (`NowPlayingLyricsView`, `LyricsHelper`) with automatic time matching, active line auto-scroll, and manual line seeking.
  - Circular tactile hero controls: 68.dp Play/Pause, 48.dp Previous/Next, 50.dp Volume Pill, 50.dp Lyrics toggle, and 50.dp Priority Queue shortcut.
  - Smooth swipe-down to collapse gesture with discrete state change reporting, dropping per-frame recomposition overhead.
- **Library & Search Power Tools:**
  - Comprehensive 11-criteria Track Sorting modal sheet (`LibrarySortModalSheet`) supporting Title, Artist, Album, Date Added, Duration, Track Number, Bitrate, Sample Rate, File Size, File Name, and Extension in Ascending or Descending orders.
  - Interactive alphabetical fast scroller (`LibraryFastScroller`) with tactile letter popups and smooth fling snapping.
  - Enhanced search bar with fuzzy text matching (`FuzzySearchHelper`), multi-attribute filtering (Artist, Album, Path), and instant clear.
  - Multi-select batch mode supporting bulk queueing, bulk playlist addition, and bulk deletion with safety confirmation modal (`ConfirmDeleteDialog`).
  - Dynamic Folder, Artist, and Album filter sheets (`FilterSelectionModalSheet`).
  - Full-detail track inspector sheet (`TrackDetailsModalSheet`) displaying bit depth, sample rate, bitrate, codec, duration, and file path.
- **Playlist Management V2:**
  - Complete Playlist CRUD: create, rename, delete, pin to top, and clear tracks.
  - In-playlist fuzzy search and live track counter.
  - Playlist cards styled with tactile 0.85 opacity and active playback indicators.
  - Sequential and Shuffled playback buttons directly accessible from playlist cards.
- **Audiophile Hardware & Volume Management:**
  - Separate volume policies for 32-bit Hardware Chip Volume (defaults to 100% / 0 dBFS) and 64-bit Bit-Perfect DSP Software Volume (defaults to safe 20% for hearing and equipment protection).
  - Persistent volume levels stored per unique connected USB DAC identifier (`vol_dac_<id>_hw32` / `vol_dac_<id>_dsp64`).
  - Hardware DAC Warm-Up feature triggered via long-press on the DAC top-bar pill, complete with confirmation dialog (`WarmupConfirmDialog`) and real-time HUD (`WarmupHudDialog`).
  - Screen Pinning / Lock Task Mode toggle in the top bar to lock the device into a dedicated DAP (Digital Audio Player) mode.
  - In-app diagnostics terminal panel (`SystemLogsPanel`) with real-time log filtering, search, export to clipboard/file, and DAC telemetry metrics.
- **Branding & Packaging:**
  - Updated high-resolution application icons for Android across all mipmap density buckets (adaptive XML, monochrome, round) and complete iOS asset sets.

### Fixed
- **Swipe-Down Lag in Now Playing:** Reduced swipe-down blur radius from 18.dp to 6.dp and converted per-frame float callbacks to discrete boolean transitions, eliminating 120fps full-tree recomposition stutter.
- **Album Artwork Blur Overhead:** Reduced global artwork blur radius from 52.dp unbounded to 12.dp rectangle, and cached `ImageBitmap` allocations in `MainActivity` to prevent reallocations every 200ms playback position tick.
- **Background Flashing During Song Transitions:** Preserved the last valid cover art bitmap while track metadata is loading (`Loading...`), preventing blank skeleton background flashes.
- **Light Mode Play/Pause Contrast Bug:** Made Mini Player and Now Playing Play/Pause button icons dynamically select `Color.White` when running in Light Mode or when button surface luminance is dark.
- **Modal Sheet Status Bar Overlap:** Capped modal bottom sheet fullscreen height at 90% (`0.90f`) of the viewport, ensuring clean status bar clearance.
- **Sort Tracks Selector Styling:** Removed unwanted redundant container background around the Ascending / Descending order toggle in `LibrarySortModalSheet`.
- **Top Bar & Playlist Opacity:** Standardized DAC top-bar pill and playlist card backgrounds to an explicit 0.85 opacity across all surface modes.

### Performance & Automated Testing
- Expanded automated unit test suite covering color contrast luminance calculation, music scanner sorting, queue resolver logic, metadata extraction, album art caching, fuzzy search, and lyrics parsing.

---

## [1.5.0-BETA] - 2026-10-16

### Added
- **Audio Engine Stability & High-Precision Pacing:**
  - Host-based Bresenham packet pacing and bit-perfect pass-through eliminating screeching and audio distortion artifacts across asynchronous USB Isochronous endpoints.
  - Synchronized background playback position tracking with the native audio engine clock.
  - Allowed hardware DAC warmup execution while music playback is paused.
  - Guaranteed `REQ_EVENT_TRACK_FINISHED` event emission upon track completion to maintain gapless transitions.
  - Asynchronous dispatch of JNI callbacks off the real-time ISO streaming thread.
- **Playlist & Storage:**
  - Custom multi-playlist creation, management, and storage scanning.
  - Hardened playlist storage with atomic file writes and in-memory caching (`PlaylistStorageHelper`).
- **UI & Settings:**
  - Persistent theme, display, and typography settings in `SharedPreferences`.
  - Introduced `TrackTitleParser` and optimized hairline border tokens.
  - Fixed top-bar header accent color resolution.

### Fixed
- Fixed memory safety issue in USB descriptor parser by copying `AltSettingInfo` by value to eliminate dangling pointers.
- Eliminated decode buffer race conditions and buffer starvation noise.
- Fixed Android `libusb_init` SELinux I/O failures.
