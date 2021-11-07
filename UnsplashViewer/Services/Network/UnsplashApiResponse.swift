//
//  UnsplashApiResponse.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import Foundation

struct UnsplashApiResponse {
    let total: Int
    let photos: [UnsplashPhoto]

    init(total: Int, photos: [UnsplashPhoto]) {
        self.total = total
        self.photos = photos
    }

    init<T>(total: Int, response: T) throws where T: Decodable {
        if let photos = response as? [UnsplashPhoto] {
            self.init(total: total, photos: photos)
        } else if let result = response as? UnsplashSearchResult {
            self.init(total: total, photos: result.results)
        } else {
            throw UnsplashApiError.invalidData
        }
    }
}
