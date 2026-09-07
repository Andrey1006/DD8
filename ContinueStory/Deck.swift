import SwiftUI
import Combine

enum Slot: Int, CaseIterable, Identifiable {
    case tonight, vault, seal, shelf, drift
    var id: Int { rawValue }

    var caption: String {
        switch self {
        case .tonight: return "Tonight"
        case .vault: return "Vault"
        case .seal: return "Seal"
        case .shelf: return "Shelf"
        case .drift: return "Drift"
        }
    }
}

enum Route: Hashable {
    case reader(UUID)
    case settings
}

@MainActor
final class Deck: ObservableObject {
    @Published var slot: Slot = .tonight
    @Published var tonightPath: [Route] = []
    @Published var shelfPath: [Route] = []
    @Published var driftPath: [Route] = []
    @Published var ritual: UUID?

    @Published var draft = ""
    @Published var mood: Tone = .dread

    static let inkLimit = 280
    var quill: Double { min(1, Double(draft.count) / Double(Self.inkLimit)) }

    var barHidden: Bool {
        switch slot {
        case .tonight: return !tonightPath.isEmpty
        case .shelf: return !shelfPath.isEmpty
        case .drift: return !driftPath.isEmpty
        default: return false
        }
    }

    func open(_ s: Slot) {
        guard slot != s else { return }
        Buzz.tap()
        slot = s
    }

    func read(_ id: UUID, from s: Slot) {
        switch s {
        case .shelf: shelfPath.append(.reader(id))
        case .drift: driftPath.append(.reader(id))
        default: tonightPath.append(.reader(id))
        }
    }
}

struct Deckhouse: View {
    @EnvironmentObject private var vault: Vault
    @StateObject private var deck = Deck()

    var body: some View {
        ZStack(alignment: .bottom) {
            Backdrop(glow: deck.slot == .seal ? Ink.past : Ink.now)

            Group {
                switch deck.slot {
                case .tonight:
                    NavigationStack(path: $deck.tonightPath) {
                        TonightView().pinned().onPaper()
                    }
                case .vault:
                    VaultMapView()
                case .seal:
                    SealView()
                case .shelf:
                    NavigationStack(path: $deck.shelfPath) {
                        ShelfView().pinned().onPaper()
                    }
                case .drift:
                    NavigationStack(path: $deck.driftPath) {
                        DriftRoom().pinned().onPaper()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(deck)

            Bar()
                .environmentObject(deck)
                .offset(y: deck.barHidden ? 160 : 0)
                .animation(.spring(response: 0.36, dampingFraction: 0.86), value: deck.barHidden)
        }
        .fullScreenCover(item: Binding(
            get: { deck.ritual.map(Held.init) },
            set: { deck.ritual = $0?.id }
        )) { held in
            RitualView(id: held.id)
                .environmentObject(vault)
                .environmentObject(deck)
        }
    }
}

struct Held: Identifiable {
    let id: UUID
}

private extension View {
    func pinned() -> some View {
        navigationDestination(for: Route.self) { r in
            switch r {
            case .reader(let id): ReaderView(id: id)
            case .settings: SettingsView()
            }
        }
    }
}

private struct Bar: View {
    @EnvironmentObject private var deck: Deck

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            key(.tonight)
            key(.vault)
            centre
            key(.shelf)
            key(.drift)
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(
            ZStack {
                Ink.well.opacity(0.94)
                Rectangle()
                    .fill(Ink.hair)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func key(_ s: Slot) -> some View {
        let live = deck.slot == s
        return Button {
            deck.open(s)
        } label: {
            VStack(spacing: 7) {
                Glyph(kind: s)
                    .stroke(live ? Ink.now : Ink.mute, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                    .frame(width: 22, height: 22)
                Text(s.caption)
                    .plateStyle(1.2, size: 8)
                    .foregroundColor(live ? Ink.now : Ink.mute.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: live)
    }

    private var centre: some View {
        let live = deck.slot == .seal
        return Button {
            deck.open(.seal)
        } label: {
            ZStack {
                Circle()
                    .fill(Ink.well)
                    .frame(width: 62, height: 62)
                    .overlay(Circle().stroke(Ink.hair, lineWidth: 1))

                Circle()
                    .fill(Ink.slab)
                    .frame(width: 52, height: 52)

                Circle()
                    .fill(Ink.bridge)
                    .frame(width: 52, height: 52)
                    .mask(
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 52 * (1 - deck.quill))
                            Color.black.frame(height: 52 * deck.quill)
                        }
                    )

                Chamfer(cut: 4, corners: .all)
                    .stroke(live || deck.quill > 0.02 ? Ink.well : Ink.veil, lineWidth: 2)
                    .frame(width: 17, height: 17)
                    .rotationEffect(.degrees(45))

                Circle()
                    .stroke(live ? Ink.now : .clear, lineWidth: 1.5)
                    .frame(width: 62, height: 62)
            }
            .offset(y: -14)
            .frame(maxWidth: .infinity)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: deck.quill)
        .animation(.easeOut(duration: 0.2), value: live)
    }
}

private struct Glyph: Shape {
    let kind: Slot

    func path(in r: CGRect) -> Path {
        var p = Path()
        switch kind {
        case .tonight:
            p.addArc(center: CGPoint(x: r.midX, y: r.maxY), radius: r.width * 0.46, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            p.move(to: CGPoint(x: r.minX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.move(to: CGPoint(x: r.midX, y: r.minY))
            p.addLine(to: CGPoint(x: r.midX, y: r.minY + r.height * 0.16))
        case .vault:
            p.addEllipse(in: r.insetBy(dx: 0, dy: 0))
            p.addEllipse(in: r.insetBy(dx: r.width * 0.3, dy: r.height * 0.3))
        case .seal:
            p.addEllipse(in: r)
        case .shelf:
            let g = r.width * 0.42
            for x in 0..<2 {
                for y in 0..<2 {
                    p.addRect(CGRect(x: r.minX + Double(x) * (g + r.width * 0.16), y: r.minY + Double(y) * (g + r.height * 0.16), width: g, height: g))
                }
            }
        case .drift:
            p.addEllipse(in: CGRect(x: r.minX, y: r.midY - r.height * 0.32, width: r.width * 0.64, height: r.height * 0.64))
            p.addEllipse(in: CGRect(x: r.maxX - r.width * 0.64, y: r.midY - r.height * 0.32, width: r.width * 0.64, height: r.height * 0.64))
        }
        return p
    }
}
