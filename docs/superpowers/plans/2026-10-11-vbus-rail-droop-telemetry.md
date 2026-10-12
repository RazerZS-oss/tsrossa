# OTG VBUS Power Rail & Electrical Telemetry Bridge Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide full terminal-driven electrical rail telemetry, automated ADB battery fuel-gauge monitoring under 500mA OTG loads, and physical copper trace voltage droop simulation in `tools/hardware_probe.py`.

**Architecture:**
1. Extend `tools/hardware_probe.py` with an ADB Battery Subsystem Poller that queries real-time battery voltage, discharge current (`current_avg`), battery temperature, and calculated OTG output power from the connected Samsung Galaxy S23 FE.
2. Add a physical copper trace droop model into `tools/hardware_probe.py` calculating Ohm's law VBUS drop across standard USB-C cable resistance ($R_{cable} \approx 0.15\,\Omega - 0.35\,\Omega$) under 100mA to 500mA DAC loads.
3. Expose battery power telemetry to the Android app (`DacTelemetryState.kt` / `AudioEngine.kt`) to alert the user if phone battery voltage or OTG power limits throttle USB DAC performance.

**Tech Stack:** Python 3 (subprocess, ADB, math), Kotlin, Android battery broadcast receiver.

**Spec:** Audited findings on 500mA VBUS rail droop and fuel-gauge electrical monitoring.

## Global Constraints
- Must not block audio streaming thread under any circumstances.
- ADB poller must handle disconnected phone gracefully.

## Review Focus
1. Fuel gauge polling interval: poll every 1s to prevent adb shell overhead.
2. Rail droop thresholds: warn if calculated VBUS drops below 4.40V (USB spec minimum).

---

### Task 1: Add ADB Battery & OTG Power Rail Poller to `tools/hardware_probe.py`

**Files:**
- Modify: `tools/hardware_probe.py`

**Interfaces:**
- Produces: CLI flags `--poll-battery`, `--simulate-droop [mA]`, `--cable-resistance [ohms]`

- [ ] **Step 1: Implement `query_adb_battery(device_id)` in `tools/hardware_probe.py`**
  Parses `dumpsys battery` fields: `voltage` (mV), `current_avg` (mA), `temperature` (°C / 10), and charging status.
- [ ] **Step 2: Implement `simulate_vbus_droop(current_ma, resistance_ohms)` in `tools/hardware_probe.py`**
  Calculates nominal 5.0V VBUS droop $\Delta V = I \times R$, output voltage at DAC connector, and plots ASCII voltage drop curve.
- [ ] **Step 3: Test CLI tool with `--poll-battery` and `--simulate-droop 500`**
  Run: `python3 tools/hardware_probe.py --simulate-droop 500`
  Expected: PASS with calculated droop and status (e.g. 4.85V > 4.40V SAFE).

---

### Task 2: Update Documentation in `tools/README.md`

**Files:**
- Modify: `tools/README.md`

- [ ] **Step 1: Document live battery & VBUS droop testing commands**
- [ ] **Step 2: Add physical test bench wiring schematics for measuring copper trace resistance**
