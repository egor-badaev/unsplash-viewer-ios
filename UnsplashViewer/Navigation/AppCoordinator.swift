//
//  AppCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage
import CoreData

final class AppCoordinator {

    private var childCoordinators: [Coordinator] = []
    private var viewControllers: [UIViewController] = []

    private let tabBarController = UITabBarController()
    private let imageDownloader = ImageDownloader()

    func start(in window: UIWindow) {

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        let coreDataManager = CoreDataManager(model: "LocalStorage")
        coreDataManager.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        coreDataManager.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        let imageDiskStorage = ImageDiskStorage()

        let favoritesManager = FavoritesManager(coreDataManager: coreDataManager,
                                                imageDiskStorage: imageDiskStorage,
                                                imageDownloader: imageDownloader)

        let photosCoordinator = PhotosCoordinator(navigationController: UINavigationController(),
                                                  favoritesmanager: favoritesManager)
        childCoordinators.append(photosCoordinator)
        photosCoordinator.appCoordinator = self
        photosCoordinator.start()

        configureTab(for: photosCoordinator,
                        title: "Unsplash",
                        tabImage: UIImage(named: "TabIcon"))


        let favoritesCoordinator = FavoritesCoordinator(navigationController: UINavigationController(),
                                                        favoritesManager: favoritesManager)
        childCoordinators.append(favoritesCoordinator)
        favoritesCoordinator.appCoordinator = self
        favoritesCoordinator.start()

        configureTab(for: favoritesCoordinator,
                        title: "Favorites",
                        tabImage: UIImage(systemName: "heart.fill"))

        tabBarController.viewControllers = viewControllers
    }

    func showPhotos() {
        tabBarController.selectedIndex = 0
    }

    private func configureTab(for coordinator: Coordinator, title: String, tabImage: UIImage?) {
        let navigator = coordinator.navigationController
        navigator.navigationBar.prefersLargeTitles = true
        navigator.navigationItem.largeTitleDisplayMode = .always
        if let rootController = navigator.viewControllers.first {
            rootController.title = title
        }
        let tabBarItem = UITabBarItem(title: title, image: tabImage, selectedImage: nil)
        navigator.tabBarItem = tabBarItem
        viewControllers.append(navigator)
    }
}
