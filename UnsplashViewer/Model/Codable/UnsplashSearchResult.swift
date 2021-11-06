//
//  UnsplashSearchResult.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import Foundation

struct UnsplashSearchResult: Decodable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]

    enum CodingKeys: String, CodingKey {
        case total, results
        case totalPages = "total_pages"
    }
}
