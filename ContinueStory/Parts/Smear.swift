import SwiftUI

struct Smear: View {
    var text: String
    var onCleared: () -> Void

    @State private var path = Path()
    @State private var last: CGPoint?
    @State private var touched: Set<Int> = []
    @State private var opened = false

    private let cols = 14
    private let rows = 12
    private let brush: CGFloat = 62
    private let enough = 0.62

    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            ZStack {
                Text(text)
                    .font(Face.story(19))
                    .lineSpacing(9)
                    .foregroundColor(Ink.past)
                    .padding(22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Fog()
                    .mask(
                        Canvas { ctx, _ in
                            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))
                            ctx.blendMode = .destinationOut
                            ctx.stroke(
                                path,
                                with: .color(.white),
                                style: StrokeStyle(lineWidth: brush, lineCap: .round, lineJoin: .round)
                            )
                        }
                        .allowsHitTesting(false)
                    )
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in wipe(v.location, in: size) }
                    .onEnded { _ in last = nil }
            )
        }
        .slab(cut: 20, corners: [.tl, .br], fill: Ink.well.opacity(0.6), stroke: Ink.hair)
    }

    private func wipe(_ p: CGPoint, in size: CGSize) {
        guard !opened else { return }

        if let l = last {
            guard hypot(p.x - l.x, p.y - l.y) > 5 else { return }
            path.addLine(to: p)
        } else {
            path.move(to: p)
        }
        last = p

        let cx = Int(p.x / size.width * CGFloat(cols))
        let cy = Int(p.y / size.height * CGFloat(rows))
        guard cx >= 0, cx < cols, cy >= 0, cy < rows else { return }
        touched.insert(cy * cols + cx)

        if Double(touched.count) / Double(cols * rows) >= enough {
            opened = true
            Buzz.snap()
            withAnimation(.easeOut(duration: 0.5)) {
                path = Path(CGRect(x: -200, y: -200, width: size.width + 400, height: size.height + 400))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: onCleared)
        }
    }
}

private struct Fog: View {
    var body: some View {
        ZStack {
            Ink.well
            Ellipse()
                .fill(Ink.slab)
                .frame(width: 320, height: 220)
                .offset(x: -60, y: -50)
                .blur(radius: 40)
            Ellipse()
                .fill(Ink.hair.opacity(0.7))
                .frame(width: 280, height: 260)
                .offset(x: 90, y: 70)
                .blur(radius: 46)
            Grain.tile
                .resizable(resizingMode: .tile)
                .opacity(0.7)
                .blendMode(.plusLighter)
        }
        .overlay(
            Text("wipe it clear")
                .plateStyle(2.4, size: 10)
                .foregroundColor(Ink.mute)
        )
    }
}
