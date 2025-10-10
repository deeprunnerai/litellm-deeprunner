# Creating a Custom Icon for LiteLLM DeepRunner App

## Design Concept

**Theme:** Fast AI/LLM gateway
**Elements:**
- 🚅 High-speed train emoji (representing speed and efficiency)
- 🏃‍♂️ Running man emoji (representing DeepRunner)
- Blue gradient background (tech/professional)
- "LiteLLM" text
- "DeepRunner" subtitle

## Quick Method: Online Icon Generator

### Option 1: Using Canva (Recommended)

1. **Go to Canva.com** (free account)

2. **Create custom size:**
   - Click "Create a design"
   - Custom dimensions: 1024 x 1024 px

3. **Design the icon:**
   ```
   Background: Blue gradient (#1e3a8a → #3b82f6)

   Center content:
   🚅 (emoji, size: 280pt, position: top-center)

   Text "LiteLLM"
   - Font: Helvetica Bold
   - Size: 180pt
   - Color: White
   - Position: middle-center

   Text "DeepRunner"
   - Font: Helvetica
   - Size: 90pt
   - Color: White
   - Position: bottom-center
   ```

4. **Export:**
   - Download as PNG (1024x1024)
   - Save as `icon_source.png`

5. **Convert to .icns:**
   - Visit: https://cloudconvert.com/png-to-icns
   - Upload `icon_source.png`
   - Download `icon_source.icns`
   - Rename to `AppIcon.icns`

6. **Install in app:**
   ```bash
   mkdir -p "LiteLLM DeepRunner.app/Contents/Resources"
   cp icon_source.icns "LiteLLM DeepRunner.app/Contents/Resources/AppIcon.icns"
   ```

### Option 2: Using SF Symbols (macOS Built-in)

1. **Open SF Symbols app** (pre-installed on macOS)

2. **Search for relevant symbols:**
   - "bolt.fill" (speed)
   - "cpu" (processing)
   - "network" (connectivity)

3. **Export as PNG** (1024x1024)

4. **Follow steps 5-6 from Option 1**

### Option 3: Using Emoji (Simplest)

1. **Create a simple emoji icon:**
   - Open **Preview.app**
   - File → New from Clipboard
   - Paste this emoji: 🚅
   - Resize to 1024x1024
   - Export as PNG

2. **Convert and install** (steps 5-6 from Option 1)

## Automated Method: Using Script

If you have ImageMagick installed:

```bash
# Install ImageMagick (if needed)
brew install imagemagick

# Run the icon creation script
./scripts/create-app-icon.sh
```

This will automatically:
- Generate a gradient background
- Add the train emoji
- Add "LiteLLM" and "DeepRunner" text
- Create all required icon sizes
- Convert to .icns format
- Install in the app bundle

## Manual Method: DIY in Preview

1. **Open Preview.app**

2. **Create new image:**
   - File → New from Clipboard
   - Or: Screenshot an emoji 🚅 at large size

3. **Resize:**
   - Tools → Adjust Size
   - Width: 1024 pixels
   - Height: 1024 pixels
   - Resolution: 72 pixels/inch

4. **Save as PNG**

5. **Convert to .icns using sips:**
   ```bash
   mkdir AppIcon.iconset

   # Generate all sizes
   sips -z 16 16 icon_source.png --out AppIcon.iconset/icon_16x16.png
   sips -z 32 32 icon_source.png --out AppIcon.iconset/icon_16x16@2x.png
   sips -z 32 32 icon_source.png --out AppIcon.iconset/icon_32x32.png
   sips -z 64 64 icon_source.png --out AppIcon.iconset/icon_32x32@2x.png
   sips -z 128 128 icon_source.png --out AppIcon.iconset/icon_128x128.png
   sips -z 256 256 icon_source.png --out AppIcon.iconset/icon_128x128@2x.png
   sips -z 256 256 icon_source.png --out AppIcon.iconset/icon_256x256.png
   sips -z 512 512 icon_source.png --out AppIcon.iconset/icon_256x256@2x.png
   sips -z 512 512 icon_source.png --out AppIcon.iconset/icon_512x512.png
   sips -z 1024 1024 icon_source.png --out AppIcon.iconset/icon_512x512@2x.png

   # Convert to .icns
   iconutil -c icns AppIcon.iconset

   # Move to app
   mv AppIcon.icns "LiteLLM DeepRunner.app/Contents/Resources/"
   ```

## Verifying Icon Installation

1. **Check if icon file exists:**
   ```bash
   ls -la "LiteLLM DeepRunner.app/Contents/Resources/AppIcon.icns"
   ```

2. **Verify Info.plist has icon reference:**
   ```bash
   grep -A1 "CFBundleIconFile" "LiteLLM DeepRunner.app/Contents/Info.plist"
   ```

   Should show:
   ```xml
   <key>CFBundleIconFile</key>
   <string>AppIcon</string>
   ```

3. **Refresh Finder cache:**
   ```bash
   # Touch the app to refresh
   touch "LiteLLM DeepRunner.app"

   # Force Finder to reload
   killall Finder
   ```

4. **Test:**
   - Look at app in Finder
   - Icon should appear
   - If not, try moving app to Desktop and back

## Design Tips

- **Keep it simple:** Icons look best with minimal elements
- **High contrast:** Use bold colors that stand out
- **Test at small sizes:** Icon should be recognizable at 16x16
- **Use vector when possible:** SF Symbols are crisp at any size
- **Avoid text at small sizes:** Text becomes unreadable below 128px

## Recommended Color Schemes

**Option 1: Blue Gradient (Tech)**
- Start: `#1e3a8a` (deep blue)
- End: `#3b82f6` (bright blue)

**Option 2: Green Gradient (AI)**
- Start: `#065f46` (deep green)
- End: `#10b981` (bright green)

**Option 3: Purple Gradient (Creative)**
- Start: `#5b21b6` (deep purple)
- End: `#a78bfa` (light purple)

## Resources

- **SF Symbols:** Pre-installed on macOS (search in Spotlight)
- **Canva:** https://canva.com (free design tool)
- **IconJar:** https://geticonjar.com (icon management)
- **PNG to ICNS:** https://cloudconvert.com/png-to-icns
- **Icon Slate:** Mac App Store (premium icon editor)

---

**Pro Tip:** Once you create a great icon, save it to the repo so team members can use the same one!

```bash
# Save source icon to repo
cp icon_source.png icons/litellm-icon-source.png
git add icons/litellm-icon-source.png
git commit -m "Add app icon source file"
```
