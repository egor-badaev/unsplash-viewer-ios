//
//  DetailsCodableViewModel.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit
import AlamofireImage

class DetailsCodableViewModel: DetailsViewControllerOutput {

    // MARK: - Properties
    weak var viewInput: DetailsViewControllerInput?

    var author: String {
        photo.user.name
    }

    var description: String? {
        if let description = photo.photoDescription {
            return description
        }
        return photo.altDescription
    }

    var imageAspectRatio: CGFloat {
        CGFloat(photo.height) / CGFloat(photo.width)
    }

    var isFavorite: Bool = false

    private var photo: UnsplashPhoto
    private let adapter: UnsplashApiAdapter
    private let imageDownloader: ImageDownloader
    private let favoritesManager: FavoritesManager

    // MARK: - Initialization

    init(photo: UnsplashPhoto,
         adapter: UnsplashApiAdapter,
         imageDownloader: ImageDownloader,
         favoritesManager: FavoritesManager
    ) {
        self.photo = photo
        self.adapter = adapter
        self.imageDownloader = imageDownloader
        self.favoritesManager = favoritesManager
    }

    // MARK: - Interface
    func fetchThumbnail() {
        let urlRequest = URLRequest(url: photo.thumbnailURL)
        imageDownloader.download(urlRequest, cacheKey: photo.thumbnailCacheKey, completion:  { [weak self] response in
            if case .success(let image) = response.result {
                DispatchQueue.main.async {
                    self?.viewInput?.didFetchThumbnail(image: image)
                }
            }
        })
    }

    func fetchDetails() {
        adapter.fetchPhoto(id: photo.id) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.viewInput?.didFailFetch(description: error.localizedDescription)
                }
            case .success(let photo):
                self.photo = photo
                DispatchQueue.main.async {
                    let infoData = self.makeInfoData()
                    self.viewInput?.didFetchInfo(infoData: infoData)
                }

                let imageURLRequest = URLRequest(url: photo.fullPhotoURL)
                self.imageDownloader.download(imageURLRequest, cacheKey: photo.fullImageCacheKey, completion:  { response in
                    if case .success(let image) = response.result {
                        DispatchQueue.main.async {
                            self.viewInput?.didFetchPhoto(image: image)
                        }
                    }
                })
            }
        }
    }

    func favoritesAction() {
        if isFavorite {
            favoritesManager.removeFromFavorites(photo: photo, completion: favoritesCompletionBlock)
        } else {
            favoritesManager.addToFavorites(photo: photo, completion: favoritesCompletionBlock)
        }
    }

    func checkFavorite() {
        favoritesManager.checkIfFavorite(photo: photo, completion: favoritesCompletionBlock)
    }

    func didFinish() {
        favoritesManager.completeFavoritesManipulation()
    }

    // MARK: - Helper methods

    private func makeInfoData() -> [DetailsInfoData] {
        [
            DetailsInfoData(with: .date(photo.createdAt)),
            DetailsInfoData(with: .location(photo.location?.title)),
            DetailsInfoData(with: .downloads(photo.downloads))
        ].compactMap({ $0 })
    }

    private lazy var favoritesCompletionBlock: FavoritesManager.CompletionHandler = { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.viewInput?.didUpdateFavoriteIsUnavailable()
            }
        case .success(let isFavorite):
            self.isFavorite = isFavorite
            DispatchQueue.main.async {
                self.viewInput?.didUpdateFavoriteStatus()
            }
        }
    }

}
