import SwiftUI
import AppKit

public struct MiniPlayerView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Ambient Blurred Artwork Background
            if let art = vm.currentArtwork {
                Image(nsImage: art)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 65)
                    .opacity(0.35)
                    .ignoresSafeArea()
            }
            
            Color.black.opacity(0.70)
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // Top Header: Quality Tag + Expand Button
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(TsrossaColors.terminalGreen)
                            .frame(width: 7, height: 7)
                        Text("tsrossa Mini • \(engine.currentTrack?.path.hasSuffix(".flac") == true ? "FLAC" : "WAV")")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { vm.toggleMiniPlayer() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 10))
                            Text("Expand")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(vm.currentTheme.onPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(vm.currentTheme.primary)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    .help("Return to Full Desktop Window")
                }
                
                // Cover Art Showcase
                ZStack(alignment: .bottomLeading) {
                    if let art = vm.currentArtwork {
                        Image(nsImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 310, height: 210)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(vm.currentTheme.surfaceContainerHigh)
                            .frame(width: 310, height: 210)
                            .overlay(
                                TsrossaBrandIcon(size: 90, cornerRadius: 20)
                            )
                    }
                    
                    // Gradient overlay with title and metadata
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(engine.formatBadgeText)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.bitPerfectGold)
                        
                        Text(engine.currentTrack?.title ?? "No Track Selected")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                        
                        Text(engine.currentTrack?.artist ?? "tsrossa Audiophile")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.75))
                            .lineLimit(1)
                    }
                    .padding(12)
                }
                .frame(width: 310, height: 210)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                
                // Live Synced Lyric Line Preview
                HStack {
                    if vm.currentLyricIndex >= 0 && vm.currentLyricIndex < vm.currentLyrics.count {
                        Text(vm.currentLyrics[vm.currentLyricIndex].text)
                            .font(.system(size: 11, weight: .medium))
                            .italic()
                            .foregroundColor(vm.currentTheme.primary)
                            .lineLimit(1)
                    } else {
                        Text("Direct Bit-Perfect Memory Stream")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(width: 310)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                
                // Mini Scrubber Bar
                VStack(spacing: 4) {
                    Slider(
                        value: Binding(
                            get: { engine.currentTime },
                            set: { newValue in engine.seek(to: newValue) }
                        ),
                        in: 0...max(1.0, engine.totalDuration)
                    )
                    .accentColor(vm.currentTheme.primary)
                    
                    HStack {
                        Text(vm.formatTime(engine.currentTime))
                        Spacer()
                        Text(vm.formatTime(engine.totalDuration))
                    }
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                }
                .frame(width: 310)
                
                // Mini Controls
                HStack(spacing: 20) {
                    // Like button
                    if let cur = engine.currentTrack {
                        let isLiked = vm.isTrackLiked(cur.path)
                        Button(action: { vm.toggleLike(track: cur) }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundColor(isLiked ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Spacer().frame(width: 14)
                    }
                    
                    // Previous
                    Button(action: { vm.playPreviousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Play / Pause FAB
                    Button(action: { engine.togglePlayPause() }) {
                        ZStack {
                            Circle()
                                .fill(vm.currentTheme.primary)
                                .frame(width: 44, height: 44)
                                .shadow(color: vm.currentTheme.primary.opacity(0.40), radius: 8, x: 0, y: 3)
                            
                            Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(vm.currentTheme.onPrimary)
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Next
                    Button(action: { vm.playNextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Telemetry toggle
                    Button(action: {
                        engine.updateTelemetry()
                        vm.showTelemetry = true
                    }) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 14))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 310)
            }
            .padding(20)
            .background(vm.currentTheme.surfaceContainer.opacity(0.85))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.70), radius: 36, x: 0, y: 18)
        }
        .frame(width: 360, height: 480)
    }
}
