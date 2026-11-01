import SwiftUI
import AppKit

public struct NowPlayingView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 28) {
            // LEFT COLUMN: Large Album Art Showcase & Track Identity
            VStack(spacing: 20) {
                Spacer(minLength: 8)
                
                ZStack {
                    if let artwork = vm.currentArtwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 310, height: 310)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(color: vm.currentTheme.primary.opacity(0.38), radius: 32, x: 0, y: 16)
                    } else {
                        TsrossaBrandIcon(size: 310, cornerRadius: 28)
                            .shadow(color: vm.currentTheme.primary.opacity(0.32), radius: 28, x: 0, y: 14)
                    }
                }
                
                VStack(spacing: 6) {
                    Text(engine.currentTrack?.title ?? "No Track Selected")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(engine.subtitleText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                // Audiophile Master Quality Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(TsrossaColors.bitPerfectGold)
                        .frame(width: 7, height: 7)
                    Text(engine.formatBadgeText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.onPrimaryContainer)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(vm.currentTheme.primaryContainer.opacity(0.65))
                .cornerRadius(20)
                
                Spacer(minLength: 8)
            }
            .frame(maxWidth: .infinity)
            
            // RIGHT COLUMN: Live Signal Path Inspector + Up Next Queue
            VStack(spacing: 16) {
                // 1. LIVE SIGNAL PATH CARD
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .foregroundColor(vm.currentTheme.primary)
                        Text("LOSSLESS SIGNAL PATH")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        Text("BIT-PERFECT")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.terminalGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(TsrossaColors.terminalGreen.opacity(0.14))
                            .cornerRadius(6)
                    }
                    
                    signalPathStep(
                        icon: "doc.badge.gearshape",
                        title: "Source Decoder (\(engine.currentTrack?.path.hasSuffix(".flac") == true ? "dr_flac" : "dr_wav"))",
                        detail: "\(engine.currentTrack?.sampleRate ?? 44100) Hz / \(engine.currentTrack?.bitDepth ?? 16)-bit Float64 Zero-Copy",
                        badgeColor: vm.currentTheme.primary
                    )
                    
                    signalPathStep(
                        icon: "memorychip",
                        title: "Memory Pinning (POSIX mlock)",
                        detail: vm.isRamPlayback ? "Locked in physical RAM • 0 SSD page faults" : "Standard buffered streaming",
                        badgeColor: vm.isRamPlayback ? TsrossaColors.audiophileCyan : vm.currentTheme.textSecondary
                    )
                    
                    signalPathStep(
                        icon: "lock.shield",
                        title: "CoreAudio HAL Output (\(engine.activeDeviceName))",
                        detail: vm.isExclusiveHogMode ? "Exclusive Hog Mode • System Mixer Bypassed" : "Shared CoreAudio Output",
                        badgeColor: TsrossaColors.bitPerfectGold
                    )
                }
                .padding(16)
                .background(vm.currentTheme.surfaceContainer.opacity(0.88))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
                )
                
                // 2. UP NEXT IN QUEUE CARD
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(vm.currentTheme.primary)
                        Text(vm.upNextQueue.isEmpty ? "UP NEXT IN LIBRARY (\(vm.tracks.count))" : "UP NEXT IN QUEUE (\(vm.upNextQueue.count))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        if !vm.upNextQueue.isEmpty {
                            Button(action: { vm.clearQueue() }) {
                                Text("Clear")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.error)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Button(action: { vm.activeTab = .playlist }) {
                            Text("Manage Queue →")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            if !vm.upNextQueue.isEmpty {
                                ForEach(Array(vm.upNextQueue.enumerated()), id: \.element.id) { idx, track in
                                    queueRowWithRemove(index: idx + 1, track: track)
                                }
                                
                                Divider()
                                    .background(vm.currentTheme.outline.opacity(0.15))
                                    .padding(.vertical, 4)
                                
                                HStack {
                                    Text("UPCOMING CONTINUATION")
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.textMuted)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                            }
                            
                            ForEach(Array(vm.tracks.prefix(35).enumerated()), id: \.offset) { idx, track in
                                compactQueueRow(index: idx + 1, track: track)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxHeight: .infinity)
                .background(vm.currentTheme.surfaceContainer.opacity(0.88))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
                )
            }
            .frame(width: 400)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }
    
    private func signalPathStep(icon: String, title: String, detail: String, badgeColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(badgeColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
    
    private func queueRowWithRemove(index: Int, track: TrackMetadata) -> some View {
        Button(action: {
            if let idx = vm.upNextQueue.firstIndex(where: { $0.path == track.path }) {
                vm.removeFromQueue(at: idx)
            }
            engine.play(track: track)
        }) {
            HStack(spacing: 8) {
                Text("NEXT #\(index)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.onPrimary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(vm.currentTheme.primary)
                    .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.primary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 10))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    if let idx = vm.upNextQueue.firstIndex(where: { $0.path == track.path }) {
                        vm.removeFromQueue(at: idx)
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(vm.currentTheme.textMuted)
                        .padding(4)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Remove from Queue")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(vm.currentTheme.primaryContainer.opacity(0.32))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(vm.currentTheme.primary.opacity(0.35), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func compactQueueRow(index: Int, track: TrackMetadata) -> some View {
        let isCurrent = engine.currentTrack?.path == track.path
        return Button(action: { engine.play(track: track) }) {
            HStack(spacing: 10) {
                if isCurrent && engine.isPlaying {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(vm.currentTheme.primary)
                        .frame(width: 22)
                } else {
                    Text("\(index)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                        .frame(width: 22)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 12, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 10))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(vm.formatTime(track.durationSeconds))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.45) : Color.white.opacity(0.03))
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
