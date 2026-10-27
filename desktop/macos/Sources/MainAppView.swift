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
            // ==========================================
            // DYNAMIC AMBIENT BACKDROP (Spotify / Material You)
            // ==========================================
            vm.currentTheme.surfaceContainerLowest
                .ignoresSafeArea()
            
            if let artwork = vm.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 80)
                    .opacity(0.24)
                    .saturation(1.4)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.6), value: currentTrackPath)
            }
            
            RadialGradient(
                colors: [vm.currentTheme.primary.opacity(0.16), Color.clear],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 850
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: vm.currentTheme)
            
            // ==========================================
            // MAIN DESKTOP LAYOUT (Sidebar + Content + Player)
            // ==========================================
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // LEFT SIDEBAR (Desktop Spotify / Apple Music Navigation)
                    sidebarView
                        .frame(width: 240)
                    
                    // VERTICAL DIVIDER
                    Rectangle()
                        .fill(vm.currentTheme.outline.opacity(0.15))
                        .frame(width: 1)
                        .ignoresSafeArea()
                    
                    // MAIN CONTENT PANE
                    VStack(spacing: 0) {
                        topHeaderBar
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                        
                        ZStack {
                            switch vm.activeTab {
                            case .library:
                                desktopLibraryTableView
                            case .nowPlaying:
                                nowPlayingCanvasView
                            case .playlist:
                                queuePlaylistView
                            case .settings:
                                audioDevicesSettingsView
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // PERSISTENT BOTTOM PLAYER BAR (Spotify / Apple Music Standard)
                persistentBottomPlayerBar
            }
            
            // SYSTEM LOGS & DIAGNOSTICS OVERLAY
            if vm.showTelemetry {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minWidth: 960, idealWidth: 1120, minHeight: 680, idealHeight: 760)
        .onAppear {
            vm.loadInitialMusicDirectory()
        }
    }
    
    private var currentTrackPath: String {
        engine.currentTrack?.path ?? ""
    }
    
    // ==========================================
    // 1. LEFT SIDEBAR (Desktop Navigation)
    // ==========================================
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Branding Header (macOS Traffic Light Aligned)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("tsrossa")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(vm.currentTheme.textPrimary)
                    
                    Circle()
                        .fill(TsrossaColors.bitPerfectGold)
                        .frame(width: 8, height: 8)
                    
                    Text("Bit-Perfect")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(TsrossaColors.bitPerfectGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(TsrossaColors.bitPerfectGold.opacity(0.15))
                        .cornerRadius(6)
                }
                
                Text("DIRECT HARDWARE AUDIO")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.primary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 36)
            .padding(.bottom, 24)
            
            // Navigation Links
            VStack(spacing: 4) {
                sidebarNavItem(tab: .library, icon: "books.vertical.fill", title: "Library", shortcut: "⌘1")
                sidebarNavItem(tab: .nowPlaying, icon: "waveform", title: "Now Playing", shortcut: "⌘2", isAnimated: engine.isPlaying && !engine.isPaused)
                sidebarNavItem(tab: .playlist, icon: "list.bullet.rectangle", title: "Queue", shortcut: "⌘3")
                sidebarNavItem(tab: .settings, icon: "speaker.wave.3.fill", title: "Audio Devices", shortcut: "⌘4")
            }
            .padding(.horizontal, 12)
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.15))
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            
            // Folder & Library Section
            VStack(alignment: .leading, spacing: 10) {
                Text("MUSIC DIRECTORY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                    .padding(.horizontal, 20)
                
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(vm.currentTheme.primary)
                    Text((vm.currentFolder as NSString).lastPathComponent)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(vm.currentTheme.textPrimary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 8) {
                    Button(action: { vm.openFolderPicker() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.badge.gearshape")
                            Text("Change")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    Button(action: { vm.rescanCurrentFolder() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Rescan")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Direct-to-DAC Engine Status Pill
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(TsrossaColors.terminalGreen)
                        .frame(width: 8, height: 8)
                    Text("COREAUDIO HAL")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(TsrossaColors.terminalGreen)
                    Spacer()
                    Text("HOG 🔒")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                }
                
                Button(action: {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                        Text("System Diagnostics")
                        Spacer()
                        Text("⌘D")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(vm.currentTheme.primaryContainer.opacity(0.40))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(vm.currentTheme.outline.opacity(0.2), lineWidth: 1)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
            .padding(16)
            .background(vm.currentTheme.surfaceContainer.opacity(0.6))
            .cornerRadius(14)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .background(vm.currentTheme.surfaceContainerLow.opacity(0.85))
    }
    
    private func sidebarNavItem(tab: AppTab, icon: String, title: String, shortcut: String, isAnimated: Bool = false) -> some View {
        let isSelected = vm.activeTab == tab
        return Button(action: { vm.activeTab = tab }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                    .frame(width: 22)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                
                Spacer()
                
                if isAnimated {
                    Image(systemName: "waveform")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(vm.currentTheme.primary)
                } else {
                    Text(shortcut)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textMuted)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? vm.currentTheme.primaryContainer.opacity(0.45) : Color.clear)
            )
            .contentShape(Rectangle()) // Entire row is 100% clickable!
        }
        .buttonStyle(TsrossaScaleButtonStyle())
    }
    
    // ==========================================
    // 2. TOP HEADER BAR (Search & Quick Actions)
    // ==========================================
    private var topHeaderBar: some View {
        HStack(spacing: 14) {
            // Instant Search Field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("Search library by song, artist, album... (⌘F)", text: $vm.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .font(.system(size: 13))
                
                if !vm.searchText.isEmpty {
                    Button(action: { vm.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(vm.currentTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.35))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
            )
            .frame(maxWidth: 420)
            
            // Sort Selector
            Button(action: { vm.toggleSort() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11))
                    Text(vm.sortMode)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.08))
                .cornerRadius(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
            
            Spacer()
            
            Text("\(filteredTracks.count) tracks")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(vm.currentTheme.textSecondary)
            
            // Circular Action Buttons (100% full hit-testing area)
            InteractiveCircleButton(icon: "waveform.path.ecg", size: 36, iconSize: 14) {
                engine.updateTelemetry()
                vm.showTelemetry = true
            }
            
            InteractiveCircleButton(icon: "arrow.clockwise", size: 36, iconSize: 14) {
                vm.rescanCurrentFolder()
            }
            
            InteractiveCircleButton(icon: "folder", size: 36, iconSize: 14) {
                vm.openFolderPicker()
            }
        }
    }
    
    // ==========================================
    // 3. DESKTOP MUSIC TABLE (Spotify / Apple Music Style)
    // ==========================================
    private var desktopLibraryTableView: some View {
        VStack(spacing: 0) {
            // Table Header Row
            HStack(spacing: 12) {
                Text("#")
                    .frame(width: 36, alignment: .center)
                Text("TITLE")
                    .frame(minWidth: 200, alignment: .leading)
                Text("ARTIST")
                    .frame(minWidth: 150, alignment: .leading)
                Text("ALBUM")
                    .frame(minWidth: 150, alignment: .leading)
                Text("FORMAT")
                    .frame(width: 80, alignment: .center)
                Spacer()
                Text("DURATION")
                    .frame(width: 70, alignment: .trailing)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(vm.currentTheme.textMuted)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.20))
            
            Divider()
                .background(vm.currentTheme.outline.opacity(0.12))
            
            // Scrollable Track Rows
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(Array(filteredTracks.enumerated()), id: \.element.id) { index, track in
                        desktopTrackRow(index: index + 1, track: track)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func desktopTrackRow(index: Int, track: TrackMetadata) -> some View {
        let isCurrent = engine.currentTrack?.path == track.path
        let isHovered = vm.hoveredTrackPath == track.path
        
        return Button(action: {
            engine.play(track: track)
        }) {
            HStack(spacing: 12) {
                // Index or Waveform icon
                ZStack {
                    if isCurrent && engine.isPlaying && !engine.isPaused {
                        Image(systemName: "waveform")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.currentTheme.primary)
                    } else if isHovered {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                    }
                }
                .frame(width: 36, alignment: .center)
                
                // Title
                Text(track.title)
                    .font(.system(size: 13, weight: isCurrent ? .bold : .medium))
                    .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                    .lineLimit(1)
                    .frame(minWidth: 200, alignment: .leading)
                
                // Artist
                Text(track.artist)
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .lineLimit(1)
                    .frame(minWidth: 150, alignment: .leading)
                
                // Album
                Text(track.album)
                    .font(.system(size: 12))
                    .foregroundColor(vm.currentTheme.textMuted)
                    .lineLimit(1)
                    .frame(minWidth: 150, alignment: .leading)
                
                // Format Chip
                Text(track.path.hasSuffix(".flac") ? "FLAC" : "WAV")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(4)
                    .frame(width: 80, alignment: .center)
                
                Spacer()
                
                // Duration
                Text(vm.formatTime(track.durationSeconds))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.35) : (isHovered ? Color.white.opacity(0.06) : Color.clear))
            )
            .contentShape(Rectangle()) // Entire row intercepts clicks!
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            vm.hoveredTrackPath = hovering ? track.path : nil
        }
        .contextMenu {
            Button("Play Now") { engine.play(track: track) }
            Button("Show in Finder") {
                NSWorkspace.shared.selectFile(track.path, inFileViewerRootedAtPath: "")
            }
            Button("Copy File Path") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(track.path, forType: .string)
            }
        }
    }
    
    // ==========================================
    // 4. NOW PLAYING CANVAS (Spotify / Mobile Parity)
    // ==========================================
    private var nowPlayingCanvasView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Massive 340x340 Squircle Album Artwork with Dynamic Seed Glow
            ZStack {
                if let artwork = vm.currentArtwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 340, height: 340)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .shadow(color: vm.currentTheme.primary.opacity(0.40), radius: 36, x: 0, y: 16)
                } else {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [vm.currentTheme.surfaceContainerHigh, vm.currentTheme.surfaceContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 340, height: 340)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: vm.currentTheme.primary.opacity(0.25), radius: 30, x: 0, y: 14)
                    
                    VStack(spacing: 14) {
                        Image(systemName: "music.note")
                            .font(.system(size: 88))
                            .foregroundColor(vm.currentTheme.primary)
                        
                        if let track = engine.currentTrack {
                            Text(track.album.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .lineLimit(1)
                                .padding(.horizontal, 24)
                        }
                    }
                }
            }
            
            // Track Title & Artist
            VStack(spacing: 6) {
                Text(engine.currentTrack?.title ?? "No Track Selected")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                
                Text(subtitleText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vm.currentTheme.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 48)
            
            // Audio Chip Badge
            Text(formatBadgeText)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(vm.currentTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(vm.currentTheme.primaryContainer.opacity(0.35))
                .cornerRadius(12)
            
            // Precision Scrubber
            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { engine.currentTime },
                        set: { newValue in engine.seek(to: newValue) }
                    ),
                    in: 0...max(1.0, engine.totalDuration)
                )
                .accentColor(vm.currentTheme.primary)
                
                HStack {
                    Text(vm.formatTime(engine.currentTime))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                    Spacer()
                    Text(vm.formatTime(engine.totalDuration))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
            }
            .frame(maxWidth: 540)
            .padding(.horizontal, 48)
            
            // Media Controls Row
            HStack(spacing: 32) {
                InteractiveCircleButton(icon: "shuffle", size: 44, iconSize: 18, fg: vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted) {
                    vm.isShuffle.toggle()
                }
                
                InteractiveCircleButton(icon: "backward.fill", size: 52, iconSize: 18, bg: Color.white.opacity(0.10)) {
                    vm.playPreviousTrack()
                }
                
                // Giant Play/Pause FAB
                InteractiveCircleButton(
                    icon: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill",
                    size: 72,
                    iconSize: 28,
                    bg: vm.currentTheme.primary,
                    fg: vm.currentTheme.onPrimary
                ) {
                    engine.togglePlayPause()
                }
                
                InteractiveCircleButton(icon: "forward.fill", size: 52, iconSize: 18, bg: Color.white.opacity(0.10)) {
                    vm.playNextTrack()
                }
                
                InteractiveCircleButton(icon: "repeat", size: 44, iconSize: 18, fg: vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted) {
                    vm.isRepeat.toggle()
                }
            }
            
            // Volume Pill
            HStack {
                InteractiveCircleButton(icon: "minus", size: 32, iconSize: 12) {
                    vm.volumeDown()
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(vm.currentTheme.primary)
                    Text("\(vm.volumeDb) dBFS")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                }
                
                Spacer()
                
                InteractiveCircleButton(icon: "plus", size: 32, iconSize: 12) {
                    vm.volumeUp()
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 48)
            .frame(maxWidth: 260)
            .background(vm.currentTheme.primaryContainer.opacity(0.55))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
            )
            
            Spacer()
        }
    }
    
    // ==========================================
    // 5. QUEUE & SETTINGS VIEWS
    // ==========================================
    private var queuePlaylistView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Playback Queue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                Spacer()
                Text("\(vm.tracks.count) queued tracks")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(Array(vm.tracks.enumerated()), id: \.offset) { idx, track in
                        HStack {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                Text(track.artist)
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text(track.path.hasSuffix(".flac") ? "FLAC" : "WAV")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            engine.play(track: track)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var audioDevicesSettingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Audio Output & Hardware Settings")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("DETECTED COREAUDIO HARDWARE ENDPOINTS")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.primary)
                
                ForEach(engine.devices) { dev in
                    Button(action: { engine.selectDevice(id: dev.id) }) {
                        HStack {
                            Image(systemName: dev.isUsb ? "cable.connector" : "speaker.wave.2")
                                .foregroundColor(vm.currentTheme.primary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dev.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                Text(dev.isUsb ? "External USB DAC (Direct UAC2 Transport)" : "Internal Apple Silicon CoreAudio Endpoint")
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            if dev.id == engine.selectedDeviceId {
                                HStack(spacing: 6) {
                                    Text("ACTIVE")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .foregroundColor(vm.currentTheme.primary)
                            }
                        }
                        .padding(12)
                        .background(dev.id == engine.selectedDeviceId ? vm.currentTheme.primaryContainer.opacity(0.35) : Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(20)
            .background(vm.currentTheme.surfaceContainer)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // ==========================================
    // 6. PERSISTENT BOTTOM PLAYER BAR (Spotify Standard)
    // ==========================================
    private var persistentBottomPlayerBar: some View {
        HStack(spacing: 16) {
            // LEFT: Thumbnail & Title (Click to open Now Playing)
            Button(action: { vm.activeTab = .nowPlaying }) {
                HStack(spacing: 12) {
                    ZStack {
                        if let art = vm.currentArtwork {
                            Image(nsImage: art)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "music.note")
                                .foregroundColor(vm.currentTheme.primary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(engine.currentTrack?.title ?? "tsrossa Bit-Perfect")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(engine.currentTrack?.artist ?? "Ready")
                                .font(.system(size: 11))
                                .foregroundColor(vm.currentTheme.textSecondary)
                                .lineLimit(1)
                            
                            if engine.currentTrack != nil {
                                Text("•  FLAC DIRECT")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(vm.currentTheme.primary)
                            }
                        }
                    }
                }
                .frame(width: 240, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // CENTER: Transport Controls & Scrubber Slider
            VStack(spacing: 4) {
                HStack(spacing: 20) {
                    InteractiveCircleButton(icon: "shuffle", size: 30, iconSize: 13, fg: vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted) {
                        vm.isShuffle.toggle()
                    }
                    
                    InteractiveCircleButton(icon: "backward.fill", size: 34, iconSize: 14) {
                        vm.playPreviousTrack()
                    }
                    
                    InteractiveCircleButton(
                        icon: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill",
                        size: 42,
                        iconSize: 18,
                        bg: vm.currentTheme.primary,
                        fg: vm.currentTheme.onPrimary
                    ) {
                        engine.togglePlayPause()
                    }
                    
                    InteractiveCircleButton(icon: "forward.fill", size: 34, iconSize: 14) {
                        vm.playNextTrack()
                    }
                    
                    InteractiveCircleButton(icon: "repeat", size: 30, iconSize: 13, fg: vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted) {
                        vm.isRepeat.toggle()
                    }
                }
                
                // Scrubber Bar
                HStack(spacing: 8) {
                    Text(vm.formatTime(engine.currentTime))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 44, alignment: .trailing)
                    
                    Slider(
                        value: Binding(
                            get: { engine.currentTime },
                            set: { newValue in engine.seek(to: newValue) }
                        ),
                        in: 0...max(1.0, engine.totalDuration)
                    )
                    .accentColor(vm.currentTheme.primary)
                    .frame(maxWidth: 380)
                    
                    Text(vm.formatTime(engine.totalDuration))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 44, alignment: .leading)
                }
            }
            
            Spacer()
            
            // RIGHT: Volume Pill & Now Playing Toggle
            HStack(spacing: 12) {
                // Volume Capsule
                HStack(spacing: 6) {
                    InteractiveCircleButton(icon: "minus", size: 26, iconSize: 10) {
                        vm.volumeDown()
                    }
                    
                    Text("\(vm.volumeDb) dBFS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                        .frame(width: 60)
                    
                    InteractiveCircleButton(icon: "plus", size: 26, iconSize: 10) {
                        vm.volumeUp()
                    }
                }
                .padding(.horizontal, 6)
                .frame(height: 36)
                .background(vm.currentTheme.primaryContainer.opacity(0.40))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                )
                
                // Expand to Now Playing
                InteractiveCircleButton(icon: vm.activeTab == .nowPlaying ? "rectangle.compress.vertical" : "rectangle.expand.vertical", size: 36, iconSize: 14) {
                    vm.activeTab = (vm.activeTab == .nowPlaying) ? .library : .nowPlaying
                }
            }
            .frame(width: 240, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(vm.currentTheme.surfaceContainer.opacity(0.95))
        .overlay(
            Rectangle()
                .fill(vm.currentTheme.outline.opacity(0.18))
                .frame(height: 1),
            alignment: .top
        )
    }
    
    // ==========================================
    // HELPERS
    // ==========================================
    private var subtitleText: String {
        if let track = engine.currentTrack {
            return "\(track.artist)  •  \(track.album)"
        }
        return "Select a track to start playback"
    }
    
    private var formatBadgeText: String {
        if let track = engine.currentTrack {
            let fmt = track.path.hasSuffix(".flac") ? "FLAC" : "WAV"
            return "\(fmt)  •  \(String(format: "%.1f", Double(track.sampleRate) / 1000.0)) kHz  •  \(track.bitDepth)-BIT HARDWARE CHIP"
        }
        return "FLAC  •  BIT-PERFECT DIRECT AUDIO"
    }
}
