# AGENTS.md - Unsplash Wallpaper macOS App

This file contains guidelines for agentic coding agents working on this Swift/SwiftUI macOS application.

## Build & Run Commands

```bash
# Build the project
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper build

# Build for release
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper -configuration Release build

# Run tests (if tests exist)
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper test

# Run a specific test
xcodebuild -project wallpaper.xcodeproj -scheme wallpaper -only-testing:wallpaperTests/SpecificTest test

# Clean build
xcodebuild -project wallpaper.xcodeproj clean

# Open in Xcode
open wallpaper.xcodeproj
```

## Code Style Guidelines

### General Formatting
- **Indentation**: 4 spaces (no tabs)
- **Line length**: No strict limit, but keep lines readable
- **Semicolons**: Do not use trailing semicolons
- **Trailing whitespace**: Remove trailing whitespace
- **File headers**: Include standard Swift header comments

```swift
//
//  FileName.swift
//  Unsplash Wallpaper
//
```

### Naming Conventions
- **Types** (classes, structs, enums, protocols): PascalCase
  - Example: `WallpaperManager`, `UnsplashImage`, `ImageQuality`
- **Variables, constants, functions**: camelCase
  - Example: `searchQuery`, `isLoading`, `loadImages()`
- **Private properties**: prefix with underscore only for specific patterns
- **Static/shared instances**: Use `shared` for singletons
- **File names**: Match primary type name (e.g., `WallpaperManager.swift`)

### Imports
- Group imports: Foundation first, then platform frameworks, then third-party
- Keep imports minimal and remove unused ones

```swift
import Foundation
import SwiftUI
import Combine
import AppKit
import ServiceManagement
```

### Type Declarations

#### Classes/Structs
- Use `struct` for data models (Codable, value semantics)
- Use `class` for ObservableObjects, singletons, and reference semantics
- Default access level is `internal` - don't add redundant modifiers

```swift
// Good
class WallpaperManager {
    static let shared = WallpaperManager()
    private init() {}
}

struct UnsplashImage: Codable, Identifiable {
    let id: String
}
```

#### Enums
- Conform to `String` for raw values used in UI
- Implement `Identifiable` for use in SwiftUI Pickers
- Include `LocalizedError` conformance for error enums

```swift
enum ImageQuality: String, CaseIterable, Identifiable {
    case small = "Small"
    case regular = "Regular"
    case full = "Full"
    
    var id: String { rawValue }
}
```

### SwiftUI Patterns

#### ViewModels
- Use `ObservableObject` protocol
- Mark published properties with `@Published`
- Use `[weak self]` in Combine pipelines
- Store cancellables in `Set<AnyCancellable>`

```swift
class WallpaperViewModel: ObservableObject {
    @Published var images: [UnsplashImage] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
}
```

#### Views
- Use `@StateObject` for view-owned view models
- Use `@ObservedObject` for injected view models
- Use `@State` for view-local state
- Use `@AppStorage` for settings backed by UserDefaults
- Use `@Environment(\.dismiss)` for dismissal actions

#### Async/Await
- Prefer `async/await` over completion handlers
- Use `Task` for calling async functions from sync contexts
- Dispatch UI updates to main queue when needed

```swift
func loadImages() {
    Task {
        do {
            let photos = try await service.fetch()
            DispatchQueue.main.async {
                self.images = photos
            }
        } catch {
            // Handle error
        }
    }
}
```

### Error Handling
- Define custom errors as enums conforming to `LocalizedError`
- Provide `errorDescription` for user-friendly messages
- Use `throws` for functions that can fail
- Handle specific HTTP status codes appropriately

```swift
enum WallpaperError: Error, LocalizedError {
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        }
    }
}
```

### JSON Handling
- Use `CodingKeys` enum for snake_case to camelCase conversion
- Use `JSONDecoder().keyDecodingStrategy = .convertFromSnakeCase` for automatic conversion
- Mark optional fields with `?`

```swift
struct UnsplashImage: Codable {
    let id: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
    }
}
```

### Extensions
- Group related functionality in extensions
- Add utility methods to existing types (e.g., `NSImage.jpegData`)

```swift
extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        // Implementation
    }
}
```

### UserDefaults
- Use `@AppStorage` property wrapper for SwiftUI settings views
- Use string keys stored in UserDefaults.standard for other access
- Provide sensible defaults

```swift
@AppStorage("imageQuality") private var imageQuality = ImageQuality.regular

// Or
var accessKey: String {
    UserDefaults.standard.string(forKey: "unsplashAccessKey") ?? ""
}
```

### macOS-Specific Patterns
- Use `NSWorkspace` for system integration (wallpaper setting, opening URLs)
- Use `NSStatusBar` for menu bar items
- Use `SMAppService` (macOS 13+) or `SMLoginItemSetEnabled` for login items
- Use `NSAppleScript` as fallback when native APIs fail

## Project Structure

- **Models**: Data structures (UnsplashImage, User models, etc.)
- **Services**: API clients (UnsplashService)
- **ViewModels**: ObservableObjects managing view state
- **Views**: SwiftUI view components
- **Managers**: Singletons for app-wide functionality (WallpaperManager, LoginItemManager)
- **Extensions**: Utility extensions on existing types

## Testing

- No test target currently exists
- When adding tests, use XCTest framework
- Test naming: `test<MethodName><Condition>()`
- Example: `testFetchPhotosReturnsImages()`

## Dependencies

- **No external package dependencies** - pure Swift/SwiftUI
- Uses Apple frameworks: Foundation, SwiftUI, Combine, AppKit, ServiceManagement
- Minimum deployment target: macOS (check project settings)

## Notes

- This app uses the Unsplash API - requires API key stored in UserDefaults
- Supports both NSWorkspace and AppleScript for wallpaper setting
- Menu bar integration uses NSPopover
- Settings use SwiftUI TabView with Settings scene type
- Follow existing code patterns when adding new features
