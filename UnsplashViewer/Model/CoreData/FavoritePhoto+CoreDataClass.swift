//
//  FavoritePhoto+CoreDataClass.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//
//

import Foundation
import CoreData

@objc(FavoritePhoto)
public class FavoritePhoto: NSManagedObject {
    func configure(with cached: CachedPhoto) {
        self.identifier = cached.data.id
        self.createdAt = cached.data.createdAt
        self.width = Int32(cached.data.width)
        self.height = Int32(cached.data.height)
//        self.color = cached.data.color
        if let description = cached.data.photoDescription {
            self.photoDescription = description
        } else {
            self.photoDescription = cached.data.altDescription
        }
        self.likes = Int32(cached.data.likes)
        if let views = cached.data.views {
            self.views = Int32(views)
        } else {
            self.views = 0
        }
        if let downloads = cached.data.downloads {
            self.downloads = Int32(downloads)
        } else {
            self.downloads = 0
        }
        self.locationTitle = cached.data.location?.title
        self.userName = cached.data.user.name
        self.thumbnailFilename = cached.images.thumb
        self.fullImageFilename = cached.images.full
    }
}
