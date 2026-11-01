import SwiftUI

public struct EqualizerBarsView: View {
    public var barColor: Color = Color(red: 1.0, green: 0.18, blue: 0.33)
    public var isPlaying: Bool = true
    
    public init(barColor: Color = Color(red: 1.0, green: 0.18, blue: 0.33), isPlaying: Bool = true) {
        self.barColor = barColor
        self.isPlaying = isPlaying
    }
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 0.08)) { timeline in
            let time = isPlaying ? timeline.date.timeIntervalSinceReferenceDate : 0.0
            
            HStack(alignment: .bottom, spacing: 2) {
                // Bar 1
                let h1: CGFloat = isPlaying ? CGFloat(4 + abs(sin(time * 6.0)) * 10) : 3
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(barColor)
                    .frame(width: 3, height: h1)
                
                // Bar 2
                let h2: CGFloat = isPlaying ? CGFloat(3 + abs(cos(time * 8.5)) * 12) : 7
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(barColor)
                    .frame(width: 3, height: h2)
                
                // Bar 3
                let h3: CGFloat = isPlaying ? CGFloat(4 + abs(sin(time * 5.0 + 1.0)) * 11) : 4
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(barColor)
                    .frame(width: 3, height: h3)
            }
            .frame(width: 14, height: 16, alignment: .bottom)
        }
    }
}
