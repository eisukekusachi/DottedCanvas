//
//  SubImageListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageListView: View {
    @ObservedObject var viewModel: DotImageViewModel

    private let style = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let range = 0 ... 255
    private let buttonDiameter: CGFloat = 16

    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))

    var body: some View {
        selectedSubImageAlphaSlider
        subImageList
    }
}

extension SubImageListView {
    private var selectedSubImageAlphaSlider: some View {
        TwoRowsSliderView(title: "Alpha",
                          value: $viewModel.currentSubImageAlpha,
                          style: sliderStyle,
                          range: range) { value in
            viewModel.updateSubImageData(id: viewModel.currentSubImageData?.id,
                                         alpha: value)
        }
                          .padding()
    }

    private func decreaseAlpha() {
        let alpha = max(viewModel.currentSubImageAlpha - 1, range.lowerBound)
        viewModel.updateSubImageData(id: viewModel.currentSubImageData?.id, alpha: alpha)
    }
    private func increaseAlpha() {
        let alpha = min(viewModel.currentSubImageAlpha + 1, range.upperBound)
        viewModel.updateSubImageData(id: viewModel.currentSubImageData?.id, alpha: alpha)
    }
    private var subImageList: some View {
        List {
            ForEach(viewModel.subImageDataArray.reversed()) { subImageData in
                SubImageListItem(selected: subImageData == viewModel.currentSubImageData,
                                 imageData: subImageData,
                                 onTapVisibleButton: { result in

                    viewModel.updateSubImageData(id: result.id, isVisible: !result.isVisible)
                    viewModel.updateMainImage()
                })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.storedCreationData.apply(subImageData)
                        viewModel.updateCurrentSubImageData(subImageData)
                    }
            }
            .onMove(perform: moveListItem)
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
    private func moveListItem(from source: IndexSet, to destination: Int) {
        viewModel.subImageDataArray = viewModel.subImageDataArray.reversed()
        viewModel.subImageDataArray.move(fromOffsets: source, toOffset: destination)
        viewModel.subImageDataArray = viewModel.subImageDataArray.reversed()

        viewModel.updateMainImage()
    }
}

struct SubImageListView_Previews: PreviewProvider {
    static var previews: some View {

        @StateObject var viewModel = DotImageViewModel()
        SubImageListView(viewModel: viewModel)
    }
}
