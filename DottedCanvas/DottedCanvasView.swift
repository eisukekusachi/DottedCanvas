//
//  DottedCanvasView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/18.
//

import SwiftUI

struct DottedCanvasView: View {

    @ObservedObject var dotImageViewModel: DotImageViewModel

    private let previewImageDiamter: CGFloat

    let defaultImageSize: CGSize = CGSize(width: 1000, height: 1000)

    @State var isCreationViewPresented: Bool = false
    @State var isVisibleLoadingView: Bool = false
    @State var isVisibleSnackbar: Bool = false
    @State var isZippingCompleted: Bool = false

    @State var message: String = ""

    init(viewModel: DotImageViewModel) {

        dotImageViewModel = viewModel
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
        DottedCanvasView(viewModel: dotImageViewModel)
        DottedCanvasView(viewModel: DotImageViewModel())
    }
}
