//
//  BaseCoordinator.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showDetailsScreen() {
        let detailsVC = DetailsViewController()
        detailsVC.title = "Author"
        navigationController.pushViewController(detailsVC, animated: true)
    }
}
