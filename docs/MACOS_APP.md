# macOS Application for LiteLLM DeepRunner

## Overview

A native macOS application bundle that launches LiteLLM with one click. No need to remember terminal commands or Docker Compose - just double-click and go!

## What It Does

1. **Opens Browser** - Launches your default browser
2. **Navigates to LiteLLM** - Opens the production LiteLLM UI at `https://prod.litellm.deeprunner.ai/ui`
3. **Shows Notification** - Displays a macOS notification when launching

**Note:** This app connects to the **production server** - no Docker required!

## Installation

### Option 1: Copy to Applications

```bash
cp -r "LiteLLM DeepRunner.app" /Applications/
```

Then open from Launchpad or Applications folder.

### Option 2: Add to Desktop

```bash
cp -r "LiteLLM DeepRunner.app" ~/Desktop/
```

Double-click from your Desktop.

### Option 3: Add to Dock

1. Copy to Applications (Option 1)
2. Open the app once
3. Right-click the icon in Dock → Options → Keep in Dock

## Usage

**Simply double-click the app!**

The app will:
- Show a notification when starting services
- Open your browser to `https://prod.litellm.deeprunner.ai/ui`
- Continue running in the background

## First Launch

On first launch, macOS may show a security warning:

```
"LiteLLM DeepRunner" cannot be opened because it is from an unidentified developer.
```

**To allow:**
1. Right-click the app → Open
2. Click "Open" in the dialog
3. macOS will remember your choice

**Alternative (System Settings):**
1. System Settings → Privacy & Security
2. Scroll down to "Security" section
3. Click "Open Anyway" next to the blocked app message

## Requirements

- **macOS 10.13+** (High Sierra or later)
- **Internet Connection** (to access production server)
- **Default Browser** (Safari, Chrome, Firefox, etc.)

## How It Works

The app is a standard macOS `.app` bundle containing:

```
LiteLLM DeepRunner.app/
├── Contents/
│   ├── Info.plist          # App metadata
│   ├── MacOS/
│   │   └── LiteLLM DeepRunner  # Launcher script
│   └── Resources/          # (Future: custom icon)
```

The launcher script (`Contents/MacOS/LiteLLM DeepRunner`):
- Simple bash script (12 lines!)
- Uses macOS notifications (`osascript`)
- Opens production URL in default browser

## Customization

### Change URL

Edit `LiteLLM DeepRunner.app/Contents/MacOS/LiteLLM DeepRunner`:

```bash
# Change this line:
open "https://prod.litellm.deeprunner.ai/ui"

# To your preferred URL (e.g., for local development):
open "http://localhost:3000/ui"
```

### Add Custom Icon

1. Create or download an `.icns` icon file
2. Save as `LiteLLM DeepRunner.app/Contents/Resources/AppIcon.icns`
3. Update `Info.plist`:
   ```xml
   <key>CFBundleIconFile</key>
   <string>AppIcon</string>
   ```

## Troubleshooting

### App Won't Open

**Error:** "App is damaged and can't be opened"

**Solution:** Remove quarantine attribute:
```bash
xattr -cr "LiteLLM DeepRunner.app"
```

### Browser Doesn't Open

- Check your default browser settings
- Manually open: `https://prod.litellm.deeprunner.ai/ui`
- Try a different browser

### Can't Connect to Server

- Check internet connection
- Verify server is running: `ping prod.litellm.deeprunner.ai`
- Check if URL has changed

## Uninstallation

```bash
# Remove from Applications
rm -rf /Applications/"LiteLLM DeepRunner.app"

# Remove from Desktop
rm -rf ~/Desktop/"LiteLLM DeepRunner.app"

# Remove from Dock
# Right-click icon → Options → Remove from Dock
```

## Development

### Rebuilding the App

If you modify the launcher script:

```bash
# Make script executable
chmod +x "LiteLLM DeepRunner.app/Contents/MacOS/LiteLLM DeepRunner"

# Test it
open "LiteLLM DeepRunner.app"
```

### Creating a DMG (Optional)

To distribute to team members:

```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "LiteLLM DeepRunner" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 425 120 \
  "LiteLLM-DeepRunner.dmg" \
  "LiteLLM DeepRunner.app"
```

## Security Notes

- App uses local Bash scripts (no external code)
- Only accesses localhost (no internet required)
- Runs Docker commands (requires Docker permissions)
- Source code in `Contents/MacOS/LiteLLM DeepRunner` (plain text)

## Future Enhancements

- [ ] Custom app icon
- [ ] Menu bar status indicator
- [ ] "Stop Services" option
- [ ] View logs from app
- [ ] Automatic updates
- [ ] System tray integration

---

**Made with ❤️ for DeepRunner.ai**
