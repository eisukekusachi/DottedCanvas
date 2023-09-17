//
//  ContentView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var mainImageLayerViewModel = MainImageLayerViewModel()
    @StateObject var projectFileListViewModel = ProjectListViewModel()

    var body: some View {
        DottedCanvasView(mainImageLayerViewModel: mainImageLayerViewModel,
                         projectListViewModel: projectFileListViewModel)
        .onAppear {
            Task {
                do {
                    let urls = URL.documents.allURLs
                    let loadedProjects = try await projectFileListViewModel.getProjectDataArray(from: urls)

                    DispatchQueue.main.async {
                        var projects = loadedProjects
                        projects.sort {
                            $0.latestUpdateDate < $1.latestUpdateDate
                        }

                        self.projectFileListViewModel.projects = projects
                    }

                } catch {
                    throw error
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
