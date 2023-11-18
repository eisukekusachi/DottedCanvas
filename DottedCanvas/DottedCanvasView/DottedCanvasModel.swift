//
//  DottedCanvasModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

struct DottedCanvasModel {
    var mainImageThumbnail: UIImage?
    var subLayers: [DottedCanvasSubLayerModel]
    var subLayerIndex: Int
    var latestUpdateDate: Date

    init(codableData: DottedCanvasModelCodable, folderURL: URL) {
        self.mainImageThumbnail = nil
        self.subLayers = codableData.subImages.map {
            DottedCanvasSubLayerModel(codableData: $0, folderURL: folderURL)
        }
        self.subLayerIndex = codableData.selectedSubImageIndex
        self.latestUpdateDate = Date()
    }
    init(mainImageThumbnail: UIImage?,
         subLayers: [DottedCanvasSubLayerModel],
         subLayerIndex: Int,
         latestUpdateDate: Date) {
        self.mainImageThumbnail = mainImageThumbnail
        self.subLayers = subLayers
        self.subLayerIndex = subLayerIndex
        self.latestUpdateDate = latestUpdateDate
    }
}
