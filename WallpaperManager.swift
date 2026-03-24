//
//  WallpaperManager.swift
//  Unsplash Wallpaper
//

import Foundation
import AppKit

class WallpaperManager {
    static let shared = WallpaperManager()
    
    private init() {}
    
    func setWallpaper(image: NSImage, screen: NSScreen? = nil) throws {
        let targetScreen = screen ?? NSScreen.main
        guard let screen = targetScreen else {
            throw WallpaperManagerError.noScreenAvailable
        }
        
        // Create a temporary file for the wallpaper
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "wallpaper_\(UUID().uuidString).jpg"
        let fileURL = tempDir.appendingPathComponent(filename)
        
        // Convert NSImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.95) else {
            throw WallpaperManagerError.failedToConvertImage
        }
        
        // Write to temporary file
        try imageData.write(to: fileURL)
        
        // Set the wallpaper using NSWorkspace
        do {
            try NSWorkspace.shared.setDesktopImageURL(fileURL, for: screen, options: [:])
        } catch {
            // Fallback to using AppleScript if NSWorkspace fails
            try setWallpaperUsingAppleScript(fileURL: fileURL, screen: screen)
        }
        
        // Clean up old temporary files (keep last 10)
        cleanupTempFiles()
    }
    
    func setWallpaperForAllScreens(image: NSImage) throws {
        for screen in NSScreen.screens {
            try setWallpaper(image: image, screen: screen)
        }
    }
    
    private func setWallpaperUsingAppleScript(fileURL: URL, screen: NSScreen) throws {
        let script = """
        tell application "System Events"
            tell every desktop
                set picture to "\(fileURL.path)"
            end tell
        end tell
        """
        
        var errorInfo: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw WallpaperManagerError.failedToCreateAppleScript
        }
        
        appleScript.executeAndReturnError(&errorInfo)
        
        if let error = errorInfo {
            let errorMessage = error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"
            throw WallpaperManagerError.appleScriptError(message: errorMessage)
        }
    }
    
    private func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let wallpaperFiles = files.filter { $0.lastPathComponent.hasPrefix("wallpaper_") }
            
            // Sort by modification date and keep only the 10 most recent
            let sortedFiles = wallpaperFiles.sorted { url1, url2 in
                let date1 = (try? FileManager.default.attributesOfItem(atPath: url1.path)[.modificationDate] as? Date) ?? Date.distantPast
                let date2 = (try? FileManager.default.attributesOfItem(atPath: url2.path)[.modificationDate] as? Date) ?? Date.distantPast
                return date1 > date2
            }
            
            if sortedFiles.count > 10 {
                for file in sortedFiles.dropFirst(10) {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("Failed to cleanup temp files: \(error)")
        }
    }
    
    func getCurrentWallpaperURL(for screen: NSScreen? = nil) -> URL? {
        let targetScreen = screen ?? NSScreen.main
        guard let screen = targetScreen else { return nil }
        return NSWorkspace.shared.desktopImageURL(for: screen)
    }
}

// Extension to convert NSImage to JPEG data
extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: compressionQuality
        ]
        
        return bitmapImage.representation(using: .jpeg, properties: properties)
    }
}

enum WallpaperManagerError: Error, LocalizedError {
    case noScreenAvailable
    case failedToConvertImage
    case failedToSetWallpaper
    case failedToCreateAppleScript
    case appleScriptError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .noScreenAvailable:
            return "No screen available"
        case .failedToConvertImage:
            return "Failed to convert image"
        case .failedToSetWallpaper:
            return "Failed to set wallpaper"
        case .failedToCreateAppleScript:
            return "Failed to create AppleScript"
        case .appleScriptError(let message):
            return "AppleScript error: \(message)"
        }
    }
}
