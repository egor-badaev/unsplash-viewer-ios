//
//  DetailsViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit

class DetailsViewController: CoordinatedViewController {

    // MARK: - Properties
    private var isFavorite = false {
        didSet {
            configureFavoritesButton()
        }
    }

    // MARK: - Subviews
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.toAutoLayout()

        scrollView.contentInset = UIEdgeInsets(
            top: AppConfig.UI.navbarMargin,
            left: AppConfig.UI.horizontalInset,
            bottom: AppConfig.UI.verticalInset,
            right: AppConfig.UI.horizontalInset)

        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.toAutoLayout()
        return contentView
    }()

    private let container: UIStackView = {
        let container = UIStackView()
        container.toAutoLayout()

        container.axis = .vertical
        container.spacing = 30.0

        return container
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.toAutoLayout()
        imageView.contentMode = .scaleAspectFit

        let placeholder = UIColor.systemGray4.image()
        imageView.image = placeholder

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.toAutoLayout()

        label.font = AppConfig.Font.primary
        label.text = "Lorem ipsum dolor sit amet"
        label.numberOfLines = 0
        
        return label
    }()

    private let infoView: UIStackView = {
        let infoView = UIStackView()
        infoView.toAutoLayout()

        infoView.axis = .horizontal
        infoView.distribution = .fillEqually
        infoView.spacing = AppConfig.UI.horizontalInset

        return infoView
    }()

    private lazy var favoritesButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(favoritesTapped(_:)))
        return item
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureViews()
    }

    // MARK: - Helper methods
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = favoritesButton
        configureFavoritesButton()
    }

    private func configureFavoritesButton() {
        favoritesButton.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favoritesButton.tintColor = isFavorite ? AppConfig.Color.favorites : AppConfig.Color.accent
    }

    private func configureViews() {

        view.addSubview(scrollView)
        scrollView.addSubview(container)

        container.addArrangedSubview(imageView)
        container.addArrangedSubview(label)
        container.addArrangedSubview(infoView)

        let mockData = InfoData.mock

        mockData.forEach { info in
            let infoTile = DetailsInfoView()
            infoTile.configure(with: info.image, text: info.text)
            infoView.addArrangedSubview(infoTile)
        }

        let safeArea = view.safeAreaLayoutGuide
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            container.topAnchor.constraint(equalTo: scrollView.topAnchor),
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(AppConfig.UI.horizontalInset * 2)),

            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            infoView.heightAnchor.constraint(equalToConstant: 73)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions
    @objc private func favoritesTapped(_ sender: UIBarButtonItem) {
        isFavorite.toggle()
    }
    
}

// MARK: - Mock data
struct InfoData {
    let image: UIImage
    let text: String

    static let mock = [
        InfoData(image: UIImage(systemName: "calendar")!, text: "Dec 12, 2021"),
        InfoData(image: UIImage(systemName: "mappin.and.ellipse")!, text: "Moscow, RU"),
        InfoData(image: UIImage(systemName: "square.and.arrow.down")!, text: "160 000")
    ]
}
