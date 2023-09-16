//
//  Toolbar.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct Toolbar: View {
    @ObservedObject var mainImageLayerViewModel: MainImageLayerViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel

    var addSubImageData: () -> Void
    var removeSubImageData: () -> Void
    var saveProject: () -> Void
    var loadProject: () -> Void
    var newProject: () -> Void

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
            .modifier(ButtonDisabled(isDisabled: mainImageLayerViewModel.subLayers.isEmpty))

            Divider()
                .frame(height: 24)

            Button(
                action: {
                    saveProject()
            },
                label: {
                    Image(systemName: "square.and.arrow.up")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: mainImageLayerViewModel.subLayers.isEmpty))

            Button(
                action: {
                    loadProject()
            },
                label: {
                    Image(systemName: "square.and.arrow.down")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: projectListViewModel.projects.isEmpty))

            Divider()
                .frame(height: 24)

            Button(
                action: {
                    newProject()
            },
                label: {
                    Image(systemName: "doc.badge.plus")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: mainImageLayerViewModel.subLayers.isEmpty))
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar(
            mainImageLayerViewModel: MainImageLayerViewModel(),
            projectListViewModel: ProjectListViewModel(),
            addSubImageData: {
                print("add")
            },
            removeSubImageData: {
                print("remove")
            },
            saveProject: {
                print("saveImage")
            },
            loadProject: {
                print("loadImage")
            },
            newProject: {
                print("newImage")
            }
        )
    }
}
