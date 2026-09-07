import SwiftUI

struct SealFace: View {
    var size: CGFloat = 72
    var live = true

    var body: some View {
        ZStack {
            Circle()
                .fill(live ? AnyShapeStyle(Ink.bridge) : AnyShapeStyle(Ink.slab))
            Circle()
                .stroke(Color.black.opacity(0.22), lineWidth: 2)
                .blur(radius: 1.5)
                .padding(3)
            Chamfer(cut: size * 0.12, corners: .all)
                .stroke(Ink.well.opacity(live ? 0.85 : 0.5), lineWidth: 2)
                .frame(width: size * 0.42, height: size * 0.42)
                .rotationEffect(.degrees(45))
        }
        .frame(width: size, height: size)
        .shadow(color: Ink.past.opacity(live ? 0.35 : 0), radius: 18, y: 6)
    }
}

struct WaxPull: View {
    var armed: Bool
    var onSeal: () -> Void

    @State private var drag: CGSize = .zero
    @State private var hop = false
    @State private var scold = false
    @State private var gone = false

    private let reach: CGFloat = -86

    var body: some View {
        VStack(spacing: 14) {
            Text(hint)
                .plateStyle(2.2, size: 9)
                .foregroundColor(scold ? Ink.past : (armed ? Ink.mute : Ink.mute.opacity(0.45)))
                .opacity(drag == .zero ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: scold)

            SealFace(live: armed)
                .scaleEffect(gone ? 0.2 : 1 + min(0.12, -drag.height / 900))
                .opacity(gone ? 0 : 1)
                .offset(x: drag.width, y: drag.height + (hop ? -16 : 0))
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            guard armed, !gone else { return }
                            drag = CGSize(width: v.translation.width * 0.35, height: min(0, v.translation.height))
                        }
                        .onEnded { v in
                            let travelled = abs(v.translation.height) + abs(v.translation.width)
                            guard armed, !gone else {
                                bark()
                                drag = .zero
                                return
                            }
                            if drag.height < reach {
                                fire()
                            } else {
                                if travelled < 12 { bounce() }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { drag = .zero }
                            }
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: armed)
        }
    }

    private var hint: String {
        if scold { return armed ? "drag it, do not tap" : "at least forty characters" }
        return armed ? "pull the seal up" : "keep writing"
    }

    private func bounce() {
        Buzz.tap()
        bark()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.4)) { hop = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.5)) { hop = false }
        }
    }

    private func bark() {
        Buzz.tap(.rigid)
        scold = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { scold = false }
    }

    private func fire() {
        Buzz.snap()
        withAnimation(.easeIn(duration: 0.28)) { gone = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSeal()
            drag = .zero
            gone = false
        }
    }
}

struct WaxTear: View {
    var onTorn: () -> Void

    @State private var pull: CGFloat = 0
    @State private var torn = false

    private let breaking: CGFloat = 118

    var body: some View {
        let t: CGFloat = min(1, pull / breaking)

        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Ink.hair, style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                    .frame(width: 108, height: 108)
                    .opacity(1 - t)

                SealFace(size: 84, live: !torn)
                    .scaleEffect(x: 1 - t * 0.18, y: 1 + t * 0.34, anchor: .top)
                    .overlay(
                        Crackle(progress: t)
                            .stroke(Ink.well, lineWidth: 2.5)
                            .frame(width: 84, height: 84)
                    )
                    .offset(y: pull * 0.45)
                    .opacity(torn ? 0 : 1)
            }
            .frame(height: 150)

            Text(torn ? "" : "hold and drag down")
                .plateStyle(2.2, size: 9)
                .foregroundColor(Ink.mute.opacity(1.0 - Double(t) * 0.7))
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { v in
                    guard !torn else { return }
                    let next = max(0, v.translation.height)
                    if Int(next / 24) != Int(pull / 24) { Buzz.tap(.soft) }
                    pull = next
                    if next >= breaking { snap() }
                }
                .onEnded { _ in
                    guard !torn else { return }
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) { pull = 0 }
                }
        )
    }

    private func snap() {
        torn = true
        Buzz.snap()
        withAnimation(.easeOut(duration: 0.22)) { pull = breaking }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24, execute: onTorn)
    }
}

private struct Crackle: Shape {
    var progress: Double

    func path(in r: CGRect) -> Path {
        var p = Path()
        guard progress > 0.06 else { return p }
        let steps = 7
        let span = r.height * progress
        p.move(to: CGPoint(x: r.midX, y: r.minY + r.height * 0.12))
        for i in 1...steps {
            let f = Double(i) / Double(steps)
            let x = r.midX + (i % 2 == 0 ? 9.0 : -9.0) * f
            p.addLine(to: CGPoint(x: x, y: r.minY + r.height * 0.12 + span * f))
        }
        return p
    }
}
