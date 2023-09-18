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
                    let projects = try await loadListProjectDataArray(from: urls)

                    DispatchQueue.main.async {
                        var projects = projects
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

    private func loadListProjectDataArray(from allURLs: [URL]) async throws -> [ProjectDataInList] {
        return try await withThrowingTaskGroup(of: ProjectDataInList?.self) { group in
            var dataArray: [ProjectDataInList] = []

            // Add tasks to unzip and load data for each ZIP file
            for zipURL in allURLs where zipURL.hasSuffix("zip") {
                group.addTask {
                    let fileName = zipURL.fileName!
                    let tmpFolderURL = URL.documents.appendingPathComponent(tmpFolder + fileName)
                    return try await projectFileListViewModel.loadListProjectData(zipFileURL: zipURL,
                                                                                  tmpFolderURL: tmpFolderURL)
                }
            }

            // Collect the results of the tasks
            for try await data in group {
                if let data {
                    dataArray.append(data)
                }
            }

            return dataArray
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
