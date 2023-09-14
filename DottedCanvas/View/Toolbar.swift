//
//  Toolbar.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct Toolbar: View {
    @ObservedObject var dotImageViewModel: DotImageLayerViewModel
    @ObservedObject var documentsViewModel: DocumentsFolderFileViewModel

    var addSubImageData: () -> Void
    var removeSubImageData: () -> Void
    var saveImage: () -> Void
    var loadImage: () -> Void
    var newImage: () -> Void

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
            .modifier(ButtonDisabled(isDisabled: dotImageViewModel.layers.isEmpty))

            Divider()
                .frame(height: 24)

            Button(
                action: {
                    saveImage()
            },
                label: {
                    Image(systemName: "square.and.arrow.up")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: dotImageViewModel.layers.isEmpty))

            Button(
                action: {
                    loadImage()
            },
                label: {
                    Image(systemName: "square.and.arrow.down")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: documentsViewModel.fileDataArray.isEmpty))

            Divider()
                .frame(height: 24)

            Button(
                action: {
                    newImage()
            },
                label: {
                    Image(systemName: "doc.badge.plus")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: dotImageViewModel.layers.isEmpty))
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar(
            dotImageViewModel: DotImageLayerViewModel(),
            documentsViewModel: DocumentsFolderFileViewModel(),
            addSubImageData: {
                print("add")
            },
            removeSubImageData: {
                print("remove")
            },
            saveImage: {
                print("saveImage")
            },
            loadImage: {
                print("loadImage")
            },
            newImage: {
                print("newImage")
            }
        )
    }
}
