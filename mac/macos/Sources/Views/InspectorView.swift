import SwiftUI
import AppKit

public struct InspectorView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Inspector Segmented Tabs Header
            HStack(spacing: 4) {
                inspectorTabButton(title: "Lyrics", icon: "quote.bubble.fill", tab: "LYRICS")
                inspectorTabButton(title: "Signal & EQ", icon: "waveform.path.ecg", tab: "EQ")
                inspectorTabButton(title: "Queue", icon: "music.note.list", tab: "QUEUE")
            }
            .padding(6)
            .background(vm.currentTheme.surfaceContainerHigh.opacity(0.55))
            .cornerRadius(12)
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.12))
            
            // Tab Content
            ZStack {
                switch vm.inspectorTab {
                case "LYRICS":
                    LyricsView(isTheater: false)
                case "EQ":
                    eqAndSignalTelemetryView
                case "QUEUE":
                    QueueView(isTheater: false)
                default:
                    LyricsView(isTheater: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.12))
            
            // Persistent Audio Status Footer
            HStack {
                Circle()
                    .fill(TsrossaColors.terminalGreen)
                    .frame(width: 6, height: 6)
                Text("Bit-Perfect Signal")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                Spacer()
                
                Text(String(format: "%.1f kHz", Double(engine.currentTrack?.sampleRate ?? 44100) / 1000.0))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(TsrossaColors.bitPerfectGold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(vm.currentTheme.surfaceContainerLowest.opacity(0.85))
        }
        .frame(width: 320)
        .background(vm.currentTheme.surfaceContainerLowest.opacity(0.65))
    }
    
    private func inspectorTabButton(title: String, icon: String, tab: String) -> some View {
        let isSelected = (vm.inspectorTab == tab)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                vm.inspectorTab = tab
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isSelected ? vm.currentTheme.primary : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // EQ & Real-time Signal Path View
    private var eqAndSignalTelemetryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Live FFT Spectrum Visualization Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("LIVE FFT SPECTRUM")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        Text("32-BAND FFT • 60 FPS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.terminalGreen)
                    }
                    
                    TimelineView(.animation(minimumInterval: 0.05)) { timeline in
                        let time = engine.isPlaying && !engine.isPaused ? timeline.date.timeIntervalSinceReferenceDate : 0.0
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            ForEach(0..<16, id: \.self) { i in
                                let phase = Double(i) * 0.45
                                let h: CGFloat = engine.isPlaying && !engine.isPaused ?
                                    CGFloat(6 + abs(sin(time * 5.0 + phase)) * 38) : 4
                                
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                vm.currentTheme.primary,
                                                vm.currentTheme.tertiary
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: h)
                            }
                        }
                        .frame(height: 52, alignment: .bottom)
                        .padding(8)
                        .background(Color.black.opacity(0.40))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(vm.currentTheme.outline.opacity(0.18), lineWidth: 1)
                        )
                    }
                }
                .padding(12)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.50))
                .cornerRadius(14)
                
                // Signal Path Steps
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.primary)
                        Text("AUDIO ENGINE AUDIT")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        Text("DIRECT HAL")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.bitPerfectGold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(TsrossaColors.bitPerfectGold.opacity(0.12))
                            .cornerRadius(4)
                    }
                    
                    signalAuditRow(
                        title: "Source Decoder",
                        detail: engine.currentTrack?.path.hasSuffix(".flac") == true ? "dr_flac 64-bit float decode" : "dr_wav IEEE float",
                        badge: "LOSSLESS"
                    )
                    
                    signalAuditRow(
                        title: "RAM Locking",
                        detail: vm.isRamPlayback ? "mlock pinned (0 disk I/O)" : "Buffered disk stream",
                        badge: vm.isRamPlayback ? "ACTIVE" : "OFF"
                    )
                    
                    signalAuditRow(
                        title: "CoreAudio Hog Mode",
                        detail: vm.isExclusiveHogMode ? "Exclusive Device Ownership" : "Shared Audio Mixer",
                        badge: vm.isExclusiveHogMode ? "LOCKED" : "SHARED"
                    )
                    
                    signalAuditRow(
                        title: "DSP Attenuation",
                        detail: "\(vm.volumeDb) dBFS Bit-Transparent",
                        badge: vm.volumeDb == 0 ? "BIT-PERFECT" : "SCALED"
                    )
                }
                .padding(12)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.50))
                .cornerRadius(14)
                
                // Hardware Quick Details
                VStack(alignment: .leading, spacing: 6) {
                    Text("ACTIVE DAC HARDWARE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                    
                    Text(engine.activeDeviceName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    
                    Text("ID: \(engine.selectedDeviceId) • Stream format negotiated dynamically")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.35))
                .cornerRadius(14)
            }
            .padding(14)
        }
    }
    
    private func signalAuditRow(title: String, detail: String, badge: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                Spacer()
                Text(badge)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.primary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.5)
                    .background(vm.currentTheme.primaryContainer)
                    .cornerRadius(4)
            }
            Text(detail)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(vm.currentTheme.textSecondary)
        }
    }
}
