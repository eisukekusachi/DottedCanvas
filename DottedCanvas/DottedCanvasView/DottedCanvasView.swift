//
//  DottedCanvasView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct DottedCanvasView: View {
    @ObservedObject var dottedCanvasViewModel: DottedCanvasViewModel
    @ObservedObject var projectListViewModel: ProjectListViewModel

    private let previewImageDiamter: CGFloat

    let defaultImageSize: CGSize = CGSize(width: 1000, height: 1000)

    @State var isSubImageViewPresented: Bool = false
    @State var isVisibleLoadingView: Bool = false
    @State var isVisibleSnackbar: Bool = false
    @State var isZippingCompleted: Bool = false
    @State var isNewImageAlertPresented: Bool = false
    @State var isDocumentsFolderViewPresented: Bool = false

    @State var selectedSubImage = SubImageModel()
    @State var selectedSubImageAlpha: Int = 255

    @State var message: String = ""

    init(dottedCanvasViewModel: DottedCanvasViewModel,
         projectListViewModel: ProjectListViewModel) {

        self.dottedCanvasViewModel = dottedCanvasViewModel
        self.projectListViewModel = projectListViewModel

        previewImageDiamter = min(UIScreen.main.bounds.size.width * 0.8, 500)
    }
    var body: some View {
        ZStack {
            VStack {
                DottedCanvasToolbarView(
                    dottedCanvasViewModel: dottedCanvasViewModel,
                    projectListViewModel: projectListViewModel,
                    addSubLayer: {
                        isSubImageViewPresented = true
                        updateSubLayer()
                    },
                    removeSubLayer: {
                        dottedCanvasViewModel.removeSelectedSubLayer()
                        updateSubLayer()
                    },
                    saveProject: {
                        let zipFileName = dottedCanvasViewModel.projectName + "." + "\(Output.zipSuffix)"
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

                DottedCanvasPreviewView(image: $dottedCanvasViewModel.mergedSubLayerImage,
                                        diameter: previewImageDiamter)

                if dottedCanvasViewModel.subLayers.isEmpty {
                    Spacer()
                    Text("Tap the + button to create a new image.")
                    Spacer()

                } else {
                    DottedCanvasSubLayerList(
                        viewModel: dottedCanvasViewModel,
                        selectedSubImageAlpha: $selectedSubImageAlpha,
                        didSelectLayer: { _ in
                            updateSubLayer()
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
        .sheet(isPresented: $isSubImageViewPresented) {
            SubImageView(isViewPresented: $isSubImageViewPresented,
                         data: selectedSubImage) { data, image in

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
                dottedCanvasViewModel.reset()
                selectedSubImage = SubImageModel()
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
        let title = TimeStampFormatter.current(template: "MMM dd HH mm ss")
        let newData = DottedCanvasSubLayerModel(title: title,
                                                image: dotImage,
                                                data: newSubImageData)

        dottedCanvasViewModel.addSubLayer(newData)
    }
    private func updateSubLayer() {
        if let subLayerData = dottedCanvasViewModel.selectedSubLayer {
            selectedSubImage = SubImageModel(layerData: subLayerData)
        }
    }

    private func saveProject(zipFileURL: URL) {
        guard let data = dottedCanvasViewModel.dottedCanvasData else { return }
        Task {
            do {
                let startDate = Date()
                let projectName = zipFileURL.fileName!

                message = "Saving..."
                isVisibleLoadingView = true
                isZippingCompleted = false
                try await Task.sleep(nanoseconds: UInt64(1 * 1000))

                try projectListViewModel.saveData(projectData: data,
                                                  zipFileURL: zipFileURL)

                projectListViewModel.upsertData(projectName: projectName,
                                                newThumbnail: data.mainImageThumbnail)

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
            let projectData = try dottedCanvasViewModel.loadData(fromZipFileURL: zipFileURL)

            dottedCanvasViewModel.update(projectData)
            selectedSubImageAlpha = dottedCanvasViewModel.selectedSubLayer?.alpha ?? 255

            if let fileName = zipFileURL.fileName {
                dottedCanvasViewModel.projectName = fileName
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
        @StateObject var dottedCanvasViewModel = DottedCanvasViewModel(
            initialSubLayers: [.init(title: "Title 0", alpha: 125),
                               .init(title: "Title 1", alpha: 225, isVisible: false),
                               .init(title: "Title 2", alpha: 25)
            ])

        DottedCanvasView(dottedCanvasViewModel: dottedCanvasViewModel,
                         projectListViewModel: ProjectListViewModel())
    }
}
