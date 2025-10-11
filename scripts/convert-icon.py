#!/usr/bin/env python3
"""Convert PNG icon to macOS .icns format."""

from PIL import Image
import os
import shutil

# Input and output
input_png = "litellm-deeprunner-icon.png"
iconset_dir = "AppIcon.iconset"

# Icon sizes required for .icns
SIZES = [16, 32, 64, 128, 256, 512, 1024]

# Remove old iconset if exists
if os.path.exists(iconset_dir):
    shutil.rmtree(iconset_dir)

# Create iconset directory
os.makedirs(iconset_dir, exist_ok=True)

# Load source image
print(f"📖 Loading {input_png}...")
img = Image.open(input_png)
print(f"   Original size: {img.size[0]}x{img.size[1]}")

# Generate all required sizes
print(f"\n🔨 Generating icon sizes...")
for size in SIZES:
    # Standard resolution
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    output_path = f"{iconset_dir}/icon_{size}x{size}.png"
    resized.save(output_path)
    print(f"   ✓ {size}x{size}")

    # Retina (@2x) resolution
    if size <= 512:
        resized_2x = img.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
        output_path_2x = f"{iconset_dir}/icon_{size}x{size}@2x.png"
        resized_2x.save(output_path_2x)
        print(f"   ✓ {size}x{size}@2x")

print(f"\n✅ Generated {len(os.listdir(iconset_dir))} icon images in {iconset_dir}/")
print(f"\n🔨 Next: Run iconutil to create .icns file")
print(f"   iconutil -c icns {iconset_dir}")
