import SwiftUI
import AppKit

public struct QueueView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    public var isTheater: Bool = false
    
    public init(isTheater: Bool = false) {
        self.isTheater = isTheater
    }
    
    public var body: some View {
        if isTheater {
            theaterQueueContent
        } else {
            desktopQueueFullView
        }
    }
    
    private var desktopQueueFullView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar with Tab Switcher
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(vm.queueTabMode == "LYRICS" ? "SYNCHRONIZED LYRICS" : "ACTIVE PLAYBACK QUEUE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    Text(vm.queueTabMode == "LYRICS" ? "Karaoke & Song Lyrics" : "Play Queue & Up Next Flow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                
                Spacer()
                
                // Dual Tab Pills: [ Up Next (N) ] [ Lyrics ]
                HStack(spacing: 6) {
                    Button(action: { vm.queueTabMode = "QUEUE" }) {
                        HStack(spacing: 5) {
                            Image(systemName: "music.note.list")
                            Text("Up Next (\(vm.upNextQueue.count))")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(vm.queueTabMode == "QUEUE" ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(vm.queueTabMode == "QUEUE" ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { vm.queueTabMode = "LYRICS" }) {
                        HStack(spacing: 5) {
                            Image(systemName: "quote.bubble.fill")
                            Text("Lyrics")
                            if vm.hasLyrics {
                                Circle()
                                    .fill(vm.queueTabMode == "LYRICS" ? vm.currentTheme.onPrimary : TsrossaColors.terminalGreen)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(vm.queueTabMode == "LYRICS" ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(vm.queueTabMode == "LYRICS" ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(3)
                .background(vm.currentTheme.surfaceContainerLowest.opacity(0.6))
                .cornerRadius(14)
                
                Spacer()
                
                // Right Actions based on Active Tab
                if vm.queueTabMode == "QUEUE" {
                    HStack(spacing: 10) {
                        if !vm.upNextQueue.isEmpty {
                            Button(action: { vm.openSaveQueueModal() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.rectangle.on.rectangle")
                                    Text("Save Queue as Playlist")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.currentTheme.onPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(vm.currentTheme.primary)
                                .cornerRadius(14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(TsrossaScaleButtonStyle())
                            
                            Button(action: { vm.clearQueue() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash")
                                    Text("Clear Queue")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(vm.currentTheme.error)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(vm.currentTheme.surfaceContainerHigh)
                                .cornerRadius(14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        if vm.hasLyrics {
                            Text(vm.currentLyrics.first?.isSynced == true ? "SYNCED LRC" : "PLAIN TEXT")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(TsrossaColors.terminalGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(TsrossaColors.terminalGreen.opacity(0.15))
                                .cornerRadius(6)
                        }
                        
                        if let cur = engine.currentTrack {
                            Button(action: { vm.loadLyrics(for: cur) }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Reload Lyrics")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(vm.currentTheme.surfaceContainerHigh)
                                .cornerRadius(14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.15))
            
            if vm.queueTabMode == "LYRICS" {
                LyricsView(isTheater: false)
            } else {
                queueScrollContent
            }
        }
    }
    
    public var queueScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // SECTION 1: NOW PLAYING CARD
                VStack(alignment: .leading, spacing: 10) {
                    Text("NOW PLAYING")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    
                    if let current = engine.currentTrack {
                        HStack(spacing: 16) {
                            ZStack {
                                if let art = vm.currentArtwork {
                                    Image(nsImage: art)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 52, height: 52)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(vm.currentTheme.primaryContainer.opacity(0.5))
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Image(systemName: "waveform")
                                                .font(.system(size: 22))
                                                .foregroundColor(vm.currentTheme.primary)
                                        )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(current.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                    .lineLimit(1)
                                HStack(spacing: 8) {
                                    Text(current.artist)
                                        .font(.system(size: 12))
                                        .foregroundColor(vm.currentTheme.textSecondary)
                                        .lineLimit(1)
                                    Text("•")
                                        .foregroundColor(vm.currentTheme.textMuted)
                                    Text(current.album)
                                        .font(.system(size: 12))
                                        .foregroundColor(vm.currentTheme.textMuted)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(current.path.hasSuffix(".flac") ? "FLAC" : "WAV") \(current.bitDepth)-bit / \(String(format: "%.1fkHz", Double(current.sampleRate)/1000.0))")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(vm.currentTheme.onPrimaryContainer)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(vm.currentTheme.primaryContainer)
                                    .cornerRadius(6)
                                
                                Text("\(vm.formatTime(engine.currentTime)) / \(vm.formatTime(current.durationSeconds))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(vm.currentTheme.surfaceContainerHigh)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(vm.currentTheme.primary.opacity(0.4), lineWidth: 1)
                        )
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "pause.circle")
                                .font(.system(size: 20))
                                .foregroundColor(vm.currentTheme.textMuted)
                            Text("No track currently playing. Pick a song from your library or queue to start listening.")
                                .font(.system(size: 13))
                                .foregroundColor(vm.currentTheme.textSecondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                    }
                }
                
                // SECTION 2: DYNAMIC UP NEXT IN QUEUE
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("UP NEXT IN QUEUE (\(vm.upNextQueue.count))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        
                        Spacer()
                        
                        if !vm.upNextQueue.isEmpty {
                            Text("These tracks play next in order before continuing normal playback")
                                .font(.system(size: 11))
                                .foregroundColor(vm.currentTheme.textMuted)
                        }
                    }
                    
                    if vm.upNextQueue.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "text.badge.plus")
                                .font(.system(size: 28))
                                .foregroundColor(vm.currentTheme.textMuted)
                            Text("Your Up Next Queue is Empty")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                            Text("Use 'Play Next' or 'Add to Queue' from the track menu or right-click to queue tracks here dynamically.")
                                .font(.system(size: 12))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.currentTheme.outline.opacity(0.18), lineWidth: 1)
                        )
                    } else {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(vm.upNextQueue.enumerated()), id: \.element.id) { idx, track in
                                queueItemRow(index: idx, track: track)
                            }
                        }
                    }
                }
                
                // SECTION 3: CONTINUATION FROM CURRENT CONTEXT
                let contextTracks = !vm.searchText.isEmpty ? vm.filteredTracks : (vm.selectedPlaylist != nil ? vm.tracks.filter { vm.selectedPlaylist!.matches(track: $0) } : vm.tracks)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("NEXT FROM: \(vm.selectedPlaylist?.name.uppercased() ?? "LIBRARY") (\(contextTracks.count) TRACKS)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textSecondary)
                        Spacer()
                        Text("Will resume automatically when Up Next queue finishes")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textMuted)
                    }
                    
                    LazyVStack(spacing: 4) {
                        ForEach(Array(contextTracks.prefix(50).enumerated()), id: \.element.id) { idx, track in
                            TrackTableRowView(index: idx + 1, track: track)
                        }
                    }
                }
                
                // SECTION 4: AUTOPLAY INFINITE RADIO RECOMMENDATIONS
                let recommendations = vm.getAutoplayRecommendations()
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(vm.isAutoplayRadio ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                            
                            Text("AUTOPLAY INFINITE RADIO")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textSecondary)
                            
                            Spacer()
                            
                            Button(action: {
                                vm.isAutoplayRadio.toggle()
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(vm.isAutoplayRadio ? TsrossaColors.terminalGreen : Color.gray.opacity(0.5))
                                        .frame(width: 7, height: 7)
                                    Text(vm.isAutoplayRadio ? "AUTOPLAY ACTIVE" : "AUTOPLAY OFF")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(vm.isAutoplayRadio ? TsrossaColors.terminalGreen : vm.currentTheme.textMuted)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(vm.currentTheme.surfaceContainerHigh)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text("When the current track or queue ends, tsrossa will seamlessly queue similar lossless music.")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textMuted)
                        
                        LazyVStack(spacing: 4) {
                            ForEach(Array(recommendations.enumerated()), id: \.element.id) { idx, track in
                                TrackTableRowView(index: idx + 1, track: track)
                            }
                        }
                    }
                    .padding(.top, 14)
                }
            }
            .padding(.horizontal, isTheater ? 12 : 28)
            .padding(.vertical, 16)
        }
    }
    
    private var theaterQueueContent: some View {
        queueScrollContent
            .background(Color.white.opacity(0.03))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
    
    private func queueItemRow(index: Int, track: TrackMetadata) -> some View {
        HStack(spacing: 12) {
            // Reorder controls (Up / Down)
            VStack(spacing: 2) {
                Button(action: {
                    if index > 0 {
                        vm.moveInQueue(from: index, to: index - 1)
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(index > 0 ? vm.currentTheme.textSecondary : Color.clear)
                        .frame(width: 18, height: 12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(index == 0)
                
                Button(action: {
                    if index < vm.upNextQueue.count - 1 {
                        vm.moveInQueue(from: index, to: index + 1)
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(index < vm.upNextQueue.count - 1 ? vm.currentTheme.textSecondary : Color.clear)
                        .frame(width: 18, height: 12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(index == vm.upNextQueue.count - 1)
            }
            .frame(width: 20)
            
            // Queue position number
            Text("#\(index + 1)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.primary)
                .frame(width: 30, alignment: .leading)
            
            // Play now button
            Button(action: {
                vm.removeFromQueue(at: index)
                engine.play(track: track)
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(vm.currentTheme.primary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Track Info
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(track.artist)
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                    Text("•")
                        .foregroundColor(vm.currentTheme.textMuted)
                    Text(track.album)
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.textMuted)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Format Badge
            Text("\(track.path.hasSuffix(".flac") ? "FLAC" : "WAV") \(track.bitDepth)-bit")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.primary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(vm.currentTheme.primaryContainer.opacity(0.35))
                .cornerRadius(5)
            
            // Duration
            Text(vm.formatTime(track.durationSeconds))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(vm.currentTheme.textSecondary)
                .frame(width: 48, alignment: .trailing)
            
            // Remove from queue button
            Button(action: { vm.removeFromQueue(at: index) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(vm.currentTheme.textMuted)
                    .padding(4)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Remove from Queue")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(vm.currentTheme.surfaceContainerHigh.opacity(0.65))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(vm.currentTheme.outline.opacity(0.18), lineWidth: 1)
        )
    }
}
