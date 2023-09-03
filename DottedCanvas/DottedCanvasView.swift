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
                    addSubImageData: {
                        isCreationViewPresented = true
                    },
                    removeSubImageData: {
                        removeSubImageData()
                    },
                    saveImage: {
                        saveImage()
                    },
                    loadImage: {
                        showDocumentsFolderView()
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
                viewModel: documentsFolderFileViewModel) { url in
                    loadImage(zipFileURL: url)
                }
        }
    }


    private func updateMainImage() {
        let index = dotImageViewModel.subImageDataArrayIndex
        let title = TimeStampFormatter.currentTimestamp(template: "MMM dd HH mm ss")
        let dotImage = dotImageViewModel.storedCreationData.dotImage
        let newData = SubImageData(title: title,
                                   image: dotImage,
                                   data: dotImageViewModel.storedCreationData)

        if dotImageViewModel.subImageDataArray.isEmpty {
            dotImageViewModel.appendSubImageData(newData)
        } else {
            dotImageViewModel.insertSubImageData(newData, at: index + 1)
        }

        dotImageViewModel.updateSelectedSubImageData(newData)
        dotImageViewModel.updateMainImage()
    }
    private func removeSubImageData() {
        let index = dotImageViewModel.subImageDataArrayIndex
        dotImageViewModel.removeSubImageData(index)
        dotImageViewModel.updateMainImage()
    }
    private func saveImage() {
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

                try dotImageViewModel.dotImageData?.writeData(to: folderURL)

                try Output.createZip(folderURL: folderURL, zipFileURL: zipFileURL)

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
    private func loadImage(zipFileURL: URL) {
        let folderURL = URL.documents.appendingPathComponent(tmpFolder)
        let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)

        Task {
            do {
                defer {
                    try? FileManager.default.removeItem(atPath: folderURL.path)
                }

                try FileManager.createNewDirectory(url: folderURL)

                try unzipFile(from: zipFileURL, to: folderURL)

                if let data: DotImageCodableData = Input.loadJson(url: jsonFileURL) {

                    let newSubImageDataArray: [SubImageData] = data.subImages.map {
                        SubImageData(codableData: $0, folderURL: folderURL)
                    }

                    dotImageViewModel.updateName(zipFileURL)
                    dotImageViewModel.updateSubImageDataArray(newSubImageDataArray)
                    dotImageViewModel.updateSelectedSubImageData(data.selectedSubImageIndex)
                }

            } catch {
                print(error)
            }
        }
    }
    private func showDocumentsFolderView() {
        isDocumentsFolderViewPresented = true
    }
    private func showAlert(_ error: Error) {
        print(error)
    }
    private func unzipFile(from sourceURL: URL, to destinationURL: URL) throws {
        try Input.unzip(srcZipURL: sourceURL, to: destinationURL)
    }
}

struct DottedCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var dotImageViewModel = DotImageViewModel(
            dataArray: [.init(title: "Title 0", alpha: 125),
                        .init(title: "Title 1", alpha: 225, isVisible: false),
                        .init(title: "Title 2", alpha: 25)
                       ])

        DottedCanvasView(dotImageViewModel: DotImageViewModel(),
                         documentsFolderFileViewModel: DocumentsFolderFileViewModel())
    }
}
