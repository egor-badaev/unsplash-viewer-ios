//
//  DetailsViewController.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 31.10.2021.
//

import UIKit
import AlamofireImage

protocol DetailsViewControllerOutput {
    var author: String { get }
    var imagePlaceholderURL: URL { get }
    var description: String? { get }
    var imageAspectRatio: CGFloat { get }
    func fetchDetails()
}

protocol DetailsViewControllerInput: AnyObject {
    func didFetchInfo(infoData: [DetailsInfoData])
    func didFetchPhoto(image: UIImage)
    func didFailFetch(description: String)
}

class DetailsViewController: CoordinatedViewController {

    // MARK: - Properties
    private var isFavorite = false {
        didSet {
            configureFavoritesButton()
        }
    }

    private let viewModel: DetailsViewControllerOutput

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

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.toAutoLayout()
        imageView.contentMode = .scaleAspectFit

        imageView.af.setImage(withURL: viewModel.imagePlaceholderURL)

        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.toAutoLayout()

        label.font = AppConfig.Font.primary
        label.text = viewModel.description
        label.numberOfLines = 0

        label.isHidden = true
        
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

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.toAutoLayout()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Life cycle
    init(viewModel: DetailsViewControllerOutput) {
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
        viewModel.fetchDetails()
    }

    // MARK: - UI Configuration
    private func configureNavigationBar() {
        title = viewModel.author
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

        view.addSubview(activityIndicator)

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

            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: viewModel.imageAspectRatio),

            activityIndicator.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: infoView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        activityIndicator.startAnimating()
    }

    // MARK: - Actions
    @objc private func favoritesTapped(_ sender: UIBarButtonItem) {
        isFavorite.toggle()
    }
    
}

// MARK: - DetailsViewControllerInput
extension DetailsViewController: DetailsViewControllerInput {
    func didFetchInfo(infoData: [DetailsInfoData]) {

        activityIndicator.stopAnimating()

        infoData.forEach { info in
            let infoTile = DetailsInfoView()
            infoTile.configure(with: info.image, text: info.text)
            self.infoView.addArrangedSubview(infoTile)
        }
    }

    func didFetchPhoto(image: UIImage) {
        imageView.image = image
    }

    func didFailFetch(description: String) {
        showError(message: description)
    }
}
