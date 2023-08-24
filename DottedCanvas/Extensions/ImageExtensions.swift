//
//  ImageExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

extension Image {
    func buttonModifier(diameter: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: diameter, height: diameter)
            .foregroundColor(Color(uiColor: GlobalData.getAssetColor(.component)))
   }
}
