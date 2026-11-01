import SwiftUI
import AppKit

public struct TrackTableRowView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public let index: Int
    public let track: TrackMetadata
    
    public init(index: Int, track: TrackMetadata) {
        self.index = index
        self.track = track
    }
    
    public var body: some View {
        let isCurrent = engine.currentTrack?.path == track.path
        let isSearchTarget = !vm.searchText.isEmpty && (index - 1) == vm.searchSelectedIndex
        let isFlac = track.path.lowercased().hasSuffix(".flac")
        
        return HStack(spacing: 14) {
            Button(action: { engine.play(track: track) }) {
                HStack(spacing: 14) {
                    // Column 1: # or Playing Indicator
                    ZStack {
                        if isCurrent {
                            Image(systemName: engine.isPlaying && !engine.isPaused ? "waveform" : "speaker.wave.2.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(vm.currentTheme.primary)
                        } else if isSearchTarget {
                            Image(systemName: "return")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.currentTheme.primary)
                        } else {
                            Text("\(index)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                        }
                    }
                    .frame(width: 34, alignment: .center)
                    
                    // Column 2: Mini Thumbnail + Title + Top Hit Badge
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isCurrent ? vm.currentTheme.primaryContainer : Color.white.opacity(0.07))
                                .frame(width: 38, height: 38)
                            
                            if isCurrent, let art = vm.currentArtwork {
                                Image(nsImage: art)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 38, height: 38)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "music.note")
                                    .font(.system(size: 14))
                                    .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                            }
                        }
                        
                        Text(track.title)
                            .font(.system(size: 13, weight: (isCurrent || isSearchTarget) ? .bold : .semibold))
                            .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        if vm.isTrackLiked(track.path) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                        
                        if isSearchTarget {
                            Text("⏎ ENTER TO PLAY")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.onPrimary)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(vm.currentTheme.primary)
                                .cornerRadius(5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Column 3: Artist
                    Text(track.artist)
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                        .frame(width: 165, alignment: .leading)
                    
                    // Column 4: Album
                    Text(track.album)
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textMuted)
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)
                    
                    // Column 5: Format Badge
                    Text("\(isFlac ? "FLAC" : "WAV") \(track.bitDepth)/\(String(format: "%.1fk", Double(track.sampleRate)/1000.0))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(isCurrent ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isCurrent ? vm.currentTheme.primaryContainer : vm.currentTheme.primaryContainer.opacity(0.35))
                        .cornerRadius(6)
                        .frame(width: 110, alignment: .center)
                    
                    // Column 6: Duration
                    Text(vm.formatTime(track.durationSeconds))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 54, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: {
                    engine.play(track: track)
                }) {
                    Label("Play Now", systemImage: "play.fill")
                }
                
                Button(action: {
                    vm.addToPlayNext(track: track)
                }) {
                    Label("Play Next (Putar Berikutnya)", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                
                Button(action: {
                    vm.addToQueueEnd(track: track)
                }) {
                    Label("Add to Queue (Tambahkan ke Antrean)", systemImage: "text.badge.plus")
                }
                
                Divider()
                
                let isLiked = vm.isTrackLiked(track.path)
                Button(action: {
                    vm.toggleLike(track: track)
                }) {
                    Label(isLiked ? "Unlike Song" : "Like Song", systemImage: isLiked ? "heart.slash" : "heart.fill")
                }
                
                Divider()
                
                Menu("Add / Remove from Playlist") {
                    ForEach(vm.playlists) { pl in
                        let inPlaylist = pl.matches(track: track)
                        Button(action: {
                            vm.toggleTrackInPlaylist(trackPath: track.path, playlistId: pl.id)
                        }) {
                            Text("\(inPlaylist ? "✓ " : "   ")\(pl.name)")
                        }
                    }
                }
                
                Divider()
                
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: track.path)])
                }) {
                    Label("Show in Finder", systemImage: "folder")
                }
            }
            
            // Column 7: Add to Queue & Playlist Menu Button
            Menu {
                Button(action: {
                    vm.addToPlayNext(track: track)
                }) {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                
                Button(action: {
                    vm.addToQueueEnd(track: track)
                }) {
                    Label("Add to Queue", systemImage: "text.badge.plus")
                }
                
                Divider()
                
                let isRowLiked = vm.isTrackLiked(track.path)
                Button(action: {
                    vm.toggleLike(track: track)
                }) {
                    Label(isRowLiked ? "Unlike Song" : "Like Song", systemImage: isRowLiked ? "heart.slash" : "heart.fill")
                }
                
                Divider()
                
                Text("Add / Remove from Playlist")
                ForEach(vm.playlists) { pl in
                    let inPlaylist = pl.matches(track: track)
                    Button(action: {
                        vm.toggleTrackInPlaylist(trackPath: track.path, playlistId: pl.id)
                    }) {
                        Text("\(inPlaylist ? "✓ " : "   ")\(pl.name)")
                    }
                }
                Divider()
                Button(action: {
                    vm.openCreatePlaylistModal()
                    vm.newPlaylistSelectedPaths.insert(track.path)
                    if vm.newPlaylistName.isEmpty && track.artist != "Unknown Artist" {
                        vm.newPlaylistName = track.artist
                    }
                }) {
                    Text("+ New Playlist with '\(track.title)'...")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(width: 34, alignment: .center)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            isCurrent
                ? vm.currentTheme.primaryContainer.opacity(0.35)
                : (isSearchTarget ? vm.currentTheme.primaryContainer.opacity(0.22) : Color.white.opacity(0.02))
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSearchTarget ? vm.currentTheme.primary.opacity(0.65) : Color.clear, lineWidth: 1)
        )
    }
}
