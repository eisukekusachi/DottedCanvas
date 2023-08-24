//
//  SubImageData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit

struct SubImageData: Identifiable, Hashable {

    var id = UUID()
    var title: String = ""

    var image: UIImage?
    var thumbnail: UIImage?

    var alpha: Int = 255
    var isVisible: Bool = true

    var red: Int = 0
    var green: Int = 0
    var blue: Int = 0

    var diameter: Int = 0
    var spacing: Int = 0

    var offsetX: Int = 0
    var offsetY: Int = 0

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
    func createDotImage(size: CGSize) -> UIImage {
        let color = UIColor(red: CGFloat(red) / 255.0,
                            green: CGFloat(green) / 255.0,
                            blue: CGFloat(blue) / 255.0,
                            alpha: 1.0)

        return UIImage.dotImage(with: size,
                                dotSize: CGFloat(diameter),
                                spacing: CGFloat(spacing),
                                offset: CGPoint(x: CGFloat(offsetX),
                                                y: CGFloat(offsetY)),
                                color: color)
    }
}
