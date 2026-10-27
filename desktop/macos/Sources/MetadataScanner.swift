import Foundation
import AVFoundation

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
                var album = fileURL.deletingLastPathComponent().lastPathComponent
                var duration = 0.0
                
                // Default heuristic parsing from filename
                if filename.contains(" - ") {
                    let parts = filename.components(separatedBy: " - ")
                    if parts.count >= 2 {
                        artist = parts[0].trimmingCharacters(in: .whitespaces)
                        title = parts[1].trimmingCharacters(in: .whitespaces)
                    }
                }
                
                // Probe real AVAsset tags
                let asset = AVURLAsset(url: fileURL)
                let dur = CMTimeGetSeconds(asset.duration)
                if !dur.isNaN && dur > 0 {
                    duration = dur
                }
                
                for item in asset.metadata {
                    guard let key = item.commonKey else { continue }
                    if key == .commonKeyTitle, let val = item.stringValue, !val.isEmpty {
                        title = val
                    } else if key == .commonKeyArtist, let val = item.stringValue, !val.isEmpty {
                        artist = val
                    } else if key == .commonKeyAlbumName, let val = item.stringValue, !val.isEmpty {
                        album = val
                    }
                }
                
                let track = TrackMetadata(
                    path: fileURL.path,
                    title: title,
                    artist: artist,
                    album: album,
                    sampleRate: 44100,
                    bitDepth: 16,
                    channels: 2,
                    durationSeconds: duration
                )
                tracks.append(track)
            }
        }
        
        return tracks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}
