//
//  BaseCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

class BaseCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    let apiAdapter: UnsplashApiAdapter
    let imageDownloader: ImageDownloader

    init(navigationController: UINavigationController, apiAdapter: UnsplashApiAdapter, imageDownloader: ImageDownloader) {
        self.navigationController = navigationController
        self.apiAdapter = apiAdapter
        self.imageDownloader = imageDownloader
    }

    func showDetailsScreen(photo: UnsplashPhoto) {
        let detailsVM = DetailsCodableViewModel(photo: photo, adapter: apiAdapter, imageDownloader: imageDownloader)
        let detailsVC = DetailsViewController(viewModel: detailsVM)
        detailsVM.viewInput = detailsVC
        navigationController.pushViewController(detailsVC, animated: true)
    }
}
