//
//  AppCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var viewControllers: [UIViewController] = []

    let tabBarController = UITabBarController()

    func start() {
        configureModule(
            rootController: PhotosViewController(),
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

        let coordinator = BaseCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)

        rootController.coordinator = coordinator
        rootController.title = title

        let tabBarItem = UITabBarItem(title: title, image: tabImage, selectedImage: nil)
        navigationController.tabBarItem = tabBarItem
        viewControllers.append(navigationController)
    }

}
