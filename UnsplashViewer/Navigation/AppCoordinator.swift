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

    var childCoordinators: [Coordinator] = []
    var viewControllers: [UIViewController] = []

    let tabBarController = UITabBarController()
//    private let apiAdapter = UnsplashApiAdapter()
    private let imageDownloader = ImageDownloader()
//    private let imageDiskStorage = ImageDiskStorage()
//    private let coreDataManager: CoreDataManager = {
//        let coreDataManager = CoreDataManager(model: "LocalStorage")
//        coreDataManager.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        coreDataManager.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return coreDataManager
//    }()

    func start() {

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
        photosCoordinator.start()

        configureTab(for: photosCoordinator,
                        title: "Unsplash",
                        tabImage: UIImage(named: "TabIcon"))


        let favoritesCoordinator = FavoritesCoordinator(navigationController: UINavigationController(),
                                                        favoritesManager: favoritesManager)
        childCoordinators.append(favoritesCoordinator)
        favoritesCoordinator.start()

        configureTab(for: favoritesCoordinator,
                        title: "Favorites",
                        tabImage: UIImage(systemName: "heart.fill"))

//        let photosCoordinator = PhotosCoordinator(
//        let photosViewModel = PhotosViewModel(adapter: apiAdapter)
//        let photosViewController = PhotosViewController(viewModel: photosViewModel)
//        photosViewModel.viewInput = photosViewController
//        configureModule(
//            rootController: photosViewController,
//            title: "Unsplash",
//            tabImage: UIImage(named: "TabIcon"))
//
//        let coreDataManager = FavoritesManager()
//        let favoritesViewModel = FavoritesViewModel(coreDataManager: coreDataManager, imageDiskStorage: imageDiskStorage)
//        configureModule(
//            rootController: FavoritesViewController(),
//            title: "Favorites",
//            tabImage: UIImage(systemName: "heart.fill"))

        tabBarController.viewControllers = viewControllers
    }

//    private func configureModule(rootController: CoordinatedViewController, title: String, tabImage: UIImage?) {
//        let navigationController = UINavigationController(rootViewController: rootController)
//        navigationController.navigationBar.prefersLargeTitles = true
//
//        let coordinator = BaseCoordinator(
//            navigationController: navigationController,
//            apiAdapter: apiAdapter,
//            imageDownloader: imageDownloader)
//
//        childCoordinators.append(coordinator)
//
//        rootController.coordinator = coordinator
//        rootController.title = title
//
//        let tabBarItem = UITabBarItem(title: title, image: tabImage, selectedImage: nil)
//        navigationController.tabBarItem = tabBarItem
//        viewControllers.append(navigationController)
//    }

    func configureTab(for coordinator: Coordinator, title: String, tabImage: UIImage?) {
        let navigator = coordinator.navigationController
        navigator.navigationBar.prefersLargeTitles = true
        navigator.navigationItem.largeTitleDisplayMode = .always
        if let rootController = navigator.viewControllers.first {
            rootController.title = title
//            rootController.navigationItem.largeTitleDisplayMode = .always
        }
        let tabBarItem = UITabBarItem(title: title, image: tabImage, selectedImage: nil)
        navigator.tabBarItem = tabBarItem
        viewControllers.append(navigator)
    }
}
