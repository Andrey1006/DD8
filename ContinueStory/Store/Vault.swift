import Foundation
import SwiftUI
import Combine

@MainActor
final class Vault: ObservableObject {
    @Published private(set) var pieces: [Piece] = []
    @Published private(set) var author: Author?
    @Published var nudgesBlocked = false

    static let schema = 2

    private enum Key {
        static let schema = "cs.schema"
        static let pieces = "cs.pieces"
        static let author = "cs.author"
        static let burned = "cs.burned"
    }

    private let d: UserDefaults
    private var frozen = false

    init(defaults: UserDefaults = .standard) {
        d = defaults

        let stamp = d.integer(forKey: Key.schema)
        frozen = stamp > Self.schema

        if let raw = d.data(forKey: Key.pieces) {
            pieces = (try? JSONDecoder.iso.decode([Piece].self, from: raw)) ?? []
        }
        if let raw = d.data(forKey: Key.author) {
            author = try? JSONDecoder.iso.decode(Author.self, from: raw)
        }

        if !frozen && stamp != Self.schema {
            d.set(Self.schema, forKey: Key.schema)
        }
    }

    var onboarded: Bool { author != nil }
    var ripe: [Piece] { pieces.inPhase(.ripe).sorted { $0.ripeAt < $1.ripeAt } }
    var sealed: [Piece] { pieces.inPhase(.sealed).sorted { $0.ripeAt < $1.ripeAt } }
    var done: [Piece] { pieces.inPhase(.done).sorted { ($1.closedAt ?? .distantPast) < ($0.closedAt ?? .distantPast) } }

    func piece(_ id: UUID) -> Piece? { pieces.first { $0.id == id } }

    @discardableResult
    func seal(_ opening: String, tone: Tone, spark: String? = nil, window: SealWindow? = nil, photo: String? = nil) -> Piece {
        let now = Date()
        let w = window ?? author?.window ?? .standard
        let p = Piece(
            id: UUID(),
            opening: opening.trimmingCharacters(in: .whitespacesAndNewlines),
            sealedAt: now,
            ripeAt: w.roll(from: now),
            toneAtSeal: tone,
            spark: spark,
            photo: photo
        )
        pieces.append(p)
        flush()
        Nudges.arm(for: p)
        return p
    }

    func close(_ id: UUID, text: String, tone: Tone, guess: String?) {
        guard let i = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[i].close = text.trimmingCharacters(in: .whitespacesAndNewlines)
        pieces[i].closedAt = Date()
        pieces[i].toneAtClose = tone
        pieces[i].guess = guess?.trimmingCharacters(in: .whitespacesAndNewlines)
        pieces[i].drift = Drift.score(pieces[i])
        Nudges.disarm(id)
        flush()
    }

    func discard(_ id: UUID) {
        guard let i = pieces.firstIndex(where: { $0.id == id }) else { return }
        if let shot = pieces[i].photo { Shots.drop(shot) }
        pieces.remove(at: i)
        Nudges.disarm(id)
        flush()
    }

    func crack(_ id: UUID) {
        guard let i = pieces.firstIndex(where: { $0.id == id }), pieces[i].phase() == .sealed else { return }
        pieces[i].cracked = true
        pieces[i].ripeAt = Date()
        Nudges.disarm(id)
        flush()
    }

    func adopt(_ profile: Author) {
        author = profile
        flush()
        Nudges.reschedule(rhythm: profile.rhythm)
    }

    var everBurned: Bool { d.bool(forKey: Key.burned) }

    func plantDemoIfVirgin() {
        guard pieces.isEmpty, !everBurned else { return }
        pieces.append(contentsOf: Seeds.starter())
        flush()
    }

    func burnEverything() {
        pieces = []
        author = nil
        Shots.wipe()
        Nudges.disarmAll()
        d.removeObject(forKey: Key.pieces)
        d.removeObject(forKey: Key.author)
        d.set(true, forKey: Key.burned)
        d.set(Self.schema, forKey: Key.schema)
    }

    private func flush() {
        guard !frozen else { return }
        if let raw = try? JSONEncoder.iso.encode(pieces) { d.set(raw, forKey: Key.pieces) }
        if let a = author, let raw = try? JSONEncoder.iso.encode(a) {
            d.set(raw, forKey: Key.author)
        }
    }
}

extension JSONDecoder {
    static let iso: JSONDecoder = {
        let x = JSONDecoder()
        x.dateDecodingStrategy = .iso8601
        return x
    }()
}

extension JSONEncoder {
    static let iso: JSONEncoder = {
        let x = JSONEncoder()
        x.dateEncodingStrategy = .iso8601
        return x
    }()
}
