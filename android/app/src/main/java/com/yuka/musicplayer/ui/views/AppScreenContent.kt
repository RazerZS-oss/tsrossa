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
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.RepeatMode
import com.yuka.musicplayer.model.TrackInfo
import com.yuka.musicplayer.model.ViewState
import com.yuka.musicplayer.update.UpdateCheckState
import java.io.File

/**
 * Screen Content Container that switches between LIBRARY and PLAYLIST with native HorizontalPager swipe gesture,
 * and seamlessly displays SETTINGS view.
 */
@OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
@Composable
fun AppScreenContent(
    viewState: ViewState,
    modifier: Modifier = Modifier,
    onNavChange: (ViewState) -> Unit = {},
    // Library
    musicRootDirectory: File,
    scannedItems: List<com.yuka.musicplayer.model.ScannedMusicItem>,
    isScanningLibrary: Boolean,
    onChangeDirectory: () -> Unit,
    currentTrack: TrackInfo?,
    playlistSet: Set<String>,
    searchQuery: String,
    onSearchChange: (String) -> Unit,
    librarySortMode: LibrarySortMode = LibrarySortMode.NAME_ASC,
    librarySortField: com.yuka.musicplayer.model.SortField = com.yuka.musicplayer.model.SortField.TITLE,
    librarySortOrder: com.yuka.musicplayer.model.SortOrder = com.yuka.musicplayer.model.SortOrder.ASCENDING,
    onCycleSort: () -> Unit = {},
    onSelectSort: ((LibrarySortMode) -> Unit)? = null,
    onSelectSortField: ((com.yuka.musicplayer.model.SortField, com.yuka.musicplayer.model.SortOrder) -> Unit)? = null,
    onShuffleLibrary: () -> Unit = {},
    onBulkAddToPlaylist: (List<File>) -> Unit = {},
    onBulkDelete: (List<File>) -> Unit = {},
    onRefreshLibrary: () -> Unit,
    onTrackActionTarget: (File) -> Unit,
    onSelectLibraryItem: (com.yuka.musicplayer.model.ScannedMusicItem) -> Unit,
    onLibraryModalOpenChanged: (Boolean) -> Unit = {},
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
    onPlayPlaylistSequential: (com.yuka.musicplayer.model.Playlist) -> Unit = {},
    onPlayPlaylistShuffled: (com.yuka.musicplayer.model.Playlist) -> Unit = {},
    onTogglePinPlaylist: (com.yuka.musicplayer.model.Playlist) -> Unit = {},
    isNowPlayingVisible: Boolean = false
) {
    val pagerState = rememberPagerState(
        initialPage = if (viewState == ViewState.PLAYLIST) 1 else 0,
        pageCount = { 2 }
    )

    LaunchedEffect(viewState) {
        val targetPage = when (viewState) {
            ViewState.LIBRARY -> 0
            ViewState.PLAYLIST -> 1
            else -> 0
        }
        if (pagerState.currentPage != targetPage && !pagerState.isScrollInProgress) {
            pagerState.animateScrollToPage(
                page = targetPage,
                animationSpec = spring(dampingRatio = 0.92f, stiffness = 420f)
            )
        }
    }

    LaunchedEffect(pagerState.settledPage) {
        val target = if (pagerState.settledPage == 0) ViewState.LIBRARY else ViewState.PLAYLIST
        if (viewState != target && viewState != ViewState.TRACK && viewState != ViewState.SETTINGS) {
            onNavChange(target)
        }
    }

    val isPlaylistSettledActive = androidx.compose.runtime.remember {
        androidx.compose.runtime.derivedStateOf { pagerState.settledPage == 1 }
    }

    Box(modifier = modifier.fillMaxSize()) {
        HorizontalPager(
            state = pagerState,
            beyondBoundsPageCount = 1,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            if (page == 0) {
                LibraryView(
                    musicRootDirectory = musicRootDirectory,
                    scannedItems = scannedItems,
                    isScanning = isScanningLibrary,
                    currentTrack = currentTrack,
                    playlistSet = playlistSet,
                    searchQuery = searchQuery,
                    sortField = librarySortField,
                    sortOrder = librarySortOrder,
                    sortMode = librarySortMode,
                    onCycleSort = onCycleSort,
                    onSelectSort = onSelectSort,
                    onSelectSortField = onSelectSortField,
                    onShufflePlay = onShuffleLibrary,
                    onRefresh = onRefreshLibrary,
                    onChangeDirectory = onChangeDirectory,
                    onSearchChange = onSearchChange,
                    onTrackSelected = onSelectLibraryItem,
                    onTrackLongPressed = onTrackActionTarget,
                    onBulkAddToPlaylist = onBulkAddToPlaylist,
                    onBulkDelete = onBulkDelete,
                    onLocalModalOpenChanged = onLibraryModalOpenChanged,
                    isNowPlayingVisible = isNowPlayingVisible,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
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
                    onPlayPlaylistSequential = onPlayPlaylistSequential,
                    onPlayPlaylistShuffled = onPlayPlaylistShuffled,
                    onTrackLongPressed = onTrackActionTarget,
                    isPlaylistTabActive = isPlaylistSettledActive.value,
                    isNowPlayingVisible = isNowPlayingVisible,
                    onTogglePinPlaylist = onTogglePinPlaylist,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}
