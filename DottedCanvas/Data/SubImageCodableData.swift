//
//  SubImageCodableData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation

let zipSuffix: String = "zip"
let tmpFolder: String = "tmpFolder"

class SubImageCodableData: Codable {
    var title: String

    var imagePath: String

    var isVisible: Bool
    var alpha: Int

    var red: Int
    var green: Int
    var blue: Int

    var diameter: Int = 0
    var spacing: Int = 0

    var offsetX: Int = 0
    var offsetY: Int = 0

    init(data: SubImageData) {
        self.title = data.title

        self.imagePath = data.imagePath

        self.alpha = data.alpha
        self.isVisible = data.isVisible

        self.red = data.red
        self.green = data.green
        self.blue = data.blue

        self.diameter = data.diameter
        self.spacing = data.spacing

        self.offsetX = data.offsetX
        self.offsetY = data.offsetY
    }
}
