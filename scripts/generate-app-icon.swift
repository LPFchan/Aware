#!/usr/bin/env swift
import AppKit
import Foundation

let sizes: [(Int, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let projectDir = scriptDir.deletingLastPathComponent()
let iconsetDir = projectDir.appendingPathComponent("Aware/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

let config = NSImage.SymbolConfiguration(pointSize: 512, weight: .regular)
guard let symbol = NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) else {
    print("Failed to load SF Symbol")
    exit(1)
}

for (size, name) in sizes {
    let config = NSImage.SymbolConfiguration(pointSize: CGFloat(size), weight: .regular)
    guard let sym = NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else { exit(1) }
    
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    NSColor.black.set()
    sym.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
             from: .zero, operation: .sourceOver, fraction: 1.0)
    image.unlockFocus()
    
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(name)")
        exit(1)
    }
    
    let url = iconsetDir.appendingPathComponent("\(name).png")
    try png.write(to: url)
    print("Generated \(name).png")
}

let contents = """
{
  "images" : [
    { "idiom" : "mac", "size" : "16x16", "filename" : "icon_16x16.png" },
    { "idiom" : "mac", "size" : "16x16", "scale" : "2x", "filename" : "icon_16x16@2x.png" },
    { "idiom" : "mac", "size" : "32x32", "filename" : "icon_32x32.png" },
    { "idiom" : "mac", "size" : "32x32", "scale" : "2x", "filename" : "icon_32x32@2x.png" },
    { "idiom" : "mac", "size" : "128x128", "filename" : "icon_128x128.png" },
    { "idiom" : "mac", "size" : "128x128", "scale" : "2x", "filename" : "icon_128x128@2x.png" },
    { "idiom" : "mac", "size" : "256x256", "filename" : "icon_256x256.png" },
    { "idiom" : "mac", "size" : "256x256", "scale" : "2x", "filename" : "icon_256x256@2x.png" },
    { "idiom" : "mac", "size" : "512x512", "filename" : "icon_512x512.png" },
    { "idiom" : "mac", "size" : "512x512", "scale" : "2x", "filename" : "icon_512x512@2x.png" }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
"""
try contents.write(to: iconsetDir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
print("Created Contents.json")
print("Done. Add Assets.xcassets to the Xcode project and set ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon")
