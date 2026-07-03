import Foundation

public struct PhotoMetadataSummary: Equatable, Sendable {
    public let camera: String?
    public let lens: String?
    public let pixelDimensions: String?
    public let iso: String?
    public let focalLength: String?
    public let aperture: String?
    public let shutterSpeed: String?

    public init(properties: [String: Any]) {
        let tiff = properties["{TIFF}"] as? [String: Any] ?? [:]
        let exif = properties["{Exif}"] as? [String: Any] ?? [:]

        let make = Self.stringValue(tiff["Make"])
        let model = Self.stringValue(tiff["Model"])
        camera = [make, model]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .nilIfEmpty

        lens = Self.stringValue(exif["LensModel"])?.nilIfEmpty

        if let width = Self.integerValue(properties["PixelWidth"]),
           let height = Self.integerValue(properties["PixelHeight"]) {
            pixelDimensions = "\(width) x \(height)"
        } else {
            pixelDimensions = nil
        }

        if let isoValue = Self.isoValue(exif["ISOSpeedRatings"]) {
            iso = "ISO \(isoValue)"
        } else {
            iso = nil
        }

        if let value = Self.doubleValue(exif["FocalLength"]) {
            focalLength = "\(Self.shortNumber(value)) mm"
        } else {
            focalLength = nil
        }

        if let value = Self.doubleValue(exif["FNumber"]) {
            aperture = "f/\(Self.shortNumber(value))"
        } else {
            aperture = nil
        }

        if let exposureTime = Self.doubleValue(exif["ExposureTime"]) {
            shutterSpeed = Self.shutterSpeedString(for: exposureTime)
        } else {
            shutterSpeed = nil
        }
    }

    private static func stringValue(_ value: Any?) -> String? {
        value as? String
    }

    private static func integerValue(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        if let value = value as? NSNumber {
            return value.intValue
        }
        return nil
    }

    private static func doubleValue(_ value: Any?) -> Double? {
        if let value = value as? Double {
            return value
        }
        if let value = value as? NSNumber {
            return value.doubleValue
        }
        return nil
    }

    private static func isoValue(_ value: Any?) -> Int? {
        if let values = value as? [Int] {
            return values.first
        }
        if let values = value as? [NSNumber] {
            return values.first?.intValue
        }
        return integerValue(value)
    }

    private static func shortNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }

    private static func shutterSpeedString(for exposureTime: Double) -> String {
        guard exposureTime > 0 else {
            return ""
        }
        if exposureTime < 1 {
            let denominator = Int((1 / exposureTime).rounded())
            return "1/\(denominator) s"
        }
        return "\(shortNumber(exposureTime)) s"
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
