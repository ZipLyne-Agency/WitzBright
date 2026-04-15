#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "→ Building Witz Lyte (release, arm64)..."
swift build -c release --arch arm64

APP="dist/Witz Lyte.app"
rm -rf dist
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp .build/arm64-apple-macosx/release/WitzLyte "$APP/Contents/MacOS/WitzLyte"
cp Resources/Info.plist "$APP/Contents/Info.plist"
[ -f Resources/AppIcon.icns ] && cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

echo "→ Ad-hoc signing..."
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo ""
echo "✅ Built: $APP"
echo "   Run:     open \"$APP\""
echo "   Install: mv \"$APP\" /Applications/"
