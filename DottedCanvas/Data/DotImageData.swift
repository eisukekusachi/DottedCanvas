//
//  DotImageData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

let jsonFileName: String = "data.dat"
let thumbnailName: String = "thumbnail.png"

enum DotImageDataError: Error {
    case fileNotFound
    case invalidData
    case invalidJsonFile
    case imageFileNotFound
    case notImage
}

struct DotImageData {
    var mainImage: UIImage?
    var subImageDataArray: [SubImageData]
    var subImageIndex: Int
    var latestUpdateDate: Date

    func writeData(to folder: URL) throws {
        try FileManager.createNewDirectory(url: folder)

        // Create codable data
        let codableData = DotImageCodableData(
            subImageDataArray: subImageDataArray,
            selectedIndex: subImageIndex
        )

        do {
            // Encode codableData to JSON
            let data = try JSONEncoder().encode(codableData)
            let jsonstr = String(data: data, encoding: .utf8)!

            // Write JSON to file
            try jsonstr.write(
                to: folder.appendingPathComponent(jsonFileName),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            throw error
        }

        do {
            // Write mainImage thumbnail
            let imageURL = folder.appendingPathComponent(thumbnailName)
            try mainImage?.pngData()?.write(to: imageURL)
        } catch {
            throw error
        }

        // Write subImage
        for i in 0..<subImageDataArray.count {
            do {
                let imageURL = folder.appendingPathComponent(subImageDataArray[i].imagePath)
                try subImageDataArray[i].image?.pngData()?.write(to: imageURL)
            } catch {
                throw error
            }
        }
    }

    static func verifyFilesAreCorrect(_ folderURL: URL, jsonFileName: String) throws {
        let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)

        guard FileManager.default.fileExists(atPath: jsonFileURL.path) else {
            throw DotImageDataError.fileNotFound
        }

        guard let result: DotImageCodableData = Input.loadJson(url: jsonFileURL) else {
            throw DotImageDataError.invalidJsonFile
        }

        try result.subImages.forEach {
            let imageURL = folderURL.appendingPathComponent($0.imagePath)

            guard FileManager.default.fileExists(atPath: imageURL.path) else {
                throw DotImageDataError.imageFileNotFound
            }

            let data = try Data(contentsOf: imageURL)
            if UIImage(data: data)?.size == .zero {
                throw DotImageDataError.notImage
            }
        }
    }
}
