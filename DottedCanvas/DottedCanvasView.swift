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

    let imageSize: CGSize = CGSize(width: 1000, height: 1000)

    init(viewModel: DotImageViewModel) {

        dotImageViewModel = viewModel
        previewImageDiamter = min(UIScreen.main.bounds.size.width * 0.8, 500)
    }
    var body: some View {
        VStack {
            Toolbar(
                addSubImageData: {
                    let index = dotImageViewModel.subImageDataArrayIndex
                    let title = TimeStampFormatter.currentTimestamp(template: "MMM dd HH mm ss")
                    let data = SubImageData(title: title, image: makeImage())

                    if  dotImageViewModel.subImageDataArray.count == 0 ||
                        index == dotImageViewModel.subImageDataArray.count - 1 {

                        dotImageViewModel.appendSubImageData(data)
                        
                    } else {
                        dotImageViewModel.insertSubImageData(data, at: index + 1)
                    }

                    dotImageViewModel.updateMainImage()
                },
                removeSubImageData: {
                    let index = dotImageViewModel.subImageDataArrayIndex
                    dotImageViewModel.removeSubImageData(index)
                    dotImageViewModel.updateMainImage()
                })

            Spacer()
                .frame(height: 12)

            MainImagePreviewView(mainImage: $dotImageViewModel.mainImage,
                                 diameter: previewImageDiamter)

            if dotImageViewModel.subImageDataArray.count == 0 {
                Spacer()
                Text("Tap the + button to create a new image.")
                Spacer()

            } else {
                SubImageListView(viewModel: dotImageViewModel)
            }
        }
        .padding()
    }

    private func makeImage() -> UIImage {
        UIImage.dotImage(with: imageSize,
                         offset: CGPoint(x: CGFloat.random(in: 0 ... 200) - 100,
                                         y: CGFloat.random(in: 0 ... 200) - 100),
                         color: UIColor.randomColor)
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
