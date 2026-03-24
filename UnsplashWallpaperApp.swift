//
//  UnsplashWallpaperApp.swift
//  Unsplash Wallpaper
//

import SwiftUI

@main
struct UnsplashWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        
        // Check and sync login item status on launch
        let loginItemManager = LoginItemManager.shared
        if loginItemManager.isAutoStartEnabled {
            loginItemManager.updateLoginItemStatus()
        }
    }
    
    func setupMenuBar() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())
        self.popover = popover
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "photo.fill", accessibilityDescription: "Wallpaper")
        statusItem?.button?.action = #selector(togglePopover)
        statusItem?.button?.target = self
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
