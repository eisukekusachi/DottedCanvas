//
//  SubImageViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/11/17.
//

import SwiftUI

class SubImageViewModel: ObservableObject {
    @Published var data: SubImageModel

    var dotImage: UIImage {
        UIImage.dotImage(with: data.imageSize,
                         dotSize: CGFloat(data.diameter),
                         spacing: CGFloat(data.spacing),
                         offset: CGPoint(x: data.offsetX, y: data.offsetY),
                         color: UIColor(red: CGFloat(data.red) / 255.0,
                                        green: CGFloat(data.green) / 255.0,
                                        blue: CGFloat(data.blue) / 255.0,
                                        alpha: CGFloat(data.alpha) / 255.0 ))
    }

    init(data: SubImageModel) {
        self.data = data
    }
}
