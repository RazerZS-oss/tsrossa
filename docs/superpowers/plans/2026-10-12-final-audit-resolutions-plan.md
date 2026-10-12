# Plan: Final Audit Resolutions (Git Index, DSD Guidance, OEM Power Onboarding, Bitrate kbps Display)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menuntaskan seluruh 4 temuan dari hasil audit:
1. Menyelaraskan seluruh file kode baru yang masih `untracked` ke Git index agar repositori utuh dan aman saat clone/distribusi.
2. Memberikan kejelasan format audio DSD (.dsf, .dff) dan PCM hi-res di antarmuka manual sistem dan filter pustaka.
3. Menambahkan kartu izin "Pengabaian Baterai OEM (Anti-Kill)" ke wizard onboarding awal (`PermissionDialog.kt`) agar HP Xiaomi/OnePlus/Oppo tidak membunuh playback di latar belakang.
4. Menambahkan kalkulasi dan tampilan Real-Time Audio Bitrate (kbps) di baris lencana format audio layar Now Playing (`TrackView.kt`).

**Architecture:**
- **Bitrate calculation:** Hitung `(fileSize * 8) / (durationSeconds * 1000)` di `TrackInfo` atau `TrackView.kt`.
- **Onboarding battery card:** Sisipkan `OemBatteryHelper` card ke dalam `PermissionDialog.kt` agar pengguna baru langsung diarahkan mengatur manajemen daya sejak peluncuran pertama.
- **Git staging:** Jalankan `git add` terstruktur untuk semua direktori baru di `app/src/`.

**Tech Stack:** Kotlin, Jetpack Compose, Git CLI, JUnit4.

---

### Task 1: Real-Time Audio Bitrate (kbps) Calculation & Display
*(Nice to have #4 from Audit: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:L370-390`)*

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/model/TrackModels.kt:L90-110`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/TrackView.kt:L340-390`
- Test: `app/src/test/java/com/yuka/musicplayer/audio/DacHardwareTimingTest.kt`

- [ ] **Step 1: Tulis unit test untuk kalkulasi bitrate kbps**
Di `app/src/test/java/com/yuka/musicplayer/audio/DacHardwareTimingTest.kt`:
```kotlin
@Test
fun testBitrateKbpsCalculation() {
    val fileSizeBytes = 25_000_000L // 25 MB
    val durationSec = 200.0          // 200 seconds
    val bitrateKbps = if (durationSec > 0) ((fileSizeBytes * 8) / (durationSec * 1000)).toInt() else 0
    assertEquals(1000, bitrateKbps)
}
```

- [ ] **Step 2: Jalankan test untuk memverifikasi perhitungan**
Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.audio.DacHardwareTimingTest.testBitrateKbpsCalculation`
Expected: PASS

- [ ] **Step 3: Tambahkan properti `bitrateKbps` pada `TrackInfo` di `TrackModels.kt`**
```kotlin
val bitrateKbps: Int
    get() {
        val size = try { file.length() } catch (_: Exception) { 0L }
        return if (durationSeconds > 0 && size > 0) {
            ((size * 8.0) / (durationSeconds * 1000.0)).toInt()
        } else {
            0
        }
    }
```

- [ ] **Step 4: Tampilkan lencana bitrate di `TrackView.kt`**
Di dalam baris **Audiophile Spec Strip** (`TrackView.kt:L343-390`), tampilkan lencana bitrate tepat di samping `track.codec.uppercase()`:
```kotlin
if (track.bitrateKbps > 0) {
    Spacer(modifier = Modifier.width(6.dp))
    Box(modifier = Modifier.size(3.dp).background(Color(0xFF445069), CircleShape))
    Spacer(modifier = Modifier.width(6.dp))
    Text(
        text = "${track.bitrateKbps} KBPS",
        color = TerminalWhite.copy(alpha = 0.85f),
        fontSize = 9.sp,
        fontWeight = FontWeight.Bold,
        fontFamily = TerminalFont
    )
}
```
Hasil visual di baris badge Now Playing:
`[ FLAC • 1042 KBPS • DIRECT USB • BIT-PERFECT ]`

---

### Task 2: Tambahkan Kartu Manajemen Daya OEM ke Wizard Setup Awal (`PermissionDialog.kt`)

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/dialogs/PermissionDialog.kt:L120-250`
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt:L200-240`

- [ ] **Step 1: Sisipkan `PermissionCard` untuk latar belakang baterai OEM di `PermissionDialog.kt`**
Tambahkan kartu:
- Judul: "MANAJEMEN BATERAI LATAR BELAKANG"
- Deskripsi: "Wajib diatur pada Xiaomi (HyperOS/MIUI), Oppo, Vivo & OnePlus agar koneksi USB DAC tidak diputus paksa saat layar ponsel terkunci."
- Tombol: "PENGATURAN BATERAI OEM" -> memanggil `onRequestBatteryOptimization`.

---

### Task 3: Dokumentasi Format Audio DSD / PCM di Manual Sistem

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/settings/UpdateHelpSections.kt`

- [ ] **Step 1: Tambahkan catatan format audio yang didukung**
Jelaskan format yang didukung secara native:
- FLAC (16-bit / 24-bit / 32-bit integer PCM hingga 384kHz)
- WAV / WAVE (Linear PCM hingga 384kHz)
- MQA (Bit-perfect bitstream passthrough untuk DAC MQA renderer)
- DSD: Direkomendasikan konversi ke FLAC 24-bit/192kHz atau 24-bit/352.8kHz sebelum pemutaran bit-perfect.

---

### Task 4: Penyelarasan Git Working Tree & Verifikasi Build

**Files:**
- Modify: Git Index

- [ ] **Step 1: Jalankan `git add` untuk semua source code dan test**
```bash
git add app/src/main/java/ app/src/test/ app/src/main/cpp/ app/build.gradle.kts docs/
```

- [ ] **Step 2: Jalankan full unit tests & build debug APK**
Run: `./gradlew testDebugUnitTest assembleDebug`
Expected: BUILD SUCCESSFUL (Semua tes lulus).

- [ ] **Step 3: Deploy dan uji coba di perangkat Samsung Galaxy S23 FE**
Run: `adb -s 192.168.100.54:38771 install -r app/build/outputs/apk/debug/app-debug.apk`
Expected: Success.
