import SwiftUI

public struct TsrossaColors {
    public static let trueBlack = Color(red: 0.0, green: 0.0, blue: 0.0)
    public static let deepNavy = Color(red: 0.055, green: 0.051, blue: 0.075) // 0x0E0D13
    public static let surfaceContainer = Color(red: 0.106, green: 0.094, blue: 0.133) // 0x1B1822
    public static let surfaceHigh = Color(red: 0.141, green: 0.129, blue: 0.176) // 0x24212D
    
    public static let terminalGreen = Color(red: 0.0, green: 1.0, blue: 0.0)
    public static let audiophileCyan = Color(red: 0.0, green: 0.898, blue: 1.0)
    public static let audiophileAmber = Color(red: 1.0, green: 0.702, blue: 0.0)
    public static let sakuraPink = Color(red: 1.0, green: 0.522, blue: 0.631)
    
    public static let textPrimary = Color(white: 0.96)
    public static let textSecondary = Color(white: 0.60)
    public static let textMuted = Color(white: 0.40)
}

public struct GlassmorphicSurface: ViewModifier {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.75
    var borderColor: Color = Color.white.opacity(0.12)
    
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
    public func glassmorphic(cornerRadius: CGFloat = 16, opacity: Double = 0.75, borderColor: Color = Color.white.opacity(0.12)) -> some View {
        self.modifier(GlassmorphicSurface(cornerRadius: cornerRadius, opacity: opacity, borderColor: borderColor))
    }
}
