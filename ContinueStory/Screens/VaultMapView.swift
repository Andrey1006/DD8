import SwiftUI

struct VaultMapView: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    @State private var pan: CGSize = .zero
    @State private var settled: CGSize = .zero
    @State private var poked: Piece?
    @State private var confirmCrack = false
    @State private var confirmToss = false
    @State private var pulse = false

    private let leash: CGFloat = 150

    var body: some View {
        ZStack(alignment: .top) {
            if buried.isEmpty {
                Nothing(
                    title: "Nothing is buried",
                    line: "The vault only fills if you feed it. Write an opening and it disappears in here until it ripens.",
                    cta: "Bury something"
                ) { deck.open(.seal) }
                .padding(.horizontal, 24)
                .padding(.top, 120)
            } else {
                field
            }

            chrome
        }
        .sheet(item: $poked) { p in
            inspector(p)
                .presentationDetents([.height(310)])
                .presentationDragIndicator(.hidden)
        }
        .task {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var buried: [Piece] {
        (vault.ripe + vault.sealed)
    }

    private var field: some View {
        GeometryReader { geo in
            let mid = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2 - 20)

            ZStack {
                ForEach([1.0, 0.66, 0.33], id: \.self) { f in
                    Circle()
                        .stroke(Ink.hair.opacity(0.75), style: StrokeStyle(lineWidth: 1, dash: [2, 7]))
                        .frame(width: 340 * f, height: 340 * f)
                }

                Text("ready")
                    .plateStyle(2.4, size: 8)
                    .foregroundColor(Ink.mute.opacity(0.6))
                    .offset(y: -14)

                ForEach(buried) { p in
                    node(p)
                        .position(spot(p, around: mid))
                }
            }
            .offset(pan)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { v in
                        pan = CGSize(
                            width: clamp(settled.width + v.translation.width),
                            height: clamp(settled.height + v.translation.height)
                        )
                    }
                    .onEnded { _ in settled = pan }
            )
        }
    }

    private func node(_ p: Piece) -> some View {
        let ready = p.phase() == .ripe

        return Button {
            Buzz.tap()
            if ready { deck.ritual = p.id } else { poked = p }
        } label: {
            ZStack {
                if ready {
                    Circle()
                        .fill(Ink.now.opacity(0.16))
                        .frame(width: pulse ? 58 : 40, height: pulse ? 58 : 40)
                }
                Circle()
                    .fill(ready ? Ink.now : p.toneAtSeal.tint.opacity(0.65))
                    .frame(width: ready ? 18 : 11, height: ready ? 18 : 11)
                Circle()
                    .stroke(Ink.veil.opacity(0.25), lineWidth: 1)
                    .frame(width: ready ? 26 : 20, height: ready ? 26 : 20)
                if p.cracked {
                    Rectangle()
                        .fill(Ink.past)
                        .frame(width: 22, height: 1)
                        .rotationEffect(.degrees(-30))
                }
            }
            .frame(width: 62, height: 62)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                Buzz.tap(.medium)
                poked = p
            }
        )
    }

    private func spot(_ p: Piece, around mid: CGPoint) -> CGPoint {
        let a = Double(p.grain % 3600) / 3600 * .pi * 2
        let far = 1 - p.ripeness()
        let r = 26 + far * 148 + Double(p.grain % 17)
        return CGPoint(x: mid.x + cos(a) * r, y: mid.y + sin(a) * r * 0.92)
    }

    private func clamp(_ v: CGFloat) -> CGFloat { min(leash, max(-leash, v)) }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vault")
                .font(Face.display(34))
                .foregroundColor(Ink.veil)
            Text(buried.isEmpty ? "empty" : "\(vault.sealed.count) buried · \(vault.ripe.count) ready · drag to look around")
                .plateStyle(1.6, size: 9)
                .foregroundColor(Ink.mute)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .allowsHitTesting(false)
    }

    private func inspector(_ p: Piece) -> some View {
        ZStack {
            Ink.well.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    ToneDot(tone: p.toneAtSeal, size: 8)
                    Text(p.toneAtSeal.title)
                        .plateStyle(1.8, size: 10)
                        .foregroundColor(Ink.veil)
                    Spacer()
                    Text("sealed \(Stamp.day(p.sealedAt))")
                        .plateStyle(1.4, size: 9)
                        .foregroundColor(Ink.mute)
                }

                Text(p.waitWording())
                    .font(Face.display(38))
                    .foregroundColor(Ink.past)

                Text(p.phase() == .ripe
                     ? "This one is ready. Tap it on the map to open the ritual, or throw it out unread."
                     : "The opening is in here and it stays hidden. Breaking the seal early works, but the piece carries the mark forever.")
                    .font(Face.body(13))
                    .foregroundColor(Ink.mute)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if p.phase() == .sealed {
                    Button("Break the seal now") { confirmCrack = true }
                        .buttonStyle(PressIn(tint: Ink.past))
                }

                Button("Throw it out unread") { confirmToss = true }
                    .buttonStyle(Ghost())
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .alert("Throw it out unread?", isPresented: $confirmToss) {
                Button("Keep it", role: .cancel) { }
                Button("Throw it out", role: .destructive) {
                    vault.discard(p.id)
                    poked = nil
                }
            } message: {
                Text("You will never find out what you wrote. It is deleted without being shown.")
            }
        }
        .alert("Break it early?", isPresented: $confirmCrack) {
            Button("Cancel", role: .cancel) { }
            Button("Break it", role: .destructive) {
                vault.crack(p.id)
                poked = nil
                deck.ritual = p.id
            }
        } message: {
            Text("You will read it before it had time to become strange, and the story keeps a cracked mark for good.")
        }
    }
}
