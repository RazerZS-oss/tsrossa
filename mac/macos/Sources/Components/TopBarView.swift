import SwiftUI
import AppKit

public struct TopBarView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Navigation Back/Forward History Buttons
            HStack(spacing: 4) {
                Button(action: {
                    if vm.activeTab != .library {
                        vm.activeTab = .library
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Back to Library")
                
                Button(action: {
                    if vm.activeTab != .nowPlaying {
                        vm.activeTab = .nowPlaying
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Go to Now Playing")
            }
            
            // Search Box with ⌘K Badge (Aether & Spotify Style)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("Search lossless tracks, artists, albums...", text: $vm.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .onSubmit {
                        vm.playSelectedSearchResult()
                    }
                    .onChange(of: vm.searchText) { newValue in
                        if !newValue.isEmpty && vm.activeTab != .library {
                            vm.activeTab = .library
                        }
                    }
                
                if !vm.searchText.isEmpty {
                    Button(action: { vm.playSelectedSearchResult() }) {
                        Text("⏎ Play")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.onPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(vm.currentTheme.primary)
                            .cornerRadius(5)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { vm.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text("⌘K")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(minWidth: 240, maxWidth: 360)
            .background(vm.currentTheme.surfaceContainerHigh.opacity(0.75))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(!vm.searchText.isEmpty ? vm.currentTheme.primary.opacity(0.6) : vm.currentTheme.outline.opacity(0.18), lineWidth: 1)
            )
            
            // Sort Button
            Button(action: { vm.toggleSort() }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 10))
                    Text(vm.sortMode)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.65))
                .cornerRadius(10)
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            
            Spacer()
            
            // DAC Audio Quality Badge with Live Pulsing Indicator (Click opens diagnostics)
            Button(action: {
                engine.updateTelemetry()
                vm.showTelemetry = true
            }) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(TsrossaColors.terminalGreen)
                        .frame(width: 6, height: 6)
                    
                    Text(engine.formatBadgeText)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(vm.currentTheme.primaryContainer.opacity(0.40))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(vm.currentTheme.primary.opacity(0.28), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            .help("Click to view Lossless Hardware Signal Path (⌘D)")
            
            // Mini Player Pop-out Toggle Button
            Button(action: { vm.toggleMiniPlayer() }) {
                HStack(spacing: 5) {
                    Image(systemName: "picture.in.picture")
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.primary)
                    Text("Mini Player")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            .help("Switch to Floating Mini Player Mode")
            
            // Right Inspector Sidebar Toggle Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.20)) {
                    vm.toggleRightInspector()
                }
            }) {
                Image(systemName: vm.showRightInspector ? "sidebar.right" : "sidebar.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vm.showRightInspector ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(vm.showRightInspector ? vm.currentTheme.primary.opacity(0.18) : vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            .help(vm.showRightInspector ? "Hide Right Inspector" : "Show Right Inspector (Lyrics, EQ, Queue)")
            
            // Quick Action Folder & Rescan Buttons
            HStack(spacing: 6) {
                topActionIconButton(icon: "folder.badge.plus", helpText: "Choose Music Folder") {
                    vm.openFolderPicker()
                }
                topActionIconButton(icon: "arrow.clockwise", helpText: "Rescan Music Library (⌘R)") {
                    vm.rescanCurrentFolder()
                }
            }
        }
    }
    
    private func topActionIconButton(icon: String, helpText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(vm.currentTheme.textPrimary)
                .frame(width: 28, height: 28)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                .cornerRadius(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(TsrossaScaleButtonStyle())
        .help(helpText)
    }
}
