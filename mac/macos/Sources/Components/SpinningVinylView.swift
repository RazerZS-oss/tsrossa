import SwiftUI
import AppKit

public struct SpinningVinylView: View {
    public var artwork: NSImage?
    public var isPlaying: Bool
    public var size: CGFloat = 52
    
    public init(artwork: NSImage?, isPlaying: Bool, size: CGFloat = 52) {
        self.artwork = artwork
        self.isPlaying = isPlaying
        self.size = size
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 0.033)) { timeline in
            let angle = isPlaying ? (timeline.date.timeIntervalSinceReferenceDate * 36.0).truncatingRemainder(dividingBy: 360.0) : 0.0
            
            ZStack {
                // Vinyl outer black grooved record
                Circle()
                    .fill(Color(red: 0.06, green: 0.06, blue: 0.08))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                // Concentric vinyl groove rings
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                    .frame(width: size * 0.85, height: size * 0.85)
                
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                    .frame(width: size * 0.70, height: size * 0.70)
                
                // Center Album Artwork or Brand Icon
                ZStack {
                    if let art = artwork {
                        Image(nsImage: art)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size * 0.58, height: size * 0.58)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(red: 0.73, green: 0.10, blue: 0.20))
                            .frame(width: size * 0.58, height: size * 0.58)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: size * 0.22, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .rotationEffect(.degrees(angle))
                
                // Center Spindle Hole
                Circle()
                    .fill(Color(red: 0.04, green: 0.04, blue: 0.05))
                    .frame(width: size * 0.14, height: size * 0.14)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.40), lineWidth: 1)
                    )
            }
            .frame(width: size, height: size)
            .shadow(color: Color.black.opacity(0.45), radius: 6, x: 0, y: 3)
        }
    }
}
