//
//  WallpaperViewModel.swift
//  Unsplash Wallpaper
//

import SwiftUI
import Combine

class WallpaperViewModel: ObservableObject {
    @Published var images: [UnsplashImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var selectedCategory: WallpaperCategory = .nature
    
    private var cancellables = Set<AnyCancellable>()
    private let wallpaperManager = WallpaperManager.shared
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.searchImages(query: query)
                } else {
                    self?.loadImages()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadImages() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let photos: [UnsplashImage]
                
                switch selectedCategory {
                case .editorial:
                    photos = try await UnsplashService.shared.fetchPhotos(orderBy: "editorial")
                case .wallpapers:
                    photos = try await UnsplashService.shared.fetchCollectionPhotos(collectionId: "1065976")
                case .nature:
                    photos = try await UnsplashService.shared.searchPhotos(query: "nature", perPage: 30).results
                case .architecture:
                    photos = try await UnsplashService.shared.searchPhotos(query: "architecture", perPage: 30).results
                case .people:
                    photos = try await UnsplashService.shared.searchPhotos(query: "people", perPage: 30).results
                case .technology:
                    photos = try await UnsplashService.shared.searchPhotos(query: "technology", perPage: 30).results
                case .animals:
                    photos = try await UnsplashService.shared.searchPhotos(query: "animals", perPage: 30).results
                case .travel:
                    photos = try await UnsplashService.shared.searchPhotos(query: "travel", perPage: 30).results
                }
                
                DispatchQueue.main.async {
                    self.images = photos
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshImages() {
        loadImages()
    }
    
    private func searchImages(query: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await UnsplashService.shared.searchPhotos(query: query, perPage: 30)
                
                DispatchQueue.main.async {
                    self.images = result.results
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func setWallpaper(from image: UnsplashImage) async {
        let quality = ImageQuality(rawValue: UserDefaults.standard.string(forKey: "imageQuality") ?? "Regular") ?? .regular
        
        let urlString: String
        switch quality {
        case .small:
            urlString = image.urls.small
        case .regular:
            urlString = image.urls.regular
        case .full:
            urlString = image.urls.full
        }
        
        do {
            let imageData = try await UnsplashService.shared.downloadImage(from: urlString)
            
            guard let nsImage = NSImage(data: imageData) else {
                throw WallpaperError.invalidImage
            }
            
            try wallpaperManager.setWallpaper(image: nsImage)
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func setRandomWallpaper() async {
        do {
            let randomPhotos = try await UnsplashService.shared.fetchRandomPhoto(count: 1)
            guard let photo = randomPhotos.first else {
                throw WallpaperError.noImagesAvailable
            }
            
            await setWallpaper(from: photo)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

enum WallpaperCategory: String, CaseIterable, Identifiable {
    case editorial = "Editorial"
    case wallpapers = "Wallpapers"
    case nature = "Nature"
    case architecture = "Architecture"
    case people = "People"
    case technology = "Technology"
    case animals = "Animals"
    case travel = "Travel"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .editorial:
            return "sparkles"
        case .wallpapers:
            return "photo.on.rectangle"
        case .nature:
            return "leaf"
        case .architecture:
            return "building.2"
        case .people:
            return "person.2"
        case .technology:
            return "cpu"
        case .animals:
            return "pawprint"
        case .travel:
            return "airplane"
        }
    }
}

enum WallpaperError: Error, LocalizedError {
    case invalidImage
    case noImagesAvailable
    case failedToSetWallpaper
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .noImagesAvailable:
            return "No images available"
        case .failedToSetWallpaper:
            return "Failed to set wallpaper"
        }
    }
}
