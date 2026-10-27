import SwiftUI

public struct TsrossaColors {
    public static let trueBlack = Color(red: 0.0, green: 0.0, blue: 0.0)
    public static let deepNavy = Color(red: 0.055, green: 0.051, blue: 0.075) // 0x0E0D13
    public static let surfaceLow = Color(red: 0.078, green: 0.071, blue: 0.102) // 0x14121A
    public static let surfaceContainer = Color(red: 0.106, green: 0.094, blue: 0.133) // 0x1B1822
    public static let surfaceHigh = Color(red: 0.141, green: 0.129, blue: 0.176) // 0x24212D
    public static let surfaceHighest = Color(red: 0.184, green: 0.169, blue: 0.231) // 0x2F2B3B
    
    // Tsrossa's signature vibrant green accent from Now Playing screen
    public static let accentGreen = Color(red: 0.62, green: 0.82, blue: 0.38) // #9ECF60
    public static let terminalGreen = Color(red: 0.0, green: 1.0, blue: 0.0)
    public static let audiophileCyan = Color(red: 0.0, green: 0.898, blue: 1.0)
    public static let bitPerfectGold = Color(red: 1.0, green: 0.843, blue: 0.0) // Yellow dot #FFD700
    public static let errorRed = Color(red: 0.95, green: 0.26, blue: 0.21)
    
    public static let textPrimary = Color(white: 0.96)
    public static let textSecondary = Color(white: 0.60)
    public static let textMuted = Color(white: 0.40)
}

public struct GlassmorphicSurface: ViewModifier {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.85
    var borderColor: Color = Color.white.opacity(0.10)
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(TsrossaColors.surfaceContainer.opacity(opacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 0.8)
            )
    }
}

extension View {
    public func glassmorphic(cornerRadius: CGFloat = 16, opacity: Double = 0.85, borderColor: Color = Color.white.opacity(0.10)) -> some View {
        self.modifier(GlassmorphicSurface(cornerRadius: cornerRadius, opacity: opacity, borderColor: borderColor))
    }
}
