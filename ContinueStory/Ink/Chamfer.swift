import SwiftUI

struct Cut: OptionSet {
    let rawValue: Int
    static let tl = Cut(rawValue: 1 << 0)
    static let tr = Cut(rawValue: 1 << 1)
    static let br = Cut(rawValue: 1 << 2)
    static let bl = Cut(rawValue: 1 << 3)
    static let all: Cut = [.tl, .tr, .br, .bl]
    static let diagonal: Cut = [.tl, .br]
}

struct Chamfer: Shape {
    var cut: CGFloat = 14
    var corners: Cut = .diagonal

    func path(in r: CGRect) -> Path {
        let c = min(cut, min(r.width, r.height) / 2)
        let tl = corners.contains(.tl) ? c : 0
        let tr = corners.contains(.tr) ? c : 0
        let br = corners.contains(.br) ? c : 0
        let bl = corners.contains(.bl) ? c : 0

        var p = Path()
        p.move(to: CGPoint(x: r.minX + tl, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - tr, y: r.minY))
        if tr > 0 { p.addLine(to: CGPoint(x: r.maxX, y: r.minY + tr)) }
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY - br))
        if br > 0 { p.addLine(to: CGPoint(x: r.maxX - br, y: r.maxY)) }
        p.addLine(to: CGPoint(x: r.minX + bl, y: r.maxY))
        if bl > 0 { p.addLine(to: CGPoint(x: r.minX, y: r.maxY - bl)) }
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + tl))
        p.closeSubpath()
        return p
    }
}

extension View {
    func slab(cut: CGFloat = 14, corners: Cut = .diagonal, fill: Color = Ink.slab, stroke: Color = Ink.hair) -> some View {
        background(Chamfer(cut: cut, corners: corners).fill(fill))
            .overlay(Chamfer(cut: cut, corners: corners).stroke(stroke, lineWidth: 1))
            .contentShape(Chamfer(cut: cut, corners: corners))
    }
}
