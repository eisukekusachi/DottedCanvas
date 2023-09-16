//
//  ProjectData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

let jsonFileName: String = "data.dat"
let thumbnailName: String = "thumbnail.png"

struct ProjectData {
    var mainImageThumbnail: UIImage?
    var subImageLayers: [SubImageData]
    var subImageLayerIndex: Int
    var latestUpdateDate: Date

    func writeData(to folder: URL) throws {
        try FileManager.createNewDirectory(url: folder)

        // Create codable data
        let codableData = MainImageCodableData(
            subImageCodableDataArray: subImageLayers.map { SubImageCodableData(data: $0) },
            selectedIndex: subImageLayerIndex
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
            try mainImageThumbnail?.pngData()?.write(to: imageURL)
        } catch {
            throw error
        }

        // Write subImage
        for i in 0..<subImageLayers.count {
            do {
                let imageURL = folder.appendingPathComponent(subImageLayers[i].imagePath)
                try subImageLayers[i].image?.pngData()?.write(to: imageURL)
            } catch {
                throw error
            }
        }
    }
}
