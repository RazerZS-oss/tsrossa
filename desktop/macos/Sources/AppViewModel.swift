import Foundation
import Combine

public class AppViewModel: ObservableObject {
    public static let shared = AppViewModel()
    
    @Published public var tracks: [TrackMetadata] = []
    @Published public var searchText: String = ""
    @Published public var showTelemetry: Bool = false
    @Published public var currentFolder: String = "Click 'Choose Music Folder' to begin"
    @Published public var copiedTelemetry: Bool = false
}
