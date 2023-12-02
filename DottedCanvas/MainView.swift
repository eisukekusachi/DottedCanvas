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

    @State var message: String = ""
    @State var isZippingCompleted: Bool = false

    @State var isSnackbarPresented: Bool = false
    @State var isNewImageAlertPresented: Bool = false
    @State var isLoadingViewPresented: Bool = false
    @State var isSubImageViewPresented: Bool = false
    @State var isProjectListViewPresented: Bool = false

    var body: some View {
        ZStack {
            LayerView(mainViewModel: mainViewModel,
                      isProjectsEmpty: projectListViewModel.isProjectsEmptyBinding,
                      addSubLayer: {
                isSubImageViewPresented = true
            },
                      saveProject: {
                let zipFileName = mainViewModel.projectName + "." + "\(Output.zipSuffix)"
                saveProject(zipFileURL: URL.documents.appendingPathComponent(zipFileName))
            },
                      loadProject: {
                isProjectListViewPresented = true
            },
                      newProject: {
                isNewImageAlertPresented = true
            })
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
            .alert(isPresented: $isNewImageAlertPresented) {
                let title = "Confirm"
                let message = ["If you create a new project, ",
                               "any existing work will be deleted.",
                               "\n",
                               "Are you sure you want to continue?"
                ].joined()
                let action = {
                    mainViewModel.reset()
                }

                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .default(Text("OK"),
                                                     action: action),
                             secondaryButton: .destructive(Text("Cancel")))
            }
            .sheet(isPresented: $isSubImageViewPresented) {
                SubImageView(isViewPresented: $isSubImageViewPresented,
                             data: mainViewModel.selectedSubImage) { data, image in

                    let title = TimeStampFormatter.current(template: "MMM dd HH mm ss")
                    let newLayerData = SubLayerModel(title: title,
                                                     image: image,
                                                     data: data)
                    mainViewModel.addSubLayer(newLayerData)
                    mainViewModel.selectedSubImageAlpha = newLayerData.alpha
                }
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

            if isLoadingViewPresented {
                LoadingDialog(isLoadingViewPresented: $isLoadingViewPresented,
                              message: $message)
                .onDisappear {
                    isSnackbarPresented = true
                }
            }
            if isSnackbarPresented {
                Snackbar(isPresented: $isSnackbarPresented,
                         imageSystemName: "hand.thumbsup.fill",
                         comment: isZippingCompleted ? "Success" : "Error")
            }
        }
    }

    private func saveProject(zipFileURL: URL) {
        guard let data = mainViewModel.dottedCanvasData else { return }
        Task {
            do {
                let startDate = Date()
                let projectName = zipFileURL.fileName!

                message = "Saving..."
                isLoadingViewPresented = true
                isZippingCompleted = false
                try await Task.sleep(nanoseconds: UInt64(1 * 1000))

                try projectListViewModel.saveData(mainModel: data,
                                                  zipFileURL: zipFileURL)

                projectListViewModel.upsertData(projectName: projectName,
                                                newThumbnail: data.mainImageThumbnail)

                let sleep: CGFloat = 1.0 - Date().timeIntervalSince(startDate)
                if sleep > 0.0 {
                    try await Task.sleep(nanoseconds: UInt64(sleep * 1000 * 1000 * 1000))
                }

                isLoadingViewPresented = false
                isZippingCompleted = true

            } catch {
                showAlert(error)
            }
        }
    }
    private func loadProject(zipFileURL: URL) {
        do {
            let projectData = try mainViewModel.loadData(fromZipFileURL: zipFileURL)

            mainViewModel.update(projectData)
            mainViewModel.selectedSubImageAlpha = mainViewModel.selectedSubImage.alpha

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
