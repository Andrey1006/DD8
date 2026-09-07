import SwiftUI

struct TonightView: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                header

                if vault.nudgesBlocked {
                    muted
                }

                if let ready = vault.ripe.first {
                    ripeCard(ready)
                } else if let next = vault.sealed.first {
                    waitingCard(next)
                }

                if vault.pieces.isEmpty {
                    Nothing(
                        title: "The desk is clear",
                        line: "Nothing sealed, nothing waiting. Two or three sentences is all it takes to start the clock.",
                        cta: "Write an opening"
                    ) { deck.open(.seal) }
                } else {
                    tally
                    if !vault.done.isEmpty { recent }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 130)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Stamp.day(Date()))
                .plateStyle(2.6, size: 9)
                .foregroundColor(Ink.mute)

            Text(greeting)
                .font(Face.display(40))
                .foregroundColor(Ink.veil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var greeting: String {
        let name = vault.author?.alias ?? "you"
        if !vault.ripe.isEmpty { return "Something came back, \(name)." }
        if vault.sealed.isEmpty { return "Nothing is buried, \(name)." }
        return "Still buried, \(name)."
    }

    private var muted: some View {
        HStack(spacing: 12) {
            Circle().fill(Ink.past).frame(width: 6, height: 6)
            Text("Notifications are off. Ripe pieces will only show up when you open the app.")
                .font(Face.body(12))
                .foregroundColor(Ink.mute)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .slab(cut: 10, corners: [.tl, .br], fill: Ink.slab.opacity(0.5), stroke: Ink.past.opacity(0.35))
    }

    private func ripeCard(_ p: Piece) -> some View {
        Button {
            Buzz.tap(.medium)
            deck.ritual = p.id
        } label: {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Ready")
                        .plateStyle(2.6, size: 10)
                        .foregroundColor(Ink.now)
                    Spacer()
                    Text("sealed \(Stamp.day(p.sealedAt))")
                        .plateStyle(1.4, size: 9)
                        .foregroundColor(Ink.mute)
                }

                Text("You wrote something \(p.gapDays) days ago and it is waiting for an ending. You will not be shown it until you wipe it clear.")
                    .font(Face.story(17))
                    .lineSpacing(6)
                    .foregroundColor(Ink.veil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    SealFace(size: 40)
                    Text("break the seal")
                        .plateStyle(2, size: 10)
                        .foregroundColor(Ink.veil)
                    Spacer()
                    Text("→").font(Face.display(20)).foregroundColor(Ink.now)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .slab(cut: 20, corners: .diagonal, fill: Ink.slab, stroke: Ink.now.opacity(0.45))
        }
        .buttonStyle(.plain)
    }

    private func waitingCard(_ p: Piece) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().stroke(Ink.hair, lineWidth: 3).frame(width: 66, height: 66)
                Circle()
                    .trim(from: 0, to: p.ripeness())
                    .stroke(Ink.past, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 66, height: 66)
                    .rotationEffect(.degrees(-90))
                ToneDot(tone: p.toneAtSeal, size: 10)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Next one back")
                    .plateStyle(2, size: 9)
                    .foregroundColor(Ink.mute)
                Text(p.waitWording())
                    .font(Face.display(26))
                    .foregroundColor(Ink.veil)
                Text("\(vault.sealed.count) buried in total")
                    .font(Face.body(12))
                    .foregroundColor(Ink.mute)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .slab(cut: 16, corners: [.tr, .bl], fill: Ink.slab.opacity(0.65))
    }

    private var tally: some View {
        HStack(spacing: 12) {
            Figure(value: "\(vault.sealed.count)", caption: "buried", tint: Ink.past)
            Figure(value: "\(vault.done.count)", caption: "finished", tint: Ink.now)
            Figure(value: "\(vault.ripe.count)", caption: "waiting on you")
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Plate(text: "Lately", trailing: "\(vault.done.count)")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vault.done.prefix(6)) { p in
                        Button {
                            deck.read(p.id, from: .tonight)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Cover(piece: p)
                                    .frame(width: 92, height: 122)
                                Text(Stamp.day(p.closedAt ?? p.sealedAt))
                                    .plateStyle(1.2, size: 8)
                                    .foregroundColor(Ink.mute)
                                Text("drift \(p.drift ?? 0)")
                                    .plateStyle(1.2, size: 8)
                                    .foregroundColor(Ink.now)
                            }
                            .frame(width: 92)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
