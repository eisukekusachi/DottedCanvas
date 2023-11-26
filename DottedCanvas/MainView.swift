//
//  MainView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var mainViewModel = MainViewModel()
    @StateObject var projectListViewModel = ProjectListViewModel()
    @State var isProjectListViewPresented: Bool = false

    var body: some View {
        LayerView(mainViewModel: mainViewModel,
                  isProjectListViewPresented: $isProjectListViewPresented,
                  isProjectsEmpty: projectListViewModel.isProjectsEmptyBinding)
        .sheet(isPresented: $isProjectListViewPresented) {
            ProjectListView(
                isViewPresented: $isProjectListViewPresented,
                viewModel: projectListViewModel,
                didSelectItem: { index in
                    let projectName = projectListViewModel.projects[index].projectName
                    let zipFileURL = URL.documents.appendingPathComponent(projectName + ".zip")
                    loadProject(zipFileURL: zipFileURL)
                })
        }
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

    private func loadProject(zipFileURL: URL) {
        do {
            let projectData = try mainViewModel.loadData(fromZipFileURL: zipFileURL)

            mainViewModel.update(projectData)
            mainViewModel.selectedSubImageAlpha = mainViewModel.selectedSubLayer?.alpha ?? 255

            if let fileName = zipFileURL.fileName {
                mainViewModel.projectName = fileName
            }

        } catch {
            showAlert(error)
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

    private func showAlert(_ error: Error) {
        print(error)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
