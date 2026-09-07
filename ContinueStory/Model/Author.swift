import Foundation

enum SealWindow: String, Codable, CaseIterable, Identifiable {
    case short, standard, long

    var id: String { rawValue }

    var title: String {
        switch self {
        case .short: return "Short"
        case .standard: return "Standard"
        case .long: return "Long"
        }
    }

    var span: ClosedRange<Int> {
        switch self {
        case .short: return 7...14
        case .standard: return 14...30
        case .long: return 30...60
        }
    }

    var blurb: String {
        switch self {
        case .short: return "One to two weeks. You will still half-remember."
        case .standard: return "Two to four weeks. The sweet spot."
        case .long: return "One to two months. Expect a stranger."
        }
    }

    func roll(from start: Date) -> Date {
        let days = Int.random(in: span)
        let jitter = Double.random(in: 0...(12 * 3600))
        return start.addingTimeInterval(Double(days) * 86_400 + jitter)
    }
}

enum Rhythm: String, Codable, CaseIterable, Identifiable {
    case off, weekly, brisk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: return "Never"
        case .weekly: return "Weekly"
        case .brisk: return "Every third day"
        }
    }

    var days: Int? {
        switch self {
        case .off: return nil
        case .weekly: return 7
        case .brisk: return 3
        }
    }
}

struct Author: Codable, Equatable {
    var alias: String
    var tones: [Tone]
    var window: SealWindow
    var rhythm: Rhythm
    var joinedAt: Date
}
