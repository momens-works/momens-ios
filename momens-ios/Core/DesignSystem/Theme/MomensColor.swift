import SwiftUI

enum MomensColor {
    // Primary
    static let primary100 = Color(hex: 0x3765EF)
    static let primary50 = Color(hex: 0x668CFF)
    static let primary10 = Color(hex: 0xF2F5FF)

    // Point
    static let pointRed = Color(hex: 0xFE8E8E)
    static let pointPurple = Color(hex: 0x7E70FF)
    static let pointYellow = Color(hex: 0xFFB554)
    static let pointMint = Color(hex: 0x70D4CC)

    // B&W
    static let white = Color(hex: 0xFFFFFF)
    static let black = Color(hex: 0x191919)

    // Background
    static let navigationGray = Color(hex: 0x666E74, opacity: 0.8)
    static let uiBackground = Color(hex: 0xEFF1F1)
    static let uiBlackBackground = Color(hex: 0x191919, opacity: 0.6)

    // Grayscale
    static let gray100 = Color(hex: 0xEDF0F4)
    static let gray200 = Color(hex: 0xD5DADD)
    static let gray300 = Color(hex: 0xBCC4CC)
    static let gray400 = Color(hex: 0x959CA3)
    static let gray500 = Color(hex: 0x788087)
    static let gray600 = Color(hex: 0x666E74)
    static let gray700 = Color(hex: 0x4A5156)
    static let gray800 = Color(hex: 0x36393C)
    static let gray900 = Color(hex: 0x202223)
}

private extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
