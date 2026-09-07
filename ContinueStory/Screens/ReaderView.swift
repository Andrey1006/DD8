import SwiftUI

struct ReaderView: View {
    let id: UUID

    @EnvironmentObject private var vault: Vault
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Backdrop(glow: Ink.past)

            if let p = vault.piece(id), let close = p.close {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        crest(p)
                        byline(p)

                        Text(p.opening)
                            .font(Face.story(19))
                            .lineSpacing(9)
                            .foregroundColor(Ink.past)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 12) {
                            Rectangle().fill(Ink.hair).frame(height: 1)
                            Text(Stamp.gap(p.gapDays))
                                .plateStyle(1.8, size: 9)
                                .foregroundColor(Ink.mute)
                            Rectangle().fill(Ink.hair).frame(height: 1)
                        }

                        Text(close)
                            .font(Face.story(19))
                            .lineSpacing(9)
                            .foregroundColor(Ink.now)
                            .fixedSize(horizontal: false, vertical: true)

                        if let g = p.guess, !g.isEmpty {
                            recall(p, guess: g)
                        }

                        driftPlate(p)
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 8)
                    .padding(.bottom, 60)
                }
            } else {
                Nothing(title: "Gone", line: "This story is not in the vault any more.")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Text("← Back")
                        .plateStyle(1.8, size: 10)
                        .foregroundColor(Ink.mute)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func crest(_ p: Piece) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Cover(piece: p)
                .frame(width: 84, height: 112)

            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 7) {
                    ToneDot(tone: p.toneAtSeal, size: 7)
                    Text(p.toneAtSeal.title).plateStyle(1.4, size: 9).foregroundColor(Ink.past)
                    Text("→").font(Face.body(11)).foregroundColor(Ink.mute)
                    ToneDot(tone: p.toneAtClose ?? p.toneAtSeal, size: 7)
                    Text((p.toneAtClose ?? p.toneAtSeal).title).plateStyle(1.4, size: 9).foregroundColor(Ink.now)
                }
                if p.cracked {
                    Text("seal broken early")
                        .plateStyle(1.6, size: 9)
                        .foregroundColor(Ink.past.opacity(0.8))
                }
                if let s = p.spark {
                    Text("from: \(s)")
                        .font(Face.body(11))
                        .foregroundColor(Ink.mute)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func byline(_ p: Piece) -> some View {
        let who = vault.author?.alias ?? "you"
        return VStack(alignment: .leading, spacing: 4) {
            Text("Started by \(who), \(Stamp.day(p.sealedAt))")
                .plateStyle(1.6, size: 9)
                .foregroundColor(Ink.past.opacity(0.85))
            Text("Finished by \(who), \(Stamp.day(p.closedAt ?? p.sealedAt))")
                .plateStyle(1.6, size: 9)
                .foregroundColor(Ink.now.opacity(0.85))
        }
    }

    private func recall(_ p: Piece, guess: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Plate(text: "Before you read it", trailing: Drift.hit(p) ? "hit" : "miss")
            Text("\u{201C}\(guess)\u{201D}")
                .font(Face.story(15))
                .foregroundColor(Ink.veil.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            Text(Drift.hit(p)
                 ? "You still had a thread of it."
                 : "Nothing of it was left in your head.")
                .font(Face.body(12))
                .foregroundColor(Ink.mute)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .slab(cut: 14, corners: [.tr, .bl], fill: Ink.slab.opacity(0.55))
    }

    private func driftPlate(_ p: Piece) -> some View {
        HStack(alignment: .center, spacing: 18) {
            Text("\(p.drift ?? 0)")
                .font(Face.display(52))
                .foregroundColor(Ink.now)
            VStack(alignment: .leading, spacing: 6) {
                Text("Drift")
                    .plateStyle(2.4, size: 9)
                    .foregroundColor(Ink.mute)
                Text(Drift.verdict(p.drift ?? 0))
                    .font(Face.display(20))
                    .foregroundColor(Ink.veil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .slab(cut: 18, corners: .diagonal, fill: Ink.slab.opacity(0.7), stroke: Ink.now.opacity(0.3))
    }
}
