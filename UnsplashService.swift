//
//  UnsplashService.swift
//  Unsplash Wallpaper
//

import Foundation

class UnsplashService {
    static let shared = UnsplashService()
    
    private let baseURL = "https://api.unsplash.com"
    private var accessKey: String {
        UserDefaults.standard.string(forKey: "unsplashAccessKey") ?? ""
    }
    
    private var headers: [String: String] {
        [
            "Authorization": "Client-ID \(accessKey)",
            "Accept-Version": "v1"
        ]
    }
    
    func fetchPhotos(page: Int = 1, perPage: Int = 30, orderBy: String = "latest") async throws -> [UnsplashImage] {
        var components = URLComponents(string: "\(baseURL)/photos")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "order_by", value: orderBy)
        ]
        
        guard let url = components.url else {
            throw UnsplashError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw UnsplashError.unauthorized
            } else if httpResponse.statusCode == 403 {
                throw UnsplashError.rateLimitExceeded
            }
            throw UnsplashError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([UnsplashImage].self, from: data)
    }
    
    func searchPhotos(query: String, page: Int = 1, perPage: Int = 30) async throws -> SearchResult {
        var components = URLComponents(string: "\(baseURL)/search/photos")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components.url else {
            throw UnsplashError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw UnsplashError.unauthorized
            } else if httpResponse.statusCode == 403 {
                throw UnsplashError.rateLimitExceeded
            }
            throw UnsplashError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(SearchResult.self, from: data)
    }
    
    func fetchRandomPhoto(count: Int = 1) async throws -> [UnsplashImage] {
        var components = URLComponents(string: "\(baseURL)/photos/random")!
        components.queryItems = [
            URLQueryItem(name: "count", value: "\(count)")
        ]
        
        guard let url = components.url else {
            throw UnsplashError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw UnsplashError.unauthorized
            } else if httpResponse.statusCode == 403 {
                throw UnsplashError.rateLimitExceeded
            }
            throw UnsplashError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([UnsplashImage].self, from: data)
    }
    
    func fetchCollectionPhotos(collectionId: String, page: Int = 1, perPage: Int = 30) async throws -> [UnsplashImage] {
        let urlString = "\(baseURL)/collections/\(collectionId)/photos"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components.url else {
            throw UnsplashError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw UnsplashError.unauthorized
            } else if httpResponse.statusCode == 403 {
                throw UnsplashError.rateLimitExceeded
            }
            throw UnsplashError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([UnsplashImage].self, from: data)
    }
    
    func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw UnsplashError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UnsplashError.downloadFailed
        }
        
        return data
    }
}

enum UnsplashError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case httpError(statusCode: Int)
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please check your API access key."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .downloadFailed:
            return "Failed to download image"
        }
    }
}

struct SearchResult: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashImage]
}
