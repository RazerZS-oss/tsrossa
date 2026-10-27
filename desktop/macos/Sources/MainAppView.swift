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
            // Background
            TsrossaColors.deepNavy.ignoresSafeArea()
            
            HStack(spacing: 0) {
                // Left Panel: Library Browser
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("tsrossa")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .foregroundColor(TsrossaColors.audiophileCyan)
                            Text("BIT-PERFECT MACOS EDITION")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(TsrossaColors.terminalGreen)
                        }
                        
                        Spacer()
                        
                        Button(action: openFolderPicker) {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                Text("Choose Folder")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(TsrossaColors.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(TsrossaColors.textSecondary)
                        TextField("Search tracks, artists...", text: $vm.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(TsrossaColors.textPrimary)
                            .font(.system(size: 13))
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    
                    Text("FOLDER: \(vm.currentFolder)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(TsrossaColors.textMuted)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                    
                    // Track List
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(filteredTracks) { track in
                                trackRow(track: track)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(width: 360)
                .background(Color.black.opacity(0.25))
                
                Divider()
                    .background(Color.white.opacity(0.08))
                
                // Right Panel: Now Playing Screen
                VStack(spacing: 24) {
                    // Header Bar with Device Selector & Logs
                    HStack {
                        // Device Selector
                        Menu {
                            ForEach(engine.devices) { dev in
                                Button(action: { engine.selectDevice(id: dev.id) }) {
                                    HStack {
                                        Text(dev.name + (dev.isUsb ? " (USB DAC)" : ""))
                                        if dev.id == engine.selectedDeviceId {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(TsrossaColors.audiophileCyan)
                                Text(selectedDeviceName)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(TsrossaColors.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9))
                                    .foregroundColor(TsrossaColors.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassmorphic(cornerRadius: 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Volume Pill (0.0 dB Bit-Perfect)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(TsrossaColors.terminalGreen)
                                .frame(width: 6, height: 6)
                            Text("BIT-PERFECT 0.0 dB")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundColor(TsrossaColors.terminalGreen)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        
                        // [LOGS] button
                        Button(action: {
                            engine.updateTelemetry()
                            vm.showTelemetry = true
                        }) {
                            Text("[ LOGS ]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(TsrossaColors.audiophileCyan)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Album Art Display Card
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [TsrossaColors.surfaceHigh, TsrossaColors.surfaceContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 240, height: 240)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(TsrossaColors.audiophileCyan.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: TsrossaColors.audiophileCyan.opacity(0.15), radius: 20, x: 0, y: 10)
                            
                            VStack(spacing: 12) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 64))
                                    .foregroundColor(TsrossaColors.audiophileCyan)
                                
                                if let track = engine.currentTrack {
                                    Text(track.path.hasSuffix(".flac") ? "FLAC AUDIO" : "WAV AUDIO")
                                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                        .foregroundColor(TsrossaColors.terminalGreen)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    // Track Info
                    VStack(spacing: 6) {
                        Text(engine.currentTrack?.title ?? "No Track Playing")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(TsrossaColors.textPrimary)
                            .lineLimit(1)
                        
                        Text(engine.currentTrack?.artist ?? "Select a track from the library")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(TsrossaColors.textSecondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 32)
                    
                    // Seek Bar & Timers
                    VStack(spacing: 6) {
                        Slider(
                            value: Binding(
                                get: { engine.currentTime },
                                set: { newValue in engine.seek(to: newValue) }
                            ),
                            in: 0...max(1.0, engine.totalDuration)
                        )
                        .accentColor(TsrossaColors.audiophileCyan)
                        
                        HStack {
                            Text(formatTime(engine.currentTime))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(TsrossaColors.textSecondary)
                            Spacer()
                            Text(formatTime(engine.totalDuration))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(TsrossaColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 48)
                    
                    // Tactile Controls
                    HStack(spacing: 28) {
                        Button(action: playPreviousTrack) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 20))
                                .foregroundColor(TsrossaColors.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { engine.togglePlayPause() }) {
                            ZStack {
                                Circle()
                                    .fill(TsrossaColors.audiophileCyan)
                                    .frame(width: 58, height: 58)
                                    .shadow(color: TsrossaColors.audiophileCyan.opacity(0.4), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: engine.isPlaying && !engine.isPaused ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.black)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: playNextTrack) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 20))
                                .foregroundColor(TsrossaColors.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.bottom, 24)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            // Telemetry Modal Overlay
            if vm.showTelemetry {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture { vm.showTelemetry = false }
                
                TelemetryModalView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minWidth: 920, minHeight: 620)
        .onAppear {
            loadInitialMusicDirectory()
        }
    }
    
    private var selectedDeviceName: String {
        if let dev = engine.devices.first(where: { $0.id == engine.selectedDeviceId }) {
            return dev.name
        }
        return "Select Output Device"
    }
    
    private func trackRow(track: TrackMetadata) -> some View {
        let isSelected = engine.currentTrack?.path == track.path
        return Button(action: { engine.play(track: track) }) {
            HStack(spacing: 12) {
                Image(systemName: isSelected && engine.isPlaying ? "waveform" : "music.note")
                    .foregroundColor(isSelected ? TsrossaColors.terminalGreen : TsrossaColors.textMuted)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? TsrossaColors.terminalGreen : TsrossaColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(track.artist)
                        .font(.system(size: 11))
                        .foregroundColor(TsrossaColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(track.path.hasSuffix(".flac") ? "FLAC" : "WAV")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(TsrossaColors.audiophileCyan)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white.opacity(0.08) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
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
        }
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
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
