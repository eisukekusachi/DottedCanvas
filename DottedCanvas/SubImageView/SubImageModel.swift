//
//  SubImageModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI
import Combine

struct DefaultDotValue {
    static let diameter = 24
    static let spacing = 24
}

struct SubImageModel {

    var alpha: Int
    var isVisible: Bool

    var red: Int
    var green: Int
    var blue: Int

    var diameter: Int
    var spacing: Int

    var offsetX: Int
    var offsetY: Int

    init(alpha: Int = 255,
         isVisible: Bool = true,

         red: Int = 0,
         green: Int = 0,
         blue: Int = 0,
         diameter: Int = 24,
         spacing: Int = 20,
         offsetX: Int = 0,
         offsetY: Int = 0) {

        self.alpha = alpha
        self.isVisible = isVisible

        self.red = max(0, min(255, red))
        self.green = max(0, min(255, green))
        self.blue = max(0, min(255, blue))

        self.diameter = max(1, diameter)
        self.spacing = max(0, spacing)

        self.offsetX = offsetX
        self.offsetY = offsetY
    }

    init(_ data: SubImageData,
         alpha: Int = 255,
         isVisible: Bool = true) {

        self.alpha = alpha
        self.isVisible = isVisible

        self.red = data.red
        self.green = data.green
        self.blue = data.blue

        self.diameter = data.diameter
        self.spacing = data.spacing

        self.offsetX = data.offsetX
        self.offsetY = data.offsetY
    }
}

extension SubImageModel {
    var currentColor: UIColor {
        UIColor(red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                blue: CGFloat(blue) / 255.0,
                alpha: 1.0)
    }

    var redStyle: SliderStyle {
        let colors = [Color(uiColor: minRed),
                      Color(uiColor: maxRed)]

        let gradient = AnyView(LinearGradient(gradient: .init(colors: colors),
                                              startPoint: .leading,
                                              endPoint: .trailing))

        return SliderStyleImpl(track: gradient,
                               thumbColor: currentColor)
    }
    var greenStyle: SliderStyle {
        let colors = [Color(uiColor: minGreen),
                      Color(uiColor: maxGreen)]

        let gradient = AnyView(LinearGradient(gradient: .init(colors: colors),
                                              startPoint: .leading,
                                              endPoint: .trailing))

        return SliderStyleImpl(track: gradient,
                               thumbColor: currentColor)
    }
    var blueStyle: SliderStyle {
        let colors = [Color(uiColor: minBlue),
                      Color(uiColor: maxBlue)]

        let gradient = AnyView(LinearGradient(gradient: .init(colors: colors),
                                              startPoint: .leading,
                                              endPoint: .trailing))

        return SliderStyleImpl(track: gradient,
                               thumbColor: currentColor)
    }

    private var minRed: UIColor {
        .init(red: 0.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    private var maxRed: UIColor {
        .init(red: 1.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    private var minGreen: UIColor {
        .init(red: CGFloat(red) / 255.0, green: 0.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    private var maxGreen: UIColor {
        .init(red: CGFloat(red) / 255.0, green: 1.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    private var minBlue: UIColor {
        .init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: 0.0, alpha: 1.0)
    }
    private var maxBlue: UIColor {
        .init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: 1.0, alpha: 1.0)
    }
}
