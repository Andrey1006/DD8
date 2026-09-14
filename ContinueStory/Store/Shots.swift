import UIKit

enum Shots {
    private static let folder = "shots"

    private static var root: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folder, isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func keep(_ image: UIImage) -> String? {
        guard let data = fit(image, side: 1400).jpegData(compressionQuality: 0.82) else { return nil }
        let name = UUID().uuidString + ".jpg"
        do {
            try data.write(to: root.appendingPathComponent(name), options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func load(_ name: String) -> UIImage? {
        UIImage(contentsOfFile: root.appendingPathComponent(name).path)
    }

    static func drop(_ name: String) {
        try? FileManager.default.removeItem(at: root.appendingPathComponent(name))
    }

    static func wipe() {
        try? FileManager.default.removeItem(at: root)
    }

    private static func fit(_ image: UIImage, side: CGFloat) -> UIImage {
        let w = image.size.width, h = image.size.height
        let longest = max(w, h)
        guard longest > side, longest > 0 else { return image }
        let k = side / longest
        let target = CGSize(width: w * k, height: h * k)
        return UIGraphicsImageRenderer(size: target).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
