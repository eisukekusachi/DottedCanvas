//
//  DottedCanvasSubLayerModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit

struct DottedCanvasSubLayerModel: Identifiable, Hashable {
    let id: UUID
    let title: String

    let image: UIImage?
    let thumbnail: UIImage?

    var alpha: Int
    var isVisible: Bool

    let red: Int
    let green: Int
    let blue: Int

    let diameter: Int
    let spacing: Int

    let offsetX: Int
    let offsetY: Int

    var imagePath: String {
        id.uuidString
    }

    init(codableData: DottedCanvasSubLayerModelCodable, folderURL: URL) {
        self.id = UUID()
        self.title = codableData.title

        let url = folderURL.appendingPathComponent(codableData.imagePath)

        if let data = try? Data(contentsOf: url) {
            self.image = UIImage(data: data)
            self.thumbnail = image?.resize(sideLength: 256, scale: 1)
        } else {
            self.image = nil
            self.thumbnail = nil
        }

        self.alpha = codableData.alpha
        self.isVisible = codableData.isVisible

        self.red = codableData.red
        self.green = codableData.green
        self.blue = codableData.blue

        self.diameter = codableData.diameter
        self.spacing = codableData.spacing

        self.offsetX = codableData.offsetX
        self.offsetY = codableData.offsetY
    }
    init(title: String,
         isVisible: Bool = true,
         image: UIImage?,
         data: SubImageModel) {
        self.id = UUID()

        self.title = title
        self.image = image
        self.thumbnail = image?.resize(to: CGSize(width: 256, height: 256))

        self.isVisible = isVisible

        self.red = data.red
        self.green = data.green
        self.blue = data.blue
        self.alpha = data.alpha

        self.diameter = data.diameter

        self.spacing = data.spacing

        self.offsetX = data.offsetX
        self.offsetY = data.offsetY
    }
    init(title: String,
         image: UIImage? = nil,

         red: Int = 0,
         green: Int = 0,
         blue: Int = 0,
         alpha: Int = 255,

         diameter: Int = 50,

         isVisible: Bool = true,

         spacing: Int = 200,
         offsetX: Int = 0,
         offsetY: Int = 0) {
        self.id = UUID()

        self.title = title
        self.image = image
        self.thumbnail = image?.resize(to: CGSize(width: 256, height: 256))

        self.red = max(0, min(255, red))
        self.green = max(0, min(255, green))
        self.blue = max(0, min(255, blue))
        self.alpha = alpha

        self.diameter = max(1, diameter)

        self.isVisible = isVisible

        self.spacing = max(0, spacing)

        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}
