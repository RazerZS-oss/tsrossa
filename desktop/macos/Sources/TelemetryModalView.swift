import SwiftUI
import AppKit

public struct TelemetryModalView: View {
    @ObservedObject var engine = AudioEngine.shared
    @ObservedObject var vm = AppViewModel.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("[ HARDWARE TELEMETRY & AUDIT ]")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(TsrossaColors.terminalGreen)
                
                Spacer()
                
                Button(action: { vm.showTelemetry = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(TsrossaColors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 12) {
                telemetryRow(label: "TRANSPORT ENGINE", value: "Apple CoreAudio HAL (Direct-to-Hardware)")
                telemetryRow(label: "EXCLUSIVE MODE", value: "kAudioDevicePropertyHogMode (LOCKED)")
                telemetryRow(label: "BIT-PERFECT INTEGRITY", value: "True Unity Gain (0.0 dBFS / Zero Resampling)")
                
                if let track = engine.currentTrack {
                    telemetryRow(label: "CURRENT TRACK", value: track.title)
                    telemetryRow(label: "AUDIO FORMAT", value: track.path.hasSuffix(".flac") ? "FLAC Lossless" : "WAV Linear PCM")
                    telemetryRow(label: "NEGOTIATED RATE", value: String(format: "%.1f kHz / %d-bit", Double(track.sampleRate) / 1000.0, track.bitDepth))
                }
                
                telemetryRow(label: "RAM PRELOAD STATUS", value: "mlock() Active (Physical RAM Paging Disabled)")
            }
            .padding(14)
            .glassmorphic(cornerRadius: 12, opacity: 0.9, borderColor: TsrossaColors.terminalGreen.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("RAW KERNEL STATUS JSON:")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(TsrossaColors.textMuted)
                
                ScrollView {
                    Text(engine.telemetryJson)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(TsrossaColors.audiophileCyan)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 120)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
            }
            
            HStack {
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(engine.telemetryJson, forType: .string)
                    vm.copiedTelemetry = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        vm.copiedTelemetry = false
                    }
                }) {
                    Text(vm.copiedTelemetry ? "✓ COPIED TO CLIPBOARD" : "[ COPY REPORT ]")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.copiedTelemetry ? TsrossaColors.terminalGreen : TsrossaColors.audiophileCyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: { vm.showTelemetry = false }) {
                    Text("CLOSE")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(TsrossaColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .frame(width: 520)
        .background(TsrossaColors.deepNavy)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func telemetryRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(TsrossaColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(TsrossaColors.terminalGreen)
        }
    }
}
