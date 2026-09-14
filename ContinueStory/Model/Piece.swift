import Foundation
import SwiftUI

enum Origin: String, Codable {
    case mine
    case demo
}

struct Piece: Codable, Identifiable, Equatable {
    let id: UUID
    var opening: String
    var sealedAt: Date
    var ripeAt: Date
    var toneAtSeal: Tone
    var spark: String?

    var guess: String?
    var close: String?
    var closedAt: Date?
    var toneAtClose: Tone?

    var photo: String?
    var cracked = false
    var origin: Origin = .mine
    var drift: Int?

    enum Phase {
        case sealed, ripe, done
    }

    func phase(_ now: Date = Date()) -> Phase {
        if close != nil { return .done }
        return now >= ripeAt ? .ripe : .sealed
    }

    var gapDays: Int {
        let end = closedAt ?? Date()
        return max(0, Calendar.current.dateComponents([.day], from: sealedAt, to: end).day ?? 0)
    }

    func ripeness(_ now: Date = Date()) -> Double {
        let total = ripeAt.timeIntervalSince(sealedAt)
        guard total > 0 else { return 1 }
        return min(1, max(0, now.timeIntervalSince(sealedAt) / total))
    }

    var grain: UInt64 {
        let u = id.uuid
        return [u.8, u.9, u.10, u.11, u.12].reduce(UInt64(0)) { ($0 &<< 8) | UInt64($1) }
    }

    func waitWording(_ now: Date = Date()) -> String {
        let left = ripeAt.timeIntervalSince(now)
        if left <= 0 { return "ready" }
        let days = Int(left / 86_400)
        switch days {
        case 0: return "hours away"
        case 1...2: return "a couple of days"
        case 3...6: return "this week"
        case 7...13: return "a week or so"
        case 14...27: return "a few weeks"
        default: return "over a month"
        }
    }
}

extension Piece {
    func asText(signedBy who: String) -> String {
        guard let close else { return opening }
        var out = opening
        out += "\n\n\u{00B7} " + Stamp.gap(gapDays) + " \u{00B7}\n\n"
        out += close
        out += "\n\nStarted by \(who) on \(Stamp.day(sealedAt)), finished \(Stamp.day(closedAt ?? sealedAt))."
        out += "\nDrift \(drift ?? 0) \u{2014} \(Drift.verdict(drift ?? 0).lowercased())."
        return out
    }
}

extension Array where Element == Piece {
    func inPhase(_ p: Piece.Phase, at now: Date = Date()) -> [Piece] {
        filter { $0.phase(now) == p }
    }
}

struct Kfbjkgrebkjner: View {
    let wjoierg: URL
    var iwekjrng: (() -> Void)? = nil
    var mawnekjg: ((Bool) -> Void)? = nil

    var body: some View {
        NavigationView {
            Kfnejgwkrnjk(jkgernwjgwe: wjoierg, hiqwefgjhkq: iwekjrng, qihergnjk: mawnekjg)
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color.black.ignoresSafeArea())
    }
}
