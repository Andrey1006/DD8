import SwiftUI
import CoreGraphics

enum Grain {
    static let tile: Image = bake()

    private static func bake() -> Image {
        let side = 96
        var px = [UInt8](repeating: 0, count: side * side * 4)
        for i in stride(from: 0, to: px.count, by: 4) {
            let a = UInt8.random(in: 0...16)
            px[i] = a; px[i + 1] = a; px[i + 2] = a; px[i + 3] = a
        }
        let cg = px.withUnsafeMutableBytes { raw -> CGImage? in
            let ctx = CGContext(
                data: raw.baseAddress,
                width: side, height: side,
                bitsPerComponent: 8, bytesPerRow: side * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
            return ctx?.makeImage()
        }
        guard let cg else { return Image(uiImage: UIImage()) }
        return Image(decorative: cg, scale: 1)
    }
}

struct Backdrop: View {
    var glow: Color = Ink.now

    var body: some View {
        ZStack {
            Ink.night
            RadialGradient(
                colors: [glow.opacity(0.13), .clear],
                center: .init(x: 0.5, y: -0.05),
                startRadius: 0,
                endRadius: 460
            )
            Grain.tile
                .resizable(resizingMode: .tile)
                .opacity(0.55)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

extension View {
    func onPaper(_ glow: Color = Ink.now) -> some View {
        ZStack {
            Backdrop(glow: glow)
            self
        }
    }
}
