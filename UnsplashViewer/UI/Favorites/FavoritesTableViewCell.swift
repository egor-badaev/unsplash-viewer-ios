//
//  FavoritesTableViewCell.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 07.11.2021.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        guard let textLabel = textLabel else { return }

        textLabel.toAutoLayout()
        var constraints = [
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        if let imageView = imageView {
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 8.0
            imageView.contentMode = .scaleAspectFill
            imageView.toAutoLayout()

            constraints.append(contentsOf: [
                imageView.widthAnchor.constraint(equalToConstant: 40.0),
                imageView.heightAnchor.constraint(equalToConstant: 40.0),
                imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),

                textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20.0)
            ])
        } else {
            // if for some reason no image was provided, imageView is nil
            constraints.append(contentsOf: [
                textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
            ])
        }
        NSLayoutConstraint.activate(constraints)

        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
}
