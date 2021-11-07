//
//  ImageDiskStorage.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 06.11.2021.
//

import UIKit

class ImageDiskStorage {

    private let documentsURL: URL

    init() {
        let documentsUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        documentsURL = documentsUrls[0]
    }

    func cachedFilename(for image: UIImage) -> String {

        let uuid = UUID().uuidString
        let filename = "\(uuid).jpg"
        let fileUrl = documentsURL.appendingPathComponent(filename)

        FileManager.default.createFile(atPath: fileUrl.path, contents: image.jpegData(compressionQuality: 0.8), attributes: nil)

        return filename
    }

    func image(filename: String) -> UIImage? {

        let fileUrl = documentsURL.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: fileUrl) {
            let image = UIImage(data: data)
            return image
        }

        return nil
    }

    func delete(filename: String?) {
        guard let filename = filename else { return }
        let fileUrl = documentsURL.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            print("Error deleting file:", error)
        }
    }
}
