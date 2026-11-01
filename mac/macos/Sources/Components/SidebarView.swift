import SwiftUI
import AppKit

public struct SidebarView: View {
    @ObservedObject private var vm = AppViewModel.shared
    @ObservedObject private var engine = AudioEngine.shared
    @ObservedObject private var updater = UpdateManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Clearance for macOS Traffic Light Window Controls
            Spacer()
                .frame(height: 46)
            
            // Brand Header with Authentic Android tsrossa Crimson Rose Logo
            HStack(spacing: 11) {
                TsrossaBrandIcon(size: 38, cornerRadius: 10)
                    .shadow(color: Color(red: 1.0, green: 0.18, blue: 0.33).opacity(0.35), radius: 8, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("tsrossa")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                        
                        Circle()
                            .fill(TsrossaColors.bitPerfectGold)
                            .frame(width: 6, height: 6)
                    }
                    Text("BIT-PERFECT MAC DAC")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
            
            // Navigation Section Label
            Text("WORKSPACE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.textMuted)
                .padding(.horizontal, 22)
                .padding(.bottom, 6)
            
            // Sidebar Navigation Items
            VStack(spacing: 3) {
                sidebarNavButton(
                    tab: .nowPlaying,
                    icon: "play.square.stack.fill",
                    title: "Now Playing",
                    shortcut: "⌘1"
                )
                sidebarNavButton(
                    tab: .library,
                    icon: "square.grid.2x2.fill",
                    title: "Music Library",
                    shortcut: "⌘2"
                )
                sidebarNavButton(
                    tab: .playlist,
                    icon: "music.note.list",
                    title: "Play Queue",
                    shortcut: "⌘3"
                )
                sidebarNavButton(
                    tab: .settings,
                    icon: "slider.horizontal.3",
                    title: "DAC & Settings",
                    shortcut: "⌘4"
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
            
            // ==========================================================
            // PLAYLISTS SECTION
            // ==========================================================
            HStack {
                Text("PLAYLISTS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                
                Spacer()
                
                Button(action: { vm.openCreatePlaylistModal() }) {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .bold))
                        Text("New")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(vm.currentTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(vm.currentTheme.primaryContainer.opacity(0.55))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Create New Playlist / Smart Filter (⌘N)")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 6)
            
            ScrollView {
                VStack(spacing: 3) {
                    // "All Tracks" reset item
                    sidebarPlaylistRow(
                        title: "All Master Tracks",
                        icon: "opticaldisc.fill",
                        count: vm.tracks.count,
                        isSelected: vm.activeTab == .library && vm.selectedPlaylistId == nil,
                        onSelect: {
                            vm.selectedPlaylistId = nil
                            vm.activeTab = .library
                        },
                        onDelete: nil
                    )
                    
                    // "Liked Songs" pinned item
                    sidebarPlaylistRow(
                        title: "Liked Songs",
                        icon: "heart.fill",
                        count: vm.likedTracksCount,
                        isSelected: vm.activeTab == .library && vm.selectedPlaylistId == "LIKED_SONGS",
                        onSelect: {
                            vm.selectedPlaylistId = "LIKED_SONGS"
                            vm.activeTab = .library
                        },
                        onDelete: nil
                    )
                    
                    ForEach(vm.playlists) { pl in
                        let matchCount = vm.tracks.filter { pl.matches(track: $0) }.count
                        sidebarPlaylistRow(
                            title: pl.name,
                            icon: pl.filterKeyword.isEmpty ? "music.note.list" : "sparkles",
                            count: matchCount,
                            isSelected: vm.activeTab == .library && vm.selectedPlaylistId == pl.id,
                            onSelect: {
                                vm.selectedPlaylistId = pl.id
                                vm.activeTab = .library
                            },
                            onDelete: {
                                vm.deletePlaylist(id: pl.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(maxHeight: 165)
            
            Spacer(minLength: 6)
            
            // Quick Palette Switcher in Sidebar
            VStack(alignment: .leading, spacing: 8) {
                Text("MATERIAL YOU PALETTE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                
                HStack(spacing: 5) {
                    sidebarPaletteDot(mode: "DYNAMIC", title: "Auto", color: vm.currentTheme.primary)
                    sidebarPaletteDot(mode: "ROSE", title: "Rose", color: Color(red: 1.0, green: 0.18, blue: 0.33))
                    sidebarPaletteDot(mode: "MATCHA", title: "Matcha", color: Color(red: 0.62, green: 0.82, blue: 0.38))
                    sidebarPaletteDot(mode: "GOLD", title: "Gold", color: Color(red: 1.0, green: 0.84, blue: 0.0))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            // Hardware Signal Path Mini-Card at Bottom of Sidebar
            Button(action: {
                engine.updateTelemetry()
                vm.showTelemetry = true
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(TsrossaColors.terminalGreen)
                            .frame(width: 7, height: 7)
                        Text(vm.isExclusiveHogMode ? "COREAUDIO HOG LOCK" : "COREAUDIO SHARED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.terminalGreen)
                        Spacer()
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                    
                    Text(activeDeviceName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(String(format: "%.1f kHz", Double(engine.currentTrack?.sampleRate ?? 44100) / 1000.0))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.bitPerfectGold)
                        Text("•")
                            .foregroundColor(vm.currentTheme.textMuted)
                        Text("\(engine.currentTrack?.bitDepth ?? 16)-BIT")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Text("•")
                            .foregroundColor(vm.currentTheme.textMuted)
                        Text("mlock")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.75))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            .padding(.horizontal, 14)
            .padding(.bottom, 16)
        }
        .background(vm.currentTheme.surfaceContainerLowest.opacity(0.65))
    }
    
    private var activeDeviceName: String {
        return engine.devices.first(where: { $0.id == engine.selectedDeviceId })?.name ?? "Default Output"
    }
    
    private func sidebarPlaylistRow(
        title: String,
        icon: String,
        count: Int,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onDelete: (() -> Void)?
    ) -> some View {
        HStack(spacing: 8) {
            Button(action: onSelect) {
                HStack(spacing: 9) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                        .frame(width: 18)
                    
                    Text(title)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? vm.currentTheme.textPrimary : vm.currentTheme.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 9))
                        .foregroundColor(vm.currentTheme.textMuted.opacity(0.65))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Delete Playlist")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(isSelected ? vm.currentTheme.primaryContainer.opacity(0.75) : Color.clear)
        .cornerRadius(10)
    }
    
    private func sidebarNavButton(tab: AppTab, icon: String, title: String, shortcut: String) -> some View {
        let isSelected = vm.activeTab == tab
        let showUpdateBadge = (tab == .settings && updater.updateAvailable)
        return Button(action: { vm.activeTab = tab }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.textSecondary)
                    .frame(width: 22)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.textSecondary)
                
                if showUpdateBadge {
                    Circle()
                        .fill(TsrossaColors.bitPerfectGold)
                        .frame(width: 6, height: 6)
                }
                
                Spacer()
                
                Text(shortcut)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textMuted.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(isSelected ? vm.currentTheme.primaryContainer.opacity(0.85) : Color.clear)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sidebarPaletteDot(mode: String, title: String, color: Color) -> some View {
        let isSelected = vm.accentColorMode == mode
        return Button(action: { vm.setAccentColorMode(mode) }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.textPrimary : vm.currentTheme.textSecondary)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(isSelected ? vm.currentTheme.primaryContainer.opacity(0.75) : Color.white.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? vm.currentTheme.primary.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
