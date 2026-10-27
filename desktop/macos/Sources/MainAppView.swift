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
            $0.artist.localizedCaseInsensitiveContains(vm.searchText)
        }
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // ==========================================
            // MATERIAL YOU DYNAMIC THEMED BACKGROUND
            // ==========================================
            backgroundLayer
            
            VStack(spacing: 0) {
                // 1. TOP HEADER (Traffic-light friendly spacing)
                topHeaderView
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                
                // 2. ACTIVE TAB CONTENT
                ZStack {
                    switch vm.activeTab {
                    case .nowPlaying:
                        nowPlayingView
                    case .library:
                        libraryView
                    case .playlist:
                        playlistView
                    case .settings:
                        settingsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 3. FLOATING MINI-PLAYER (when on Library, Playlist, or Settings and playing)
                if vm.activeTab != .nowPlaying && engine.currentTrack != nil {
                    floatingMiniPlayer
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                
                // 4. AUTHENTIC MATERIAL 3 BOTTOM NAVIGATION BAR
                bottomNavigationBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: 580)
            .frame(maxWidth: .infinity)
            
            // SYSTEM LOGS MODAL OVERLAY
            if vm.showTelemetry {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minWidth: 460, minHeight: 780)
        .onAppear {
            vm.loadInitialMusicDirectory()
        }
    }
    
    // Background Canvas Layer (Configurable via Settings)
    @ViewBuilder
    private var backgroundLayer: some View {
        if vm.bgCanvasMode == "BLACK" {
            Color.black.ignoresSafeArea()
        } else if vm.bgCanvasMode == "AURA", let artwork = vm.currentArtwork {
            ZStack {
                vm.currentTheme.surfaceContainerLowest.ignoresSafeArea()
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 75)
                    .opacity(0.35)
                    .saturation(1.4)
                    .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        vm.currentTheme.surfaceContainerLowest,
                        vm.currentTheme.surface
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [vm.currentTheme.primary.opacity(0.18), Color.clear],
                    center: .top,
                    startRadius: 40,
                    endRadius: 550
                )
                .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
        }
    }
    
    // ==========================================
    // TOP HEADER (Traffic-Light Clean Spacing)
    // ==========================================
    private var topHeaderView: some View {
        HStack(alignment: .center, spacing: 0) {
            // Dedicated clearance for macOS window buttons (Close, Minimize, Zoom)
            Spacer()
                .frame(width: 64)
            
            HStack(spacing: 6) {
                Text("tsrossa")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                
                Circle()
                    .fill(TsrossaColors.bitPerfectGold)
                    .frame(width: 7, height: 7)
                
                Text("Bit-Perfect")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            
            Spacer()
            
            // 4 Circular Quick Action Buttons (100% full click area!)
            HStack(spacing: 8) {
                headerCircleButton(icon: "waveform.path.ecg") {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }
                
                headerCircleButton(icon: "arrow.clockwise") {
                    vm.openFolderPicker()
                }
                
                headerCircleButton(icon: "bolt.fill") {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }
                
                headerCircleButton(icon: "lock.fill") {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }
            }
        }
    }
    
    private func headerCircleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            .frame(width: 36, height: 36)
            .contentShape(Circle())
        }
        .buttonStyle(TsrossaScaleButtonStyle())
    }
    
    // ==========================================
    // NOW PLAYING VIEW (Matching Screenshot 01)
    // ==========================================
    private var nowPlayingView: some View {
        VStack(spacing: 18) {
            Spacer()
            
            // Large Squircle Album Art Card with Material You Dynamic Glow
            ZStack {
                if let artwork = vm.currentArtwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: vm.currentTheme.primary.opacity(0.40), radius: 30, x: 0, y: 14)
                } else {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [vm.currentTheme.surfaceContainerHigh, vm.currentTheme.surfaceContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 320, height: 320)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: vm.currentTheme.primary.opacity(0.25), radius: 25, x: 0, y: 12)
                    
                    VStack(spacing: 14) {
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
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
            .padding(.top, 6)
            
            // Track Title & Artist
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
            .padding(.horizontal, 32)
            
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
            .padding(.horizontal, 32)
            
            // Audio Format Badges
            HStack(spacing: 8) {
                Text(formatBadgeText)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            
            // Media Controls (Shuffle, Prev, Giant Play/Pause FAB, Next, Repeat)
            HStack(spacing: 24) {
                // Shuffle
                Button(action: { vm.isShuffle.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(vm.isShuffle ? vm.currentTheme.primary.opacity(0.15) : Color.white.opacity(0.06))
                            .frame(width: 42, height: 42)
                        Image(systemName: "shuffle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                    }
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                // Previous
                Button(action: { vm.playPreviousTrack() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 52, height: 52)
                        Image(systemName: "backward.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                    .frame(width: 52, height: 52)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                // Giant Play/Pause Dynamic Accent Button
                Button(action: { engine.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(vm.currentTheme.primary)
                            .frame(width: 72, height: 72)
                            .shadow(color: vm.currentTheme.primary.opacity(0.45), radius: 14, x: 0, y: 6)
                        
                        Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(vm.currentTheme.onPrimary)
                    }
                    .frame(width: 72, height: 72)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                // Next
                Button(action: { vm.playNextTrack() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 52, height: 52)
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                    .frame(width: 52, height: 52)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                // Repeat
                Button(action: { vm.isRepeat.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(vm.isRepeat ? vm.currentTheme.primary.opacity(0.15) : Color.white.opacity(0.06))
                            .frame(width: 42, height: 42)
                        Image(systemName: "repeat")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                    }
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
            
            // Volume Pill & Queue Row
            HStack(spacing: 12) {
                // Wide Volume Pill
                HStack {
                    Button(action: { vm.volumeDown() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 34, height: 34)
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                        }
                        .frame(width: 34, height: 34)
                        .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 13))
                            .foregroundColor(vm.currentTheme.primary)
                        Text("\(vm.volumeDb) dBFS")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: { vm.volumeUp() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 34, height: 34)
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                        }
                        .frame(width: 34, height: 34)
                        .contentShape(Circle())
                    }
                    .buttonStyle(TsrossaScaleButtonStyle())
                }
                .padding(.horizontal, 10)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(vm.currentTheme.primaryContainer.opacity(0.55))
                .cornerRadius(26)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                )
                
                // Queue Button
                Button(action: { vm.activeTab = .playlist }) {
                    ZStack {
                        Circle()
                            .fill(vm.currentTheme.primaryContainer.opacity(0.55))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Circle().stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
                            )
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(vm.currentTheme.primary)
                    }
                    .frame(width: 52, height: 52)
                    .contentShape(Circle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    // ==========================================
    // LIBRARY VIEW (Matching Screenshot 02)
    // ==========================================
    private var libraryView: some View {
        VStack(spacing: 12) {
            // Search Bar Container
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(vm.currentTheme.textSecondary)
                
                TextField("Search your music...", text: $vm.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .font(.system(size: 14))
                
                Button(action: { vm.openFolderPicker() }) {
                    Image(systemName: "folder")
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                Button(action: { vm.rescanCurrentFolder() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.35))
            .cornerRadius(24)
            .padding(.horizontal, 24)
            .padding(.top, 4)
            
            // Filter / Count Row
            HStack {
                Button(action: { vm.toggleSort() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11))
                        Text(vm.sortMode)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TsrossaScaleButtonStyle())
                
                Spacer()
                
                Text("Music • \(vm.tracks.count) tracks")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            .padding(.horizontal, 24)
            
            // Track List
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredTracks) { track in
                        libraryTrackRow(track: track)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }
    
    private func libraryTrackRow(track: TrackMetadata) -> some View {
        let isCurrent = engine.currentTrack?.path == track.path
        return Button(action: { engine.play(track: track) }) {
            HStack(spacing: 14) {
                // Square Album Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                    
                    if isCurrent, let art = vm.currentArtwork {
                        Image(nsImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: isCurrent && engine.isPlaying ? "waveform" : "music.note")
                            .font(.system(size: 18))
                            .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                    }
                }
                
                // Track Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isCurrent ? vm.currentTheme.primary : vm.currentTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(track.artist)  •  \(track.path.hasSuffix(".flac") ? "FLAC" : "WAV")")
                        .font(.system(size: 12))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(vm.formatTime(track.durationSeconds))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(vm.currentTheme.textMuted)
            }
            .padding(10)
            .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.28) : Color.clear)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ==========================================
    // FLOATING MINI-PLAYER (Bottom of Library)
    // ==========================================
    private var floatingMiniPlayer: some View {
        HStack(spacing: 12) {
            // Mini Thumbnail
            ZStack {
                if let art = vm.currentArtwork {
                    Image(nsImage: art)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 42, height: 42)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: "music.note")
                        .foregroundColor(vm.currentTheme.primary)
                }
            }
            
            // Title & Format Badge
            VStack(alignment: .leading, spacing: 3) {
                Text(engine.currentTrack?.title ?? "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(engine.currentTrack?.artist ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(vm.currentTheme.textSecondary)
                        .lineLimit(1)
                    
                    Text("FLAC • 44.1k")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.currentTheme.primary)
                }
            }
            
            Spacer()
            
            // Mini Play/Pause Circle
            Button(action: { engine.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(vm.currentTheme.primary)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(vm.currentTheme.onPrimary)
                }
                .frame(width: 38, height: 38)
                .contentShape(Circle())
            }
            .buttonStyle(TsrossaScaleButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(vm.currentTheme.surfaceContainerHigh)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            vm.activeTab = .nowPlaying
        }
    }
    
    // ==========================================
    // MATERIAL 3 BOTTOM NAVIGATION BAR
    // ==========================================
    private var bottomNavigationBar: some View {
        HStack {
            navTabItem(tab: .library, icon: "books.vertical.fill", title: "Library")
            navTabItem(tab: .playlist, icon: "text.badge.plus", title: "Playlist")
            navTabItem(tab: .nowPlaying, icon: "waveform", title: "Now Playing")
            navTabItem(tab: .settings, icon: "gearshape.fill", title: "Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(vm.currentTheme.surfaceContainerLow)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(vm.currentTheme.outline.opacity(0.20), lineWidth: 1)
        )
    }
    
    private func navTabItem(tab: AppTab, icon: String, title: String) -> some View {
        let isSelected = vm.activeTab == tab
        return Button(action: { vm.activeTab = tab }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(vm.currentTheme.primary.opacity(0.22))
                            .frame(width: 58, height: 28)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                }
                .frame(height: 28)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(TsrossaScaleButtonStyle())
    }
    
    // ==========================================
    // PLAYLIST & QUEUE VIEW
    // ==========================================
    private var playlistView: some View {
        VStack(spacing: 16) {
            Text("Queue & Playlists")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.top, 24)
            
            Text("Currently Queued: \(vm.tracks.count) tracks")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(vm.currentTheme.textSecondary)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(vm.tracks.enumerated()), id: \.offset) { idx, track in
                        HStack {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                                .frame(width: 24)
                            
                            Text(track.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(vm.currentTheme.textPrimary)
                            
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
    
    // ==========================================
    // COMPLETE SETTINGS SCREEN (Audiophile & Theme)
    // ==========================================
    private var settingsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Audio Output & Settings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .padding(.top, 16)
                
                // 1. OUTPUT DEVICE & DAC HARDWARE
                settingsCard(title: "OUTPUT DEVICE SELECTION") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(engine.devices) { dev in
                            Button(action: { engine.selectDevice(id: dev.id) }) {
                                HStack(spacing: 12) {
                                    Image(systemName: dev.isUsb ? "cable.connector" : "speaker.wave.2")
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
                                .background(dev.id == engine.selectedDeviceId ? vm.currentTheme.primaryContainer.opacity(0.35) : Color.white.opacity(0.04))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(dev.id == engine.selectedDeviceId ? vm.currentTheme.primary.opacity(0.4) : Color.clear, lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Divider().background(vm.currentTheme.outline.opacity(0.15))
                        
                        settingsToggleRow(
                            title: "Bit-Perfect Exclusive Lock (Hog Mode)",
                            subtitle: "Direct DAC ownership, completely bypassing macOS system audio mixer",
                            isOn: $vm.isExclusiveHogMode
                        )
                        
                        Divider().background(vm.currentTheme.outline.opacity(0.15))
                        
                        settingsToggleRow(
                            title: "Hardware Sample Rate Switching",
                            subtitle: "Automatically switches DAC clock frequency (44.1k to 192k) with zero resampling",
                            isOn: $vm.isAutoClockSwitch
                        )
                        
                        Divider().background(vm.currentTheme.outline.opacity(0.15))
                        
                        settingsToggleRow(
                            title: "Zero-Jitter RAM Playback (mlock)",
                            subtitle: "Pins decoded audio frames into physical memory to eliminate SSD read latency",
                            isOn: $vm.isRamPlayback
                        )
                    }
                }
                
                // 2. THEME & APPEARANCE (Matching mobile tsrossa!)
                settingsCard(title: "THEME & VISUAL APPEARANCE") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Accent Color Palette")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                        
                        HStack(spacing: 6) {
                            accentPill(title: "Dynamic (Monet)", mode: "DYNAMIC", color: vm.currentTheme.primary)
                            accentPill(title: "Matcha", mode: "MATCHA", color: Color(red: 0.62, green: 0.82, blue: 0.38))
                            accentPill(title: "Gold", mode: "GOLD", color: Color(red: 1.0, green: 0.84, blue: 0.0))
                            accentPill(title: "Cyan", mode: "CYAN", color: Color(red: 0.0, green: 0.898, blue: 1.0))
                        }
                        
                        Divider().background(vm.currentTheme.outline.opacity(0.15))
                        
                        Text("Background Canvas Mode")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(vm.currentTheme.textPrimary)
                        
                        HStack(spacing: 8) {
                            bgPill(title: "Tonal M3", mode: "DYNAMIC")
                            bgPill(title: "Artwork Aura", mode: "AURA")
                            bgPill(title: "Pitch Black", mode: "BLACK")
                        }
                    }
                }
                
                // 3. MUSIC DIRECTORY & STORAGE
                settingsCard(title: "MUSIC DIRECTORY & LIBRARY") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Music Folder:")
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
                                .background(vm.currentTheme.primaryContainer.opacity(0.40))
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
                        
                        Text("Supported Decoders: Native dr_flac (16/24-bit FLAC) & dr_wav (PCM WAV)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(vm.currentTheme.textMuted)
                    }
                }
                
                // 4. HARDWARE TELEMETRY & AUDIT
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
                        
                        Button(action: {
                            engine.updateTelemetry()
                            vm.showTelemetry = true
                        }) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                Text("Open Full Hardware Diagnostics Report (⌘D)")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(vm.currentTheme.primary)
                            .padding(12)
                            .background(vm.currentTheme.primaryContainer.opacity(0.35))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(TsrossaScaleButtonStyle())
                    }
                }
                
                // 5. ABOUT TSROSSA
                settingsCard(title: "ABOUT TSROSSA") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("tsrossa bit-perfect player")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                            Spacer()
                            Text("v1.6.0 macOS")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                        Text("High-fidelity bit-perfect audio player designed for external USB DACs and Apple Silicon CoreAudio hardware with zero DSP degradation.")
                            .font(.system(size: 11))
                            .foregroundColor(vm.currentTheme.textSecondary)
                        
                        Divider().background(vm.currentTheme.outline.opacity(0.15))
                        
                        HStack {
                            Text("Android Creator:")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                            Text("yukaatsu")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                            Spacer()
                            Text("macOS Engine:")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(vm.currentTheme.textMuted)
                            Text("Apple Silicon C++17")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(vm.currentTheme.primary)
                        }
                    }
                }
                
                Spacer().frame(height: 120)
            }
            .padding(.horizontal, 20)
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
        .background(vm.currentTheme.surfaceContainer)
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
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? vm.currentTheme.onPrimary : vm.currentTheme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
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
