//
//  Coordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

protocol Coordinator: AnyObject {
    var appCoordinator: AppCoordinator? { get set }
    var navigationController: UINavigationController { get }
}
