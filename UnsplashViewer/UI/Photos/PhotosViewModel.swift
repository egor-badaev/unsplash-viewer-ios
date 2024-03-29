//
//  PhotosViewModel.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import Foundation
import AlamofireImage

class PhotosViewModel: PhotosViewControllerOutput {

    enum Mode {
        case editorial
        case search
    }

    // MARK: - Properties
    weak var viewInput: PhotosViewControllerInput?

    var numberOfItems: Int {
        return currentFeed.totalPhotos >= fetchedItems + AppConfig.API.perPage ? fetchedItems + AppConfig.API.perPage : currentFeed.totalPhotos
    }

    var fetchedItems: Int {
        currentFeed.photos.count
    }

    private var mode: Mode = .editorial {
        didSet {
            viewInput?.didSwitchMode()
        }
    }

    private let adapter: UnsplashApiAdapter
    let imageDownloader: ImageDownloader

    private let editorialFeed = PhotoFeed()
    private let searchFeed = PhotoFeed()

    private var currentFeed: PhotoFeed {
        switch mode {
        case .editorial:
            return editorialFeed
        case .search:
            return searchFeed
        }
    }
    
    private var searchQuery: String? = nil {
        didSet {
            searchFeed.reset()
        }
    }

    // MARK: - Initialization
    init(adapter: UnsplashApiAdapter, imageDownloader: ImageDownloader) {
        self.adapter = adapter
        self.imageDownloader = imageDownloader
    }

    // MARK: - Interface
    func photo(for indexPath: IndexPath) -> UnsplashPhoto {
        currentFeed.photos[indexPath.item]
    }

    func fetchPhotos() {
        guard !currentFeed.isFetching,
        (mode != .search || searchQuery != nil) else { return }
        currentFeed.isFetching = true

        let requestType: UnsplashApiAdapter.RequestType
        switch mode {
        case .editorial:
            requestType = .editorial
        case .search:
            guard let query = searchQuery else { return }
            requestType = .search(query)
        }

        adapter.fetchPhotos(for: requestType, page: currentFeed.currentPage) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.currentFeed.isFetching = false
                    self.viewInput?.didFailFetch(description: error.localizedDescription)
                }
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentFeed.isFetching = false
                    self.currentFeed.totalPhotos = response.total
                    self.currentFeed.photos.append(contentsOf: response.photos)
                    if self.currentFeed.currentPage > 1 {
                        let updatedIndexPaths = self.getUpdatedIndexPaths(with: response.photos)
                        self.viewInput?.didFetchPhotos(newIndexPaths: updatedIndexPaths)
                    } else {
                        self.viewInput?.didFetchPhotos(newIndexPaths: nil)
                    }
                    self.currentFeed.currentPage += 1
                }
            }
        }
    }

    func startSearch() {
        mode = .search
    }

    func endSearch() {
        searchQuery = nil
        mode = .editorial
    }

    func performSearch(query: String) {
        searchQuery = query
        fetchPhotos()
    }

    // MARK: - Helper methods
    private func getUpdatedIndexPaths(with newPhotos: [UnsplashPhoto]) -> [IndexPath] {
        let startIndex = currentFeed.photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
    }
}
