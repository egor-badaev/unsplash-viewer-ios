//
//  CoreDataError.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 07.11.2021.
//

import Foundation

enum CoreDataError: LocalizedError {
    case fetchRequestError

    var errorDescription: String? {
        switch self {
        case .fetchRequestError:
            return "❗️ Cannot build NSFetchRequest"
        }
    }
}

