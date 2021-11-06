//
//  DetailsCodableViewModel.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit
import AlamofireImage

class DetailsCodableViewModel: DetailsViewControllerOutput {

    weak var viewInput: DetailsViewControllerInput?

    var author: String {
        photo.user.name
    }

    var imagePlaceholderURL: URL {
        photo.thumbnailURL
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

    private var photo: UnsplashPhoto
    private let adapter: UnsplashApiAdapter
    private let imageDownloader: ImageDownloader

    init(photo: UnsplashPhoto, adapter: UnsplashApiAdapter, imageDownloader: ImageDownloader) {
        self.photo = photo
        self.adapter = adapter
        self.imageDownloader = imageDownloader
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
                self.imageDownloader.download(imageURLRequest, completion:  { response in
                    if case .success(let image) = response.result {
                        DispatchQueue.main.async {
                            self.viewInput?.didFetchPhoto(image: image)
                        }
                    }
                })
            }
        }
    }

    private func makeInfoData() -> [DetailsInfoData] {
        [
            DetailsInfoData(with: .date(photo.createdAt)),
            DetailsInfoData(with: .location(photo.location?.title)),
            DetailsInfoData(with: .downloads(photo.downloads))
        ].compactMap({ $0 })
    }
}
