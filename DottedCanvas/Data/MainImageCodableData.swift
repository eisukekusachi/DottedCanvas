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

    init(subImageDataArray: [SubImageData], selectedIndex: Int) {
        self.subImages = []
        self.selectedSubImageIndex = selectedIndex

        subImageDataArray.forEach { data in
            let codableData = SubImageCodableData(data: data)
            self.subImages.append(codableData)
        }
    }
}
