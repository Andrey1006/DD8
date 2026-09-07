import SwiftUI

enum Order: String, CaseIterable, Identifiable {
    case fresh, gap, drift
    var id: String { rawValue }
    var title: String {
        switch self {
        case .fresh: return "Newest"
        case .gap: return "Longest gap"
        case .drift: return "Most drift"
        }
    }
}

struct ShelfView: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    @State private var order: Order = .fresh

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shelf")
                        .font(Face.display(34))
                        .foregroundColor(Ink.veil)
                    Text(vault.done.isEmpty ? "nothing finished yet" : "\(vault.done.count) finished · every cover drawn from its own story")
                        .plateStyle(1.6, size: 9)
                        .foregroundColor(Ink.mute)
                }

                if vault.done.isEmpty {
                    Nothing(
                        title: "The shelf is bare",
                        line: nextLine,
                        cta: vault.ripe.isEmpty ? "Start one" : "Finish the ripe one"
                    ) {
                        if let r = vault.ripe.first { deck.ritual = r.id } else { deck.open(.seal) }
                    }
                } else {
                    HStack(spacing: 8) {
                        ForEach(Order.allCases) { o in
                            Chip(text: o.title, on: order == o) { order = o }
                        }
                    }

                    LazyVGrid(columns: cols, spacing: 14) {
                        ForEach(Array(sorted.enumerated()), id: \.element.id) { i, p in
                            tile(p, column: i % 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 130)
        }
    }

    private var nextLine: String {
        if let r = vault.ripe.first {
            return "One opening is ripe and waiting for an ending. It has been sitting for \(r.gapDays) days."
        }
        if let s = vault.sealed.first {
            return "Nothing has come back yet. The first one breaks open in \(s.waitWording())."
        }
        return "Finished stories land here, each with a cover built from its own tones, gap and drift."
    }

    private var sorted: [Piece] {
        switch order {
        case .fresh: return vault.done
        case .gap: return vault.done.sorted { $0.gapDays > $1.gapDays }
        case .drift: return vault.done.sorted { ($0.drift ?? 0) > ($1.drift ?? 0) }
        }
    }

    private func tile(_ p: Piece, column: Int) -> some View {
        Button {
            deck.read(p.id, from: .shelf)
        } label: {
            VStack(spacing: 6) {
                Cover(piece: p)
                    .aspectRatio(3.0 / 4.0, contentMode: .fit)
                Text("\(p.drift ?? 0)")
                    .plateStyle(1, size: 8)
                    .foregroundColor(Ink.mute)
            }
            .offset(y: column % 2 == 1 ? 10 : 0)
        }
        .buttonStyle(.plain)
    }
}
