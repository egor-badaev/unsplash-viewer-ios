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

    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alertVC.addAction(action)
        }
        present(alertVC, animated: true, completion: nil)
    }

    func showError(message: String) {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        showAlert(title: "Error", message: message, actions: [okAction])
    }
}
