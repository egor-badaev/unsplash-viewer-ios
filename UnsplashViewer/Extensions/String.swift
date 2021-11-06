//
//  String.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import UIKit

extension String {
    /**
     Convert `String` to `URL` object

     - returns: `URL` object
     - throws: `UnsplashApiError.invalidURL` if cannot convert

     */
    func toURL() throws -> URL {
        guard let url = URL(string: self) else {
            print("Cannot create URL from string")
            throw UnsplashApiError.invalidURL
        }
        return url
    }

    /**
     Convert `String` to `Date` object with ISO 8601 format

     - returns: `Date` object
     - throws: `UnsplashApiError.invalidData` if cannot convert

     */
    func toISO8601Date(withFormatOptions formatOptions: ISO8601DateFormatter.Options = [.withInternetDateTime]) throws -> Date {

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = formatOptions

        guard let date = dateFormatter.date(from: self) else {
            print("Cannot create date from string")
            throw UnsplashApiError.invalidData
        }

        return date

    }

    /**
     Convert `String` to `UIColor` object.

     - returns: `UIColor` object
     - throws: `UnsplashApiError.invalidData` if cannot convert

     Supports 3-, 6- and 8-digit color models

     [Source](https://stackoverflow.com/a/33397427/4776676)
     */
    func toUIColor() throws -> UIColor {
        let hex = self.trimmingCharacters(in: .alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            throw UnsplashApiError.invalidData
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)

    }
}
