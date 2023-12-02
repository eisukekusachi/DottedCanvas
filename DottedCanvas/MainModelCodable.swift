//
//  MainModelCodable.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

struct MainModelCodable: Codable {
    var subImages: [SubLayerModelCodable] = []
    var selectedSubImageIndex: Int = 0
    var latestUpdateDate: Date = Date()

    init(subLayerDataCoableArray: [SubLayerModelCodable], selectedIndex: Int) {
        self.subImages = subLayerDataCoableArray
        self.selectedSubImageIndex = selectedIndex
    }
}
