import SwiftUI
import AppKit

public struct LibraryView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Hero Featured Banner with Dynamic Stage Glow (Aether Studio Style)
            ZStack(alignment: .leading) {
                // Dynamic Stage Glow
                RadialGradient(
                    colors: [vm.currentTheme.primary.opacity(0.24), Color.clear],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 380
                )
                
                HStack(spacing: 22) {
                    // Active Album Cover Art with Play Overlay
                    Button(action: {
                        if engine.currentTrack != nil {
                            engine.togglePlayPause()
                        } else if let first = vm.filteredTracks.first {
                            engine.play(track: first)
                        }
                    }) {
                        ZStack {
                            if let art = vm.currentArtwork {
                                Image(nsImage: art)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 104, height: 104)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                    )
                                    .shadow(color: vm.currentTheme.primary.opacity(0.35), radius: 14, x: 0, y: 6)
                            } else {
                                TsrossaBrandIcon(size: 104, cornerRadius: 16)
                                    .shadow(color: vm.currentTheme.primary.opacity(0.28), radius: 14, x: 0, y: 6)
                            }
                            
                            // Play Overlay Button Icon
                            Circle()
                                .fill(Color.black.opacity(0.40))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Track & Master Metadata
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 7) {
                            Text(engine.currentTrack != nil ? "NOW MASTERING" : "HI-RES AUDIOPHILE COLLECTION")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.primary)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(vm.currentTheme.primary.opacity(0.16))
                                .cornerRadius(5)
                            
                            Text(engine.formatBadgeText)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(TsrossaColors.bitPerfectGold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(TsrossaColors.bitPerfectGold.opacity(0.12))
                                .cornerRadius(5)
                            
                            if vm.isRamPlayback {
                                Text("POSIX mlock")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundColor(TsrossaColors.audiophileCyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(TsrossaColors.audiophileCyan.opacity(0.10))
                                    .cornerRadius(5)
                            }
                        }
                        
                        Text(engine.currentTrack?.title ?? (vm.selectedPlaylist?.name ?? "Local Audiophile Library"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(engine.currentTrack?.artist ?? "\(vm.filteredTracks.count) Lossless Tracks Available")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .lineLimit(1)
                            
                            if let album = engine.currentTrack?.album, !album.isEmpty {
                                Text("•")
                                    .foregroundColor(vm.currentTheme.textMuted)
                                Text(album)
                                    .font(.system(size: 12))
                                    .foregroundColor(vm.currentTheme.textMuted)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Hero Action Buttons
                    HStack(spacing: 10) {
                        Button(action: {
                            if engine.currentTrack != nil {
                                engine.togglePlayPause()
                            } else if let first = vm.filteredTracks.first {
                                engine.play(track: first)
                            }
                        }) {
                            HStack(spacing: 7) {
                                Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text(engine.isPlaying && !engine.isPaused ? "Pause Master" : "Play Master")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(vm.currentTheme.onPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(vm.currentTheme.primary)
                            .cornerRadius(12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(TsrossaScaleButtonStyle())
                        
                        Button(action: {
                            vm.isShuffle = true
                            vm.playNextTrack()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Shuffle")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(vm.currentTheme.surfaceContainerHigh.opacity(0.80))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(TsrossaScaleButtonStyle())
                        
                        if let cur = engine.currentTrack {
                            let isLiked = vm.isTrackLiked(cur.path)
                            Button(action: { vm.toggleLike(track: cur) }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 14))
                                    .foregroundColor(isLiked ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(vm.currentTheme.surfaceContainerHigh.opacity(0.80))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(TsrossaScaleButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .frame(height: 136)
            .background(vm.currentTheme.surfaceContainerLow.opacity(0.40))
            
            // Audiophile Filter Strip
            audiophileFilterBar
            
            // Widescreen Multi-Column Table Header
            HStack(spacing: 12) {
                Text("#")
                    .frame(width: 28, alignment: .center)
                Text("TITLE & ARTIST")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("ALBUM")
                    .frame(minWidth: 100, maxWidth: 170, alignment: .leading)
                Text("CODEC / BITRATE")
                    .frame(width: 125, alignment: .center)
                Text("TIME")
                    .frame(width: 48, alignment: .trailing)
                Text("FAV")
                    .frame(width: 24, alignment: .center)
                Text("")
                    .frame(width: 24, alignment: .center)
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(vm.currentTheme.textMuted)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(vm.currentTheme.surfaceContainerLowest.opacity(0.60))
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.12))
            
            // Track Rows or Empty State
            if vm.filteredTracks.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.system(size: 34))
                        .foregroundColor(vm.currentTheme.textMuted)
                    Text("No tracks match the current filter")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    Text("Try clearing your format, bit-depth, kHz, or playlist filters.")
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.textSecondary)
                    Button(action: { vm.resetAllFilters() }) {
                        Text("Reset All Filters")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(vm.currentTheme.onPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(vm.currentTheme.primary)
                            .cornerRadius(12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 3) {
                        ForEach(Array(vm.filteredTracks.enumerated()), id: \.element.id) { idx, track in
                            TrackTableRowView(index: idx + 1, track: track)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var audiophileFilterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: Format & Hardware Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Text("ALL MASTERS (\(vm.filteredTracks.count))")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .padding(.trailing, 4)
                    
                    // Format Chips
                    ForEach(["ALL", "FLAC", "WAV"], id: \.self) { fmt in
                        filterChipButton(
                            title: fmt,
                            isSelected: vm.selectedFormatFilter == fmt
                        ) {
                            vm.selectedFormatFilter = (vm.selectedFormatFilter == fmt && fmt != "ALL") ? "ALL" : fmt
                        }
                    }
                    
                    Divider()
                        .frame(height: 12)
                        .padding(.horizontal, 3)
                    
                    // Bit Depth Chips
                    ForEach([UInt32(24), UInt32(16), UInt32(32)], id: \.self) { bits in
                        filterChipButton(
                            title: "\(bits)-BIT",
                            isSelected: vm.selectedBitDepthFilter == bits
                        ) {
                            vm.selectedBitDepthFilter = (vm.selectedBitDepthFilter == bits) ? 0 : bits
                        }
                    }
                    
                    Divider()
                        .frame(height: 12)
                        .padding(.horizontal, 3)
                    
                    // Clock Rate Chips
                    ForEach(
                        [
                            (UInt32(44100), "44.1k"),
                            (UInt32(48000), "48k"),
                            (UInt32(96000), "96k"),
                            (UInt32(192000), "192k")
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
                            HStack(spacing: 3) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 9))
                                Text("Clear")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 1.0, green: 0.25, blue: 0.25).opacity(0.14))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 8)
        .background(vm.currentTheme.surfaceContainer.opacity(0.40))
    }
    
    private func filterChipButton(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 9, weight: isSelected ? .bold : .semibold, design: .monospaced))
            }
            .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? vm.currentTheme.primary : Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? vm.currentTheme.primary : vm.currentTheme.outline.opacity(0.16), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
