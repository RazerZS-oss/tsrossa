import SwiftUI
import AppKit

public struct TransportBarView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            // 1. LEFT SECTION: Spinning Vinyl Cover Art + Title + Artist + Favorite
            Button(action: { vm.activeTab = .nowPlaying }) {
                HStack(spacing: 12) {
                    SpinningVinylView(
                        artwork: vm.currentArtwork,
                        isPlaying: engine.isPlaying && !engine.isPaused,
                        size: 50
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(engine.currentTrack?.title ?? "No Track Selected")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        Text(engine.currentTrack?.artist ?? "Select track to begin")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textSecondary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(TsrossaColors.bitPerfectGold)
                                .frame(width: 4, height: 4)
                            Text("\(String(format: "%.1f kHz", Double(engine.currentTrack?.sampleRate ?? 44100) / 1000.0)) • \(engine.currentTrack?.bitDepth ?? 16)-BIT")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    if let cur = engine.currentTrack {
                        let isCurLiked = vm.isTrackLiked(cur.path)
                        Button(action: { vm.toggleLike(track: cur) }) {
                            Image(systemName: isCurLiked ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundColor(isCurLiked ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(isCurLiked ? "Unlike Song" : "Like Song")
                    }
                }
                .frame(width: 260, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 2. CENTER SECTION: Transport Buttons + Precision Timeline Scrubber
            VStack(spacing: 5) {
                HStack(spacing: 16) {
                    // Shuffle
                    Button(action: { vm.isShuffle.toggle() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                            .frame(width: 28, height: 28)
                            .background(vm.isShuffle ? vm.currentTheme.primary.opacity(0.16) : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Previous
                    Button(action: { vm.playPreviousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Center Play/Pause FAB with glowing aura
                    Button(action: { engine.togglePlayPause() }) {
                        ZStack {
                            Circle()
                                .fill(vm.currentTheme.primary)
                                .frame(width: 40, height: 40)
                                .shadow(color: vm.currentTheme.primary.opacity(0.40), radius: 8, x: 0, y: 3)
                            
                            Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(vm.currentTheme.onPrimary)
                        }
                        .frame(width: 40, height: 40)
                        .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Next
                    Button(action: { vm.playNextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    // Repeat
                    Button(action: { vm.isRepeat.toggle() }) {
                        Image(systemName: "repeat")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                            .frame(width: 28, height: 28)
                            .background(vm.isRepeat ? vm.currentTheme.primary.opacity(0.16) : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                
                // Scrubber Timeline Row
                HStack(spacing: 8) {
                    Text(vm.formatTime(engine.currentTime))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 38, alignment: .trailing)
                    
                    Slider(
                        value: Binding(
                            get: { engine.currentTime },
                            set: { newValue in engine.seek(to: newValue) }
                        ),
                        in: 0...max(1.0, engine.totalDuration)
                    )
                    .accentColor(vm.currentTheme.primary)
                    
                    Text(vm.formatTime(engine.totalDuration))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 38, alignment: .leading)
                }
                .frame(maxWidth: 500)
            }
            .frame(maxWidth: .infinity)
            
            // 3. RIGHT SECTION: Inspector Toggles + Theater + Volume Attenuation
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                
                // Step Attenuator Pill (- / 0 dBFS / +)
                HStack(spacing: 6) {
                    Button(action: { vm.volumeDown() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    Text("\(vm.volumeDb) dB")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                        .frame(width: 48)
                    
                    Button(action: { vm.volumeUp() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(vm.currentTheme.primaryContainer.opacity(0.35))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
                )
                
                // Inspector Tab Quick-Switches: Lyrics, Signal/EQ, Queue
                transportTabIconButton(icon: "quote.bubble", tab: "LYRICS", helpText: "Time-Synced Lyrics")
                transportTabIconButton(icon: "waveform.path.ecg", tab: "EQ", helpText: "Signal Path & Visualizer")
                transportTabIconButton(icon: "music.note.list", tab: "QUEUE", helpText: "Play Queue")
                
                // Theater Mode (Cmd + F)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        vm.isTheaterMode.toggle()
                    }
                }) {
                    Image(systemName: vm.isTheaterMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.isTheaterMode ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(vm.isTheaterMode ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .clipShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                .help("Toggle Theater Mode (⌘F)")
            }
            .frame(width: 320, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .background(vm.currentTheme.surfaceContainer.opacity(0.95))
    }
    
    private func transportTabIconButton(icon: String, tab: String, helpText: String) -> some View {
        let isActive = vm.showRightInspector && vm.inspectorTab == tab
        return Button(action: {
            if vm.showRightInspector && vm.inspectorTab == tab {
                withAnimation(.easeInOut(duration: 0.18)) {
                    vm.showRightInspector = false
                }
            } else {
                withAnimation(.easeInOut(duration: 0.18)) {
                    vm.switchInspectorTab(tab)
                }
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isActive ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                .frame(width: 30, height: 30)
                .background(isActive ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                .clipShape(Circle())
        }
        .buttonStyle(TsrossaScaleButtonStyle())
        .help(helpText)
    }
}
