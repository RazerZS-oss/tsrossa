import SwiftUI
import AppKit

public struct LibraryView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Featured Hero Header Banner
            HStack(spacing: 20) {
                ZStack {
                    if let art = vm.currentArtwork {
                        Image(nsImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 84, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: vm.currentTheme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
                    } else {
                        TsrossaBrandIcon(size: 84, cornerRadius: 16)
                            .shadow(color: vm.currentTheme.primary.opacity(0.28), radius: 12, x: 0, y: 6)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(vm.selectedPlaylist != nil ? "SMART PLAYLIST / COLLECTION" : "LOSSLESS MASTER COLLECTION")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        
                        if let pl = vm.selectedPlaylist, !pl.filterKeyword.isEmpty {
                            Text("FILTER: \(pl.filterKeyword.uppercased())")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.onPrimaryContainer)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(vm.currentTheme.primaryContainer)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(vm.selectedPlaylist?.name ?? "Local Audiophile Library")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    
                    Text("\(vm.filteredTracks.count) of \(vm.tracks.count) tracks  •  \(vm.currentFolder)  •  Zero-Copy Direct Memory Engine")
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Hero Play, Shuffle & New Playlist Actions
                HStack(spacing: 10) {
                    Button(action: {
                        if let first = vm.filteredTracks.first {
                            engine.play(track: first)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text(vm.selectedPlaylist != nil ? "Play \(vm.selectedPlaylist?.name ?? "Playlist")" : "Play Filtered")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(vm.currentTheme.onPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(vm.currentTheme.primary)
                        .cornerRadius(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    Button(action: {
                        vm.isShuffle = true
                        vm.playNextTrack()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "shuffle")
                            Text("Shuffle")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(vm.currentTheme.surfaceContainerHigh)
                        .cornerRadius(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(vm.currentTheme.surfaceContainerLow.opacity(0.55))
            
            // Audiophile Filter Strip
            audiophileFilterBar
            
            // Widescreen Multi-Column Table Header
            HStack(spacing: 14) {
                Text("#")
                    .frame(width: 34, alignment: .center)
                Text("TITLE")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("ARTIST")
                    .frame(width: 165, alignment: .leading)
                Text("ALBUM")
                    .frame(width: 150, alignment: .leading)
                Text("ENCODING")
                    .frame(width: 110, alignment: .center)
                Image(systemName: "clock")
                    .frame(width: 54, alignment: .trailing)
                Text("LIST")
                    .frame(width: 34, alignment: .center)
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(vm.currentTheme.textMuted)
            .padding(.horizontal, 28)
            .padding(.vertical, 9)
            .background(vm.currentTheme.surfaceContainerLowest.opacity(0.5))
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.15))
            
            // Multi-Column Track Rows (or Empty Filter State)
            if vm.filteredTracks.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(vm.currentTheme.textMuted)
                    Text("No tracks match the current filter")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    Text("Try clearing your format, bit-depth, kHz, or playlist filters.")
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textSecondary)
                    Button(action: { vm.resetAllFilters() }) {
                        Text("Reset All Filters")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(vm.currentTheme.onPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(vm.currentTheme.primary)
                            .cornerRadius(16)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(vm.filteredTracks.enumerated()), id: \.element.id) { idx, track in
                            TrackTableRowView(index: idx + 1, track: track)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
    }
    
    private var audiophileFilterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1: Playlist & Artist Filter Pills + "+ New Playlist"
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    Text("PLAYLIST:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                    
                    filterChipButton(
                        title: "All (\(vm.tracks.count))",
                        isSelected: vm.selectedPlaylistId == nil
                    ) {
                        vm.selectedPlaylistId = nil
                    }
                    
                    ForEach(vm.playlists) { pl in
                        let count = vm.tracks.filter { pl.matches(track: $0) }.count
                        filterChipButton(
                            title: "\(pl.name) (\(count))",
                            icon: pl.filterKeyword.isEmpty ? "music.note.list" : "sparkles",
                            isSelected: vm.selectedPlaylistId == pl.id
                        ) {
                            vm.selectedPlaylistId = (vm.selectedPlaylistId == pl.id) ? nil : pl.id
                        }
                    }
                    
                    Button(action: { vm.openCreatePlaylistModal() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 10))
                            Text("New Playlist")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(vm.currentTheme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(vm.currentTheme.primaryContainer.opacity(0.45))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.currentTheme.primary.opacity(0.4), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 28)
            }
            
            // Row 2: Format (FLAC / WAV) + Bit Depth (24-bit / 16-bit / 8-bit) + Sample Rate (kHz)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    // FORMAT GROUP
                    Text("FORMAT:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                    
                    ForEach(["ALL", "FLAC", "WAV"], id: \.self) { fmt in
                        filterChipButton(
                            title: fmt,
                            isSelected: vm.selectedFormatFilter == fmt
                        ) {
                            vm.selectedFormatFilter = (vm.selectedFormatFilter == fmt && fmt != "ALL") ? "ALL" : fmt
                        }
                    }
                    
                    Divider()
                        .frame(height: 14)
                        .padding(.horizontal, 4)
                    
                    // BIT DEPTH GROUP (24-bit, 16-bit, 8-bit, 32-bit)
                    Text("BIT DEPTH:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                    
                    ForEach([UInt32(24), UInt32(16), UInt32(8), UInt32(32)], id: \.self) { bits in
                        filterChipButton(
                            title: "\(bits)-BIT",
                            isSelected: vm.selectedBitDepthFilter == bits
                        ) {
                            vm.selectedBitDepthFilter = (vm.selectedBitDepthFilter == bits) ? 0 : bits
                        }
                    }
                    
                    Divider()
                        .frame(height: 14)
                        .padding(.horizontal, 4)
                    
                    // SAMPLE RATE (kHz) GROUP
                    Text("CLOCK:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                    
                    ForEach(
                        [
                            (UInt32(44100), "44.1 kHz"),
                            (UInt32(48000), "48 kHz"),
                            (UInt32(88200), "88.2 kHz"),
                            (UInt32(96000), "96 kHz"),
                            (UInt32(192000), "192 kHz")
                        ],
                        id: \.0
                    ) { rate, label in
                        filterChipButton(
                            title: label,
                            isSelected: vm.selectedSampleRateFilter == rate
                        ) {
                            vm.selectedSampleRateFilter = (vm.selectedSampleRateFilter == rate) ? 0 : rate
                        }
                    }
                    
                    if vm.hasActiveFilters {
                        Button(action: { vm.resetAllFilters() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Reset")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color(red: 1.0, green: 0.25, blue: 0.25).opacity(0.16))
                            .cornerRadius(12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .padding(.vertical, 10)
        .background(vm.currentTheme.surfaceContainer.opacity(0.55))
    }
    
    private func filterChipButton(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 9, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold, design: .monospaced))
            }
            .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? vm.currentTheme.primary : Color.white.opacity(0.06))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? vm.currentTheme.primary : vm.currentTheme.outline.opacity(0.18), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
