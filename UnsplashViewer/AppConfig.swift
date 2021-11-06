//
//  AppConfig.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 01.11.2021.
//

import UIKit

enum AppConfig {
    enum UI {

        static let navbarMargin: CGFloat = 10.0
        static let horizontalInset: CGFloat = 16.0
        static let verticalInset: CGFloat = 16.0

        enum Collection {
            static let horizontalSpacing: CGFloat = 12.0
            static let verticalSpacing: CGFloat = 12.0
            static let referenceCellWidth: CGFloat = 220
            static let minimalNumberOfColumns = 2
        }
    }

    enum Font {
        static let primary: UIFont = .systemFont(ofSize: 17)
        static let secondary: UIFont = .systemFont(ofSize: 12)
    }

    enum Color {
        static let accent: UIColor = UIColor(named: "AccentColor") ?? .label
        static let favorites: UIColor = UIColor(named: "FavoritesColor") ?? #colorLiteral(red: 0.9450980392, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
    }

    enum API {
        // TODO: make this dependable on device (more for iPads)
        static let perPage: Int = 24
    }
}
