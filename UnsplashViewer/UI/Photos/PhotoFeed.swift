//
//  PhotoFeed.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import Foundation

class PhotoFeed {
    var photos = [UnsplashPhoto]()
    var currentPage: Int = 1
    var totalPhotos: Int = 0
    var isFetching: Bool = false

    func reset() {
        photos = []
        currentPage = 1
        totalPhotos = 0
        isFetching = false
    }
}
