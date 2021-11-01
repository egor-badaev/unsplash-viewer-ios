//
//  DetailsInfoView.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 01.11.2021.
//

import UIKit

class DetailsInfoView: UIView {

    // MARK: - Properties
    private let inset: CGFloat = 10

    // MARK: - Subviews
    private let container: UIStackView = {
        let container = UIStackView()
        container.toAutoLayout()

        container.axis = .vertical
        container.spacing = 20.0

        return container
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()

        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.font = AppConfig.Font.secondary
        label.textAlignment = .center
        return label
    }()

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    func configure(with image: UIImage, text: String) {
        imageView.image = image
        label.text = text
    }

    // MARK: - Helper methods
    private func configureView() {
        backgroundColor = .systemGray6

        layer.masksToBounds = true
        layer.cornerRadius = 20

        addSubview(container)
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(label)

        let constraints = [
            container.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ]

        NSLayoutConstraint.activate(constraints)
    }

}
