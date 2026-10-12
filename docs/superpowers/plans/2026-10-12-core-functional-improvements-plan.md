# Plan: Core Engine Buffer Persistence, UI Hierarchy Wiring & Live Audio Feedback

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sempurnakan dan selesaikan seluruh temuan fungsional teknis: persistensi profil buffer USB pada startup, propagasi state yang benar di seluruh hierarki antarmuka Compose (MainActivity -> AppScreenContent -> SettingsView -> PlaybackLaunchSection), serta feedback audio interaktif saat perubahan buffer terjadi di tengah playback. (Mengabaikan terlebih dahulu urusan rilis GitHub / commit git).

**Architecture:**
1. Tambahkan state reaktif `usbBufferProfile` di `MainActivity.kt` yang dimuat dari SharedPreferences (`usb_buffer_profile`, default = 1).
2. Terapkan konfigurasi awal ke mesin C++ secara otomatis melalui `LaunchedEffect(Unit)` saat aplikasi dibuka.
3. Alirkan state dan event handler `onUsbBufferProfileChange` ke `AppScreenContent.kt` dan `SettingsView.kt`.
4. Berikan notifikasi/Toast edukatif kepada pengguna apabila profil buffer diubah saat audio sedang aktif: *"USB buffer profile updated (applies on next track transition)"*.

**Tech Stack:** Kotlin, Jetpack Compose, JNI, C++20, Android Toast API.

---

### Task 1: Inisialisasi & Persistensi Profil Buffer USB di `MainActivity.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/MainActivity.kt:L190-210, L360-390`
- Test: `app/src/test/java/com/yuka/musicplayer/audio/DacHardwareTimingTest.kt`

- [ ] **Step 1: Tambahkan unit test untuk pemetaan profil buffer ke jumlah transfer & paket**
Di `app/src/test/java/com/yuka/musicplayer/audio/DacHardwareTimingTest.kt`:
```kotlin
@Test
fun testBufferProfileParameters() {
    fun getBufferParams(profile: Int): Pair<Int, Int> = when (profile) {
        0 -> 8 to 8       // 64ms Ultra Low Latency
        2 -> 16 to 32     // 500ms Maximum Stability
        else -> 12 to 16  // 192ms Audiophile Low Jitter (Default)
    }
    assertEquals(8 to 8, getBufferParams(0))
    assertEquals(12 to 16, getBufferParams(1))
    assertEquals(16 to 32, getBufferParams(2))
}
```

- [ ] **Step 2: Jalankan test untuk memverifikasi test lolos**
Run: `./gradlew testDebugUnitTest --tests com.yuka.musicplayer.audio.DacHardwareTimingTest.testBufferProfileParameters`
Expected: PASS

- [ ] **Step 3: Tambahkan state `usbBufferProfile` dan `LaunchedEffect` di `MainActivity.kt`**
Di `MainActivity.kt`:
```kotlin
var usbBufferProfile by remember {
    mutableStateOf(sharedPref.getInt("usb_buffer_profile", 1))
}

// Inisialisasi profil buffer USB ke C++ saat aplikasi pertama kali menyala
LaunchedEffect(Unit) {
    val (transfers, packets) = when (usbBufferProfile) {
        0 -> 8 to 8
        2 -> 16 to 32
        else -> 12 to 16
    }
    com.yuka.musicplayer.audio.AudioEngine.setUsbBufferProfile(transfers, packets)
}
```

---

### Task 2: Hubungkan Propagasi State di `AppScreenContent.kt` & `SettingsView.kt`

**Files:**
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/SettingsView.kt:L20-80`
- Modify: `app/src/main/java/com/yuka/musicplayer/ui/views/AppScreenContent.kt:L90-198`

- [ ] **Step 1: Tambahkan parameter di `SettingsView.kt`**
Di `SettingsView.kt`, tambahkan:
```kotlin
usbBufferProfile: Int = 1,
onUsbBufferProfileChange: (Int) -> Unit = {},
```
Dan teruskan ke `PlaybackLaunchSection(...)`.

- [ ] **Step 2: Sambungkan `AppScreenContent.kt` ke `SettingsView`**
Tambahkan parameter yang sama pada `AppScreenContent.kt` dan teruskan nilai `usbBufferProfile` dan `onUsbBufferProfileChange` dari `MainActivity`.

- [ ] **Step 3: Berikan feedback Toast visual saat profil diubah saat musik berputar**
Di `MainActivity.kt` saat callback `onUsbBufferProfileChange` dipanggil:
```kotlin
onUsbBufferProfileChange = { newProfile ->
    usbBufferProfile = newProfile
    sharedPref.edit().putInt("usb_buffer_profile", newProfile).apply()
    val (transfers, packets) = when (newProfile) {
        0 -> 8 to 8
        2 -> 16 to 32
        else -> 12 to 16
    }
    com.yuka.musicplayer.audio.AudioEngine.setUsbBufferProfile(transfers, packets)
    if (audioEngine.isPlaying()) {
        Toast.makeText(context, "Buffer profile updated (active on next track)", Toast.LENGTH_SHORT).show()
    }
}
```

---

### Task 3: Verifikasi Kompilasi & Pengujian di Perangkat

**Files:**
- Build: `./gradlew compileDebugKotlin` & `./gradlew testDebugUnitTest`
- Deploy: Pasang pembaruan ke HP Samsung Galaxy S23 FE

- [ ] **Step 1: Jalankan kompilasi Kotlin & seluruh unit test**
Run: `./gradlew compileDebugKotlin testDebugUnitTest`
Expected: BUILD SUCCESSFUL (Semua tes hijau).

- [ ] **Step 2: Build APK Debug**
Run: `./gradlew assembleDebug`
Expected: Sukses menghasilkan `app-debug.apk`.

- [ ] **Step 3: Deploy ke HP Samsung Galaxy S23 FE (`RRCWA04DRQW`)**
Run: `adb -s RRCWA04DRQW install -r app/build/outputs/apk/debug/app-debug.apk`
Expected: Success.
