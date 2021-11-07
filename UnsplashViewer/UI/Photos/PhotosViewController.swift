//
//  PhotosViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

protocol PhotosViewControllerOutput {
    var numberOfItems: Int { get }
    var fetchedItems: Int { get }
    var imageDownloader: ImageDownloader { get }
    func photo(for indexPath: IndexPath) -> UnsplashPhoto
    func fetchPhotos()
    func startSearch()
    func endSearch()
    func performSearch(query: String)
}

protocol PhotosViewControllerInput: AnyObject {
    func didFailFetch(description: String)
    func didFetchPhotos(newIndexPaths: [IndexPath]?)
    func didSwitchMode()
}

class PhotosViewController: CoordinatedViewController {

    // MARK: - Properties

    let viewModel: PhotosViewControllerOutput
    private let reuseID = String(describing: PhotosCollectionViewCell.self)

    // MARK: - Subviews

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self

        return searchController
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.toAutoLayout()
        collectionView.backgroundColor = .systemBackground

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self

        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: reuseID)

        collectionView.isHidden = true

        return collectionView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.toAutoLayout()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private lazy var emptyContainer: UIStackView = {
        print(type(of: self), #function)
        let emptyContainer = UIStackView()
        emptyContainer.toAutoLayout()
        emptyContainer.axis = .vertical
        emptyContainer.spacing = 20

        let emptyLabel: UILabel = {
            let label = UILabel()
            label.toAutoLayout()

            label.numberOfLines = 0
            label.font = AppConfig.Font.primary
            label.text = "Failed to load data"
            label.textAlignment = .center

            return label
        }()

        emptyContainer.addArrangedSubview(emptyLabel)

        let retryButton: UIButton = {
            let button = UIButton(type: .system)
            button.toAutoLayout()

            button.setTitle("Retry", for: .normal)
            button.addTarget(self, action: #selector(retryFetch(_:)), for: .touchUpInside)

            return button
        }()

        emptyContainer.addArrangedSubview(retryButton)

        return emptyContainer
    }()

    private var emptyViewIsSet = false

    // MARK: - Life cycle
    init(viewModel: PhotosViewControllerOutput){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureViews()
        fetchData()
    }

    // MARK: - Data
    private func fetchData() {
        activityIndicator.startAnimating()
        viewModel.fetchPhotos()
    }

    // MARK: - UI Configuration
    private func configureNavigationBar() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func configureViews() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureEmptyView() {
        guard !emptyViewIsSet && collectionView.isHidden else { return }
        view.addSubview(emptyContainer)
        let constraints = [
            emptyContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: AppConfig.UI.horizontalInset),
            emptyContainer.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            emptyContainer.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        emptyViewIsSet = true
    }

    private func setEmptyView(visible: Bool) {
        guard emptyViewIsSet else { return }
        emptyContainer.isHidden = !visible
    }

    // MARK: - Actions
    @objc private func retryFetch(_ sender: UIButton) {
        fetchData()
    }
}

// MARK: - UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as? PhotosCollectionViewCell else { fatalError("Application misconfigured: check class for collectionView reusable identifier") }

        if isLoadingCell(for: indexPath) {
            cell.configure(with: .nothing)
        } else {
            let photo = viewModel.photo(for: indexPath)
            cell.configure(with: .image(photo, viewModel.imageDownloader))
        }

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
        guard let coordinator = coordinator as? PhotosCoordinator else { return }
        coordinator.showDetailsScreen(photo: viewModel.photo(for: indexPath))
    }

}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchPhotos()
        }
    }
}

// MARK: - PhotosViewControllerInput
extension PhotosViewController: PhotosViewControllerInput {
    func didSwitchMode() {
        collectionView.reloadSections(IndexSet(integer: 0))
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height &&
            self.collectionView.contentOffset.y > 0 &&
            viewModel.numberOfItems > 0) {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    func didFailFetch(description: String) {
        activityIndicator.stopAnimating()
        configureEmptyView()
        setEmptyView(visible: true)
        showError(message: description)
    }

    func didFetchPhotos(newIndexPaths: [IndexPath]?) {
        guard let newIndexPaths = newIndexPaths else {
            activityIndicator.stopAnimating()
            setEmptyView(visible: false)
            collectionView.isHidden = false
            collectionView.reloadData()
            return
        }

        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPaths)
        let indexPathsToInsert = indexPathsToInsert(newIndexPaths, reloading: indexPathsToReload)
        collectionView.insertItems(at: indexPathsToInsert)
        collectionView.reloadItems(at: indexPathsToReload)

    }
}

// MARK: - Helper methods
private extension PhotosViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= viewModel.fetchedItems
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    func indexPathsToInsert(_ newIndexPath: [IndexPath], reloading visibleIndexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsToInsert = Set(newIndexPath).subtracting(visibleIndexPaths)
        return Array(indexPathsToInsert)
    }
}

// MARK: - UISearchBarDelegate
extension PhotosViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.startSearch()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let query = searchBar.text,
              query.count > 0 else {
                  viewModel.endSearch()
                  return
              }
        viewModel.performSearch(query: query)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.endSearch()
    }
}
