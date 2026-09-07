import Foundation

enum Drift {
    static func score(_ p: Piece) -> Int {
        guard let close = p.close, let toneNow = p.toneAtClose else { return 0 }

        let gap = min(1.0, Double(p.gapDays) / 45.0)
        let heat = abs(p.toneAtSeal.warmth - toneNow.warmth)
        let echo = 1 - overlap(p.opening, close)

        let raw = gap * 0.34 + heat * 0.28 + echo * 0.38
        return Int((raw * 100).rounded())
    }

    static func verdict(_ score: Int) -> String {
        switch score {
        case ..<25: return "You finished yourself"
        case 25..<45: return "Same hand, different day"
        case 45..<65: return "Two authors, one notebook"
        case 65..<82: return "A stranger picked it up"
        default: return "Nothing survived the gap"
        }
    }

    static func recall(_ p: Piece) -> Double {
        guard let g = p.guess, !g.isEmpty else { return 0 }
        return overlap(g, p.opening)
    }

    static func hit(_ p: Piece) -> Bool { recall(p) > 0.08 }

    static func overlap(_ a: String, _ b: String) -> Double {
        let x = content(a), y = content(b)
        guard !x.isEmpty, !y.isEmpty else { return 0 }
        let shared = x.intersection(y).count
        return Double(shared) / Double(x.union(y).count)
    }

    private static let filler: Set<String> = [
        "that", "this", "with", "from", "they", "them", "then", "than", "there",
        "have", "been", "were", "what", "when", "will", "would", "could", "into",
        "just", "like", "some", "over", "your", "about", "which", "their", "because"
    ]

    private static func content(_ s: String) -> Set<String> {
        let words = s.lowercased().split { !$0.isLetter }
        return Set(words.map(String.init).filter { $0.count > 3 && !filler.contains($0) })
    }
}
