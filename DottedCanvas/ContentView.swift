//
//  ContentView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dotImageLayerViewModel = DotImageLayerViewModel()
    @StateObject var projectFileListViewModel = ProjectFileListViewModel()

    var body: some View {
        DottedCanvasView(dotImageLayerViewModel: dotImageLayerViewModel,
                         projectFileListViewModel: projectFileListViewModel)
        .onAppear {
            Task {
                do {
                    try await projectFileListViewModel.appendDocumentsFolderFile()

                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
