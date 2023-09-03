//
//  ViewModifiers.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/03.
//

import SwiftUI

struct ButtonDisabled: ViewModifier {
    let isDisabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.25 : 1.0)
    }
}
