//
//  FavoritesViewModel.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import UIKit
import CoreData

final class FavoritesViewModel: NSObject, FavoritesViewControllerOutput {

    weak var input: FavoritesViewControllerInput?
    let favoritesManager: FavoritesManager

    var numberOfRows: Int {
        resultsController.fetchedObjects?.count ?? 0
    }

    private lazy var resultsController: NSFetchedResultsController<FavoritePhoto> = {

        let sortDescriptor = NSSortDescriptor(key: #keyPath(FavoritePhoto.identifier), ascending: true)

        guard let resultsController: NSFetchedResultsController<FavoritePhoto> = favoritesManager.coreDataManager.makeFetchedResultsController(for: FavoritePhoto.self, in: .background, sortingBy: sortDescriptor, with: nil) as? NSFetchedResultsController<FavoritePhoto> else {
            fatalError("Cannot build result controller")
        }

        return resultsController
    }()

    init(favoritesManager: FavoritesManager) {
        self.favoritesManager = favoritesManager
        super.init()
        resultsController.delegate = self
    }

    func loadThumbnail(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {

        let favoritePhoto = resultsController.object(at: indexPath)

        DispatchQueue.global().async {
            guard let cacheFilename = favoritePhoto.thumbnailFilename,
                  let image = self.favoritesManager.imageDiskStorage.image(filename: cacheFilename) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }

    func favoritePhoto(for indexPath: IndexPath) -> FavoritePhoto {
        resultsController.object(at: indexPath)
    }

    func thumbnail(for indexPath: IndexPath) -> UIImage? {
        let photo = favoritePhoto(for: indexPath)
        guard let thumbnailFilename = photo.thumbnailFilename else { return nil }
        let thumbnail = favoritesManager.imageDiskStorage.image(filename: thumbnailFilename)
        return thumbnail
    }

    func reloadData(completion: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.resultsController.performFetch()
                completion?(true, nil)
            } catch {
                guard let completion = completion else {
                    print(error.localizedDescription)
                    return
                }
                completion(false, error)
            }
        }
    }

    func removeFromFavorites(at indexPath: IndexPath, completion: @escaping (Bool, Error?) -> Void) {
        let favoritePhoto = favoritePhoto(for: indexPath)
        favoritesManager.removeFromFavorites(favorite: favoritePhoto, immediately: true) { result in
            switch result {
            case .failure(let error):
                completion(false, error)
            case .success(_):
                completion(true, nil)
            }
        }
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension FavoritesViewModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        input?.willUpdate()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        guard let indexPath = indexPath else { return }

        switch type {
        case .delete:
            input?.updateRow(at: indexPath, action: .delete)
        case .insert:
            input?.updateRow(at: indexPath, action: .add)
        case .move:
            guard let newIndexPath = newIndexPath else { return }
            input?.updateRow(at: indexPath, action: .move(newIndexPath))
        case .update:
            input?.updateRow(at: indexPath, action: .redraw)
        @unknown default:
            print("Unknown action type: \(type)")
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        input?.didUpdate()
    }
}
