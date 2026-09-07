import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Ink {
    static let night = Color(hex: 0x191E3A)
    static let well = Color(hex: 0x11152B)
    static let slab = Color(hex: 0x232B4E)
    static let hair = Color(hex: 0x2E376B)

    static let past = Color(hex: 0xF2A65A)
    static let now = Color(hex: 0x5CE1C6)

    static let veil = Color(hex: 0xEDEAF6)
    static let mute = Color(hex: 0x8A90B8)

    static let bridge = LinearGradient(
        colors: [past, now],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
