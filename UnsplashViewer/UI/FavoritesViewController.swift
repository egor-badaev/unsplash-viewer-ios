//
//  FavoritesViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

class FavoritesViewController: CoordinatedViewController {

    // MARK: - Properties
    private let reuseID = String(describing: UITableViewCell.self)

    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.toAutoLayout()
        tableView.sectionHeaderHeight = AppConfig.UI.navbarMargin
        tableView.rowHeight = 66.0

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)

        return tableView
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    // MARK: - Helper methods
    private func configureViews() {

        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide

        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)

        let placeholder = UIColor.systemGray4.image(CGSize(width: 40, height: 40))

        cell.imageView?.image = placeholder
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 8.0
        cell.textLabel?.text = "Author"
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        return cell
    }

}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coordinator = coordinator as? BaseCoordinator else { return }
        coordinator.showDetailsScreen()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
}
