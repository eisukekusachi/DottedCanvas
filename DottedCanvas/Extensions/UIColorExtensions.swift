//
//  UIColorExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit

extension UIColor {
    static var randomColor: UIColor {
        let red = CGFloat.random(in: 0 ... 255) / 255.0
        let green = CGFloat.random(in: 0 ... 255) / 255.0
        let blue = CGFloat.random(in: 0 ... 255) / 255.0
        return .init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
