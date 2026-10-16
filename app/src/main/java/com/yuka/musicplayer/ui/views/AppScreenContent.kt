package com.yuka.musicplayer.ui.views

import android.content.SharedPreferences
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.model.ViewState
import com.yuka.musicplayer.update.UpdateCheckState
import java.io.File

/**
 * Screen Content Container that switches between LIBRARY, PLAYLIST, TRACK, and SETTINGS views with fluid physics transitions.
 */
@Composable
fun AppScreenContent(
    viewState: ViewState,
    modifier: Modifier = Modifier,
    // Library
    musicRootDirectory: File,
    scannedItems: List<com.yuka.musicplayer.model.ScannedMusicItem>,
    isScanningLibrary: Boolean,
    onChangeDirectory: () -> Unit,
    currentTrack: TrackInfo?,
    playlistSet: Set<String>,
    searchQuery: String,
    onSearchChange: (String) -> Unit,
    librarySortMode: LibrarySortMode,
    onCycleSort: () -> Unit,
    onRefreshLibrary: () -> Unit,
    onTrackActionTarget: (File) -> Unit,
    onSelectLibraryItem: (com.yuka.musicplayer.model.ScannedMusicItem) -> Unit,
    // Playlist
    playlists: List<com.yuka.musicplayer.model.Playlist>,
    selectedPlaylistId: String,
    activePlayingPlaylistId: String?,
    onSelectPlaylistTab: (String) -> Unit,
    onCreatePlaylistClick: () -> Unit,
    onRenamePlaylistClick: (com.yuka.musicplayer.model.Playlist) -> Unit,
    onDeletePlaylistClick: (com.yuka.musicplayer.model.Playlist) -> Unit,
    isShuffleEnabled: Boolean,
    onToggleShuffle: () -> Unit,
    repeatMode: RepeatMode,
    onCycleRepeat: () -> Unit,
    priorityQueueSize: Int,
    onOpenQueue: () -> Unit,
    onPlayPlaylistFile: (File, String) -> Unit,
    onPlaylistFileRemoved: (String, String) -> Unit,
    onClearPlaylistAction: (String) -> Unit,
    // Track Player
    playbackPosition: Double,
    onSeekTo: (Double) -> Unit,
    isPlaying: Boolean,
    onTogglePlay: () -> Unit,
    currentVolume: Float,
    onVolumeChange: (Float) -> Unit,
    onPlayNext: () -> Unit,
    onPlayPrev: () -> Unit,
    isHardwareVolumeActive: Boolean = false,
    // Settings
    sharedPref: SharedPreferences,
    bgMode: String,
    onBgModeChange: (String) -> Unit,
    fontScale: Float,
    onFontScaleChange: (Float) -> Unit,
    hapticEnabled: Boolean,
    onHapticChange: (Boolean) -> Unit,
    keepAwake: Boolean,
    onKeepAwakeChange: (Boolean) -> Unit,
    defaultScreenStr: String,
    onDefaultScreenChange: (String) -> Unit,
    accentMode: String,
    onAccentModeChange: (String) -> Unit,
    accentFixedColorStr: String,
    onAccentFixedColorChange: (String) -> Unit,
    isNotificationGranted: Boolean,
    isStorageGranted: Boolean,
    isDndGranted: Boolean,
    isBatteryOptimizationIgnored: Boolean = true,
    onRequestNotification: () -> Unit,
    onRequestStorage: () -> Unit,
    onRequestDnd: () -> Unit,
    onRequestBatteryOptimization: () -> Unit = {},
    onOpenPermissionDialog: () -> Unit,
    onOpenHelp: () -> Unit,
    updateCheckState: UpdateCheckState,
    onOpenUpdateDialog: () -> Unit,
    usbBufferProfile: Int = 1,
    onUsbBufferProfileChange: (Int) -> Unit = {}
) {
    fun viewStateIndex(state: ViewState): Int = when (state) {
        ViewState.LIBRARY -> 0
        ViewState.PLAYLIST -> 1
        ViewState.TRACK -> 2
        ViewState.SETTINGS -> 3
    }

    Box(modifier = modifier.fillMaxSize()) {
        AnimatedContent(
            targetState = viewState,
            transitionSpec = {
                val forward = viewStateIndex(targetState) > viewStateIndex(initialState)
                if (forward) {
                    (slideInHorizontally(
                        animationSpec = spring(dampingRatio = 0.85f, stiffness = 380f),
                        initialOffsetX = { fullWidth -> (fullWidth * 0.25f).toInt() }
                    ) + fadeIn(animationSpec = tween(220))).togetherWith(
                        slideOutHorizontally(
                            animationSpec = spring(dampingRatio = 0.85f, stiffness = 380f),
                            targetOffsetX = { fullWidth -> -(fullWidth * 0.25f).toInt() }
                        ) + fadeOut(animationSpec = tween(180))
                    )
                } else {
                    (slideInHorizontally(
                        animationSpec = spring(dampingRatio = 0.85f, stiffness = 380f),
                        initialOffsetX = { fullWidth -> -(fullWidth * 0.25f).toInt() }
                    ) + fadeIn(animationSpec = tween(220))).togetherWith(
                        slideOutHorizontally(
                            animationSpec = spring(dampingRatio = 0.85f, stiffness = 380f),
                            targetOffsetX = { fullWidth -> (fullWidth * 0.25f).toInt() }
                        ) + fadeOut(animationSpec = tween(180))
                    )
                }
            },
            label = "ScreenTransition"
        ) { targetScreen ->
            when (targetScreen) {
                ViewState.LIBRARY -> {
                    LibraryView(
                        musicRootDirectory = musicRootDirectory,
                        scannedItems = scannedItems,
                        isScanning = isScanningLibrary,
                        currentTrack = currentTrack,
                        playlistSet = playlistSet,
                        searchQuery = searchQuery,
                        sortMode = librarySortMode,
                        onCycleSort = onCycleSort,
                        onRefresh = onRefreshLibrary,
                        onChangeDirectory = onChangeDirectory,
                        onSearchChange = onSearchChange,
                        onTrackSelected = onSelectLibraryItem,
                        onTrackLongPressed = { file ->
                            onTrackActionTarget(file)
                        },
                        modifier = Modifier.fillMaxSize()
                    )
                }
                ViewState.PLAYLIST -> {
                    PlaylistView(
                        playlists = playlists,
                        selectedPlaylistId = selectedPlaylistId,
                        activePlayingPlaylistId = activePlayingPlaylistId,
                        currentTrack = currentTrack,
                        isShuffleEnabled = isShuffleEnabled,
                        repeatMode = repeatMode,
                        priorityQueueSize = priorityQueueSize,
                        onSelectPlaylistTab = onSelectPlaylistTab,
                        onCreatePlaylistClick = onCreatePlaylistClick,
                        onRenamePlaylistClick = onRenamePlaylistClick,
                        onDeletePlaylistClick = onDeletePlaylistClick,
                        onToggleShuffle = onToggleShuffle,
                        onCycleRepeat = onCycleRepeat,
                        onOpenQueue = onOpenQueue,
                        onFileSelected = onPlayPlaylistFile,
                        onFileRemoved = onPlaylistFileRemoved,
                        onClearPlaylist = onClearPlaylistAction,
                        onTrackLongPressed = onTrackActionTarget,
                        modifier = Modifier.fillMaxSize()
                    )
                }
                ViewState.TRACK -> {
                    TrackView(
                        track = currentTrack,
                        playbackPosition = playbackPosition,
                        isPlaying = isPlaying,
                        currentVolume = currentVolume,
                        isShuffleEnabled = isShuffleEnabled,
                        repeatMode = repeatMode,
                        priorityQueueSize = priorityQueueSize,
                        onTogglePlay = onTogglePlay,
                        onVolumeChange = onVolumeChange,
                        onPlayNext = onPlayNext,
                        onPlayPrev = onPlayPrev,
                        onToggleShuffle = onToggleShuffle,
                        onCycleRepeat = onCycleRepeat,
                        onOpenQueue = onOpenQueue,
                        onSeekTo = onSeekTo,
                        isHardwareVolumeActive = isHardwareVolumeActive,
                        modifier = Modifier.fillMaxSize()
                    )
                }
                ViewState.SETTINGS -> {
                    SettingsView(
                        prefs = sharedPref,
                        bgMode = bgMode,
                        onBgModeChange = onBgModeChange,
                        fontScale = fontScale,
                        onFontScaleChange = onFontScaleChange,
                        hapticEnabled = hapticEnabled,
                        onHapticChange = onHapticChange,
                        keepAwake = keepAwake,
                        onKeepAwakeChange = onKeepAwakeChange,
                        defaultScreen = defaultScreenStr,
                        onDefaultScreenChange = onDefaultScreenChange,
                        accentMode = accentMode,
                        onAccentModeChange = onAccentModeChange,
                        accentFixedColorStr = accentFixedColorStr,
                        onAccentFixedColorChange = onAccentFixedColorChange,
                        isNotificationGranted = isNotificationGranted,
                        isStorageGranted = isStorageGranted,
                        isDndGranted = isDndGranted,
                        isBatteryOptimizationIgnored = isBatteryOptimizationIgnored,
                        onRequestNotification = onRequestNotification,
                        onRequestStorage = onRequestStorage,
                        onRequestDnd = onRequestDnd,
                        onRequestBatteryOptimization = onRequestBatteryOptimization,
                        onOpenPermissionDialog = onOpenPermissionDialog,
                        onOpenHelp = onOpenHelp,
                        updateCheckState = updateCheckState,
                        onOpenUpdateDialog = onOpenUpdateDialog,
                        usbBufferProfile = usbBufferProfile,
                        onUsbBufferProfileChange = onUsbBufferProfileChange,
                        modifier = Modifier.fillMaxSize()
                    )
                }
            }
        }
    }
}
