//
//  ToolbarView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct ToolbarView: View {
    @ObservedObject var mainViewModel: MainViewModel
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
            .modifier(ButtonDisabled(isDisabled: mainViewModel.subLayers.isEmpty))

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
            .modifier(ButtonDisabled(isDisabled: mainViewModel.subLayers.isEmpty))

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
            .modifier(ButtonDisabled(isDisabled: mainViewModel.subLayers.isEmpty))
        }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView(
            mainViewModel: MainViewModel(),
            projectListViewModel: ProjectListViewModel(projects: []),
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
