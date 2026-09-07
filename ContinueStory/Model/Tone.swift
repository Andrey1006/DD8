import SwiftUI

enum Tone: String, Codable, CaseIterable, Identifiable {
    case dread, tender, absurd, cold, feverish, wry, luminous, hollow

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var blurb: String {
        switch self {
        case .dread: return "something is about to go wrong"
        case .tender: return "close, quiet, unguarded"
        case .absurd: return "the rules stopped applying"
        case .cold: return "flat light, no mercy"
        case .feverish: return "too fast, too bright"
        case .wry: return "a joke with teeth"
        case .luminous: return "the good kind of strange"
        case .hollow: return "someone left the room"
        }
    }

    var warmth: Double {
        switch self {
        case .cold: return 0.0
        case .hollow: return 0.12
        case .dread: return 0.28
        case .wry: return 0.45
        case .absurd: return 0.58
        case .feverish: return 0.72
        case .luminous: return 0.86
        case .tender: return 1.0
        }
    }

    var tint: Color {
        Color(hue: 0.52 - warmth * 0.44, saturation: 0.58, brightness: 0.92)
    }
}
