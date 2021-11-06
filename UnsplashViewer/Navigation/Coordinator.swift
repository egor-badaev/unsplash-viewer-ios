//
//  Coordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var apiAdapter: UnsplashApiAdapter { get }
    var imageDownloader: ImageDownloader { get }
    func showDetailsScreen(photo: UnsplashPhoto)
}
