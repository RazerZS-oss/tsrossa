import Foundation
import Combine

public struct OutputDevice: Identifiable, Hashable {
    public let id: UInt32
    public let name: String
    public let isUsb: Bool
    public let isDefault: Bool
    public let sampleRate: Double
}

public struct TrackMetadata: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let path: String
    public let sampleRate: UInt32
    public let bitDepth: UInt32
    public let channels: UInt32
    public let durationSeconds: Double
    
    public init(path: String, title: String, artist: String, album: String, sampleRate: UInt32, bitDepth: UInt32, channels: UInt32, durationSeconds: Double) {
        self.id = path
        self.path = path
        self.title = title
        self.artist = artist
        self.album = album
        self.sampleRate = sampleRate
        self.bitDepth = bitDepth
        self.channels = channels
        self.durationSeconds = durationSeconds
    }
}

public class AudioEngine: ObservableObject {
    public static let shared = AudioEngine()
    
    @Published public var isPlaying: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var currentTime: Double = 0.0
    @Published public var totalDuration: Double = 0.0
    @Published public var currentTrack: TrackMetadata? = nil
    @Published public var devices: [OutputDevice] = []
    @Published public var selectedDeviceId: UInt32 = 0
    @Published public var telemetryJson: String = "{}"
    
    private var progressTimer: Timer?
    
    private init() {
        _ = tsrossa_init()
        refreshDevices()
    }
    
    deinit {
        stopProgressTimer()
        tsrossa_shutdown()
    }
    
    public func refreshDevices() {
        let count = tsrossa_get_device_count()
        var list: [OutputDevice] = []
        for i in 0..<count {
            let name = String(cString: tsrossa_get_device_name(i))
            let id = tsrossa_get_device_id(i)
            let isUsb = tsrossa_get_device_is_usb(i)
            let isDef = tsrossa_get_device_is_default(i)
            let rate = tsrossa_get_device_sample_rate(i)
            list.append(OutputDevice(id: id, name: name, isUsb: isUsb, isDefault: isDef, sampleRate: rate))
            if isDef && selectedDeviceId == 0 {
                selectedDeviceId = id
            }
        }
        self.devices = list
    }
    
    public func selectDevice(id: UInt32) {
        if tsrossa_select_device(id) {
            self.selectedDeviceId = id
            refreshDevices()
        }
    }
    
    public func play(track: TrackMetadata) {
        self.currentTrack = track
        if tsrossa_play(track.path) {
            self.isPlaying = true
            self.isPaused = false
            self.totalDuration = tsrossa_get_total_duration()
            startProgressTimer()
            updateTelemetry()
        }
    }
    
    public func togglePlayPause() {
        if isPlaying {
            if isPaused {
                tsrossa_resume()
                isPaused = false
            } else {
                tsrossa_pause()
                isPaused = true
            }
            updateTelemetry()
        } else if let track = currentTrack {
            play(track: track)
        }
    }
    
    public func stop() {
        tsrossa_stop()
        isPlaying = false
        isPaused = false
        currentTime = 0.0
        stopProgressTimer()
        updateTelemetry()
    }
    
    public func seek(to seconds: Double) {
        _ = tsrossa_seek(seconds)
        self.currentTime = seconds
        updateTelemetry()
    }
    
    public func updateTelemetry() {
        self.telemetryJson = String(cString: tsrossa_get_telemetry_json())
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        DispatchQueue.main.async {
            self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.isPlaying && !self.isPaused {
                    self.currentTime = tsrossa_get_current_time()
                    if !tsrossa_is_playing() && self.currentTime >= self.totalDuration - 0.5 {
                        self.stop()
                    }
                }
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
