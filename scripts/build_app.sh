#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CACHE_DIR="/tmp/swift-tmp/clang-cache"
APP_NAME="Pomodoro.app"
APP_DIR="$ROOT_DIR/$APP_NAME"

echo "🔨 Building Pomodoro application binary..."
mkdir -p "$CACHE_DIR"

cd "$ROOT_DIR"
swift build \
    --disable-sandbox \
    -c release \
    -Xbuild-tools-swiftc -module-cache-path -Xbuild-tools-swiftc "$CACHE_DIR" \
    -Xswiftc -module-cache-path -Xswiftc "$CACHE_DIR" \
    --product PomodoroApp

BIN_PATH="$(swift build --disable-sandbox -c release --show-bin-path)/PomodoroApp"

if [ ! -f "$BIN_PATH" ]; then
    echo "❌ Error: Could not find built binary at $BIN_PATH"
    exit 1
fi

echo "📦 Creating macOS application bundle structure: $APP_NAME"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/PomodoroApp"
cp "$ROOT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

if [ -f "$ROOT_DIR/Resources/AppIcon.icns" ]; then
    cp "$ROOT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

echo "🔏 Performing ad-hoc code signature..."
codesign --force --deep -s - "$APP_DIR"

echo "✅ Successfully built $APP_NAME!"
echo "👉 You can run it with: open $APP_NAME"
