//
//  LayerView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct LayerView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @Binding var isProjectListViewPresented: Bool
    @Binding var isProjectsEmpty: Bool

    @State var isSubImageViewPresented: Bool = false
    @State var isVisibleLoadingView: Bool = false
    @State var isVisibleSnackbar: Bool = false
    @State var isZippingCompleted: Bool = false
    @State var isNewImageAlertPresented: Bool = false

    @State var selectedSubImage = SubImageModel()

    @State var message: String = ""

    var body: some View {
        ZStack {
            VStack {
                ToolbarView(
                    mainViewModel: mainViewModel,
                    isProjectsEmpty: $isProjectsEmpty,
                    addSubLayer: {
                        isSubImageViewPresented = true
                        updateSubLayer()
                    },
                    removeSubLayer: {
                        mainViewModel.removeSelectedSubLayer()
                        updateSubLayer()
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
                    SubLayerList(
                        viewModel: mainViewModel,
                        selectedSubImageAlpha: $mainViewModel.selectedSubImageAlpha,
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
                mainViewModel.selectedSubImageAlpha = data.alpha
            }
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
        let newData = SubLayerModel(title: title,
                                    image: dotImage,
                                    data: newSubImageData)

        mainViewModel.addSubLayer(newData)
    }
    private func updateSubLayer() {
        if let subLayerData = mainViewModel.selectedSubLayer {
            selectedSubImage = SubImageModel(layerData: subLayerData)
        }
    }

    private func saveProject(zipFileURL: URL) {
        /*
        guard let data = mainViewModel.dottedCanvasData else { return }
        Task {
            do {
                let startDate = Date()
                let projectName = zipFileURL.fileName!

                message = "Saving..."
                isVisibleLoadingView = true
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

                isVisibleLoadingView = false
                isZippingCompleted = true

            } catch {
                showAlert(error)
            }
        }
        */
    }
    private func showAlert(_ error: Error) {
        print(error)
    }
}

struct LayerView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel(
            initialSubLayers: [.init(title: "Title 0", alpha: 125),
                               .init(title: "Title 1", alpha: 225, isVisible: false),
                               .init(title: "Title 2", alpha: 25)
            ])
        @State var isProjectListViewPresented: Bool = false
        @State var isProjectsEmpty: Bool = false

        LayerView(mainViewModel: mainViewModel,
                  isProjectListViewPresented: $isProjectListViewPresented,
                  isProjectsEmpty: $isProjectsEmpty)
    }
}
