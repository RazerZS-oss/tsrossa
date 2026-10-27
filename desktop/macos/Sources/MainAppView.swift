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
            // Material You Dynamic Ambient Background
            LinearGradient(
                colors: [vm.currentTheme.surfaceContainerLowest, vm.currentTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: vm.currentTheme)
            
            VStack(spacing: 0) {
                // 1. TOP HEADER (tsrossa ● Bit-Perfect + Quick Action Icons)
                topHeaderView
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
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
                
                // 3. FLOATING MINI-PLAYER (when on Library or Playlist and playing)
                if vm.activeTab != .nowPlaying && engine.currentTrack != nil {
                    floatingMiniPlayer
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
                
                // 4. AUTHENTIC MATERIAL 3 BOTTOM NAVIGATION BAR
                bottomNavigationBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            
            // SYSTEM LOGS MODAL OVERLAY
            if vm.showTelemetry {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minWidth: 480, idealWidth: 540, minHeight: 840, idealHeight: 890)
        .onAppear {
            loadInitialMusicDirectory()
        }
    }
    
    // ==========================================
    // TOP HEADER (Matching Screenshots 1 & 2)
    // ==========================================
    private var topHeaderView: some View {
        HStack {
            HStack(spacing: 8) {
                Text("tsrossa")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                
                Circle()
                    .fill(TsrossaColors.bitPerfectGold)
                    .frame(width: 8, height: 8)
                
                Text("Bit-Perfect")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
            
            Spacer()
            
            // 4 Circular Quick Action Buttons
            HStack(spacing: 12) {
                headerCircleButton(icon: "waveform.path.ecg") {
                    engine.updateTelemetry()
                    vm.showTelemetry = true
                }
                
                headerCircleButton(icon: "arrow.clockwise") {
                    openFolderPicker()
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
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(vm.currentTheme.textSecondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ==========================================
    // NOW PLAYING VIEW (Material You Dynamic)
    // ==========================================
    private var nowPlayingView: some View {
        VStack(spacing: 20) {
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
                        .shadow(color: vm.currentTheme.primary.opacity(0.35), radius: 30, x: 0, y: 14)
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
            .padding(.top, 10)
            
            // Track Title & Artist
            VStack(spacing: 6) {
                Text(engine.currentTrack?.title ?? "No Track Selected")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(vm.currentTheme.textPrimary)
                    .lineLimit(1)
                
                Text(subtitleText)
                    .font(.system(size: 15, weight: .medium))
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
                    Text(formatTime(engine.currentTime))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(vm.currentTheme.textSecondary)
                    Spacer()
                    Text(formatTime(engine.totalDuration))
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
            
            // Media Controls (Shuffle, Prev, Play/Pause, Next, Repeat)
            HStack(spacing: 28) {
                // Shuffle
                Button(action: { vm.isShuffle.toggle() }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 18))
                        .foregroundColor(vm.isShuffle ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Previous
                Button(action: playPreviousTrack) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 52, height: 52)
                        Image(systemName: "backward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Large Play/Pause Dynamic Accent Button
                Button(action: { engine.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(vm.currentTheme.primary)
                            .frame(width: 72, height: 72)
                            .shadow(color: vm.currentTheme.primary.opacity(0.42), radius: 14, x: 0, y: 6)
                        
                        Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(vm.currentTheme.onPrimary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Next
                Button(action: playNextTrack) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 52, height: 52)
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(vm.currentTheme.textPrimary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Repeat
                Button(action: { vm.isRepeat.toggle() }) {
                    Image(systemName: "repeat")
                        .font(.system(size: 18))
                        .foregroundColor(vm.isRepeat ? vm.currentTheme.primary : vm.currentTheme.textMuted)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Volume Pill & Queue Row (Material You Dynamic Tones)
            HStack(spacing: 12) {
                // Wide Volume Pill
                HStack {
                    Button(action: { vm.volumeDb = max(-60, vm.volumeDb - 1) }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                    
                    Button(action: { vm.volumeDb = min(0, vm.volumeDb + 1) }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(vm.currentTheme.textPrimary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
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
                }
                .buttonStyle(PlainButtonStyle())
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
                
                Button(action: openFolderPicker) {
                    Image(systemName: "folder")
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { loadInitialMusicDirectory() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.35))
            .cornerRadius(24)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Filter / Count Row
            HStack {
                Button(action: toggleSort) {
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
                }
                .buttonStyle(PlainButtonStyle())
                
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
                
                // More Options / Star
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 14))
                        .foregroundColor(vm.currentTheme.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(10)
            .background(isCurrent ? vm.currentTheme.primaryContainer.opacity(0.28) : Color.clear)
            .cornerRadius(12)
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
                        .font(.system(size: 16))
                        .foregroundColor(vm.currentTheme.onPrimary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(vm.currentTheme.surfaceContainerHigh)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(vm.currentTheme.outline.opacity(0.25), lineWidth: 1)
        )
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
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
                }
                .frame(height: 28)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? vm.currentTheme.primary : vm.currentTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ==========================================
    // PLAYLIST & SETTINGS VIEWS
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
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var settingsView: some View {
        VStack(spacing: 20) {
            Text("Audio Output & Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(vm.currentTheme.textPrimary)
                .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("OUTPUT DEVICE SELECTION")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.currentTheme.primary)
                
                ForEach(engine.devices) { dev in
                    Button(action: { engine.selectDevice(id: dev.id) }) {
                        HStack {
                            Image(systemName: dev.isUsb ? "cable.connector" : "speaker.wave.2")
                                .foregroundColor(vm.currentTheme.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dev.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(vm.currentTheme.textPrimary)
                                Text(dev.isUsb ? "External USB DAC (UAC2)" : "Internal CoreAudio Output")
                                    .font(.system(size: 11))
                                    .foregroundColor(vm.currentTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            if dev.id == engine.selectedDeviceId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(vm.currentTheme.primary)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
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
    
    private func playNextTrack() {
        guard let current = engine.currentTrack, let idx = vm.tracks.firstIndex(where: { $0.path == current.path }) else {
            if let first = vm.tracks.first { engine.play(track: first) }
            return
        }
        let nextIdx = (idx + 1) % vm.tracks.count
        engine.play(track: vm.tracks[nextIdx])
    }
    
    private func playPreviousTrack() {
        guard let current = engine.currentTrack, let idx = vm.tracks.firstIndex(where: { $0.path == current.path }) else {
            return
        }
        let prevIdx = (idx - 1 + vm.tracks.count) % vm.tracks.count
        engine.play(track: vm.tracks[prevIdx])
    }
    
    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Music Directory"
        
        if panel.runModal() == .OK, let url = panel.url {
            vm.currentFolder = url.path
            vm.tracks = MetadataScanner.scanDirectory(url: url)
        }
    }
    
    private func loadInitialMusicDirectory() {
        let defaultMusicUrl = URL(fileURLWithPath: "/Users/alen/Music/Music")
        if FileManager.default.fileExists(atPath: defaultMusicUrl.path) {
            vm.currentFolder = defaultMusicUrl.path
            vm.tracks = MetadataScanner.scanDirectory(url: defaultMusicUrl)
            if let first = vm.tracks.first, engine.currentTrack == nil {
                engine.currentTrack = first
                vm.updateThemeForTrack(track: first)
            }
        }
    }
    
    private func toggleSort() {
        if vm.sortMode == "DATE (NEWEST)" {
            vm.sortMode = "A-Z TITLE"
            vm.tracks.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        } else {
            vm.sortMode = "DATE (NEWEST)"
            vm.tracks.reverse()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
