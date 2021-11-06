//
//  UnsplashPhoto.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit

// MARK: - UnsplashPhoto
struct UnsplashPhoto: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let color: UIColor
    let photoDescription: String?
    let altDescription: String?
    let urls: URLs
    let links: Links
    let likes: Int
    let views: Int?
    let downloads: Int?
    let location: Location?
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case color
        case photoDescription = "description"
        case altDescription = "alt_description"
        case urls
        case links
        case likes
        case views
        case downloads
        case location
        case user
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        createdAt = try UnsplashPhoto.decodeDateString(with: container, forKey: .createdAt)
        width = try UnsplashPhoto.decodeIntFromString(with: container, forKey: .width)
        height = try UnsplashPhoto.decodeIntFromString(with: container, forKey: .height)
        color = try UnsplashPhoto.decodeColorString(with: container, forKey: .color)
        photoDescription = try? container.decode(String.self, forKey: .photoDescription)
        altDescription = try? container.decode(String.self, forKey: .altDescription)
        urls = try container.decode(URLs.self, forKey: .urls)
        links = try container.decode(Links.self, forKey: .links)
        likes = try UnsplashPhoto.decodeIntFromString(with: container, forKey: .likes)
        views = try? UnsplashPhoto.decodeIntFromString(with: container, forKey: .views)
        downloads = try? UnsplashPhoto.decodeIntFromString(with: container, forKey: .downloads)
        location = try? container.decode(Location.self, forKey: .location)
        user = try container.decode(User.self, forKey: .user)
    }

    // MARK: - Links
    struct Links: Codable {
        let linksSelf: URL
        let html: URL
        let download: URL
        let downloadLocation: URL

        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
            case html
            case download
            case downloadLocation = "download_location"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            linksSelf = try UnsplashPhoto.decodeUrlString(with: container, forKey: .linksSelf)
            html = try UnsplashPhoto.decodeUrlString(with: container, forKey: .html)
            download = try UnsplashPhoto.decodeUrlString(with: container, forKey: .download)
            downloadLocation = try UnsplashPhoto.decodeUrlString(with: container, forKey: .downloadLocation)
        }

    }

    // MARK: - Location
    struct Location: Codable {
        let title: String?
    }

    // MARK: - User
    struct User: Codable {
        let name: String
    }

    // MARK: - PhotoURLs
    struct URLs: Codable {
        let raw: URL
        let full: URL
        let regular: URL
        let small: URL
        let thumb: URL

        enum CodingKeys: String, CodingKey {
            case raw
            case full
            case regular
            case small
            case thumb
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            raw = try UnsplashPhoto.decodeUrlString(with: container, forKey: .raw)
            full = try UnsplashPhoto.decodeUrlString(with: container, forKey: .full)
            regular = try UnsplashPhoto.decodeUrlString(with: container, forKey: .regular)
            small = try UnsplashPhoto.decodeUrlString(with: container, forKey: .small)
            thumb = try UnsplashPhoto.decodeUrlString(with: container, forKey: .thumb)
        }
    }
}
// MARK: - Helper methods
extension UnsplashPhoto {

    private static func decodeUrlString<T:CodingKey>(with container: KeyedDecodingContainer<T>, forKey key: T) throws -> URL {
        let urlString = try container.decode(String.self, forKey: key)
        let url = try urlString.toURL()
        return url
    }

    private static func decodeDateString<T:CodingKey>(with container: KeyedDecodingContainer<T>, forKey key: T) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        let date = try dateString.toISO8601Date(withFormatOptions: [.withInternetDateTime, .withColonSeparatorInTimeZone])
        return date
    }

    private static func decodeColorString<T:CodingKey>(with container: KeyedDecodingContainer<T>, forKey key: T) throws -> UIColor {
        let colorString = try container.decode(String.self, forKey: key)
        let color = try colorString.toUIColor()
        return color
    }

    private static func decodeIntFromString<T:CodingKey>(with container: KeyedDecodingContainer<T>, forKey key: T) throws -> Int {

        if let number = try? container.decode(Int.self, forKey: key) {
            return number
        }

        let string = try container.decode(String.self, forKey: key)
        if let number = Int(string) {
            return number
        }

        throw UnsplashApiError.responseNotRecognized
    }
}

// MARK: - Configuration Helper
extension UnsplashPhoto {
    /// Image to use in collection view
    var thumbnailURL: URL {
        self.urls.small
    }

    /// Image to use in details view
    var fullPhotoURL: URL {
        self.urls.regular
    }
}
