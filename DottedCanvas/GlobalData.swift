//
//  GlobalData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/20.
//

import SwiftUI

enum ColorAssetKey: String {
    case component
    case reversalComponent
    case trackColor
}

enum GlobalData {
    static func getAssetColor(_ assetName: ColorAssetKey) -> UIColor {
        UIColor(named: assetName.rawValue) ?? .clear
    }
}
