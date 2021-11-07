//
//  CachedPhoto.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import Foundation

struct CachedPhoto {
    struct Images {
        let thumb: String
        let full: String
    }

    let data: UnsplashPhoto
    let images: Images
}
