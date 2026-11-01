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
                TsrossaBrandIcon(size: 34, cornerRadius: 9)
                    .shadow(color: Color(red: 1.0, green: 0.18, blue: 0.33).opacity(0.35), radius: 8, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 5) {
                        Text("tsrossa")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                        
                        Circle()
                            .fill(TsrossaColors.bitPerfectGold)
                            .frame(width: 5, height: 5)
                    }
                    Text("STUDIO LOSSLESS DAC")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // SECTION 1: DISCOVER
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DISCOVER")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 2)
                        
                        sidebarNavButton(
                            title: "Now Playing Stage",
                            icon: "play.square.stack.fill",
                            isSelected: vm.activeTab == .nowPlaying,
                            shortcut: "⌘1",
                            action: { vm.activeTab = .nowPlaying }
                        )
                        
                        sidebarCustomButton(
                            title: "Hi-Res Masters",
                            icon: "sparkle",
                            badge: "24-Bit",
                            badgeColor: TsrossaColors.bitPerfectGold,
                            isSelected: vm.activeTab == .library && vm.selectedBitDepthFilter == 24,
                            action: {
                                vm.selectedBitDepthFilter = (vm.selectedBitDepthFilter == 24 ? 0 : 24)
                                vm.activeTab = .library
                            }
                        )
                        
                        sidebarCustomButton(
                            title: "Autoplay Radio",
                            icon: "broadcast",
                            badge: vm.isAutoplayRadio ? "ON" : "OFF",
                            badgeColor: vm.isAutoplayRadio ? TsrossaColors.terminalGreen : vm.currentTheme.textMuted,
                            isSelected: false,
                            action: {
                                vm.isAutoplayRadio.toggle()
                                vm.toastMessage = vm.isAutoplayRadio ? "Autoplay Infinite Radio Enabled" : "Autoplay Radio Disabled"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    if vm.toastMessage.contains("Autoplay") { vm.toastMessage = "" }
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                    
                    // SECTION 2: MY LIBRARY
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MY LIBRARY")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 2)
                        
                        sidebarCustomButton(
                            title: "Favorite Tracks",
                            icon: "heart.fill",
                            badge: "\(vm.likedTracksCount)",
                            badgeColor: vm.currentTheme.primary,
                            isSelected: vm.activeTab == .library && vm.selectedPlaylistId == "LIKED_SONGS",
                            action: {
                                vm.selectedPlaylistId = "LIKED_SONGS"
                                vm.activeTab = .library
                            }
                        )
                        
                        sidebarCustomButton(
                            title: "FLAC Archive",
                            icon: "filemenu.and.selection",
                            badge: "FLAC",
                            badgeColor: vm.currentTheme.primary,
                            isSelected: vm.activeTab == .library && vm.selectedFormatFilter == "FLAC",
                            action: {
                                vm.selectedFormatFilter = (vm.selectedFormatFilter == "FLAC" ? "ALL" : "FLAC")
                                vm.activeTab = .library
                            }
                        )
                        
                        sidebarCustomButton(
                            title: "Studio WAV Stems",
                            icon: "waveform.badge.magnifyingglass",
                            badge: "WAV",
                            badgeColor: TsrossaColors.audiophileCyan,
                            isSelected: vm.activeTab == .library && vm.selectedFormatFilter == "WAV",
                            action: {
                                vm.selectedFormatFilter = (vm.selectedFormatFilter == "WAV" ? "ALL" : "WAV")
                                vm.activeTab = .library
                            }
                        )
                        
                        sidebarNavButton(
                            title: "All Library Tracks",
                            icon: "opticaldisc.fill",
                            isSelected: vm.activeTab == .library && vm.selectedPlaylistId == nil && vm.selectedFormatFilter == "ALL" && vm.selectedBitDepthFilter == 0,
                            shortcut: "⌘2",
                            action: {
                                vm.selectedPlaylistId = nil
                                vm.selectedFormatFilter = "ALL"
                                vm.selectedBitDepthFilter = 0
                                vm.activeTab = .library
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                    
                    // SECTION 3: PLAYLISTS
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("PLAYLISTS")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                            
                            Spacer()
                            
                            Button(action: { vm.openCreatePlaylistModal() }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 8, weight: .bold))
                                    Text("New")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .foregroundColor(vm.currentTheme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(vm.currentTheme.primaryContainer.opacity(0.55))
                                .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Create New Playlist (⌘N)")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                        
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
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 4)
            }
            
            Spacer(minLength: 6)
            
            // Bottom Hardware Output Indicator Card (Sennheiser / DAC / Exclusive Hog Mode)
            Button(action: {
                engine.updateTelemetry()
                vm.showTelemetry = true
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(vm.currentTheme.primary.opacity(0.18))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "headphones")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(engine.activeDeviceName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(TsrossaColors.terminalGreen)
                                .frame(width: 5, height: 5)
                            Text(vm.isExclusiveHogMode ? "Exclusive Hog Mode" : "Bit-Perfect Direct")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(TsrossaColors.terminalGreen)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {
                        vm.activeTab = .settings
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12))
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Audio Engine Settings (⌘4)")
                }
                .padding(10)
                .background(vm.currentTheme.surfaceContainerHigh.opacity(0.60))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
                )
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .frame(width: 236)
        .background(vm.currentTheme.surfaceContainerLowest.opacity(0.65))
    }
    
    private func sidebarNavButton(title: String, icon: String, isSelected: Bool, shortcut: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                    .frame(width: 18)
                
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                
                Spacer()
                
                Text(shortcut)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary.opacity(0.70) : vm.currentTheme.textMuted)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? vm.currentTheme.primary : Color.clear)
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sidebarCustomButton(title: String, icon: String, badge: String, badgeColor: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary : badgeColor)
                    .frame(width: 18)
                
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                
                Spacer()
                
                Text(badge)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimary : badgeColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.20) : badgeColor.opacity(0.14))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? vm.currentTheme.primary : Color.clear)
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
                        .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
                        .frame(width: 18)
                    
                    Text(title)
                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(isSelected ? vm.currentTheme.onPrimary.opacity(0.70) : vm.currentTheme.textMuted)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if let del = onDelete {
                Button(action: del) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isSelected ? vm.currentTheme.onPrimary.opacity(0.70) : vm.currentTheme.textMuted)
                        .padding(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? vm.currentTheme.primary : Color.clear)
        .cornerRadius(10)
    }
}
