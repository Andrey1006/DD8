import SwiftUI

struct SlipField: View {
    @Binding var text: String
    var hint: String
    var tint: Color = Ink.now
    var limit: Int?
    var autofocus = false

    @FocusState private var on: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(hint)
                        .font(Face.body(17))
                        .foregroundColor(Ink.mute.opacity(0.55))
                }
                TextField("", text: $text)
                    .font(Face.body(17, .medium))
                    .foregroundColor(Ink.veil)
                    .tint(tint)
                    .focused($on)
                    .autocorrectionDisabled()
                    .onChange(of: text) { v in
                        if let limit, v.count > limit { text = String(v.prefix(limit)) }
                    }
            }
            .frame(height: 26)

            Rectangle()
                .fill(on ? tint : Ink.hair)
                .frame(height: on ? 2 : 1)
                .animation(.easeOut(duration: 0.18), value: on)
        }
        .task {
            guard autofocus else { return }
            try? await Task.sleep(nanoseconds: 320_000_000)
            on = true
        }
    }
}

struct PaperField: View {
    @Binding var text: String
    var hint: String
    var tint: Color = Ink.now
    var limit: Int?
    var minHeight: CGFloat = 150
    var autofocus = false

    @FocusState private var on: Bool
    private let step: CGFloat = 28

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { ctx, size in
                var y = step - 6
                while y < size.height {
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: size.width, y: y))
                    ctx.stroke(line, with: .color(Ink.hair.opacity(0.5)), lineWidth: 1)
                    y += step
                }
            }
            .allowsHitTesting(false)

            if text.isEmpty {
                Text(hint)
                    .font(Face.story(17))
                    .lineSpacing(step - 21)
                    .foregroundColor(Ink.mute.opacity(0.5))
                    .padding(.top, 1)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(Face.story(17))
                .lineSpacing(step - 21)
                .foregroundColor(Ink.veil)
                .tint(tint)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .focused($on)
                .padding(.leading, -1)
                .onChange(of: text) { v in
                    if let limit, v.count > limit {
                        text = String(v.prefix(limit))
                        Buzz.tap(.rigid)
                    }
                }
        }
        .frame(minHeight: minHeight, alignment: .top)
        .task {
            guard autofocus else { return }
            try? await Task.sleep(nanoseconds: 320_000_000)
            on = true
        }
    }
}

struct Quill: View {
    var fill: Double
    var tint: Color = Ink.now

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Capsule().fill(Ink.well)
                Capsule()
                    .fill(LinearGradient(colors: [tint.opacity(0.45), tint], startPoint: .top, endPoint: .bottom))
                    .frame(height: max(3, geo.size.height * fill))
            }
            .overlay(Capsule().stroke(Ink.hair, lineWidth: 1))
        }
        .frame(width: 5)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: fill)
    }
}
