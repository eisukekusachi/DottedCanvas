//
//  DottedCanvasView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

enum IOError: Error {
    case failedToLoadJson
}

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

    @State var dotImageCreationData = DotImageCreationData()
    @State var selectedImageAlpha: Int = 255

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
                        updateDotImageCreationData()
                    },
                    removeSubImageData: {
                        mainImageLayerViewModel.removeSelectedSubLayer()
                        updateDotImageCreationData()
                    },
                    saveImage: {
                        saveDotImageToDocumentsFolder()
                    },
                    loadImage: {
                        isDocumentsFolderViewPresented = true
                    },
                    newImage: {
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
                        selectedImageAlpha: $selectedImageAlpha,
                        didSelectItem: { _ in
                            updateDotImageCreationData()
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
            DotImageCreationView(isViewPresented: $isCreationViewPresented,
                                 creationData: dotImageCreationData) {
                let newData = updateMainImage()
                selectedImageAlpha = newData.alpha
            }
        }
        .sheet(isPresented: $isDocumentsFolderViewPresented) {
            DocumentsProjectView(
                isViewPresented: $isDocumentsFolderViewPresented,
                projectList: projectListViewModel,
                didSelectItem: { index in

                    let projectName = projectListViewModel.projects[index].projectName
                    let zipFileURL = URL.documents.appendingPathComponent(projectName + ".zip")
                    loadDotImageFromDocumentsFolder(zipFileURL: zipFileURL)
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
                dotImageCreationData.reset()
            }

            return Alert(title: Text(title),
                  message: Text(message),
                  primaryButton: .default(Text("OK"),
                                          action: action),
                  secondaryButton: .destructive(Text("Cancel")))
        }
    }


    private func updateMainImage() -> SubImageData {
        let newData = SubImageData(title: TimeStampFormatter.current(template: "MMM dd HH mm ss"),
                                   data: dotImageCreationData)

        mainImageLayerViewModel.addSubLayer(newData)

        return newData
    }
    private func updateDotImageCreationData() {
        if let subLayer = mainImageLayerViewModel.selectedSubLayer {
            dotImageCreationData.apply(subLayer)
        }
    }
    private func saveDotImageToDocumentsFolder() {
        let zipFileName = mainImageLayerViewModel.projectName + "." + "\(zipSuffix)"
        let zipFileURL = URL.documents.appendingPathComponent(zipFileName)
        let folderURL = URL.documents.appendingPathComponent(tmpFolder)

        Task {
            do {
                defer {
                    try? FileManager.default.removeItem(atPath: folderURL.path)
                }

                let startDate = Date()

                message = "Saving..."
                isVisibleLoadingView = true
                isZippingCompleted = false
                try await Task.sleep(nanoseconds: UInt64(1 * 1000))

                try mainImageLayerViewModel.projectData?.writeData(to: folderURL)
                try Output.createZip(folderURL: folderURL, zipFileURL: zipFileURL)

                projectListViewModel.upsertProjectData(mainImageLayerViewModel.projectData,
                                                       projectName: mainImageLayerViewModel.projectName)

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
    private func loadDotImageFromDocumentsFolder(zipFileURL: URL) {
        let folderURL = URL.documents.appendingPathComponent(tmpFolder)

        Task {
            do {
                defer {
                    try? FileManager.default.removeItem(atPath: folderURL.path)
                }

                try FileManager.createNewDirectory(url: folderURL)
                try Input.unzip(srcZipURL: zipFileURL, to: folderURL)

                let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)

                if let data: MainImageCodableData = Input.loadJson(url: jsonFileURL) {

                    mainImageLayerViewModel.subLayers = data.subImages.map {
                        SubImageData(codableData: $0, folderURL: folderURL)
                    }
                    mainImageLayerViewModel.updateSelectedSubLayer(index: data.selectedSubImageIndex)

                } else {
                    throw IOError.failedToLoadJson
                }

                if let fileName = zipFileURL.fileName {
                    mainImageLayerViewModel.projectName = fileName
                }
                
            } catch {
                print(error)
            }
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
