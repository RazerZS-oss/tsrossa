import Foundation
import Combine
import AppKit
import SwiftUI

public enum AppTab: String, CaseIterable {
    case library = "Library"
    case playlist = "Playlist"
    case nowPlaying = "Now Playing"
    case settings = "Settings"
}

public class AppViewModel: ObservableObject {
    public static let shared = AppViewModel()
    
    @Published public var activeTab: AppTab = .nowPlaying
    @Published public var tracks: [TrackMetadata] = []
    @Published public var searchText: String = ""
    @Published public var showTelemetry: Bool = false
    @Published public var currentFolder: String = "/Users/alen/Music/Music"
    @Published public var copiedTelemetry: Bool = false
    @Published public var volumeDb: Int = 0 // 0 dBFS unity gain
    @Published public var isShuffle: Bool = false
    @Published public var isRepeat: Bool = false
    @Published public var sortMode: String = "DATE (NEWEST)"
    
    // Material 3 Dynamic Theming & Artwork State
    @Published public var currentArtwork: NSImage? = nil
    @Published public var currentTheme: DynamicMaterialTheme = .defaultTheme
    
    // Audiophile & CoreAudio Engine Settings
    @Published public var isExclusiveHogMode: Bool = true
    @Published public var isAutoClockSwitch: Bool = true
    @Published public var isRamPlayback: Bool = true
    @Published public var keepScreenAwake: Bool = true
    @Published public var bufferProfile: String = "192ms Jitter Safe"
    
    // Appearance & Customization Settings
    @Published public var themeMode: String = "DARK" // DARK, OLED, LIGHT
    @Published public var bgCanvasMode: String = "DYNAMIC" // DYNAMIC, AURA, BLACK
    @Published public var accentColorMode: String = "DYNAMIC" // DYNAMIC, MATCHA, GOLD, CYAN
    
    private var keyMonitor: Any?
    
    public init() {
        setupKeyboardMonitor()
    }
    
    deinit {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    public func updateThemeForTrack(track: TrackMetadata) {
        ArtworkExtractor.loadArtworkAndTheme(for: track.path) { [weak self] artwork, theme in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 0.50)) {
                self.currentArtwork = artwork
                if self.accentColorMode == "DYNAMIC" {
                    self.currentTheme = theme
                }
            }
        }
    }
    
    public func setAccentColorMode(_ mode: String) {
        accentColorMode = mode
        withAnimation(.easeInOut(duration: 0.35)) {
            switch mode {
            case "ROSE":
                currentTheme = DynamicMaterialTheme(seedR: 1.0, seedG: 0.18, seedB: 0.33)
            case "MATCHA":
                currentTheme = DynamicMaterialTheme(seedR: 0.62, seedG: 0.82, seedB: 0.38)
            case "GOLD":
                currentTheme = DynamicMaterialTheme(seedR: 1.0, seedG: 0.84, seedB: 0.0)
            case "CYAN":
                currentTheme = DynamicMaterialTheme(seedR: 0.0, seedG: 0.90, seedB: 1.0)
            default: // DYNAMIC
                if let track = AudioEngine.shared.currentTrack {
                    updateThemeForTrack(track: track)
                } else {
                    currentTheme = DynamicMaterialTheme.defaultTheme
                }
            }
        }
    }
    
    public func playNextTrack() {
        guard !tracks.isEmpty else { return }
        if let current = AudioEngine.shared.currentTrack, let idx = tracks.firstIndex(where: { $0.path == current.path }) {
            let nextIdx: Int
            if isShuffle && tracks.count > 1 {
                var rand = Int.random(in: 0..<tracks.count)
                if rand == idx { rand = (idx + 1) % tracks.count }
                nextIdx = rand
            } else {
                nextIdx = (idx + 1) % tracks.count
            }
            AudioEngine.shared.play(track: tracks[nextIdx])
        } else if let first = tracks.first {
            AudioEngine.shared.play(track: first)
        }
    }
    
    public func playPreviousTrack() {
        guard !tracks.isEmpty else { return }
        if let current = AudioEngine.shared.currentTrack, let idx = tracks.firstIndex(where: { $0.path == current.path }) {
            let prevIdx = (idx - 1 + tracks.count) % tracks.count
            AudioEngine.shared.play(track: tracks[prevIdx])
        } else if let first = tracks.first {
            AudioEngine.shared.play(track: first)
        }
    }
    
    public func volumeUp() {
        volumeDb = min(0, volumeDb + 1)
    }
    
    public func volumeDown() {
        volumeDb = max(-60, volumeDb - 1)
    }
    
    public func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Music Directory"
        
        if panel.runModal() == .OK, let url = panel.url {
            currentFolder = url.path
            tracks = MetadataScanner.scanDirectory(url: url)
        }
    }
    
    public func rescanCurrentFolder() {
        let url = URL(fileURLWithPath: currentFolder)
        if FileManager.default.fileExists(atPath: url.path) {
            tracks = MetadataScanner.scanDirectory(url: url)
        }
    }
    
    public func loadInitialMusicDirectory() {
        let defaultMusicUrl = URL(fileURLWithPath: currentFolder)
        if FileManager.default.fileExists(atPath: defaultMusicUrl.path) {
            tracks = MetadataScanner.scanDirectory(url: defaultMusicUrl)
            if let first = tracks.first, AudioEngine.shared.currentTrack == nil {
                AudioEngine.shared.currentTrack = first
                updateThemeForTrack(track: first)
            }
        }
    }
    
    public func toggleSort() {
        if sortMode == "DATE (NEWEST)" {
            sortMode = "A-Z TITLE"
            tracks.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        } else if sortMode == "A-Z TITLE" {
            sortMode = "ARTIST"
            tracks.sort { $0.artist.localizedCaseInsensitiveCompare($1.artist) == .orderedAscending }
        } else {
            sortMode = "DATE (NEWEST)"
            tracks.reverse()
        }
    }
    
    public func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && seconds >= 0 else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // Desktop Keyboard Shortcut Monitor
    public func setupKeyboardMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            let firstResponder = NSApp.keyWindow?.firstResponder
            let isEditingText = firstResponder is NSTextView && (firstResponder as? NSTextView)?.isEditable == true
            
            let isCommand = event.modifierFlags.contains(.command)
            
            if isEditingText {
                if event.keyCode == 53 { // Escape
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    return nil
                }
                return event
            }
            
            if isCommand {
                switch event.keyCode {
                case 18: // Cmd + 1 -> Now Playing
                    self.activeTab = .nowPlaying
                    return nil
                case 19: // Cmd + 2 -> Library
                    self.activeTab = .library
                    return nil
                case 20: // Cmd + 3 -> Play Queue
                    self.activeTab = .playlist
                    return nil
                case 21: // Cmd + 4 -> Settings
                    self.activeTab = .settings
                    return nil
                case 2: // Cmd + D -> Diagnostics
                    self.showTelemetry.toggle()
                    return nil
                case 15: // Cmd + R -> Rescan
                    self.rescanCurrentFolder()
                    return nil
                case 1: // Cmd + S -> Shuffle
                    self.isShuffle.toggle()
                    return nil
                case 17: // Cmd + T -> Repeat
                    self.isRepeat.toggle()
                    return nil
                case 126: // Cmd + Up Arrow -> Volume Up
                    self.volumeUp()
                    return nil
                case 125: // Cmd + Down Arrow -> Volume Down
                    self.volumeDown()
                    return nil
                case 124: // Cmd + Right Arrow -> Next track
                    self.playNextTrack()
                    return nil
                case 123: // Cmd + Left Arrow -> Prev track
                    self.playPreviousTrack()
                    return nil
                default:
                    break
                }
            } else {
                switch event.keyCode {
                case 49: // Spacebar -> Play / Pause
                    AudioEngine.shared.togglePlayPause()
                    return nil
                case 124: // Right Arrow -> Next track
                    self.playNextTrack()
                    return nil
                case 123: // Left Arrow -> Prev track
                    self.playPreviousTrack()
                    return nil
                case 126: // Up Arrow -> Volume Up
                    self.volumeUp()
                    return nil
                case 125: // Down Arrow -> Volume Down
                    self.volumeDown()
                    return nil
                case 53: // Escape
                    if self.showTelemetry {
                        self.showTelemetry = false
                        return nil
                    }
                default:
                    break
                }
            }
            
            return event
        }
    }
}
