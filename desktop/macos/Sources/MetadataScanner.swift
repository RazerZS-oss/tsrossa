import Foundation

public class MetadataScanner {
    public static func scanDirectory(url: URL) -> [TrackMetadata] {
        var tracks: [TrackMetadata] = []
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .nameKey]
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return tracks
        }
        
        for case let fileURL as URL in enumerator {
            let ext = fileURL.pathExtension.lowercased()
            if ext == "flac" || ext == "wav" {
                let filename = fileURL.deletingPathExtension().lastPathComponent
                var title = filename
                var artist = "Unknown Artist"
                
                // Parse common "Artist - Title" filename format
                if filename.contains(" - ") {
                    let parts = filename.components(separatedBy: " - ")
                    if parts.count >= 2 {
                        artist = parts[0].trimmingCharacters(in: .whitespaces)
                        title = parts[1].trimmingCharacters(in: .whitespaces)
                    }
                }
                
                // Use default or placeholder metadata if not yet probed
                let path = fileURL.path
                let track = TrackMetadata(
                    path: path,
                    title: title,
                    artist: artist,
                    album: fileURL.deletingLastPathComponent().lastPathComponent,
                    sampleRate: 44100,
                    bitDepth: 16,
                    channels: 2,
                    durationSeconds: 0.0
                )
                tracks.append(track)
            }
        }
        
        return tracks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}
