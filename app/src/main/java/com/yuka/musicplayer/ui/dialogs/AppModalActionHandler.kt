package com.yuka.musicplayer.ui.dialogs

import android.content.Context
import android.content.SharedPreferences
import android.widget.Toast
import com.yuka.musicplayer.audio.AudioPlayerManager
import com.yuka.musicplayer.model.LibrarySortMode
import com.yuka.musicplayer.model.PlaybackSource
import com.yuka.musicplayer.model.sortLibraryFiles
import com.yuka.musicplayer.model.appendPlaylist
import com.yuka.musicplayer.model.loadPlaylist
import com.yuka.musicplayer.model.removePlaylist
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Controller/handler for all modal actions (Queue manipulation, Playlist operations, Track Context actions, Permissions).
 */
class AppModalActionHandler(
    private val context: Context,
    private val coroutineScope: CoroutineScope,
    private val sharedPref: SharedPreferences,
    private val getPriorityQueue: () -> List<File>,
    private val setPriorityQueue: (List<File>) -> Unit,
    private val getPlaylistPaths: () -> List<String>,
    private val setPlaylistPaths: (List<String>) -> Unit,
    private val getPlaylistSet: () -> Set<String>,
    private val getCurrentPlaybackSourceStr: () -> String,
    private val isShuffleEnabled: () -> Boolean,
    private val getShuffledList: () -> List<File>,
    private val setShuffledList: (List<File>) -> Unit,
    private val getLibrarySortMode: () -> LibrarySortMode,
    private val setPlaybackLibraryFiles: (List<File>) -> Unit,
    private val syncPreparedNextTrack: () -> Unit,
    private val playTrack: (File, Boolean, Boolean, PlaybackSource) -> Unit,
    private val onDismissPermissionDialog: () -> Unit,
    private val onDismissQueuePanel: () -> Unit,
    private val onDismissTrackOptions: () -> Unit
) {

    fun onCompletePermissions() {
        sharedPref.edit().putBoolean("completed_permission_onboarding", true).apply()
        onDismissPermissionDialog()
    }

    fun onRemoveFromQueue(idx: Int) {
        val currentQueue = getPriorityQueue()
        if (idx in currentQueue.indices) {
            val updated = currentQueue.filterIndexed { i, _ -> i != idx }
            setPriorityQueue(updated)
            AudioPlayerManager.priorityQueue = updated
            syncPreparedNextTrack()
        }
    }

    fun onClearQueue() {
        setPriorityQueue(emptyList())
        AudioPlayerManager.priorityQueue = emptyList()
        syncPreparedNextTrack()
    }

    fun onSelectQueueTrack(file: File) {
        onDismissQueuePanel()
        val currentQueue = getPriorityQueue()
        if (currentQueue.any { it.absolutePath == file.absolutePath }) {
            val updated = currentQueue.filter { it.absolutePath != file.absolutePath }
            setPriorityQueue(updated)
            AudioPlayerManager.priorityQueue = updated
        }
        val targetSource = if (getPlaylistPaths().any { it == file.absolutePath }) {
            PlaybackSource.PLAYLIST
        } else {
            PlaybackSource.LIBRARY
        }
        playTrack(file, false, true, targetSource)
    }

    fun onPlayTrackAction(target: File, targetSource: PlaybackSource) {
        onDismissTrackOptions()
        if (targetSource == PlaybackSource.LIBRARY) {
            val files = target.parentFile?.listFiles()?.filter {
                !it.isDirectory && (
                    it.extension.equals("flac", ignoreCase = true) ||
                    it.extension.equals("wav", ignoreCase = true) ||
                    it.extension.equals("wave", ignoreCase = true)
                )
            }?.let { sortLibraryFiles(it, getLibrarySortMode()) } ?: emptyList()
            setPlaybackLibraryFiles(files)
        }
        playTrack(target, false, true, targetSource)
    }

    fun onPlayNextInQueue(target: File) {
        val updated = listOf(target) + getPriorityQueue()
        setPriorityQueue(updated)
        AudioPlayerManager.priorityQueue = updated
        syncPreparedNextTrack()
        Toast.makeText(context, "Added as next track", Toast.LENGTH_SHORT).show()
    }

    fun onAddToQueue(target: File) {
        val updated = getPriorityQueue() + target
        setPriorityQueue(updated)
        AudioPlayerManager.priorityQueue = updated
        syncPreparedNextTrack()
        Toast.makeText(context, "Added to queue (#${updated.size})", Toast.LENGTH_SHORT).show()
    }

    fun onAddToPlaylist(pathToAdd: String) {
        coroutineScope.launch(Dispatchers.IO) {
            val added = appendPlaylist(context, pathToAdd, getPlaylistSet())
            if (added) {
                val newPaths = loadPlaylist(context)
                withContext(Dispatchers.Main) {
                    setPlaylistPaths(newPaths)
                    Toast.makeText(context, "Added to playlist", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    fun onRemoveFromPlaylist(pathToRemove: String) {
        coroutineScope.launch(Dispatchers.IO) {
            val newPaths = removePlaylist(context, pathToRemove, getPlaylistPaths())
            withContext(Dispatchers.Main) {
                setPlaylistPaths(newPaths)
                if (getCurrentPlaybackSourceStr() == PlaybackSource.PLAYLIST.name) {
                    if (isShuffleEnabled()) {
                        setShuffledList(getShuffledList().filter { it.absolutePath != pathToRemove })
                    }
                    syncPreparedNextTrack()
                }
                Toast.makeText(context, "Removed from playlist", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
