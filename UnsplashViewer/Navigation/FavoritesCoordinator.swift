//
//  FavoritesCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import UIKit
import CoreData

final class FavoritesCoordinator: BaseCoordinator {
    private let favoritesManager: FavoritesManager

    init(navigationController: UINavigationController, favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
        super.init(navigationController: navigationController)
    }

    func start() {
        let favoritesViewModel = FavoritesViewModel(favoritesManager: favoritesManager)
        let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
        favoritesViewController.coordinator = self
        favoritesViewModel.input = favoritesViewController
        navigationController.setViewControllers([favoritesViewController], animated: false)
    }

    func showDetailsScreen(favoritePhoto: FavoritePhoto) {
        let detailsViewModel = DetailsCoreDataViewModel(photo: favoritePhoto, manager: favoritesManager)
        let detailsViewController = DetailsViewController(viewModel: detailsViewModel)
        detailsViewModel.viewInput = detailsViewController
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}
