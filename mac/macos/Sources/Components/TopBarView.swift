import SwiftUI
import AppKit

public struct TopBarView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Search Box (Spotify Typeahead + Enter to Play Top Hit)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("Search tracks, artists... (Press ⏎ to play)", text: $vm.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
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
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(vm.currentTheme.primary)
                            .cornerRadius(6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Press Return/Enter to immediately play the highlighted result")
                    
                    Button(action: { vm.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(vm.currentTheme.textSecondary)
                            .contentShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(width: 330)
            .background(vm.currentTheme.surfaceContainerHigh.opacity(0.85))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(!vm.searchText.isEmpty ? vm.currentTheme.primary.opacity(0.6) : vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
            )
            
            // Sort Button
            Button(action: { vm.toggleSort() }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11))
                    Text(vm.sortMode)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.65))
                .cornerRadius(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            
            // + New Playlist Quick Button
            Button(action: { vm.openCreatePlaylistModal() }) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.rectangle.on.folder.fill")
                        .font(.system(size: 11))
                    Text("New Playlist")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(vm.currentTheme.onPrimaryContainer)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(vm.currentTheme.primaryContainer.opacity(0.65))
                .cornerRadius(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            
            Spacer()
            
            // Hardware Status Pill
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.primary)
                Text(engine.formatBadgeText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(vm.currentTheme.primaryContainer.opacity(0.45))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(vm.currentTheme.primary.opacity(0.30), lineWidth: 1)
            )
            
            // Quick Action Circle Buttons
            HStack(spacing: 8) {
                topActionCircleButton(icon: "folder.badge.plus", helpText: "Choose Music Folder") {
                    vm.openFolderPicker()
                }
                topActionCircleButton(icon: "arrow.clockwise", helpText: "Rescan Music Library (⌘R)") {
                    vm.rescanCurrentFolder()
                }
                topActionCircleButton(icon: "waveform.path.ecg", helpText: "Signal Path & Hardware Diagnostics (⌘D)") {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }
            }
        }
    }
    
    private func topActionCircleButton(icon: String, helpText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(vm.currentTheme.surfaceContainerHigh)
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
            }
            .frame(width: 34, height: 34)
            .contentShape(Circle())
        }
        .buttonStyle(TsrossaScaleButtonStyle())
        .help(helpText)
    }
}
