#!/bin/bash

# Build native macOS app with WebView
# This creates a proper macOS app that opens LiteLLM in its own window

set -e

APP_NAME="LiteLLM DeepRunner"
APP_BUNDLE="${APP_NAME}.app"
SWIFT_SOURCE="app-source/main.swift"

echo "🔨 Building LiteLLM DeepRunner macOS App"
echo "========================================"
echo ""

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift compiler not found"
    echo "   Xcode Command Line Tools required"
    echo "   Install: xcode-select --install"
    exit 1
fi

echo "✅ Swift compiler found"
echo ""

# Check if source exists
if [ ! -f "$SWIFT_SOURCE" ]; then
    echo "❌ Source file not found: $SWIFT_SOURCE"
    exit 1
fi

echo "📁 Creating app bundle structure..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

echo "🔨 Compiling Swift source..."
swiftc "$SWIFT_SOURCE" \
    -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" \
    -framework Cocoa \
    -framework WebKit

echo "📝 Creating Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>LiteLLM DeepRunner</string>
    <key>CFBundleIdentifier</key>
    <string>ai.deeprunner.litellm</string>
    <key>CFBundleName</key>
    <string>LiteLLM DeepRunner</string>
    <key>CFBundleDisplayName</key>
    <string>LiteLLM DeepRunner</string>
    <key>CFBundleVersion</key>
    <string>0.3.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.3.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 DeepRunner.ai. All rights reserved.</string>
</dict>
</plist>
EOF

# Copy icon if it exists
if [ -f "AppIcon.icns" ]; then
    echo "🎨 Adding app icon..."
    cp AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"
fi

# Code sign the app with entitlements
echo "🔐 Code signing app..."
if [ -f "app-source/LiteLLM.entitlements" ]; then
    codesign --force --deep --sign - \
        --entitlements app-source/LiteLLM.entitlements \
        --options runtime \
        "${APP_BUNDLE}" 2>/dev/null || {
        echo "⚠️  Code signing with entitlements failed, trying without sandbox..."
        # Fallback: try without sandbox
        codesign --force --deep --sign - "${APP_BUNDLE}"
    }
else
    # Simple code signing without entitlements
    codesign --force --deep --sign - "${APP_BUNDLE}"
fi

echo ""
echo "✅ Build complete!"
echo ""
echo "📦 App location: ${APP_BUNDLE}"
echo ""
echo "🚀 To install:"
echo "   cp -r \"${APP_BUNDLE}\" /Applications/"
echo ""
echo "🎨 To add an icon:"
echo "   cp AppIcon.icns \"${APP_BUNDLE}/Contents/Resources/\""
echo ""
echo "▶️  To test:"
echo "   open \"${APP_BUNDLE}\""
echo ""
