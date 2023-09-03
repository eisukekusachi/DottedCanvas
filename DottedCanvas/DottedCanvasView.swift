//
//  DottedCanvasView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct DottedCanvasView: View {

    @ObservedObject var dotImageViewModel: DotImageViewModel
    @ObservedObject var documentsFolderFileViewModel: DocumentsFolderFileViewModel

    private let previewImageDiamter: CGFloat

    let defaultImageSize: CGSize = CGSize(width: 1000, height: 1000)

    @State var isCreationViewPresented: Bool = false
    @State var isVisibleLoadingView: Bool = false
    @State var isVisibleSnackbar: Bool = false
    @State var isZippingCompleted: Bool = false
    @State var isNewImageAlertPresented: Bool = false
    @State var isDocumentsFolderViewPresented: Bool = false

    @State var message: String = ""

    init(dotImageViewModel: DotImageViewModel,
         documentsFolderFileViewModel: DocumentsFolderFileViewModel) {

        self.dotImageViewModel = dotImageViewModel
        self.documentsFolderFileViewModel = documentsFolderFileViewModel

        previewImageDiamter = min(UIScreen.main.bounds.size.width * 0.8, 500)
    }
    var body: some View {
        ZStack {
            VStack {
                Toolbar(
                    dotImageViewModel: dotImageViewModel,
                    addSubImageData: {
                        isCreationViewPresented = true
                    },
                    removeSubImageData: {
                        dotImageViewModel.removeCurrentSubImageData()
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

                MainImagePreviewView(mainImage: $dotImageViewModel.mainImage,
                                     diameter: previewImageDiamter)

                if dotImageViewModel.subImageDataArray.isEmpty {
                    Spacer()
                    Text("Tap the + button to create a new image.")
                    Spacer()

                } else {
                    SubImageListView(viewModel: dotImageViewModel)
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
                                 creationData: dotImageViewModel.storedCreationData) {
                updateMainImage()
            }
        }
        .sheet(isPresented: $isDocumentsFolderViewPresented) {
            DocumentsFolderView(
                isViewPresented: $isDocumentsFolderViewPresented,
                viewModel: documentsFolderFileViewModel) { title in

                    let zipFileURL = URL.documents.appendingPathComponent(title + ".zip")
                    loadDotImageFromDocumentsFolder(zipFileURL: zipFileURL)
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
                dotImageViewModel.reset()
            }

            return Alert(title: Text(title),
                  message: Text(message),
                  primaryButton: .default(Text("OK"),
                                          action: action),
                  secondaryButton: .destructive(Text("Cancel")))
        }
    }


    private func updateMainImage() {
        let title = TimeStampFormatter.current(template: "MMM dd HH mm ss")
        let dotImage = dotImageViewModel.storedCreationData.dotImage
        let newData = SubImageData(title: title,
                                   image: dotImage,
                                   data: dotImageViewModel.storedCreationData)

        dotImageViewModel.addSubImageData(newData)
    }
    private func saveDotImageToDocumentsFolder() {
        let folderURL = URL.documents.appendingPathComponent(tmpFolder)
        let zipFileURL = URL.documents.appendingPathComponent(dotImageViewModel.name + "." + "\(zipSuffix)")

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

                try dotImageViewModel.saveDataAsZipFile(src: folderURL,
                                                        to: zipFileURL)

                documentsFolderFileViewModel.upsert(title: dotImageViewModel.name,
                                                    imageData: dotImageViewModel.dotImageData)

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
                try dotImageViewModel.loadData(from: folderURL)

                if let fileName = zipFileURL.fileName {
                    dotImageViewModel.updateName(fileName)
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
        @StateObject var dotImageViewModel = DotImageViewModel(
            dataArray: [.init(title: "Title 0", alpha: 125),
                        .init(title: "Title 1", alpha: 225, isVisible: false),
                        .init(title: "Title 2", alpha: 25)
                       ])

        DottedCanvasView(dotImageViewModel: dotImageViewModel,
                         documentsFolderFileViewModel: DocumentsFolderFileViewModel())
    }
}
