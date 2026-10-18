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
    @Published public var currentFolder: String = "Click 'Choose Music Folder' to begin"
    @Published public var copiedTelemetry: Bool = false
    @Published public var volumeDb: Int = 0 // 0 dBFS unity gain
    @Published public var isShuffle: Bool = false
    @Published public var isRepeat: Bool = false
    @Published public var sortMode: String = "DATE (NEWEST)"
    
    // Material 3 Dynamic Theming & Artwork State
    @Published public var currentArtwork: NSImage? = nil
    @Published public var currentTheme: DynamicMaterialTheme = .defaultTheme
    
    public func updateThemeForTrack(track: TrackMetadata) {
        ArtworkExtractor.loadArtworkAndTheme(for: track.path) { [weak self] artwork, theme in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 0.45)) {
                self.currentArtwork = artwork
                self.currentTheme = theme
            }
        }
    }
}
