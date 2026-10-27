import Foundation
import AVFoundation

public class MetadataScanner {
    /// Ultra-fast pass (<5ms): enumerates FLAC/WAV files without blocking on AVURLAsset I/O.
    /// Explicitly skips Apple Music's `.musiclibrary` package to avoid unnecessary TCC database probes.
    public static func fastScanDirectory(url: URL) -> [TrackMetadata] {
        var tracks: [TrackMetadata] = []
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .nameKey, .isPackageKey]
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return tracks
        }
        
        for case let fileURL as URL in enumerator {
            let path = fileURL.path
            if path.contains(".musiclibrary") || path.contains("Automatically Add to Music") {
                enumerator.skipDescendants()
                continue
            }
            
            let ext = fileURL.pathExtension.lowercased()
            if ext == "flac" || ext == "wav" {
                let filename = fileURL.deletingPathExtension().lastPathComponent
                var title = filename
                var artist = "Unknown Artist"
                let album = fileURL.deletingLastPathComponent().lastPathComponent
                
                // Heuristic parsing from "Title - Artist" or "Artist - Title"
                if filename.contains(" - ") {
                    let parts = filename.components(separatedBy: " - ")
                    if parts.count >= 2 {
                        title = parts[0].trimmingCharacters(in: .whitespaces)
                        artist = parts[1].trimmingCharacters(in: .whitespaces)
                    }
                }
                
                let track = TrackMetadata(
                    path: path,
                    title: title,
                    artist: artist,
                    album: album,
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
    
    /// Background pass: enriches tracks with real duration and embedded FLAC/ID3 tags off the main thread.
    public static func enrichMetadataInBackground(tracks: [TrackMetadata], completion: @escaping ([TrackMetadata]) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var enriched: [TrackMetadata] = []
            enriched.reserveCapacity(tracks.count)
            
            for item in tracks {
                let fileURL = URL(fileURLWithPath: item.path)
                var title = item.title
                var artist = item.artist
                var album = item.album
                var duration = item.durationSeconds
                
                let asset = AVURLAsset(url: fileURL)
                let dur = CMTimeGetSeconds(asset.duration)
                if !dur.isNaN && dur > 0 {
                    duration = dur
                }
                
                for meta in asset.metadata {
                    guard let key = meta.commonKey else { continue }
                    if key == .commonKeyTitle, let val = meta.stringValue, !val.isEmpty {
                        title = val
                    } else if key == .commonKeyArtist, let val = meta.stringValue, !val.isEmpty {
                        artist = val
                    } else if key == .commonKeyAlbumName, let val = meta.stringValue, !val.isEmpty {
                        album = val
                    }
                }
                
                enriched.append(
                    TrackMetadata(
                        path: item.path,
                        title: title,
                        artist: artist,
                        album: album,
                        sampleRate: item.sampleRate,
                        bitDepth: item.bitDepth,
                        channels: item.channels,
                        durationSeconds: duration
                    )
                )
            }
            
            DispatchQueue.main.async {
                completion(enriched)
            }
        }
    }
}
