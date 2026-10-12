# Oscilloscope Timing & Hardware Telemetry Verification Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide full digital oscilloscopic verification tooling, sub-microsecond hardware timing telemetry, and an automated hardware bridge script for external digital oscilloscopes / logic analyzers.

**Architecture:** 
1. Embed high-resolution monotonic microsecond timestamp telemetry into native C++ driver (`AudioStreamer.cpp`, `UsbDacController.cpp`) tracking DAC PLL lock delay, interface switch delay, and USB micro-frame jitter.
2. Expose structured JNI telemetry metrics to Android Kotlin/JUnit layer so oscilloscope-equivalent digital square-wave timing benchmarks can be asserted in automated unit tests.
3. Build a standalone Linux host Python bridge script (`tools/hardware_probe.py`) using PyVISA / SCPI / `sigrok-cli` that automatically connects to any standard USB/LAN digital oscilloscope or logic analyzer, captures analog/digital traces during playback transitions, and verifies signal integrity.

**Tech Stack:** C++20, JNI, Kotlin, JUnit 4, Python 3 (PyVISA, sigrok-cli / SCPI).

**Spec:** Audited findings on hardware DAC probe verification and timing telemetry.

## Global Constraints
- Android API 26 minimum, API 34 target.
- Zero audio buffer underrun/allocation in real-time hot streaming loops.
- Python bridge script must handle absent physical instruments gracefully (mock / dry-run mode when no hardware scope is plugged in).

## Review Focus
1. Telemetry logging overhead in hot audio loop: must use lock-free atomic or ring buffer; zero heap allocations per USB frame.
2. Monotonic clock accuracy: use `std::chrono::steady_clock` to avoid system wall-clock jump artifacts.
3. Unit tests must run hermetically without requiring an actual USB DAC or oscilloscope connected.

---

### Task 1: Add High-Resolution Native Timing Telemetry to C++ Driver

**Files:**
- Modify: `app/src/main/cpp/AudioEngineState.h`
- Modify: `app/src/main/cpp/AudioEngineState.cpp`
- Modify: `app/src/main/cpp/AudioStreamer.cpp`
- Modify: `app/src/main/cpp/UsbDacController.cpp`

**Interfaces:**
- Produces: `struct DacTimingTelemetry { int64_t last_interface_settle_us; int64_t last_pll_relock_us; int64_t last_anti_pop_padding_us; int64_t max_iso_jitter_ns; };`

- [ ] **Step 1: Define `DacTimingTelemetry` struct and atomic recording methods in `AudioEngineState.h`**
- [ ] **Step 2: Instrument `UsbDacController::setSampleRate` and `setInterface` with microsecond measurement timestamps**
- [ ] **Step 3: Instrument `AudioStreamer` pre-roll silence generator with microsecond duration telemetry**
- [ ] **Step 4: Build native library via CMake to verify compilation**
  Run: `cmake --build app/.cxx/Debug/5b47161b/arm64-v8a --target native-audio`
  Expected: PASS (clean build)

---

### Task 2: Expose JNI Telemetry and Implement Verification Unit Tests

**Files:**
- Modify: `app/src/main/cpp/native-lib.cpp`
- Create: `app/src/test/java/com/yuka/musicplayer/DacHardwareTimingTest.kt`

**Interfaces:**
- Consumes: `AudioEngineState::getTimingTelemetry()`
- Produces: Kotlin data class `DacTimingMetrics(interfaceSettleUs, pllRelockUs, antiPopPaddingUs, maxIsoJitterNs)`

- [ ] **Step 1: Expose native JNI method `nativeGetTimingMetrics()`**
- [ ] **Step 2: Write JUnit test `DacHardwareTimingTest.kt` asserting exact hardware timing bounds:**
  - Interface settle duration == 15,000 µs (15 ms)
  - PLL relock delay == 50,000 µs (50 ms)
  - Cold switch anti-pop padding >= 180,000 µs (180 ms)
  - Warm resume anti-pop padding >= 50,000 µs (50 ms)
- [ ] **Step 3: Run unit tests via Gradle**
  Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.DacHardwareTimingTest`
  Expected: PASS

---

### Task 3: Build Linux Host Hardware Oscilloscope Bridge Tool (`tools/hardware_probe.py`)

**Files:**
- Create: `tools/hardware_probe.py`
- Create: `tools/README.md`

**Interfaces:**
- Consumes: SCPI / VISA over USB-TMC, LAN, or `sigrok-cli` / Saleae / Rigol / PicoScope.
- Produces: CLI tool with commands `--scan`, `--capture`, `--measure-transient`, `--dry-run`.

- [ ] **Step 1: Write `tools/hardware_probe.py` with SCPI/PyVISA auto-discovery and sigrok-cli fallback**
- [ ] **Step 2: Add dry-run simulation mode demonstrating oscilloscope probe verification directly in terminal**
- [ ] **Step 3: Run dry-run verification and document hardware wiring instructions in `tools/README.md`**
  Run: `python3 tools/hardware_probe.py --dry-run`
  Expected: Waveform simulation report showing DAC transient voltage, rise time, and settling time.
