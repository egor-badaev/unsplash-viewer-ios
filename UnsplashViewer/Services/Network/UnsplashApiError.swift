//
//  UnsplashApiError.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import Foundation

public enum UnsplashApiError: LocalizedError {
    case badResponse
    case invalidData
    case invalidURL
    case limitExceeded(Int)
    case statusCode(Int)
    case noTotal
    case noData
    case failedToGetFullImage
    case responseNotRecognized

    public var errorDescription: String? {

        switch self {
        case .badResponse:
            return "Received invalid response from server"
        case .invalidData:
            return "Received invalid data from server"
        case .invalidURL:
            return "Tried to access invalid URL"
        case .limitExceeded(let limit):
            return String(format: "Exceeded available limit of %d requests per hour", limit)
        case .statusCode(let code):
            switch code {
            case 400:
                return "The request was unacceptable, often due to missing a required parameter"
            case 401:
                return "Invalid Access Token"
            case 403:
                return "Missing permissions to perform request"
            case 404:
                return "The requested resource doesn’t exist"
            case 500, 503:
                return "Something went wrong on server"
            default:
                return "Failed to read server response"
            }
        case .noTotal:
            return "Total number of images is missing"
        case .noData:
            return "Server response has no data"
        case .failedToGetFullImage:
            return "Failed to get full image"
        case .responseNotRecognized:
            return "Failed to recognize response from server"
        }
    }
}
