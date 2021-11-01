//
//  PhotosViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

class PhotosViewController: CoordinatedViewController {

    // MARK: - Properties

    private let reuseID = String(describing: UICollectionViewCell.self)

    // MARK: - Subviews

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"

        return searchController
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.toAutoLayout()
        collectionView.backgroundColor = .systemBackground

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseID)

        return collectionView
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureViews()
    }

    // MARK: - Helper methods
    private func configureNavigationBar() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func configureViews() {
        view.addSubview(collectionView)

        let safeArea = view.safeAreaLayoutGuide

        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        24
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)

        cell.backgroundColor = .systemGray4

        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        var height: CGFloat

        let totalWidth = collectionView.bounds.width
        let safeAreaInsets = view.safeAreaInsets

        let horizontalInsets = 2 * AppConfig.UI.horizontalInset + safeAreaInsets.right + safeAreaInsets.left

        var numberOfColumns = Int(totalWidth / AppConfig.UI.Collection.referenceCellWidth)
        if numberOfColumns < AppConfig.UI.Collection.minimalNumberOfColumns {
            numberOfColumns = AppConfig.UI.Collection.minimalNumberOfColumns
        }

        width = ( totalWidth - horizontalInsets - CGFloat(numberOfColumns - 1) * AppConfig.UI.Collection.horizontalSpacing) / CGFloat(numberOfColumns)

        height = width

        return CGSize(width: width, height: height)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        AppConfig.UI.Collection.verticalSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        AppConfig.UI.Collection.horizontalSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = AppConfig.UI.horizontalInset
        let verticalInset = AppConfig.UI.verticalInset
        return UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let coordinator = coordinator as? BaseCoordinator else { return }
        coordinator.showDetailsScreen()
    }

}

// MARK: - UISearchResultsUpdating
extension PhotosViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text else { return }
        print(searchText)
    }
}
