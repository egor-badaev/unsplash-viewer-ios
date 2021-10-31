//
//  CoordinatedViewController.swift
//  UnsplashViewer
//
//  Base view controller for coordinator-based navigation
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

class CoordinatedViewController: UIViewController {

    weak var coordinator: Coordinator?

    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    }

}
