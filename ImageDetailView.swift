//
//  ImageDetailView.swift
//  Unsplash Wallpaper
//

import SwiftUI

struct ImageDetailView: View {
    let image: UnsplashImage
    @ObservedObject var viewModel: WallpaperViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var loadedImage: NSImage?
    @State private var isSettingWallpaper = false
    @State private var showingSuccess = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Close") {
                    dismiss()
                }
                Spacer()
            }
            .padding()
            
            // Image
            if let nsImage = loadedImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 400)
                    .overlay(
                        ProgressView()
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(image.description ?? "Untitled")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Text("Photo by \(image.user.name)")
                        .foregroundColor(.secondary)
                    
                    if let portfolio = image.user.portfolioURL,
                       let url = URL(string: portfolio) {
                        Link("View Profile", destination: url)
                            .font(.caption)
                    }
                }
                
                if let location = image.location?.city {
                    HStack {
                        Image(systemName: "mappin")
                        Text(location)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                HStack(spacing: 16) {
                    Label("\(image.likes)", systemImage: "heart.fill")
                    Label("\(image.downloads ?? 0)", systemImage: "arrow.down.circle.fill")
                    Label("\(image.views ?? 0)", systemImage: "eye.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Spacer()
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    downloadImage()
                }) {
                    Label("Download", systemImage: "arrow.down.circle")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    setWallpaper()
                }) {
                    if isSettingWallpaper {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Label("Set as Wallpaper", systemImage: "photo.fill")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSettingWallpaper)
            }
            .padding()
        }
        .frame(width: 600, height: 700)
        .onAppear {
            loadFullImage()
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Wallpaper has been set successfully!")
        }
    }
    
    private func loadFullImage() {
        guard let url = URL(string: image.urls.regular) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let nsImage = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = nsImage
                }
            }
        }.resume()
    }
    
    private func setWallpaper() {
        isSettingWallpaper = true
        
        Task {
            await viewModel.setWallpaper(from: image)
            
            DispatchQueue.main.async {
                isSettingWallpaper = false
                showingSuccess = true
            }
        }
    }
    
    private func downloadImage() {
        guard let url = URL(string: image.urls.full) else { return }
        
        NSWorkspace.shared.open(url)
    }
}
