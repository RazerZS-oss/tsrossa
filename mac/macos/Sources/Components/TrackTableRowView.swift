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
        let isLiked = vm.isTrackLiked(track.path)
        
        return HStack(spacing: 12) {
            Button(action: { engine.play(track: track) }) {
                HStack(spacing: 12) {
                    // Column 1: # or Animated Equalizer Bars Indicator
                    ZStack {
                        if isCurrent {
                            EqualizerBarsView(
                                barColor: vm.currentTheme.primary,
                                isPlaying: engine.isPlaying && !engine.isPaused
                            )
                        } else if isSearchTarget {
                            Image(systemName: "return")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.currentTheme.primary)
                        } else {
                            Text("\(index)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                        }
                    }
                    .frame(width: 28, alignment: .center)
                    
                    // Column 2: Mini Artwork / Icon + Title + Artist
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isCurrent ? vm.currentTheme.primaryContainer : Color.white.opacity(0.06))
                                .frame(width: 34, height: 34)
                            
                            if isCurrent, let art = vm.currentArtwork {
                                Image(nsImage: art)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 34, height: 34)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                Image(systemName: "music.note")
                                    .font(.system(size: 12))
                                    .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .font(.system(size: 13, weight: (isCurrent || isSearchTarget) ? .bold : .medium))
                                .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                                .lineLimit(1)
                            
                            Text(track.artist)
                                .font(.system(size: 11))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if isSearchTarget {
                            Text("⏎ ENTER")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.onPrimary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(vm.currentTheme.primary)
                                .cornerRadius(4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Column 3: Album (Responsive: shown when space permits)
                    Text(track.album)
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textMuted)
                        .lineLimit(1)
                        .frame(minWidth: 100, maxWidth: 170, alignment: .leading)
                    
                    // Column 4: Format / Bitrate Badge
                    Text("\(isFlac ? "FLAC" : "WAV") \(track.bitDepth)-BIT / \(String(format: "%.1fk", Double(track.sampleRate)/1000.0))")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(isCurrent ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.primary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(isCurrent ? vm.currentTheme.primaryContainer : vm.currentTheme.primaryContainer.opacity(0.35))
                        .cornerRadius(6)
                        .frame(width: 125, alignment: .center)
                    
                    // Column 5: Duration
                    Text(vm.formatTime(track.durationSeconds))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 48, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                Button(action: { engine.play(track: track) }) {
                    Label("Play Now", systemImage: "play.fill")
                }
                Button(action: { vm.addToPlayNext(track: track) }) {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                Button(action: { vm.addToQueueEnd(track: track) }) {
                    Label("Add to Queue", systemImage: "text.badge.plus")
                }
                Divider()
                Button(action: { vm.toggleLike(track: track) }) {
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
            
            // Column 6: Favorite Heart Button
            Button(action: { vm.toggleLike(track: track) }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 12))
                    .foregroundColor(isLiked ? vm.currentTheme.primary : vm.currentTheme.textMuted.opacity(0.40))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Column 7: Actions Menu
            Menu {
                Button(action: { vm.addToPlayNext(track: track) }) {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                Button(action: { vm.addToQueueEnd(track: track) }) {
                    Label("Add to Queue", systemImage: "text.badge.plus")
                }
                Divider()
                Button(action: { vm.toggleLike(track: track) }) {
                    Label(isLiked ? "Unlike Song" : "Like Song", systemImage: isLiked ? "heart.slash" : "heart.fill")
                }
                Divider()
                Text("Playlists")
                ForEach(vm.playlists) { pl in
                    let inPlaylist = pl.matches(track: track)
                    Button(action: {
                        vm.toggleTrackInPlaylist(trackPath: track.path, playlistId: pl.id)
                    }) {
                        Text("\(inPlaylist ? "✓ " : "   ")\(pl.name)")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 11))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .frame(width: 22, height: 22)
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(width: 24, alignment: .center)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            isCurrent
                ? vm.currentTheme.primaryContainer.opacity(0.30)
                : (isSearchTarget ? vm.currentTheme.primaryContainer.opacity(0.20) : Color.white.opacity(0.015))
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSearchTarget ? vm.currentTheme.primary.opacity(0.55) : Color.clear, lineWidth: 1)
        )
    }
}
