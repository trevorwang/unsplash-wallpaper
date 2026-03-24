//
//  UnsplashImage.swift
//  Unsplash Wallpaper
//

import Foundation

struct UnsplashImage: Codable, Identifiable {
    let id: String
    let createdAt: String?
    let updatedAt: String?
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool?
    let description: String?
    let altDescription: String?
    let urls: ImageURLs
    let links: ImageLinks
    let user: UnsplashUser
    let location: Location?
    let views: Int?
    let downloads: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case altDescription = "alt_description"
        case urls
        case links
        case user
        case location
        case views
        case downloads
    }
}

struct ImageURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let smallS3: String?
    
    enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb
        case smallS3 = "small_s3"
    }
}

struct ImageLinks: Codable {
    let own: String?
    let html: String
    let download: String
    let downloadLocation: String?
    
    enum CodingKeys: String, CodingKey {
        case own = "self"
        case html
        case download
        case downloadLocation = "download_location"
    }
}

struct UnsplashUser: Codable {
    let id: String
    let updatedAt: String?
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let links: UserLinks
    let profileImage: ProfileImage?
    let instagramUsername: String?
    let totalCollections: Int?
    let totalLikes: Int?
    let totalPhotos: Int?
    let acceptedTos: Bool?
    let forHire: Bool?
    let social: Social?
    
    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
        case bio
        case location
        case links
        case profileImage = "profile_image"
        case instagramUsername = "instagram_username"
        case totalCollections = "total_collections"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case acceptedTos = "accepted_tos"
        case forHire = "for_hire"
        case social
    }
}

struct UserLinks: Codable {
    let own: String?
    let html: String
    let photos: String
    let likes: String
    let portfolio: String?
    let following: String?
    let followers: String?
    
    enum CodingKeys: String, CodingKey {
        case own = "self"
        case html
        case photos
        case likes
        case portfolio
        case following
        case followers
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct Social: Codable {
    let instagramUsername: String?
    let portfolioURL: String?
    let twitterUsername: String?
    let paypalEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case instagramUsername = "instagram_username"
        case portfolioURL = "portfolio_url"
        case twitterUsername = "twitter_username"
        case paypalEmail = "paypal_email"
    }
}

struct Location: Codable {
    let city: String?
    let country: String?
    let position: Position?
    let name: String?
}

struct Position: Codable {
    let latitude: Double?
    let longitude: Double?
}
