//
//  FavoritesViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

protocol FavoritesViewControllerOutput {
    var numberOfRows: Int { get }
    func loadThumbnail(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void)
    func favoritePhoto(for indexPath: IndexPath) -> FavoritePhoto
    func thumbnail(for indexPath: IndexPath) -> UIImage?
    func removeFromFavorites(at indexPath: IndexPath, completion: @escaping (Bool, Error?) -> Void)
    func reloadData(completion: ((Bool, Error?) -> Void)?)
}

enum RowAction {
    case add
    case delete
    case move(IndexPath)
    case redraw
}

protocol FavoritesViewControllerInput: AnyObject {

    func willUpdate()
    func updateRow(at indexPath: IndexPath, action: RowAction)
    func didUpdate()
}

class FavoritesViewController: CoordinatedViewController {

    // MARK: - Properties
    private let reuseID = String(describing: FavoritesTableViewCell.self)
    private let viewModel: FavoritesViewControllerOutput
    private var hasPendingUpdates = false
    private var initialLoadComplete = false

    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.toAutoLayout()
        tableView.sectionHeaderHeight = AppConfig.UI.navbarMargin
        tableView.rowHeight = 66.0

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: reuseID)

        return tableView
    }()

    // MARK: - Life cycle

    init(viewModel: FavoritesViewControllerOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()

        viewModel.reloadData { [weak self] success, error in
            guard let self = self else { return }

            guard success else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.initialLoadComplete = true
                self.checkNoFavorites()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if hasPendingUpdates {
            tableView.reloadData()
            hasPendingUpdates = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if initialLoadComplete {
            checkNoFavorites()
        }
    }

    // MARK: - Helper methods
    private func configureViews() {

        view.addSubview(tableView)

        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func checkNoFavorites() {
        if viewModel.numberOfRows == 0 {
            let alertAction = UIAlertAction(title: "Show me", style: .default) { [weak self] _ in
                guard let self = self,
                      let coordinator = self.coordinator as? FavoritesCoordinator else { return }
                coordinator.transitionToPhotos()
            }
            showAlert(title: "No favorites here", message: "It looks like you don't have any favorites yet. Time to add some on the main screen!", actions: [alertAction])
        }
    }

}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)

        let favoritePhoto = viewModel.favoritePhoto(for: indexPath)



        cell.imageView?.image = viewModel.thumbnail(for: indexPath)
        cell.textLabel?.text = favoritePhoto.userName

        return cell
    }

}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coordinator = coordinator as? FavoritesCoordinator else { return }
        let photo = viewModel.favoritePhoto(for: indexPath)
        coordinator.showDetailsScreen(favoritePhoto: photo)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove from favorites") { [weak self] _, _, actionCompletion in
            guard let self = self else { return }
            self.viewModel.removeFromFavorites(at: indexPath) { [weak self] success, error in
                if let error = error {
                    self?.showError(message: error.localizedDescription)
                }
                actionCompletion(success)
            }
        }
        deleteAction.image = UIImage(named: "xmark.bin.circle")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

// MARK: - FavoritesViewControllerInput
extension FavoritesViewController: FavoritesViewControllerInput {
    func willUpdate() {
        handleBackgroundUpdates { [weak self] in
            self?.tableView.beginUpdates()
        }
    }

    func updateRow(at indexPath: IndexPath, action: RowAction) {

        handleBackgroundUpdates { [weak self] in
            switch action {
            case .add:
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
            case .delete:
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .move(let newIndexPath):
                self?.tableView.moveRow(at: indexPath, to: newIndexPath)
            case .redraw:
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func didUpdate() {
        handleBackgroundUpdates { [weak self] in
            self?.tableView.endUpdates()
        }
    }

    private func handleBackgroundUpdates(handler: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            // check if view is in hierarchy
            guard let _ = self.view.window else {
                self.hasPendingUpdates = true
                return
            }

            // execute code on the main thread if the view is visible
            handler()
        }
    }
}
