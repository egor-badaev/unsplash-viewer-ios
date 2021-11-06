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
        case image(URL)
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
        case .image(let url):
            imageView.af.setImage(withURL: url, completion:  { [weak self] _ in
                self?.toggleLoading(false)
            })
        }
    }

    // MARK: - Helper methods
    private func configureViews() {
        addSubview(imageView)
        addSubview(activityIndicator)

        let constraints = [
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
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
