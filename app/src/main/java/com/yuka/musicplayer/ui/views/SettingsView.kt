package com.yuka.musicplayer.ui.views

import android.content.SharedPreferences
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yuka.musicplayer.ui.views.settings.*
import com.yuka.musicplayer.update.UpdateCheckState

@Composable
fun SettingsView(
    prefs: SharedPreferences,
    bgMode: String,
    onBgModeChange: (String) -> Unit,
    fontScale: Float,
    onFontScaleChange: (Float) -> Unit,
    hapticEnabled: Boolean,
    onHapticChange: (Boolean) -> Unit,
    keepAwake: Boolean,
    onKeepAwakeChange: (Boolean) -> Unit,
    defaultScreen: String,
    onDefaultScreenChange: (String) -> Unit,
    accentMode: String,
    onAccentModeChange: (String) -> Unit,
    accentFixedColorStr: String,
    onAccentFixedColorChange: (String) -> Unit,
    isNotificationGranted: Boolean = true,
    isStorageGranted: Boolean = true,
    isDndGranted: Boolean = false,
    isBatteryOptimizationIgnored: Boolean = true,
    onRequestNotification: () -> Unit = {},
    onRequestStorage: () -> Unit = {},
    onRequestDnd: () -> Unit = {},
    onRequestBatteryOptimization: () -> Unit = {},
    onOpenPermissionDialog: () -> Unit = {},
    onOpenHelp: () -> Unit = {},
    updateCheckState: UpdateCheckState = UpdateCheckState.Idle,
    onCheckForUpdate: () -> Unit = {},
    onOpenUpdateDialog: () -> Unit = {},
    usbBufferProfile: Int = 1,
    onUsbBufferProfileChange: (Int) -> Unit = {},
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 14.dp, vertical = 8.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // --- 1. THEME & DISPLAY ---
        ThemeSettingsSection(
            bgMode = bgMode,
            onBgModeChange = onBgModeChange,
            accentMode = accentMode,
            onAccentModeChange = onAccentModeChange,
            accentFixedColorStr = accentFixedColorStr,
            onAccentFixedColorChange = onAccentFixedColorChange
        )

        // --- 2. TYPOGRAPHY & TOUCH ---
        TypographyHapticsSection(
            prefs = prefs,
            fontScale = fontScale,
            onFontScaleChange = onFontScaleChange,
            hapticEnabled = hapticEnabled,
            onHapticChange = onHapticChange
        )

        // --- 3. PLAYBACK & BEHAVIOR ---
        PlaybackLaunchSection(
            prefs = prefs,
            keepAwake = keepAwake,
            onKeepAwakeChange = onKeepAwakeChange,
            defaultScreen = defaultScreen,
            onDefaultScreenChange = onDefaultScreenChange,
            usbBufferProfile = usbBufferProfile,
            onUsbBufferProfileChange = onUsbBufferProfileChange
        )

        // --- 4. PERMISSIONS & SYSTEM ACCESS ---
        PermissionsSettingsSection(
            isNotificationGranted = isNotificationGranted,
            isStorageGranted = isStorageGranted,
            isDndGranted = isDndGranted,
            isBatteryOptimizationIgnored = isBatteryOptimizationIgnored,
            onRequestNotification = onRequestNotification,
            onRequestStorage = onRequestStorage,
            onRequestDnd = onRequestDnd,
            onRequestBatteryOptimization = onRequestBatteryOptimization,
            onOpenPermissionDialog = onOpenPermissionDialog
        )

        // --- 5. DOCUMENTATION & SYSTEM MANUAL ---
        SystemManualSection(
            onOpenHelp = onOpenHelp
        )

        // --- 6. APPLICATION UPDATES ---
        ApplicationUpdatesSection(
            updateCheckState = updateCheckState,
            onOpenUpdateDialog = onOpenUpdateDialog
        )
    }
}
