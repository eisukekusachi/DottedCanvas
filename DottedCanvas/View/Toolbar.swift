//
//  Toolbar.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct Toolbar: View {

    var addSubImageData: () -> Void
    var removeSubImageData: () -> Void

    private let buttonDiameter: CGFloat = 24

    var body: some View {
        HStack(spacing: 24) {

            Button(
                action: {
                    addSubImageData()
            },
                   label: {
                       Image(systemName: "plus.circle")
                           .buttonModifier(diameter: buttonDiameter)
            })

            Button(
                action: {
                    removeSubImageData()
            },
                label: {
                    Image(systemName: "minus.circle")
                        .buttonModifier(diameter: buttonDiameter)
            })
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar(
            addSubImageData: {
                print("add")
            },
            removeSubImageData: {
                print("remove")
            })
    }
}
