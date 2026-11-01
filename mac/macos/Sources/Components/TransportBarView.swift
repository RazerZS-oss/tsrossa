import SwiftUI
import AppKit

public struct TransportBarView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            // 1. LEFT SECTION: Mini Artwork + Track Title + Artist
            Button(action: { vm.activeTab = .nowPlaying }) {
                HStack(spacing: 12) {
                    ZStack {
                        if let art = vm.currentArtwork {
                            Image(nsImage: art)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            TsrossaBrandIcon(size: 56, cornerRadius: 12)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(engine.currentTrack?.title ?? "No Track Selected")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        Text(engine.currentTrack?.artist ?? "Select a track")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textSecondary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(TsrossaColors.bitPerfectGold)
                                .frame(width: 5, height: 5)
                            Text("\(String(format: "%.1f kHz", Double(engine.currentTrack?.sampleRate ?? 44100) / 1000.0)) • \(engine.currentTrack?.bitDepth ?? 16)-BIT")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let cur = engine.currentTrack {
                        let isCurLiked = vm.isTrackLiked(cur.path)
                        Button(action: { vm.toggleLike(track: cur) }) {
                            Image(systemName: isCurLiked ? "heart.fill" : "heart")
                                .font(.system(size: 15))
                                .foregroundColor(isCurLiked ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(isCurLiked ? "Unlike Track (Cmd + L)" : "Like Track (Cmd + L)")
                    }
                }
                .frame(width: 275, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 2. CENTER SECTION: Transport Buttons + Wide Precision Scrubber
            VStack(spacing: 6) {
                HStack(spacing: 18) {
                    // Shuffle
                    Button(action: { vm.isShuffle.toggle() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                            .frame(width: 30, height: 30)
                            .background(vm.isShuffle ? vm.currentTheme.primary.opacity(0.16) : Color.clear)
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Previous
                    Button(action: { vm.playPreviousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Center Play/Pause FAB
                    Button(action: { engine.togglePlayPause() }) {
                        ZStack {
                            Circle()
                                .fill(vm.currentTheme.primary)
                                .frame(width: 42, height: 42)
                                .shadow(color: vm.currentTheme.primary.opacity(0.40), radius: 8, x: 0, y: 3)
                            
                            Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(vm.currentTheme.onPrimary)
                        }
                        .frame(width: 42, height: 42)
                        .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Next
                    Button(action: { vm.playNextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Repeat
                    Button(action: { vm.isRepeat.toggle() }) {
                        Image(systemName: "repeat")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                            .frame(width: 30, height: 30)
                            .background(vm.isRepeat ? vm.currentTheme.primary.opacity(0.16) : Color.clear)
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                
                // Scrubber Timeline Row
                HStack(spacing: 10) {
                    Text(vm.formatTime(engine.currentTime))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 42, alignment: .trailing)
                    
                    Slider(
                        value: Binding(
                            get: { engine.currentTime },
                            set: { newValue in engine.seek(to: newValue) }
                        ),
                        in: 0...max(1.0, engine.totalDuration)
                    )
                    .accentColor(vm.currentTheme.primary)
                    
                    Text(vm.formatTime(engine.totalDuration))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 42, alignment: .leading)
                }
                .frame(maxWidth: 520)
            }
            .frame(maxWidth: .infinity)
            
            // 3. RIGHT SECTION: Hardware Attenuation Volume + Queue + Telemetry
            HStack(spacing: 10) {
                Spacer(minLength: 0)
                
                // Step Attenuator Pill (- / 0 dBFS / +)
                HStack(spacing: 8) {
                    Button(action: { vm.volumeDown() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.primary)
                        Text("\(vm.volumeDb) dBFS")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                    .frame(width: 74)
                    
                    Button(action: { vm.volumeUp() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(vm.currentTheme.primaryContainer.opacity(0.45))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                )
                
                // Lyrics Quick Switch
                Button(action: {
                    if vm.activeTab != .playlist {
                        vm.activeTab = .playlist
                        vm.queueTabMode = "LYRICS"
                    } else if vm.queueTabMode == "LYRICS" {
                        vm.queueTabMode = "QUEUE"
                    } else {
                        vm.queueTabMode = "LYRICS"
                    }
                }) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor((vm.activeTab == .playlist && vm.queueTabMode == "LYRICS") ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .frame(width: 34, height: 34)
                        .background((vm.activeTab == .playlist && vm.queueTabMode == "LYRICS") ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                .help("Toggle Synced Lyrics")
                
                // Queue Quick Switch
                Button(action: {
                    if vm.activeTab == .playlist && vm.queueTabMode == "QUEUE" {
                        vm.activeTab = .nowPlaying
                    } else {
                        vm.activeTab = .playlist
                        vm.queueTabMode = "QUEUE"
                    }
                }) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor((vm.activeTab == .playlist && vm.queueTabMode == "QUEUE") ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .frame(width: 34, height: 34)
                        .background((vm.activeTab == .playlist && vm.queueTabMode == "QUEUE") ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                .help("Toggle Play Queue (Cmd + 3)")
                
                // Theater Mode Quick Switch (Cmd + F)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        vm.isTheaterMode.toggle()
                    }
                }) {
                    Image(systemName: vm.isTheaterMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(vm.isTheaterMode ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(vm.isTheaterMode ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                .help("Toggle Theater Fullscreen Mode (Cmd + F)")
            }
            .frame(width: 335, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .background(vm.currentTheme.surfaceContainer.opacity(0.95))
    }
}
