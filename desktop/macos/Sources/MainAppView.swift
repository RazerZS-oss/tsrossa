import SwiftUI
import AppKit

public struct MainAppView: View {
    @ObservedObject private var engine = AudioEngine.shared
    @ObservedObject private var vm = AppViewModel.shared
    
    private var filteredTracks: [TrackMetadata] {
        if vm.searchText.isEmpty {
            return vm.tracks
        }
        return vm.tracks.filter {
            $0.title.localizedCaseInsensitiveContains(vm.searchText) ||
            $0.artist.localizedCaseInsensitiveContains(vm.searchText) ||
            $0.album.localizedCaseInsensitiveContains(vm.searchText)
        }
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // ==========================================================
            // 0. MATERIAL YOU (MONET) DYNAMIC DESKTOP AMBIENT BACKGROUND
            // ==========================================================
            backgroundLayer
            
            // ==========================================================
            // MAIN WIDESCREEN DESKTOP ARCHITECTURE
            // (Spotify macOS + Apple Music macOS + Roon Reference)
            // ==========================================================
            VStack(spacing: 0) {
                // UPPER WORKSPACE: LEFT SIDEBAR + MAIN WIDESCREEN CONTENT
                HStack(spacing: 0) {
                    // ZONE 1: NATIVE MACOS SIDEBAR (236px fixed)
                    desktopSidebar
                        .frame(width: 236)
                    
                    // Vertical Divider
                    Rectangle()
                        .fill(vm.currentTheme.outline.opacity(0.18))
                        .frame(width: 1)
                    
                    // ZONE 2: MAIN WIDESCREEN CONTENT AREA
                    VStack(spacing: 0) {
                        desktopTopBar
                            .padding(.horizontal, 28)
                            .padding(.top, 18)
                            .padding(.bottom, 14)
                        
                        Divider()
                            .background(vm.currentTheme.outline.opacity(0.14))
                        
                        ZStack {
                            switch vm.activeTab {
                            case .library:
                                desktopLibraryView
                            case .nowPlaying:
                                desktopNowPlayingSplitView
                            case .playlist:
                                desktopQueueView
                            case .settings:
                                desktopSettingsBentoView
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Top border of transport bar
                Rectangle()
                    .fill(vm.currentTheme.outline.opacity(0.22))
                    .frame(height: 1)
                
                // ZONE 3: PERSISTENT BOTTOM TRANSPORT BAR (Full Width, 90px height)
                desktopBottomTransportBar
                    .frame(height: 90)
            }
            
            // ==========================================================
            // HARDWARE DIAGNOSTICS & TELEMETRY MODAL (Cmd + D)
            // ==========================================================
            if vm.showTelemetry {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minWidth: 980, minHeight: 680)
        .onAppear {
            vm.loadInitialMusicDirectory()
        }
    }
    
    // =========================================================================
    // AMBIENT BACKGROUND (Strictly Clipped so Layout Geometry Never Expands!)
    // =========================================================================
    @ViewBuilder
    private var backgroundLayer: some View {
        if vm.bgCanvasMode == "BLACK" {
            Color.black.ignoresSafeArea()
        } else if vm.bgCanvasMode == "AURA", let artwork = vm.currentArtwork {
            Color.clear
                .background(vm.currentTheme.surfaceContainerLowest)
                .overlay(
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 85)
                        .opacity(0.32)
                        .saturation(1.35)
                )
                .clipped()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        vm.currentTheme.surfaceContainerLowest,
                        vm.currentTheme.surface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [vm.currentTheme.primary.opacity(0.16), Color.clear],
                    center: .topLeading,
                    startRadius: 40,
                    endRadius: 680
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [vm.currentTheme.tertiary.opacity(0.10), Color.clear],
                    center: .bottomTrailing,
                    startRadius: 60,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        }
    }
    
    // =========================================================================
    // ZONE 1: LEFT NAVIGATION SIDEBAR (Apple Music / Spotify / Roon Style)
    // =========================================================================
    private var desktopSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Clearance for macOS Red/Yellow/Green Traffic Light Window Controls
            Spacer()
                .frame(height: 46)
            
            // Brand Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(vm.currentTheme.primaryContainer)
                        .frame(width: 34, height: 34)
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(vm.currentTheme.primary)
                }
                
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
            .padding(.bottom, 24)
            
            // Navigation Section Label
            Text("WORKSPACE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.textMuted)
                .padding(.horizontal, 22)
                .padding(.bottom, 8)
            
            // Sidebar Navigation Items
            VStack(spacing: 4) {
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
            
            Spacer()
            
            // Quick Palette Switcher in Sidebar
            VStack(alignment: .leading, spacing: 8) {
                Text("MATERIAL YOU PALETTE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                
                HStack(spacing: 6) {
                    sidebarPaletteDot(mode: "DYNAMIC", title: "Auto", color: vm.currentTheme.primary)
                    sidebarPaletteDot(mode: "MATCHA", title: "Matcha", color: Color(red: 0.62, green: 0.82, blue: 0.38))
                    sidebarPaletteDot(mode: "GOLD", title: "Gold", color: Color(red: 1.0, green: 0.84, blue: 0.0))
                    sidebarPaletteDot(mode: "CYAN", title: "Cyan", color: Color(red: 0.0, green: 0.898, blue: 1.0))
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
            
            // Hardware Signal Path Mini-Card at Bottom of Sidebar (Roon / Audirvana Reference)
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
    
    private func sidebarNavButton(tab: AppTab, icon: String, title: String, shortcut: String) -> some View {
        let isSelected = vm.activeTab == tab
        return Button(action: { vm.activeTab = tab }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.textSecondary)
                    .frame(width: 22)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.textSecondary)
                
                Spacer()
                
                Text(shortcut)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textMuted.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
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
    
    // =========================================================================
    // TOP UTILITY BAR (Search, Quick Actions, Hardware Status)
    // =========================================================================
    private var desktopTopBar: some View {
        HStack(spacing: 14) {
            // Search Box (Spotify / Apple Music Desktop style)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("Search tracks, artists, or albums...", text: $vm.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .onChange(of: vm.searchText) { newValue in
                        if !newValue.isEmpty && vm.activeTab != .library {
                            vm.activeTab = .library
                        }
                    }
                
                if !vm.searchText.isEmpty {
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
            .frame(width: 300)
            .background(vm.currentTheme.surfaceContainerHigh.opacity(0.85))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
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
            
            Spacer()
            
            // Hardware Status Pill
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.primary)
                Text(formatBadgeText)
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
    
    // =========================================================================
    // VIEW 1: WIDESCREEN NOW PLAYING SPLIT VIEW (Apple Music / Tidal / Roon)
    // =========================================================================
    private var desktopNowPlayingSplitView: some View {
        HStack(spacing: 28) {
            // LEFT COLUMN: Large Album Art Showcase & Track Identity
            VStack(spacing: 20) {
                Spacer(minLength: 8)
                
                ZStack {
                    if let artwork = vm.currentArtwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 310, height: 310)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(color: vm.currentTheme.primary.opacity(0.38), radius: 32, x: 0, y: 16)
                    } else {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [vm.currentTheme.surfaceContainerHigh, vm.currentTheme.surfaceContainer],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 310, height: 310)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: vm.currentTheme.primary.opacity(0.22), radius: 24, x: 0, y: 12)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: 76))
                                .foregroundColor(vm.currentTheme.primary)
                            Text("BIT-PERFECT MASTER")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textSecondary)
                        }
                    }
                }
                
                VStack(spacing: 6) {
                    Text(engine.currentTrack?.title ?? "No Track Selected")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(subtitleText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                // Audiophile Master Quality Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(TsrossaColors.bitPerfectGold)
                        .frame(width: 7, height: 7)
                    Text(formatBadgeText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.onPrimaryContainer)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(vm.currentTheme.primaryContainer.opacity(0.65))
                .cornerRadius(20)
                
                Spacer(minLength: 8)
            }
            .frame(maxWidth: .infinity)
            
            // RIGHT COLUMN: Live Signal Path Inspector + Up Next Queue (Roon / Apple Music Desktop)
            VStack(spacing: 16) {
                // 1. LIVE SIGNAL PATH CARD
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .foregroundColor(vm.currentTheme.primary)
                        Text("LOSSLESS SIGNAL PATH")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        Text("BIT-PERFECT")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(TsrossaColors.terminalGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(TsrossaColors.terminalGreen.opacity(0.14))
                            .cornerRadius(6)
                    }
                    
                    signalPathStep(
                        icon: "doc.badge.gearshape",
                        title: "Source Decoder (\(engine.currentTrack?.path.hasSuffix(".flac") == true ? "dr_flac" : "dr_wav"))",
                        detail: "\(engine.currentTrack?.sampleRate ?? 44100) Hz / \(engine.currentTrack?.bitDepth ?? 16)-bit Float64 Zero-Copy",
                        badgeColor: vm.currentTheme.primary
                    )
                    
                    signalPathStep(
                        icon: "memorychip",
                        title: "Memory Pinning (POSIX mlock)",
                        detail: vm.isRamPlayback ? "Locked in physical RAM • 0 SSD page faults" : "Standard buffered streaming",
                        badgeColor: vm.isRamPlayback ? TsrossaColors.audiophileCyan : vm.currentTheme.textSecondary
                    )
                    
                    signalPathStep(
                        icon: "lock.shield",
                        title: "CoreAudio HAL Output (\(activeDeviceName))",
                        detail: vm.isExclusiveHogMode ? "Exclusive Hog Mode • System Mixer Bypassed" : "Shared CoreAudio Output",
                        badgeColor: TsrossaColors.bitPerfectGold
                    )
                }
                .padding(16)
                .background(vm.currentTheme.surfaceContainer.opacity(0.88))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
                )
                
                // 2. UP NEXT IN QUEUE CARD
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(vm.currentTheme.primary)
                        Text("UP NEXT IN LIBRARY (\(vm.tracks.count) TRACKS)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                        Spacer()
                        Button(action: { vm.activeTab = .library }) {
                            Text("View Full Table →")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(vm.tracks.prefix(40).enumerated()), id: \.offset) { idx, track in
                                compactQueueRow(index: idx + 1, track: track)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxHeight: .infinity)
                .background(vm.currentTheme.surfaceContainer.opacity(0.88))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(vm.currentTheme.outline.opacity(0.22), lineWidth: 1)
                )
            }
            .frame(width: 400)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }
    
    private func signalPathStep(icon: String, title: String, detail: String, badgeColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(badgeColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                Text(detail)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
    
    private func compactQueueRow(index: Int, track: TrackMetadata) -> some View {
        let isCurrent = engine.currentTrack?.path == track.path
        return Button(action: { engine.play(track: track) }) {
            HStack(spacing: 10) {
                if isCurrent && engine.isPlaying {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(vm.currentTheme.primary)
                        .frame(width: 22)
                } else {
                    Text("\(index)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                        .frame(width: 22)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 12, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 10))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(vm.formatTime(track.durationSeconds))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.45) : Color.white.opacity(0.03))
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // =========================================================================
    // VIEW 2: WIDESCREEN MUSIC LIBRARY (Spotify / Apple Music Table + Hero)
    // =========================================================================
    private var desktopLibraryView: some View {
        VStack(spacing: 0) {
            // Featured Hero Header Banner
            HStack(spacing: 20) {
                ZStack {
                    if let art = vm.currentArtwork {
                        Image(nsImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: vm.currentTheme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(vm.currentTheme.primaryContainer)
                            .frame(width: 96, height: 96)
                        Image(systemName: "opticaldisc.fill")
                            .font(.system(size: 42))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("LOSSLESS MASTER COLLECTION")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    
                    Text("Local Audiophile Library")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    
                    Text("\(filteredTracks.count) tracks  •  \(vm.currentFolder)  •  Zero-Copy Direct Memory Engine")
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Hero Play & Shuffle Actions
                HStack(spacing: 10) {
                    Button(action: {
                        if engine.currentTrack != nil {
                            engine.togglePlayPause()
                        } else if let first = filteredTracks.first {
                            engine.play(track: first)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                            Text(engine.isPlaying && !engine.isPaused ? "Pause" : "Play Library")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(vm.currentTheme.onPrimary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(vm.currentTheme.primary)
                        .cornerRadius(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    Button(action: {
                        vm.isShuffle = true
                        vm.playNextTrack()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "shuffle")
                            Text("Shuffle")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(vm.currentTheme.surfaceContainerHigh)
                        .cornerRadius(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(vm.currentTheme.surfaceContainerLow.opacity(0.55))
            
            // Widescreen Multi-Column Table Header
            HStack(spacing: 14) {
                Text("#")
                    .frame(width: 34, alignment: .center)
                Text("TITLE")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("ARTIST")
                    .frame(width: 170, alignment: .leading)
                Text("ALBUM")
                    .frame(width: 160, alignment: .leading)
                Text("ENCODING")
                    .frame(width: 110, alignment: .center)
                Image(systemName: "clock")
                    .frame(width: 60, alignment: .trailing)
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(vm.currentTheme.textMuted)
            .padding(.horizontal, 28)
            .padding(.vertical, 10)
            .background(vm.currentTheme.surfaceContainerLowest.opacity(0.5))
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.15))
            
            // Multi-Column Track Rows
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(Array(filteredTracks.enumerated()), id: \.element.id) { idx, track in
                        desktopTrackTableRow(index: idx + 1, track: track)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    private func desktopTrackTableRow(index: Int, track: TrackMetadata) -> some View {
        let isCurrent = engine.currentTrack?.path == track.path
        let isFlac = track.path.lowercased().hasSuffix(".flac")
        
        return Button(action: { engine.play(track: track) }) {
            HStack(spacing: 14) {
                // Column 1: # or Playing Indicator
                ZStack {
                    if isCurrent {
                        Image(systemName: engine.isPlaying && !engine.isPaused ? "waveform" : "speaker.wave.2.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.currentTheme.primary)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                    }
                }
                .frame(width: 34, alignment: .center)
                
                // Column 2: Mini Thumbnail + Title
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCurrent ? vm.currentTheme.primaryContainer : Color.white.opacity(0.07))
                            .frame(width: 38, height: 38)
                        
                        if isCurrent, let art = vm.currentArtwork {
                            Image(nsImage: art)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 38, height: 38)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "music.note")
                                .font(.system(size: 14))
                                .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                        }
                    }
                    
                    Text(track.title)
                        .font(.system(size: 13, weight: isCurrent ? .bold : .semibold))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Column 3: Artist
                Text(track.artist)
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .lineLimit(1)
                    .frame(width: 170, alignment: .leading)
                
                // Column 4: Album
                Text(track.album)
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textMuted)
                    .lineLimit(1)
                    .frame(width: 160, alignment: .leading)
                
                // Column 5: Format Badge
                Text("\(isFlac ? "FLAC" : "WAV") \(track.bitDepth)/\(String(format: "%.1fk", Double(track.sampleRate)/1000.0))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isCurrent ? vm.currentTheme.onPrimaryContainer : vm.currentTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isCurrent ? vm.currentTheme.primaryContainer : vm.currentTheme.primaryContainer.opacity(0.35))
                    .cornerRadius(6)
                    .frame(width: 110, alignment: .center)
                
                // Column 6: Duration
                Text(vm.formatTime(track.durationSeconds))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.32) : Color.white.opacity(0.02))
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // =========================================================================
    // VIEW 3: WIDESCREEN PLAY QUEUE VIEW
    // =========================================================================
    private var desktopQueueView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE PLAYBACK QUEUE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                    Text("Play Queue & Upcoming Master Tracks")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(vm.currentTheme.textPrimary)
                }
                Spacer()
                Text("\(filteredTracks.count) tracks queued")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.15))
            
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(Array(filteredTracks.enumerated()), id: \.element.id) { idx, track in
                        desktopTrackTableRow(index: idx + 1, track: track)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }
    
    // =========================================================================
    // VIEW 4: WIDESCREEN 2-COLUMN BENTO SETTINGS (Desktop Audiophile Layout)
    // =========================================================================
    private var desktopSettingsBentoView: some View {
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
                                
                                HStack(spacing: 8) {
                                    accentPill(title: "Dynamic (Monet)", mode: "DYNAMIC", color: vm.currentTheme.primary)
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
                        
                        // 5. ABOUT TSROSSA
                        settingsCard(title: "ABOUT TSROSSA MACOS") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("tsrossa bit-perfect desktop player")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(vm.currentTheme.textPrimary)
                                    Spacer()
                                    Text("v1.6.0 macOS")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(vm.currentTheme.primary)
                                }
                                Text("Native Apple Silicon CoreAudio HAL port of yukaatsu/tsrossa with Material You dynamic color extraction and zero-DSP hardware playback.")
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(28)
        }
    }
    
    // =========================================================================
    // ZONE 3: PERSISTENT BOTTOM TRANSPORT BAR (Spotify / Apple Music macOS)
    // =========================================================================
    private var desktopBottomTransportBar: some View {
        HStack(spacing: 16) {
            // 1. LEFT SECTION: Mini Artwork + Track Title + Artist (270px)
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.currentTheme.surfaceContainerHigh)
                                .frame(width: 56, height: 56)
                            Image(systemName: "music.note")
                                .font(.system(size: 20))
                                .foregroundColor(vm.currentTheme.primary)
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
                }
                .frame(width: 260, alignment: .leading)
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
            
            // 3. RIGHT SECTION: Hardware Attenuation Volume + Queue + Telemetry (260px)
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
                
                // Queue Quick Switch
                Button(action: {
                    vm.activeTab = (vm.activeTab == .playlist) ? .nowPlaying : .playlist
                }) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(vm.activeTab == .playlist ? vm.currentTheme.onPrimary : vm.currentTheme.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(vm.activeTab == .playlist ? vm.currentTheme.primary : vm.currentTheme.surfaceContainerHigh)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                .help("Toggle Queue (⌘3)")
            }
            .frame(width: 260, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .background(vm.currentTheme.surfaceContainer.opacity(0.95))
    }
    
    // =========================================================================
    // REUSABLE SETTINGS COMPONENTS
    // =========================================================================
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
    
    // =========================================================================
    // HELPERS
    // =========================================================================
    private var activeDeviceName: String {
        if let dev = engine.devices.first(where: { $0.id == engine.selectedDeviceId }) {
            return dev.name
        }
        return engine.devices.first?.name ?? "Apple Silicon CoreAudio DAC"
    }
    
    private var subtitleText: String {
        if let track = engine.currentTrack {
            return "\(track.artist)  •  \(track.album)"
        }
        return "Select a track from your library"
    }
    
    private var formatBadgeText: String {
        if let track = engine.currentTrack {
            let fmt = track.path.lowercased().hasSuffix(".flac") ? "FLAC" : "WAV"
            return "\(fmt)  •  \(String(format: "%.1f", Double(track.sampleRate) / 1000.0)) kHz  •  \(track.bitDepth)-BIT HARDWARE"
        }
        return "FLAC  •  BIT-PERFECT DIRECT"
    }
}
