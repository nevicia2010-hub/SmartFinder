import AppKit
import SmartFinderCore

final class VisualIconProvider {
    private let iconProvider = IconProvider()

    func icon(for item: FileItem, size: CGFloat) -> NSImage {
        switch item.category {
        case .document, .audio, .archive, .code:
            return typeCard(for: item, size: size)
        default:
            return iconProvider.icon(for: item, size: NSSize(width: size, height: size))
        }
    }

    private func typeCard(for item: FileItem, size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        NSColor.clear.setFill()
        NSRect(x: 0, y: 0, width: size, height: size).fill()

        let cardRect = NSRect(x: size * 0.14, y: size * 0.08, width: size * 0.72, height: size * 0.84)
        let color = accentColor(for: item)
        color.setFill()
        NSBezierPath(roundedRect: cardRect, xRadius: size * 0.12, yRadius: size * 0.12).fill()

        NSColor.white.withAlphaComponent(0.25).setFill()
        NSBezierPath(
            roundedRect: NSRect(x: cardRect.minX, y: cardRect.maxY - size * 0.22, width: cardRect.width, height: size * 0.22),
            xRadius: size * 0.12,
            yRadius: size * 0.12
        ).fill()

        let label = label(for: item)
        let labelFont = NSFont.systemFont(ofSize: max(11, size * 0.20), weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: NSColor.white
        ]
        let labelSize = label.size(withAttributes: attributes)
        label.draw(
            at: NSPoint(x: cardRect.midX - labelSize.width / 2, y: cardRect.midY - labelSize.height / 2),
            withAttributes: attributes
        )

        if item.category == .audio {
            drawAudioGlyph(in: cardRect, size: size)
        } else if item.category == .archive {
            drawArchiveGlyph(in: cardRect, size: size)
        } else if item.category == .code {
            drawCodeGlyph(in: cardRect, size: size)
        }

        image.unlockFocus()
        return image
    }

    private func accentColor(for item: FileItem) -> NSColor {
        let ext = item.url.pathExtension.lowercased()
        switch item.category {
        case .document:
            if ext == "pdf" { return NSColor(calibratedRed: 0.82, green: 0.16, blue: 0.14, alpha: 1) }
            if ["xls", "xlsx", "numbers"].contains(ext) { return NSColor(calibratedRed: 0.12, green: 0.55, blue: 0.28, alpha: 1) }
            if ["ppt", "pptx", "key"].contains(ext) { return NSColor(calibratedRed: 0.86, green: 0.36, blue: 0.14, alpha: 1) }
            return NSColor(calibratedRed: 0.18, green: 0.38, blue: 0.78, alpha: 1)
        case .audio:
            return NSColor(calibratedRed: 0.46, green: 0.28, blue: 0.82, alpha: 1)
        case .archive:
            return NSColor(calibratedRed: 0.38, green: 0.35, blue: 0.46, alpha: 1)
        case .code:
            return NSColor(calibratedRed: 0.15, green: 0.45, blue: 0.58, alpha: 1)
        default:
            return .systemGray
        }
    }

    private func label(for item: FileItem) -> String {
        let ext = item.url.pathExtension.uppercased()
        if !ext.isEmpty {
            return String(ext.prefix(5))
        }

        switch item.category {
        case .audio: return "AUD"
        case .archive: return "ZIP"
        case .code: return "CODE"
        case .document: return "DOC"
        default: return "FILE"
        }
    }

    private func drawAudioGlyph(in rect: NSRect, size: CGFloat) {
        NSColor.white.withAlphaComponent(0.35).setStroke()
        let path = NSBezierPath()
        path.lineWidth = max(1.5, size * 0.025)
        let y = rect.minY + size * 0.18
        for index in 0..<5 {
            let x = rect.minX + size * (0.18 + CGFloat(index) * 0.09)
            path.move(to: NSPoint(x: x, y: y))
            path.line(to: NSPoint(x: x, y: y + size * CGFloat([0.10, 0.18, 0.28, 0.18, 0.10][index])))
        }
        path.stroke()
    }

    private func drawArchiveGlyph(in rect: NSRect, size: CGFloat) {
        NSColor.white.withAlphaComponent(0.35).setFill()
        for index in 0..<4 {
            let box = NSRect(
                x: rect.minX + size * (0.20 + CGFloat(index % 2) * 0.12),
                y: rect.minY + size * (0.16 + CGFloat(index / 2) * 0.10),
                width: size * 0.09,
                height: size * 0.07
            )
            NSBezierPath(roundedRect: box, xRadius: size * 0.01, yRadius: size * 0.01).fill()
        }
    }

    private func drawCodeGlyph(in rect: NSRect, size: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: max(9, size * 0.13), weight: .bold),
            .foregroundColor: NSColor.white.withAlphaComponent(0.38)
        ]
        "</>".draw(at: NSPoint(x: rect.minX + size * 0.20, y: rect.minY + size * 0.16), withAttributes: attributes)
    }
}
