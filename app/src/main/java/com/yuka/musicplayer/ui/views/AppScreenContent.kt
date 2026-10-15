package com.yuka.musicplayer.ui.views

import android.content.Context
import android.content.SharedPreferences
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.widget.Toast
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.yuka.musicplayer.audio.AudioEngine
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.PlaybackSource
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.model.ViewState
import com.yuka.musicplayer.model.sortLibraryFiles
import com.yuka.musicplayer.update.UpdateCheckState
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Screen Content Container that switches between LIBRARY, PLAYLIST, TRACK, and SETTINGS views.
 */
@Composable
fun ColumnScope.AppScreenContent(
    viewState: ViewState,
    context: Context,
    coroutineScope: CoroutineScope,
    audioEngine: AudioEngine,
    audioManager: AudioManager,
    audioFocusRequest: AudioFocusRequest?,
    focusChangeListener: AudioManager.OnAudioFocusChangeListener,
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
    onStopPlayback: () -> Unit,
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
    onCheckForUpdate: () -> Unit,
    onOpenUpdateDialog: () -> Unit,
    usbBufferProfile: Int = 1,
    onUsbBufferProfileChange: (Int) -> Unit = {}
) {
    when (viewState) {
        ViewState.LIBRARY -> {
            LibraryView(
                musicRootDirectory = musicRootDirectory,
                scannedItems = scannedItems,
                isScanning = isScanningLibrary,
                playingFile = currentTrack?.file,
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
                modifier = Modifier.weight(1f)
            )
        }
        ViewState.PLAYLIST -> {
            PlaylistView(
                playlists = playlists,
                selectedPlaylistId = selectedPlaylistId,
                activePlayingPlaylistId = activePlayingPlaylistId,
                playingFile = currentTrack?.file,
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
                modifier = Modifier.weight(1f)
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
                onStop = onStopPlayback,
                onToggleShuffle = onToggleShuffle,
                onCycleRepeat = onCycleRepeat,
                onOpenQueue = onOpenQueue,
                onSeekTo = onSeekTo,
                modifier = Modifier.weight(1f)
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
                onCheckForUpdate = onCheckForUpdate,
                onOpenUpdateDialog = onOpenUpdateDialog,
                usbBufferProfile = usbBufferProfile,
                onUsbBufferProfileChange = onUsbBufferProfileChange,
                modifier = Modifier.weight(1f)
            )
        }
    }
}
