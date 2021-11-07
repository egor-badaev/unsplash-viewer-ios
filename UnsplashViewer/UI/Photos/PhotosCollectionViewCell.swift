//
//  PhotosCollectionViewCell.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit
import AlamofireImage

class PhotosCollectionViewCell: UICollectionViewCell {

    // MARK: - Helper types
    enum Configuration {
        case nothing
        case image(UnsplashPhoto, ImageDownloader)
    }

    // MARK: - Subviews
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.toAutoLayout()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        imageView.image = nil
    }

    // MARK: - Interface
    func configure(with configuration: Configuration) {
        switch configuration {
        case .nothing:
            toggleLoading(true)
        case .image(let photo, let imageDownloader):
            contentView.backgroundColor = photo.color
            imageView.af.imageDownloader = imageDownloader
            imageView.af.setImage(withURL: photo.thumbnailURL, cacheKey: photo.thumbnailCacheKey, completion:  { [weak self] _ in
                self?.toggleLoading(false)
            })
        }
    }

    // MARK: - Helper methods
    private func configureViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)

        let constraints = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func toggleLoading(_ isLoading: Bool) {
        imageView.isHidden = isLoading
        if isLoading {
            imageView.image = nil
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
