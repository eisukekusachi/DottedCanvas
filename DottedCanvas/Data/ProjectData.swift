//
//  ProjectData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit


struct ProjectData {

    static let zipSuffix: String = "zip"
    static let jsonFileName: String = "data.dat"
    static let thumbnailName: String = "thumbnail.png"
    static let tmpFolder: String = "tmpFolder"

    var mainImageThumbnail: UIImage?
    var subImageLayers: [SubImageData]
    var subImageLayerIndex: Int
    var latestUpdateDate: Date

    init(codableData: ProjectCodableData, folderURL: URL) {
        self.mainImageThumbnail = nil
        self.subImageLayers = codableData.subImages.map {
            SubImageData(codableData: $0, folderURL: folderURL)
        }
        self.subImageLayerIndex = codableData.selectedSubImageIndex
        self.latestUpdateDate = Date()
    }
    init(mainImageThumbnail: UIImage?,
         subImageLayers: [SubImageData],
         subImageLayerIndex: Int,
         latestUpdateDate: Date) {
        self.mainImageThumbnail = mainImageThumbnail
        self.subImageLayers = subImageLayers
        self.subImageLayerIndex = subImageLayerIndex
        self.latestUpdateDate = latestUpdateDate
    }
}
