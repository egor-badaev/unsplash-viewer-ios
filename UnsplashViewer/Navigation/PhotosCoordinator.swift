//
//  PhotosCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import Foundation
import AlamofireImage
import UIKit

final class PhotosCoordinator: BaseCoordinator {
    private let apiAdapter = UnsplashApiAdapter()
    private let favoritesManager: FavoritesManager
    private lazy var imageDownloader: ImageDownloader = {
        favoritesManager.imageDownloader
    }()

    init(navigationController: UINavigationController, favoritesmanager: FavoritesManager) {
        self.favoritesManager = favoritesmanager
        super.init(navigationController: navigationController)
    }

    func start() {
        let photosViewModel = PhotosViewModel(adapter: apiAdapter, imageDownloader: imageDownloader)
        let photosViewController = PhotosViewController(viewModel: photosViewModel)
        photosViewController.coordinator = self
        photosViewModel.viewInput = photosViewController
        navigationController.setViewControllers([photosViewController], animated: false)
    }

    func showDetailsScreen(photo: UnsplashPhoto) {
        let detailsViewModel = DetailsCodableViewModel(photo: photo,
                                                       adapter: apiAdapter,
                                                       imageDownloader: imageDownloader,
                                                       favoritesManager: favoritesManager)
        let detailsViewController = DetailsViewController(viewModel: detailsViewModel)
        detailsViewModel.viewInput = detailsViewController
        navigationController.pushViewController(detailsViewController, animated: true)
    }
}
