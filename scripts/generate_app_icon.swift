#!/usr/bin/env swift
import AppKit
import Foundation

let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = projectRoot.appendingPathComponent("Packaging/AppIcon.icns")
let iconsetURL = projectRoot.appendingPathComponent("Packaging/AppIcon.iconset")

let iconFiles: [(name: String, pixels: CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func scaled(_ value: CGFloat, _ size: CGFloat) -> CGFloat {
    value * size / 1024
}

func roundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func strokeRoundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor, width: CGFloat) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    path.lineWidth = width
    color.setStroke()
    path.stroke()
}

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    let outerRect = NSRect(
        x: scaled(96, size),
        y: scaled(92, size),
        width: scaled(832, size),
        height: scaled(840, size)
    )
    let outerRadius = scaled(190, size)
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.05, green: 0.38, blue: 0.55, alpha: 1),
        NSColor(calibratedRed: 0.08, green: 0.66, blue: 0.60, alpha: 1)
    ])
    gradient?.draw(
        in: NSBezierPath(roundedRect: outerRect, xRadius: outerRadius, yRadius: outerRadius),
        angle: 45
    )

    strokeRoundedRect(
        outerRect.insetBy(dx: scaled(18, size), dy: scaled(18, size)),
        radius: scaled(174, size),
        color: NSColor.white.withAlphaComponent(0.28),
        width: max(1, scaled(8, size))
    )

    let windowRect = NSRect(
        x: scaled(192, size),
        y: scaled(214, size),
        width: scaled(640, size),
        height: scaled(596, size)
    )
    roundedRect(windowRect, radius: scaled(72, size), color: NSColor.white.withAlphaComponent(0.96))

    let toolbarRect = NSRect(
        x: windowRect.minX,
        y: windowRect.maxY - scaled(118, size),
        width: windowRect.width,
        height: scaled(118, size)
    )
    roundedRect(toolbarRect, radius: scaled(72, size), color: NSColor(calibratedRed: 0.90, green: 0.96, blue: 0.97, alpha: 1))

    let sidebarRect = NSRect(
        x: windowRect.minX + scaled(28, size),
        y: windowRect.minY + scaled(36, size),
        width: scaled(158, size),
        height: windowRect.height - scaled(180, size)
    )
    roundedRect(sidebarRect, radius: scaled(28, size), color: NSColor(calibratedRed: 0.12, green: 0.50, blue: 0.62, alpha: 0.16))

    for index in 0..<3 {
        let y = sidebarRect.maxY - scaled(CGFloat(52 + index * 84), size)
        roundedRect(
            NSRect(x: sidebarRect.minX + scaled(28, size), y: y, width: scaled(102, size), height: scaled(24, size)),
            radius: scaled(12, size),
            color: NSColor(calibratedRed: 0.12, green: 0.42, blue: 0.50, alpha: 0.36)
        )
    }

    let tileSize = scaled(108, size)
    let tileGap = scaled(34, size)
    let gridStartX = windowRect.minX + scaled(226, size)
    let gridStartY = windowRect.minY + scaled(122, size)

    for row in 0..<3 {
        for col in 0..<3 {
            let rect = NSRect(
                x: gridStartX + CGFloat(col) * (tileSize + tileGap),
                y: gridStartY + CGFloat(row) * (tileSize + tileGap),
                width: tileSize,
                height: tileSize
            )
            roundedRect(rect, radius: scaled(24, size), color: NSColor(calibratedRed: 0.82, green: 0.91, blue: 0.92, alpha: 1))
        }
    }

    let photoRect = NSRect(
        x: gridStartX + tileSize + tileGap,
        y: gridStartY + tileSize + tileGap,
        width: tileSize,
        height: tileSize
    )
    roundedRect(photoRect, radius: scaled(24, size), color: NSColor(calibratedRed: 0.17, green: 0.60, blue: 0.70, alpha: 1))

    let mountain = NSBezierPath()
    mountain.move(to: NSPoint(x: photoRect.minX + scaled(18, size), y: photoRect.minY + scaled(24, size)))
    mountain.line(to: NSPoint(x: photoRect.minX + scaled(48, size), y: photoRect.minY + scaled(64, size)))
    mountain.line(to: NSPoint(x: photoRect.minX + scaled(70, size), y: photoRect.minY + scaled(42, size)))
    mountain.line(to: NSPoint(x: photoRect.minX + scaled(92, size), y: photoRect.minY + scaled(82, size)))
    mountain.line(to: NSPoint(x: photoRect.maxX - scaled(14, size), y: photoRect.minY + scaled(24, size)))
    mountain.close()
    NSColor.white.withAlphaComponent(0.92).setFill()
    mountain.fill()

    roundedRect(
        NSRect(
            x: photoRect.minX + scaled(20, size),
            y: photoRect.maxY - scaled(36, size),
            width: scaled(18, size),
            height: scaled(18, size)
        ),
        radius: scaled(9, size),
        color: NSColor(calibratedRed: 1, green: 0.92, blue: 0.48, alpha: 1)
    )

    image.unlockFocus()
    return image
}

func writePNG(image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SmartFinderIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to render PNG"])
    }
    try png.write(to: url)
}

try? FileManager.default.removeItem(at: iconsetURL)
try? FileManager.default.removeItem(at: outputURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

for file in iconFiles {
    try writePNG(
        image: drawIcon(size: file.pixels),
        to: iconsetURL.appendingPathComponent(file.name)
    )
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", outputURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "SmartFinderIcon", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "iconutil failed"])
}

try FileManager.default.removeItem(at: iconsetURL)
print("Generated \(outputURL.path)")
