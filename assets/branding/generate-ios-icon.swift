// Render every iOS AppIcon slot from the supplied Kinship logo.
// Run from the repository root: swift assets/branding/generate-ios-icon.swift
// Composite transparent corners over ivory #F8F9F6; Apple requires an opaque icon.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let sourceDirectory = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL.deletingLastPathComponent()
let iconDirectory = sourceDirectory.appendingPathComponent("../../ios/Runner/Assets.xcassets/AppIcon.appiconset").standardizedFileURL
let manifest = iconDirectory.appendingPathComponent("Contents.json")
let logoURL = sourceDirectory.appendingPathComponent("../icons/kinship_logo.png").standardizedFileURL

struct Slot: Decodable {
    let size: String
    let scale: String
    let filename: String
}
struct Catalog: Decodable { let images: [Slot] }

let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: manifest))
guard let source = CGImageSourceCreateWithURL(logoURL as CFURL, nil),
      let logo = CGImageSourceCreateImageAtIndex(source, 0, nil),
      logo.width == logo.height else { throw NSError(domain: "Icon", code: 1) }
let ivory = CGColor(red: 248 / 255, green: 249 / 255, blue: 246 / 255, alpha: 1)

func drawIcon(pixels: Int) throws -> Data {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8,
        bytesPerRow: 0, space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else { throw NSError(domain: "Icon", code: 1) }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.interpolationQuality = .high
    let bounds = CGRect(x: 0, y: 0, width: pixels, height: pixels)
    context.setFillColor(ivory)
    context.fill(bounds)
    context.draw(logo, in: bounds)

    guard let image = context.makeImage(),
          let output = CFDataCreateMutable(nil, 0),
          let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil)
    else { throw NSError(domain: "Icon", code: 2) }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw NSError(domain: "Icon", code: 3) }
    return output as Data
}

for slot in catalog.images {
    let pointSize = Double(slot.size.split(separator: "x")[0])!
    let scale = Double(slot.scale.dropLast())!
    let pixels = Int(pointSize * scale)
    try drawIcon(pixels: pixels).write(to: iconDirectory.appendingPathComponent(slot.filename))
    print("\(slot.filename): \(pixels)x\(pixels)")
}
