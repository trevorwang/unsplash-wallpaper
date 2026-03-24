//
//  LoginItemManager.swift
//  Unsplash Wallpaper
//

import Foundation
import Combine
import ServiceManagement

class LoginItemManager: ObservableObject {
    static let shared = LoginItemManager()
    
    @Published var isAutoStartEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAutoStartEnabled, forKey: "autoStart")
            updateLoginItemStatus()
        }
    }
    
    private init() {
        self.isAutoStartEnabled = UserDefaults.standard.bool(forKey: "autoStart")
    }
    
    func updateLoginItemStatus() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.yourcompany.UnsplashWallpaper"
        
        if #available(macOS 13.0, *) {
            // Use SMAppService for macOS 13+
            let service = SMAppService.loginItem(identifier: "\(bundleIdentifier).helper")
            
            do {
                if isAutoStartEnabled {
                    if service.status == .notFound {
                        try service.register()
                        print("Login item registered successfully")
                    }
                } else {
                    if service.status == .enabled {
                        try service.unregister()
                        print("Login item unregistered successfully")
                    }
                }
            } catch {
                print("Failed to update login item: \(error.localizedDescription)")
            }
        } else {
            // For older macOS versions, use SMLoginItemSetEnabled
            let helperBundleIdentifier = "\(bundleIdentifier).helper"
            let success = SMLoginItemSetEnabled(helperBundleIdentifier as CFString, isAutoStartEnabled)
            if !success {
                print("Failed to update login item status")
            }
        }
    }
    
    func checkLoginItemStatus() -> Bool {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.yourcompany.UnsplashWallpaper"
        
        if #available(macOS 13.0, *) {
            let service = SMAppService.loginItem(identifier: "\(bundleIdentifier).helper")
            return service.status == .enabled
        } else {
            // For older versions, we rely on the stored preference
            return UserDefaults.standard.bool(forKey: "autoStart")
        }
    }
}
