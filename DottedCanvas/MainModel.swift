//
//  MainModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

struct MainModel {
    let mainImageThumbnail: UIImage?
    let subLayers: [SubLayerModel]
    let subLayerIndex: Int
    let latestUpdateDate: Date

    init(codableData: MainModelCodable, folderURL: URL) {
        self.mainImageThumbnail = nil
        self.subLayers = codableData.subImages.map {
            SubLayerModel(codableData: $0, folderURL: folderURL)
        }
        self.subLayerIndex = codableData.selectedSubImageIndex
        self.latestUpdateDate = Date()
    }
    init(mainImageThumbnail: UIImage?,
         subLayers: [SubLayerModel],
         subLayerIndex: Int,
         latestUpdateDate: Date) {
        self.mainImageThumbnail = mainImageThumbnail
        self.subLayers = subLayers
        self.subLayerIndex = subLayerIndex
        self.latestUpdateDate = latestUpdateDate
    }
}
