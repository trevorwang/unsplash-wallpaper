//
//  MenuBarView.swift
//  Unsplash Wallpaper
//

import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = WallpaperViewModel()
    @State private var currentWallpaper: NSImage?
    @State private var isAutoChanging = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "photo.fill")
                    .font(.title2)
                Text("Unsplash Wallpaper")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            // Current wallpaper preview
            if let wallpaper = currentWallpaper {
                Image(nsImage: wallpaper)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(8)
                    .padding(.horizontal)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .cornerRadius(8)
                    .overlay(
                        Text("No wallpaper set")
                            .foregroundColor(.secondary)
                    )
                    .padding(.horizontal)
            }
            
            // Quick actions
            VStack(spacing: 8) {
                Button(action: {
                    Task {
                        await viewModel.setRandomWallpaper()
                        loadCurrentWallpaper()
                    }
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Random Wallpaper")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    openMainWindow()
                }) {
                    HStack {
                        Image(systemName: "photo.stack")
                        Text("Browse Gallery")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                // Auto-change toggle
                Toggle("Auto-change every hour", isOn: $isAutoChanging)
                    .onChange(of: isAutoChanging) { newValue in
                        if newValue {
                            startAutoChange()
                        } else {
                            stopAutoChange()
                        }
                    }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Footer
            HStack {
                Button("Preferences...") {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                .buttonStyle(.link)
                
                Spacer()
                
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.link)
            }
            .padding()
        }
        .frame(width: 280, height: 380)
        .onAppear {
            loadCurrentWallpaper()
            viewModel.loadImages()
        }
        .onDisappear {
            stopAutoChange()
        }
    }
    
    private func loadCurrentWallpaper() {
        if let screen = NSScreen.main,
           let url = NSWorkspace.shared.desktopImageURL(for: screen),
           let image = NSImage(contentsOf: url) {
            currentWallpaper = image
        }
    }
    
    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "Unsplash Wallpaper" }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    private func startAutoChange() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task {
                await viewModel.setRandomWallpaper()
                DispatchQueue.main.async {
                    self.loadCurrentWallpaper()
                }
            }
        }
        timer?.fire()
    }
    
    private func stopAutoChange() {
        timer?.invalidate()
        timer = nil
    }
}
