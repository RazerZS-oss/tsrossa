import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    @ObservedObject private var updater = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COREAUDIO HAL & APPEARANCE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Text("Audio Output & Desktop Preferences")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                    Spacer()
                    Button(action: {
                        engine.updateTelemetry()
                        vm.showTelemetry = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "waveform.path.ecg")
                            Text("Live Hardware Audit (⌘D)")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.onPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(vm.currentTheme.primary)
                        .cornerRadius(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                
                // 2-Column Widescreen Bento Grid
                HStack(alignment: .top, spacing: 20) {
                    // LEFT BENTO COLUMN
                    VStack(spacing: 20) {
                        // 1. OUTPUT DEVICE SELECTION
                        settingsCard(title: "OUTPUT DEVICE & DAC HARDWARE") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(engine.devices) { dev in
                                    Button(action: { engine.selectDevice(id: dev.id) }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: dev.isUsb ? "cable.connector" : "speaker.wave.2.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(vm.currentTheme.primary)
                                                .frame(width: 24)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(dev.name)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(vm.currentTheme.textPrimary)
                                                Text(dev.isUsb ? "External USB DAC (UAC2 Direct Hardware Link)" : "Internal Apple Silicon CoreAudio Hardware")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(vm.currentTheme.textSecondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if dev.id == engine.selectedDeviceId {
                                                HStack(spacing: 6) {
                                                    Text(String(format: "%.1f kHz", dev.sampleRate / 1000.0))
                                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                        .foregroundColor(vm.currentTheme.primary)
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(vm.currentTheme.primary)
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .background(dev.id == engine.selectedDeviceId ? vm.currentTheme.primaryContainer.opacity(0.40) : Color.white.opacity(0.04))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(dev.id == engine.selectedDeviceId ? vm.currentTheme.primary.opacity(0.45) : Color.clear, lineWidth: 1)
                                        )
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Divider().background(vm.currentTheme.outline.opacity(0.15))
                                
                                settingsToggleRow(
                                    title: "Bit-Perfect Exclusive Lock (Hog Mode)",
                                    subtitle: "Direct DAC ownership, bypassing macOS system audio mixer",
                                    isOn: $vm.isExclusiveHogMode
                                )
                                
                                Divider().background(vm.currentTheme.outline.opacity(0.15))
                                
                                settingsToggleRow(
                                    title: "Dynamic Hardware Clock Switching",
                                    subtitle: "Switches DAC sample rate (44.1k–192k) to match native file",
                                    isOn: $vm.isAutoClockSwitch
                                )
                                
                                Divider().background(vm.currentTheme.outline.opacity(0.15))
                                
                                settingsToggleRow(
                                    title: "Zero-Jitter RAM Playback (mlock)",
                                    subtitle: "Pins decoded PCM frames in physical RAM to prevent SSD latency",
                                    isOn: $vm.isRamPlayback
                                )
                            }
                        }
                        
                        // 2. MUSIC DIRECTORY & LIBRARY
                        settingsCard(title: "MUSIC DIRECTORY & STORAGE") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Watched Folder:")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(vm.currentTheme.primary)
                                    Text(vm.currentFolder)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.textPrimary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                                
                                HStack(spacing: 10) {
                                    Button(action: { vm.openFolderPicker() }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "folder.badge.gearshape")
                                            Text("Change Folder")
                                        }
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(vm.currentTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(vm.currentTheme.primaryContainer.opacity(0.45))
                                        .cornerRadius(8)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(TsrossaScaleButtonStyle())
                                    
                                    Button(action: { vm.rescanCurrentFolder() }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Rescan Library")
                                        }
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(vm.currentTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(8)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(TsrossaScaleButtonStyle())
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // RIGHT BENTO COLUMN
                    VStack(spacing: 20) {
                        // 3. THEME & VISUAL APPEARANCE
                        settingsCard(title: "MATERIAL YOU & DESKTOP APPEARANCE") {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Accent Color Palette")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                
                                HStack(spacing: 6) {
                                    accentPill(title: "Auto (Monet)", mode: "DYNAMIC", color: vm.currentTheme.primary)
                                    accentPill(title: "Rose", mode: "ROSE", color: Color(red: 1.0, green: 0.18, blue: 0.33))
                                    accentPill(title: "Matcha", mode: "MATCHA", color: Color(red: 0.62, green: 0.82, blue: 0.38))
                                    accentPill(title: "Gold", mode: "GOLD", color: Color(red: 1.0, green: 0.84, blue: 0.0))
                                    accentPill(title: "Cyan", mode: "CYAN", color: Color(red: 0.0, green: 0.898, blue: 1.0))
                                }
                                
                                Divider().background(vm.currentTheme.outline.opacity(0.15))
                                
                                Text("Desktop Background Canvas")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                
                                HStack(spacing: 8) {
                                    bgPill(title: "Tonal M3", mode: "DYNAMIC")
                                    bgPill(title: "Artwork Aura", mode: "AURA")
                                    bgPill(title: "Pitch Black", mode: "BLACK")
                                }
                            }
                        }
                        
                        // 4. SIGNAL PATH & HARDWARE AUDIT
                        settingsCard(title: "SIGNAL PATH & HARDWARE AUDIT") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Stream State:")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.textSecondary)
                                    Spacer()
                                    Text("ACTIVE (0 dBFS Bit-Perfect)")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(TsrossaColors.terminalGreen)
                                }
                                HStack {
                                    Text("DAC Clock:")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.textSecondary)
                                    Spacer()
                                    Text("\(engine.currentTrack?.sampleRate ?? 44100) Hz Crystal Lock")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(TsrossaColors.bitPerfectGold)
                                }
                                HStack {
                                    Text("Native Decoders:")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.textSecondary)
                                    Spacer()
                                    Text("dr_flac / dr_wav (C++17)")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.primary)
                                }
                            }
                        }
                        
                        // 5. ABOUT TSROSSA & UPDATES
                        settingsCard(title: "ABOUT TSROSSA MACOS & SOFTWARE UPDATES") {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 14) {
                                    TsrossaBrandIcon(size: 48, cornerRadius: 12)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text("tsrossa bit-perfect desktop player")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(vm.currentTheme.textPrimary)
                                            Spacer()
                                            Text("v\(updater.currentVersion) macOS")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(vm.currentTheme.primary)
                                        }
                                        Text("Native Apple Silicon CoreAudio HAL port with Material You dynamic theming and zero-DSP hardware playback.")
                                            .font(.system(size: 11))
                                            .foregroundColor(vm.currentTheme.textSecondary)
                                    }
                                }
                                
                                Divider().background(vm.currentTheme.outline.opacity(0.15))
                                
                                // Software Update Checker & Installer
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("GitHub OTA Software Update")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(vm.currentTheme.textPrimary)
                                            Text("github.com/\(updater.repoOwner)/\(updater.repoName)")
                                                .font(.system(size: 10, design: .monospaced))
                                                .foregroundColor(vm.currentTheme.textSecondary)
                                        }
                                        Spacer()
                                        
                                        if updater.isChecking {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                        } else {
                                            Button(action: {
                                                updater.checkForUpdates()
                                            }) {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "arrow.triangle.2.circlepath")
                                                        .font(.system(size: 11))
                                                    Text(updater.hasChecked ? "Check Again" : "Check for Updates")
                                                        .font(.system(size: 11, weight: .semibold))
                                                }
                                                .foregroundColor(vm.currentTheme.onPrimary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(vm.currentTheme.primary)
                                                .cornerRadius(12)
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(TsrossaScaleButtonStyle())
                                            .disabled(updater.isDownloading || updater.isExtracting)
                                        }
                                    }
                                    
                                    if !updater.statusMessage.isEmpty {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(updater.updateAvailable ? TsrossaColors.bitPerfectGold : (updater.isDownloading ? vm.currentTheme.primary : TsrossaColors.terminalGreen))
                                                .frame(width: 6, height: 6)
                                            Text(updater.statusMessage)
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundColor(updater.updateAvailable ? TsrossaColors.bitPerfectGold : vm.currentTheme.textSecondary)
                                        }
                                    }
                                    
                                    if updater.updateAvailable {
                                        VStack(alignment: .leading, spacing: 8) {
                                            if !updater.releaseNotes.isEmpty {
                                                Text("Release Notes:")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                    .foregroundColor(vm.currentTheme.textMuted)
                                                Text(updater.releaseNotes)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(vm.currentTheme.textPrimary)
                                                    .lineLimit(4)
                                                    .padding(8)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.white.opacity(0.04))
                                                    .cornerRadius(8)
                                            }
                                            
                                            if updater.isDownloading {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    ProgressView(value: updater.downloadProgress, total: 1.0)
                                                        .accentColor(vm.currentTheme.primary)
                                                    HStack {
                                                        Text("\(Int(updater.downloadProgress * 100))%")
                                                            .font(.system(size: 10, design: .monospaced))
                                                            .foregroundColor(vm.currentTheme.textSecondary)
                                                        Spacer()
                                                        Text("Downloading package...")
                                                            .font(.system(size: 10, design: .monospaced))
                                                            .foregroundColor(vm.currentTheme.textSecondary)
                                                    }
                                                }
                                            } else if updater.isExtracting {
                                                HStack(spacing: 8) {
                                                    ProgressView().scaleEffect(0.7)
                                                    Text("Installing & relaunching...")
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .foregroundColor(vm.currentTheme.primary)
                                                }
                                            } else {
                                                Button(action: {
                                                    updater.startDownloadAndInstall()
                                                }) {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "arrow.down.circle.fill")
                                                        Text("Update to v\(updater.latestVersion) & Restart")
                                                    }
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(Color.black)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(TsrossaColors.bitPerfectGold)
                                                    .cornerRadius(12)
                                                    .contentShape(Rectangle())
                                                }
                                                .buttonStyle(TsrossaScaleButtonStyle())
                                            }
                                        }
                                        .padding(10)
                                        .background(vm.currentTheme.primaryContainer.opacity(0.25))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(TsrossaColors.bitPerfectGold.opacity(0.35), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
        }
    }
    
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.primary)
            
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(vm.currentTheme.surfaceContainer.opacity(0.90))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
        )
    }
    
    private func settingsToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: vm.currentTheme.primary))
        }
    }
    
    private func accentPill(title: String, mode: String, color: Color) -> some View {
        let isSelected = vm.accentColorMode == mode
        return Button(action: { vm.setAccentColorMode(mode) }) {
            HStack(spacing: 5) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? vm.currentTheme.primary : Color.white.opacity(0.06))
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func bgPill(title: String, mode: String) -> some View {
        let isSelected = vm.bgCanvasMode == mode
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.35)) {
                vm.bgCanvasMode = mode
            }
        }) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? vm.currentTheme.primary : Color.white.opacity(0.06))
                .cornerRadius(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
