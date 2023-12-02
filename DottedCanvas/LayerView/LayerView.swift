//
//  LayerView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct LayerView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel

    var addSubLayer: () -> Void
    var saveProject: () -> Void
    var loadProject: () -> Void
    var newProject: () -> Void

    @State var message: String = ""

    var body: some View {
        VStack {
            ToolbarView(
                mainViewModel: mainViewModel,
                projectListViewModel: projectListViewModel,
                addSubLayer: {
                    addSubLayer()
                },
                removeSubLayer: {
                    mainViewModel.removeSelectedSubLayer()
                },
                saveProject: {
                    saveProject()
                },
                loadProject: {
                    loadProject()
                },
                newProject: {
                    newProject()
                }
            )

            Spacer()
                .frame(height: 12)

            PreviewView(image: $mainViewModel.mergedSubLayerImage,
                        diameter: min(UIScreen.main.bounds.size.width * 0.8, 500))

            if mainViewModel.subLayers.isEmpty {
                Spacer()
                Text("Tap the + button to create a new image.")
                Spacer()

            } else {
                LayerListView(viewModel: mainViewModel)
            }
        }
        .padding()
        .onReceive(mainViewModel.$selectedSubLayer, perform: { subLayer in
            mainViewModel.selectedSubImage = SubImageModel(subLayerData: subLayer)
        })
    }
}

struct LayerView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel(
            initialSubLayers: [.init(title: "Title 0", alpha: 125),
                               .init(title: "Title 1", alpha: 225, isVisible: false),
                               .init(title: "Title 2", alpha: 25)
            ])
        @StateObject var projectListViewModel = ProjectListViewModel(projects: [])

        LayerView(mainViewModel: mainViewModel,
                  projectListViewModel: projectListViewModel,
                  addSubLayer: {
            print("addSubLayer")
        },
                  saveProject: {
            print("saveProject")
        },
                  loadProject: {
            print("loadProject")
        },
                  newProject: {
            print("newProject")
        })
    }
}
