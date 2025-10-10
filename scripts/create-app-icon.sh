#!/bin/bash

# Script to create a macOS app icon for LiteLLM DeepRunner
# Requires ImageMagick: brew install imagemagick

set -e

echo "🎨 Creating LiteLLM DeepRunner App Icon"
echo "========================================"
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found. Please install it:"
    echo "   brew install imagemagick"
    echo ""
    echo "Or create an icon manually using:"
    echo "  1. https://cloudconvert.com/png-to-icns (online converter)"
    echo "  2. https://www.canva.com (design a 1024x1024 icon)"
    echo "  3. Icon Slate (Mac app for .icns creation)"
    exit 1
fi

# Create temp directory
TEMP_DIR="$(mktemp -d)"
ICON_NAME="AppIcon"
OUTPUT_DIR="LiteLLM DeepRunner.app/Contents/Resources"

echo "📁 Creating Resources directory..."
mkdir -p "$OUTPUT_DIR"

# Create a simple icon using ImageMagick
echo "🖼️  Generating icon image..."

# Create base 1024x1024 image with gradient background (blue gradient)
convert -size 1024x1024 \
    gradient:'#1e3a8a'-'#3b82f6' \
    "$TEMP_DIR/base.png"

# Add emoji and text layers
convert "$TEMP_DIR/base.png" \
    -gravity center \
    -pointsize 280 \
    -annotate +0-180 '🚅' \
    -pointsize 180 \
    -fill white \
    -font "Helvetica-Bold" \
    -annotate +0+50 'LiteLLM' \
    -pointsize 90 \
    -annotate +0+160 'DeepRunner' \
    "$TEMP_DIR/icon_1024.png"

# Generate all required icon sizes for macOS
echo "📐 Generating icon sizes..."
sizes=(16 32 64 128 256 512 1024)
iconset="$TEMP_DIR/$ICON_NAME.iconset"
mkdir -p "$iconset"

for size in "${sizes[@]}"; do
    convert "$TEMP_DIR/icon_1024.png" \
        -resize ${size}x${size} \
        "$iconset/icon_${size}x${size}.png"

    # Create @2x versions
    double=$((size * 2))
    convert "$TEMP_DIR/icon_1024.png" \
        -resize ${double}x${double} \
        "$iconset/icon_${size}x${size}@2x.png"
done

# Convert iconset to icns
echo "🎨 Creating .icns file..."
iconutil -c icns "$iconset" -o "$OUTPUT_DIR/$ICON_NAME.icns"

# Update Info.plist to reference the icon
echo "📝 Updating Info.plist..."
PLIST_FILE="LiteLLM DeepRunner.app/Contents/Info.plist"

if ! grep -q "CFBundleIconFile" "$PLIST_FILE"; then
    # Add icon reference before </dict>
    sed -i '' '/<\/dict>/i\
    <key>CFBundleIconFile</key>\
    <string>AppIcon</string>
' "$PLIST_FILE"
fi

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Icon created successfully!"
echo "   Location: $OUTPUT_DIR/$ICON_NAME.icns"
echo ""
echo "🚀 Test the app:"
echo "   open \"LiteLLM DeepRunner.app\""
echo ""
echo "💡 To customize the icon:"
echo "   1. Design a 1024x1024 PNG"
echo "   2. Save as: icon_source.png"
echo "   3. Re-run this script with your custom image"
