//
//  ContentView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dottedCanvasViewModel = DottedCanvasViewModel()
    @StateObject var projectListViewModel = ProjectListViewModel()

    var body: some View {
        DottedCanvasView(dottedCanvasViewModel: dottedCanvasViewModel,
                         projectListViewModel: projectListViewModel)
        .onAppear {
            Task {
                do {
                    let urls = URL.documents.allURLs
                    let projects = try await loadListProjectDataArray(from: urls)

                    DispatchQueue.main.async {
                        self.projectListViewModel.projects = projects
                    }

                } catch {
                    throw error
                }
            }
        }
    }

    private func loadListProjectDataArray(from allURLs: [URL]) async throws -> [ProjectListModel] {
        return try await withThrowingTaskGroup(of: ProjectListModel?.self) { group in
            var dataArray: [ProjectListModel] = []

            // Add tasks to unzip and load data for each ZIP file
            for zipURL in allURLs where zipURL.hasSuffix("zip") {
                group.addTask {
                    return try await projectListViewModel.loadData(fromZipFileURL: zipURL)
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
