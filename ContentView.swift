//
//  ContentView.swift
//  Unsplash Wallpaper
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WallpaperViewModel()
    @State private var selectedImage: UnsplashImage?
    @State private var showingDetail = false
    
    let columns = [
        GridItem(.adaptive(minimum: 250), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)
                .frame(minWidth: 200)
            
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search photos...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding()
                
                // Image grid
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.images.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No images found")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.images) { image in
                                ImageCard(image: image)
                                    .onTapGesture {
                                        selectedImage = image
                                        showingDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let image = selectedImage {
                    ImageDetailView(image: image, viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Unsplash Wallpaper")
        .toolbar {
            ToolbarItem {
                Button(action: { viewModel.refreshImages() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            viewModel.loadImages()
        }
    }
}

struct ImageCard: View {
    let image: UnsplashImage
    @State private var loadedImage: NSImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let nsImage = loadedImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(image.description ?? "Untitled")
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("by \(image.user.name)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if image.likes > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                            Text("\(image.likes)")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: image.urls.small) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let nsImage = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = nsImage
                }
            }
        }.resume()
    }
}

struct SidebarView: View {
    @ObservedObject var viewModel: WallpaperViewModel
    
    var body: some View {
        List {
            Section("Categories") {
                ForEach(WallpaperCategory.allCases) { category in
                    Button(action: {
                        viewModel.selectedCategory = category
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                            Spacer()
                            if viewModel.selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section("Collections") {
                Button(action: {
                    viewModel.selectedCategory = .editorial
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Editorial")
                        Spacer()
                        if viewModel.selectedCategory == .editorial {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.selectedCategory = .wallpapers
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Wallpapers")
                        Spacer()
                        if viewModel.selectedCategory == .wallpapers {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
