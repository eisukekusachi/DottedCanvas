//
//  TextExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

extension Text {
    func textModifier(size: CGFloat) -> some View {
        self
            .font(.custom("Helvetica", size: size))
            .foregroundColor(.primary)
    }
    func buttonTextModifier(size: CGFloat) -> some View {
        self
            .font(.custom("Helvetica-bold", size: size))
            .foregroundColor(.primary)
   }
}
