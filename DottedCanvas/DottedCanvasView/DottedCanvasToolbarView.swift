//
//  DottedCanvasToolbarView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct DottedCanvasToolbarView: View {
    @ObservedObject var dottedCanvasViewModel: DottedCanvasViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel

    var addSubLayer: () -> Void
    var removeSubLayer: () -> Void
    var saveProject: () -> Void
    var loadProject: () -> Void
    var newProject: () -> Void

    private let buttonDiameter: CGFloat = 24

    var body: some View {
        HStack(spacing: 24) {
            Button(
                action: {
                    addSubLayer()
            },
                   label: {
                       Image(systemName: "plus.circle")
                           .buttonModifier(diameter: buttonDiameter)
            })

            Button(
                action: {
                    removeSubLayer()
            },
                label: {
                    Image(systemName: "minus.circle")
                        .buttonModifier(diameter: buttonDiameter)
            })
            .modifier(ButtonDisabled(isDisabled: dottedCanvasViewModel.subLayers.isEmpty))

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
            .modifier(ButtonDisabled(isDisabled: dottedCanvasViewModel.subLayers.isEmpty))

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
            .modifier(ButtonDisabled(isDisabled: dottedCanvasViewModel.subLayers.isEmpty))
        }
    }
}

struct DottedCanvasToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        DottedCanvasToolbarView(
            dottedCanvasViewModel: DottedCanvasViewModel(),
            projectListViewModel: ProjectListViewModel(),
            addSubLayer: {
                print("add")
            },
            removeSubLayer: {
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
