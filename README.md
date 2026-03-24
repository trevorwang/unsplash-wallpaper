# Unsplash Wallpaper

A beautiful macOS menu bar app that brings stunning Unsplash wallpapers to your desktop. Browse, search, and set high-quality photos from Unsplash with ease.

![Unsplash Wallpaper Screenshot](screenshot.png)

## Features

- **Browse Gallery** - Explore curated collections and categories
- **Smart Search** - Find the perfect wallpaper with real-time search
- **Categories** - Nature, Architecture, People, Technology, Animals, Travel, and more
- **One-Click Set** - Set wallpapers instantly for all screens or specific displays
- **Image Quality** - Choose between Small, Regular, or Full resolution
- **Menu Bar Access** - Quick access from the menu bar with random wallpaper picker
- **Auto-Change** - Automatically change wallpapers at intervals (15min, 30min, hourly, daily)
- **Start at Login** - Optional auto-start when you log in
- **Download** - Save your favorite wallpapers locally

## Requirements

- macOS 11.0+
- Unsplash API Access Key (free)

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/unsplash-wallpaper.git
cd unsplash-wallpaper
```

2. Open in Xcode:
```bash
open wallpaper.xcodeproj
```

3. Build and run (⌘+R)

### Download

Download the latest release from the [Releases](https://github.com/yourusername/unsplash-wallpaper/releases) page.

## Setup

1. Get your free API key from [Unsplash Developers](https://unsplash.com/developers)
2. Open the app and go to **Preferences** (⌘+,)
3. Enter your API Access Key in the General tab
4. Start browsing wallpapers!

## Usage

### Main Window
- Browse categories in the sidebar
- Search for specific wallpapers
- Click any image to view details
- Click "Set as Wallpaper" to apply

### Menu Bar
- Click the photo icon in your menu bar
- Click "Random Wallpaper" for instant refresh
- Toggle "Auto-change" for automatic rotation
- Click "Browse Gallery" to open the main window

### Settings

**General:**
- API Access Key
- Start at login
- Download location

**Appearance:**
- Image quality (Small/Regular/Full)
- Auto-change interval

## Development

### Build

```bash
# Build debug version
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper build

# Build release version
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper -configuration Release build
```

### Project Structure

```
wallpaper/
├── ContentView.swift           # Main window UI
├── ImageDetailView.swift       # Image detail modal
├── MenuBarView.swift           # Menu bar popup UI
├── SettingsView.swift          # Preferences window
├── WallpaperViewModel.swift    # Main view model
├── WallpaperManager.swift      # Wallpaper setting logic
├── UnsplashService.swift       # Unsplash API client
├── UnsplashImage.swift         # Data models
├── LoginItemManager.swift      # Auto-start management
└── UnsplashWallpaperApp.swift  # App entry point
```

## Tech Stack

- **Language:** Swift
- **Framework:** SwiftUI
- **Platforms:** AppKit, ServiceManagement
- **Concurrency:** async/await, Combine
- **Architecture:** MVVM

## License

MIT License - see [LICENSE](LICENSE) file

## Credits

- Wallpapers powered by [Unsplash](https://unsplash.com)
- Built with ❤️ using SwiftUI

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Note:** This is an unofficial app and is not affiliated with Unsplash.
