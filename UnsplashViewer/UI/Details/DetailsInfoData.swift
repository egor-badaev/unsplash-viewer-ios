//
//  DetailsInfoData.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit

struct DetailsInfoData {

    enum Category {
        case date(Date)
        case location(String?)
        case downloads(Int?)

        var image: UIImage? {
            switch self {
            case .date(_):
                return UIImage(systemName: "calendar")
            case .location(_):
                return UIImage(systemName: "mappin.and.ellipse")
            case .downloads(_):
                return UIImage(systemName: "square.and.arrow.down")
            }
        }
    }

    let image: UIImage?
    let text: String

    init(image: UIImage?, text: String) {
        self.image = image
        self.text = text
    }

    init?(with category: Category) {
        switch category {
        case .date(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale.current
            let dateString = formatter.string(from: date)
            self.init(image: category.image, text: dateString)
        case .location(let title):
            if let title = title {
                self.init(image: category.image, text: title)
            } else {
                return nil
            }
        case .downloads(let downloads):
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            if let downloads = downloads,
               let downloadsString = formatter.string(for: downloads) {
                self.init(image: category.image, text: downloadsString)
            } else {
                return nil
            }
        }
    }
}

