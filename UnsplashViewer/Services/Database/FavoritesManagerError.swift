//
//  FavoritesManagerError.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 07.11.2021.
//

import Foundation

enum FavoritesManagerError: LocalizedError {
    case noResults
    case noCachedImages
    case unknown

    var errorDescription: String? {
        switch self {
        case .noResults:
            return "Request didn't return any results"
        case .noCachedImages:
            return "Failed to fetch cached images"
        case .unknown:
            return "Operation failed due to unknown error"
        }
    }
}
