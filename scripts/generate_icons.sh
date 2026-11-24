#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ICONSET_DIR="/tmp/PomodoroIcon.iconset"

mkdir -p "$ICONSET_DIR"
mkdir -p "$ROOT_DIR/Resources"

# Generate base PNG using Swift CoreGraphics
TMPDIR=/tmp/swift-tmp swift -module-cache-path /tmp/swift-tmp/clang-cache - << 'EOF'
import Cocoa

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

guard let context = NSGraphicsContext.current?.cgContext else {
    exit(1)
}

// Background rounded squircle / macOS App Icon shape
let rect = CGRect(origin: .zero, size: size)
let path = CGPath(roundedRect: rect.insetBy(dx: 48, dy: 48), cornerWidth: 224, cornerHeight: 224, transform: nil)

context.saveGState()
context.addPath(path)
context.clip()

// Vibrant background gradient (crimson to deep warm ruby)
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bgColors = [
    NSColor(red: 0.95, green: 0.22, blue: 0.23, alpha: 1.0).cgColor,
    NSColor(red: 0.75, green: 0.08, blue: 0.12, alpha: 1.0).cgColor
] as CFArray
if let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
    context.drawLinearGradient(bgGradient, start: CGPoint(x: 512, y: 1024), end: CGPoint(x: 512, y: 0), options: [])
}
context.restoreGState()

// Draw subtle inner shadow / glow
context.saveGState()
context.addPath(path)
context.setStrokeColor(NSColor(white: 1.0, alpha: 0.25).cgColor)
context.setLineWidth(12)
context.strokePath()
context.restoreGState()

// Draw Pomodoro Timer Dial Ring
context.saveGState()
let dialCenter = CGPoint(x: 512, y: 470)
let dialRadius: CGFloat = 260
let dialRect = CGRect(x: dialCenter.x - dialRadius, y: dialCenter.y - dialRadius, width: dialRadius * 2, height: dialRadius * 2)

// Dial background
context.setFillColor(NSColor(white: 0.0, alpha: 0.15).cgColor)
context.fillEllipse(in: dialRect)

// Outer dial ticks
context.setStrokeColor(NSColor(white: 1.0, alpha: 0.8).cgColor)
context.setLineWidth(8)
context.strokeEllipse(in: dialRect)

// Dial ticks (12 hour / 4 quadrant marks)
for i in 0..<12 {
    let angle = CGFloat(i) * (.pi / 6)
    let isMajor = (i % 3 == 0)
    let innerR = dialRadius - (isMajor ? 36 : 20)
    let outerR = dialRadius - 8
    let p1 = CGPoint(x: dialCenter.x + innerR * cos(angle), y: dialCenter.y + innerR * sin(angle))
    let p2 = CGPoint(x: dialCenter.x + outerR * cos(angle), y: dialCenter.y + outerR * sin(angle))
    
    context.setStrokeColor(NSColor(white: 1.0, alpha: isMajor ? 0.9 : 0.5).cgColor)
    context.setLineWidth(isMajor ? 8 : 4)
    context.strokeLineSegments(between: [p1, p2])
}

// Timer hand / pointer
let handAngle: CGFloat = .pi / 3 // 25 min approx
let handLength: CGFloat = dialRadius * 0.72
let handEnd = CGPoint(x: dialCenter.x + handLength * cos(handAngle), y: dialCenter.y + handLength * sin(handAngle))
context.setStrokeColor(NSColor.white.cgColor)
context.setLineWidth(14)
context.setLineCap(.round)
context.strokeLineSegments(between: [dialCenter, handEnd])

// Center pivot
context.setFillColor(NSColor.white.cgColor)
context.fillEllipse(in: CGRect(x: dialCenter.x - 22, y: dialCenter.y - 22, width: 44, height: 44))
context.restoreGState()

// Top Tomato Leaf Stem
context.saveGState()
context.setFillColor(NSColor(red: 0.30, green: 0.75, blue: 0.35, alpha: 1.0).cgColor)

let leaf1 = CGMutablePath()
leaf1.move(to: CGPoint(x: 512, y: 750))
leaf1.addQuadCurve(to: CGPoint(x: 430, y: 840), control: CGPoint(x: 440, y: 770))
leaf1.addQuadCurve(to: CGPoint(x: 512, y: 750), control: CGPoint(x: 490, y: 810))
context.addPath(leaf1)
context.fillPath()

let leaf2 = CGMutablePath()
leaf2.move(to: CGPoint(x: 512, y: 750))
leaf2.addQuadCurve(to: CGPoint(x: 594, y: 840), control: CGPoint(x: 584, y: 770))
leaf2.addQuadCurve(to: CGPoint(x: 512, y: 750), control: CGPoint(x: 534, y: 810))
context.addPath(leaf2)
context.fillPath()

let stem = CGMutablePath()
stem.move(to: CGPoint(x: 512, y: 750))
stem.addQuadCurve(to: CGPoint(x: 520, y: 880), control: CGPoint(x: 530, y: 810))
stem.addQuadCurve(to: CGPoint(x: 502, y: 750), control: CGPoint(x: 508, y: 810))
context.addPath(stem)
context.fillPath()
context.restoreGState()

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    exit(1)
}

let outputPath = "/tmp/PomodoroIcon.iconset/icon_512x512@2x.png"
try! pngData.write(to: URL(fileURLWithPath: outputPath))
EOF

# Resize into standard iconset resolutions using sips
BASE_PNG="/tmp/PomodoroIcon.iconset/icon_512x512@2x.png"
cp "$BASE_PNG" "$ROOT_DIR/Resources/AppIcon.png"

sips -z 16 16     "$BASE_PNG" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     "$BASE_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$BASE_PNG" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     "$BASE_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$BASE_PNG" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   "$BASE_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$BASE_PNG" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   "$BASE_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$BASE_PNG" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null

# Compile to .icns
iconutil -c icns "$ICONSET_DIR" -o "$ROOT_DIR/Resources/AppIcon.icns"
rm -rf "$ICONSET_DIR"

echo "✓ Created Resources/AppIcon.icns and Resources/AppIcon.png"
