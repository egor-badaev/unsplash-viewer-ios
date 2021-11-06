//
//  AppCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

final class AppCoordinator {

    var childCoordinators: [Coordinator] = []
    var viewControllers: [UIViewController] = []

    let tabBarController = UITabBarController()
    private let apiAdapter = UnsplashApiAdapter()
    private let imageDownloader = ImageDownloader()

    func start() {
        let photosViewModel = PhotosViewModel(adapter: apiAdapter)
        let photosViewController = PhotosViewController(viewModel: photosViewModel)
        photosViewModel.viewInput = photosViewController
        configureModule(
            rootController: photosViewController,
            title: "Unsplash",
            tabImage: UIImage(named: "TabIcon"))

        configureModule(
            rootController: FavoritesViewController(),
            title: "Favorites",
            tabImage: UIImage(systemName: "heart.fill"))

        tabBarController.viewControllers = viewControllers
    }

    private func configureModule(rootController: CoordinatedViewController, title: String, tabImage: UIImage?) {
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.navigationBar.prefersLargeTitles = true

        let coordinator = BaseCoordinator(
            navigationController: navigationController,
            apiAdapter: apiAdapter,
            imageDownloader: imageDownloader)

        childCoordinators.append(coordinator)

        rootController.coordinator = coordinator
        rootController.title = title

        let tabBarItem = UITabBarItem(title: title, image: tabImage, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        viewControllers.append(navigationController)
    }

}
