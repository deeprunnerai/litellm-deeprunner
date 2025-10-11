#!/usr/bin/env python3
"""Generate macOS app icon with train and runner emojis."""

from PIL import Image, ImageDraw, ImageFont
import os

# Icon sizes required for .icns
SIZES = [16, 32, 64, 128, 256, 512, 1024]

# Create iconset directory
iconset_dir = "AppIcon.iconset"
os.makedirs(iconset_dir, exist_ok=True)

# Base size for design
base_size = 1024

# Create base image with gradient background
img = Image.new('RGB', (base_size, base_size), color='#2563eb')  # Blue background

# Add circular gradient effect
draw = ImageDraw.Draw(img)

# Draw circle background
circle_color = '#3b82f6'
circle_bbox = [base_size * 0.1, base_size * 0.1, base_size * 0.9, base_size * 0.9]
draw.ellipse(circle_bbox, fill=circle_color)

# Try to add text (emojis)
try:
    # Use system font that supports emojis
    font_size = int(base_size * 0.6)
    # Try different emoji fonts
    for font_path in [
        "/System/Library/Fonts/Apple Color Emoji.ttc",
        "/Library/Fonts/Apple Color Emoji.ttc",
    ]:
        if os.path.exists(font_path):
            font = ImageFont.truetype(font_path, font_size)
            # Draw train and runner emojis
            text = "🚅"
            text_bbox = draw.textbbox((0, 0), text, font=font)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]
            x = (base_size - text_width) / 2
            y = (base_size - text_height) / 2 - 50
            draw.text((x, y), text, font=font, embedded_color=True)

            # Add runner
            text2 = "🏃"
            text_bbox2 = draw.textbbox((0, 0), text2, font=font)
            text_width2 = text_bbox2[2] - text_bbox2[0]
            x2 = (base_size - text_width2) / 2
            y2 = y + text_height - 20
            draw.text((x2, y2), text2, font=font, embedded_color=True)
            break
except Exception as e:
    print(f"Could not add emojis: {e}")
    # Fallback: just use solid colors
    pass

# Generate all required sizes
for size in SIZES:
    # Standard resolution
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(f"{iconset_dir}/icon_{size}x{size}.png")

    # Retina (@2x) resolution
    if size <= 512:
        resized_2x = img.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
        resized_2x.save(f"{iconset_dir}/icon_{size}x{size}@2x.png")

print(f"✅ Generated icon images in {iconset_dir}/")
print(f"📦 Total images: {len(os.listdir(iconset_dir))}")
print(f"\nNext step: Run iconutil to create .icns file")
print(f"   iconutil -c icns {iconset_dir}")
