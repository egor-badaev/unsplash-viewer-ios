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
    lazy var safeArea = view.safeAreaLayoutGuide

    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    }

    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
