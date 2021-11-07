//
//  FavoritePhoto+CoreDataProperties.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//
//

import UIKit
import CoreData


extension FavoritePhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePhoto> {
        return NSFetchRequest<FavoritePhoto>(entityName: "FavoritePhoto")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var width: Int32
    @NSManaged public var height: Int32
    @NSManaged public var color: UIColor?
    @NSManaged public var photoDescription: String?
    @NSManaged public var likes: Int32
    @NSManaged public var views: Int32
    @NSManaged public var downloads: Int32
    @NSManaged public var locationTitle: String?
    @NSManaged public var userName: String?
    @NSManaged public var thumbnailFilename: String?
    @NSManaged public var fullImageFilename: String?

}
