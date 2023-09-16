//
//  MainImageCodableData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import UIKit

class MainImageCodableData: Codable {
    var subImages: [SubImageCodableData]
    var selectedSubImageIndex: Int = 0
    var latestUpdateDate: Date = Date()

    init(subImageCodableDataArray: [SubImageCodableData], selectedIndex: Int) {
        self.subImages = subImageCodableDataArray
        self.selectedSubImageIndex = selectedIndex
    }
}
