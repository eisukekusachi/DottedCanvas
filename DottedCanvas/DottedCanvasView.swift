//
//  DottedCanvasView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct DottedCanvasView: View {

    @ObservedObject var mainImageLayerViewModel: MainImageLayerViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel

    private let previewImageDiamter: CGFloat

    let defaultImageSize: CGSize = CGSize(width: 1000, height: 1000)

    @State var isCreationViewPresented: Bool = false
    @State var isVisibleLoadingView: Bool = false
    @State var isVisibleSnackbar: Bool = false
    @State var isZippingCompleted: Bool = false
    @State var isNewImageAlertPresented: Bool = false
    @State var isDocumentsFolderViewPresented: Bool = false

    @State var selectedSubImageData = SubImageModel()
    @State var selectedSubImageAlpha: Int = 255

    @State var message: String = ""

    init(mainImageLayerViewModel: MainImageLayerViewModel,
         projectListViewModel: ProjectListViewModel) {

        self.mainImageLayerViewModel = mainImageLayerViewModel
        self.projectListViewModel = projectListViewModel

        previewImageDiamter = min(UIScreen.main.bounds.size.width * 0.8, 500)
    }
    var body: some View {
        ZStack {
            VStack {
                Toolbar(
                    mainImageLayerViewModel: mainImageLayerViewModel,
                    projectListViewModel: projectListViewModel,
                    addSubImageData: {
                        isCreationViewPresented = true
                        updateSubImageCreationData()
                    },
                    removeSubImageData: {
                        mainImageLayerViewModel.removeSelectedSubLayer()
                        updateSubImageCreationData()
                    },
                    saveProject: {
                        let zipFileName = mainImageLayerViewModel.projectName + "." + "\(Output.zipSuffix)"
                        saveProject(zipFileURL: URL.documents.appendingPathComponent(zipFileName))
                    },
                    loadProject: {
                        isDocumentsFolderViewPresented = true
                    },
                    newProject: {
                        isNewImageAlertPresented = true
                    }
                )

                Spacer()
                    .frame(height: 12)

                MainImagePreviewView(mainImage: $mainImageLayerViewModel.mergedSubLayers,
                                     diameter: previewImageDiamter)

                if mainImageLayerViewModel.subLayers.isEmpty {
                    Spacer()
                    Text("Tap the + button to create a new image.")
                    Spacer()

                } else {
                    SubImageListView(
                        mainImageLayerViewModel: mainImageLayerViewModel,
                        selectedSubImageAlpha: $selectedSubImageAlpha,
                        didSelectItem: { _ in
                            updateSubImageCreationData()
                    })
                }
            }
            .padding()

            if isVisibleLoadingView {
                LoadingDialog(isVisibleLoadingView: $isVisibleLoadingView,
                              message: $message)
                    .onDisappear {
                        isVisibleSnackbar = true
                    }
            }

            if isVisibleSnackbar {
                Snackbar(isDisplayed: $isVisibleSnackbar,
                         imageSystemName: "hand.thumbsup.fill",
                         comment: isZippingCompleted ? "Success" : "Error")
            }
        }
        .sheet(isPresented: $isCreationViewPresented) {
            SubImageView(isViewPresented: $isCreationViewPresented,
                         data: selectedSubImageData) { data, image in

                updateMainImage(newSubImageData: data,
                                dotImage: image)
                selectedSubImageAlpha = data.alpha
            }
        }
        .sheet(isPresented: $isDocumentsFolderViewPresented) {
            ProjectListView(
                isViewPresented: $isDocumentsFolderViewPresented,
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
                mainImageLayerViewModel.reset()
                selectedSubImageData.reset()
            }

            return Alert(title: Text(title),
                  message: Text(message),
                  primaryButton: .default(Text("OK"),
                                          action: action),
                  secondaryButton: .destructive(Text("Cancel")))
        }
    }

    private func updateMainImage(newSubImageData: SubImageModel,
                                 dotImage: UIImage?) {
        let newData = SubImageData(title: TimeStampFormatter.current(template: "MMM dd HH mm ss"),
                                   image: dotImage,
                                   data: newSubImageData)

        mainImageLayerViewModel.addSubLayer(newData)
    }
    private func updateSubImageCreationData() {
        if let subLayer = mainImageLayerViewModel.selectedSubLayer {
            selectedSubImageData.apply(subLayer)
        }
    }

    private func saveProject(zipFileURL: URL) {
        guard let projectData = mainImageLayerViewModel.projectData else { return }
        Task {
            do {
                let startDate = Date()
                let projectName = zipFileURL.fileName!

                message = "Saving..."
                isVisibleLoadingView = true
                isZippingCompleted = false
                try await Task.sleep(nanoseconds: UInt64(1 * 1000))

                try projectListViewModel.saveData(projectData: projectData,
                                                  zipFileURL: zipFileURL)

                projectListViewModel.upsertData(projectName: projectName,
                                                newThumbnail: projectData.mainImageThumbnail)

                let sleep: CGFloat = 1.0 - Date().timeIntervalSince(startDate)
                if sleep > 0.0 {
                    try await Task.sleep(nanoseconds: UInt64(sleep * 1000 * 1000 * 1000))
                }

                isVisibleLoadingView = false
                isZippingCompleted = true

            } catch {
                showAlert(error)
            }
        }
    }
    private func loadProject(zipFileURL: URL) {
        do {
            let tmpFolderURL = URL.documents.appendingPathComponent(Output.tmpFolder)
            let projectData = try mainImageLayerViewModel.loadData(fromZipFileURL: zipFileURL)

            mainImageLayerViewModel.update(projectData)
            selectedSubImageAlpha = mainImageLayerViewModel.selectedSubLayer?.alpha ?? 255

            if let fileName = zipFileURL.fileName {
                mainImageLayerViewModel.projectName = fileName
            }

        } catch {
            showAlert(error)
        }
    }

    private func showAlert(_ error: Error) {
        print(error)
    }
}

struct DottedCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = MainImageLayerViewModel(
            initialSubLayers: [.init(title: "Title 0", alpha: 125),
                               .init(title: "Title 1", alpha: 225, isVisible: false),
                               .init(title: "Title 2", alpha: 25)
            ])

        DottedCanvasView(mainImageLayerViewModel: viewModel,
                         projectListViewModel: ProjectListViewModel())
    }
}
