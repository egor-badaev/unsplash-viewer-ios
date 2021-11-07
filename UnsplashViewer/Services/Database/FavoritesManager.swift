//
//  FavoritesManager.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import Foundation
import AlamofireImage


final class FavoritesManager {

    typealias CompletionHandler = (Result<Bool, Error>) -> Void

    // MARK: - Data managers
    let coreDataManager: CoreDataManager
    let imageDiskStorage: ImageDiskStorage
    let imageDownloader: ImageDownloader

    // MARK: - Deferred deletion queue
    private var pendingRemoval = [FavoritePhoto]()

    // MARK: - Initialization
    init(coreDataManager: CoreDataManager, imageDiskStorage: ImageDiskStorage, imageDownloader: ImageDownloader) {
        self.coreDataManager = coreDataManager
        self.imageDiskStorage = imageDiskStorage
        self.imageDownloader = imageDownloader
    }

    // MARK: - Interface
    func checkIfFavorite(photo: UnsplashPhoto, completion: @escaping CompletionHandler) {
        findFavorite(photo: photo) { result in
            switch result {
            case .failure(let error):
                if let coreDataError = error as? FavoritesManagerError,
                   coreDataError == .noResults {
                    completion(.success(false))
                } else {
                    completion(.failure(error))
                }
            case .success(_):
                completion(.success(true))
            }
        }
    }

    func addToFavorites(photo: UnsplashPhoto, completion: @escaping CompletionHandler) {

        guard let fullImage = imageDownloader.imageCache?.image(withIdentifier: photo.fullImageCacheKey),
              let thumbImage = imageDownloader.imageCache?.image(withIdentifier: photo.thumbnailCacheKey) else {
                  completion(.failure(FavoritesManagerError.noCachedImages))
                  return
              }

        let cachedImages = CachedPhoto.Images(
            thumb: imageDiskStorage.cachedFilename(for: fullImage),
            full: imageDiskStorage.cachedFilename(for: thumbImage))

        let cachedPhoto = CachedPhoto(data: photo, images: cachedImages)

        let favoritePhoto = coreDataManager.create(from: FavoritePhoto.self, in: .background)
        favoritePhoto.configure(with: cachedPhoto)

        coreDataManager.saveAsync { [weak self] success, error in
            if error != nil || !success {
                self?.imageDiskStorage.delete(filename: cachedImages.thumb)
                self?.imageDiskStorage.delete(filename: cachedImages.full)
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FavoritesManagerError.unknown))
                }
                return
            }

            completion(.success(true))
        }

    }

    func reAddToFavorites(favorite: FavoritePhoto, completion: @escaping CompletionHandler) {

        pendingRemoval.removeAll { $0 == favorite }
        completion(.success(true))
    }

    func removeFromFavorites(favorite: FavoritePhoto, immediately removeImmediately: Bool, completion: CompletionHandler?) {

        if removeImmediately {
            coreDataManager.deleteAsync(object: favorite) { [weak self] success, error in
                if let error = error {
                    completion?(.failure(error))
                    return
                }

                guard success else {
                    completion?(.failure(FavoritesManagerError.unknown))
                    return
                }

                self?.imageDiskStorage.delete(filename: favorite.fullImageFilename)
                self?.imageDiskStorage.delete(filename: favorite.thumbnailFilename)

                completion?(.success(false))
            }
        } else {
            pendingRemoval.append(favorite)
            completion?(.success(false))
        }
    }

    func removeFromFavorites(photo: UnsplashPhoto, completion: @escaping CompletionHandler) {
        findFavorite(photo: photo) { [weak self] result in
            if case .success(let favoritePhoto) = result {
                self?.removeFromFavorites(favorite: favoritePhoto, immediately: false, completion: completion)
            }
        }
    }

    func completeFavoritesManipulation() {
        pendingRemoval = pendingRemoval.compactMap({ photo in
            removeFromFavorites(favorite: photo, immediately: true, completion: nil)
            return nil
        })
    }

    // MARK: - Helpers
    private func findFavorite(photo: UnsplashPhoto, completion: @escaping (Result<FavoritePhoto, Error>) -> Void) {
        let attribute = "identifier"
        let value = photo.id
        let predicate = NSPredicate(format: "%K like %@", attribute, value)

        coreDataManager.fetchDataAsync(for: FavoritePhoto.self, with: predicate) { favoritePhotos, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let favoritePhoto = favoritePhotos.first else {
                completion(.failure(FavoritesManagerError.noResults))
                return
            }
            completion(.success(favoritePhoto))
        }
    }

}
