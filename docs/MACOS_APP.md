# macOS Application for LiteLLM DeepRunner

## Overview

A native macOS application bundle that launches LiteLLM with one click. No need to remember terminal commands or Docker Compose - just double-click and go!

## What It Does

1. **Checks Docker** - Verifies Docker Desktop is running
2. **Starts Docker** - Opens Docker Desktop if needed
3. **Starts Services** - Launches all LiteLLM containers (`docker compose up -d`)
4. **Opens UI** - Opens LiteLLM admin interface in your default browser

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
- **Docker Desktop** installed
- **Project Directory** must remain at `/Users/gauravdr/Projects/litellm-deeprunner`

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
- Bash script that manages Docker and services
- Uses macOS notifications (`osascript`)
- Finds project directory automatically

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

### Docker Won't Start

- Ensure Docker Desktop is installed
- Check Docker Desktop settings: Running on login
- Manually start Docker, then try the app again

### Services Don't Start

```bash
# Manually check status
cd /Users/gauravdr/Projects/litellm-deeprunner
docker compose ps

# View logs
docker compose logs
```

### Browser Doesn't Open

- Check if port 3000 is in use: `lsof -i :3000`
- Manually open: `http://localhost:3000/ui`

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
