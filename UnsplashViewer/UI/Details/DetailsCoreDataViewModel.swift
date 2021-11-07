//
//  DetailsCoreDataViewModel.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 07.11.2021.
//

import UIKit

class DetailsCoreDataViewModel: DetailsViewControllerOutput {

    // MARK: - Properties
    weak var viewInput: DetailsViewControllerInput?

    var author: String {
        photo.userName ?? ""
    }

    var description: String? {
        photo.description
    }

    var imageAspectRatio: CGFloat {
        CGFloat(photo.height) / CGFloat(photo.width)
    }

    var isFavorite: Bool = true

    private let photo: FavoritePhoto
    private let manager: FavoritesManager

    // MARK: - Initialization
    init(
        photo: FavoritePhoto,
        manager: FavoritesManager
    ) {
        self.photo = photo
        self.manager = manager
    }

    // MARK: - Interface
    func fetchThumbnail() {
        if let filename = photo.thumbnailFilename,
           let image = manager.imageDiskStorage.image(filename: filename) {
            DispatchQueue.main.async {
                self.viewInput?.didFetchThumbnail(image: image)
            }
        }
    }

    func fetchDetails() {
        let infoData = makeInfoData()
        DispatchQueue.main.async {
            self.viewInput?.didFetchInfo(infoData: infoData)
        }

        if let filename = photo.fullImageFilename,
           let image = manager.imageDiskStorage.image(filename: filename) {
            DispatchQueue.main.async {
                self.viewInput?.didFetchPhoto(image: image)
            }
        }
    }

    func checkFavorite() {
        DispatchQueue.main.async {
            self.viewInput?.didUpdateFavoriteStatus()
        }
    }

    func favoritesAction() {
        if isFavorite {
            manager.removeFromFavorites(favorite: photo, immediately: false, completion: handler)
        } else {
            manager.reAddToFavorites(favorite: photo, completion: handler)
        }
    }

    func didFinish() {
        manager.completeFavoritesManipulation()
    }

    // MARK: - Helper methods

    private func makeInfoData() -> [DetailsInfoData] {
        [
            DetailsInfoData(with: .date(photo.createdAt)),
            DetailsInfoData(with: .location(photo.locationTitle)),
            DetailsInfoData(with: .downloads(Int(photo.downloads)))
        ].compactMap({ $0 })
    }

    private lazy var handler: FavoritesManager.CompletionHandler = { [weak self] result in
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
