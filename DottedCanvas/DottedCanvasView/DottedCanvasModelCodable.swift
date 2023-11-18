//
//  DottedCanvasModelCodable.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

struct DottedCanvasModelCodable: Codable {
    var subImages: [DottedCanvasSubLayerModelCodable] = []
    var selectedSubImageIndex: Int = 0
    var latestUpdateDate: Date = Date()

    init(subLayerDataCoableArray: [DottedCanvasSubLayerModelCodable], selectedIndex: Int) {
        self.subImages = subLayerDataCoableArray
        self.selectedSubImageIndex = selectedIndex
    }
}
