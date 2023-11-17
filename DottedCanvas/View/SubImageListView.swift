//
//  SubImageListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageListView: View {
    @ObservedObject var mainImageLayerViewModel: MainImageLayerViewModel
    @Binding var selectedSubImageAlpha: Int
    var didSelectItem: ((Int) -> Void)?

    private let style = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let range = 0 ... 255
    private let buttonDiameter: CGFloat = 16

    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))

    var body: some View {
        selectedImageAlphaSlider
        imageList
    }
}

extension SubImageListView {
    private var selectedImageAlphaSlider: some View {
        TwoRowsSliderView(
            title: "Alpha",
            value: $selectedSubImageAlpha,
            style: sliderStyle,
            range: range) { value in

                mainImageLayerViewModel.updateSubLayer(id: mainImageLayerViewModel.selectedSubImageData?.id,
                                                       alpha: value)
        }
            .padding()
    }
    private var imageList: some View {
        List {
            ForEach(Array(mainImageLayerViewModel.subLayers.enumerated().reversed()),
                    id: \.element) { index, data in

                SubImageItem(
                    imageItem: data,
                    selected: data == mainImageLayerViewModel.selectedSubImageData,
                    didTapVisibleButton: { result in

                        mainImageLayerViewModel.updateSubLayer(id: data.id, isVisible: result)
                        mainImageLayerViewModel.updateMergedSubLayers()
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        mainImageLayerViewModel.selectedSubImageData = data
                        selectedSubImageAlpha = data.alpha

                        didSelectItem?(index)
                    }
            }
            .onMove(perform: moveItem)
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
    private func moveItem(from source: IndexSet, to destination: Int) {
        mainImageLayerViewModel.subLayers = mainImageLayerViewModel.subLayers.reversed()
        mainImageLayerViewModel.subLayers.move(fromOffsets: source, toOffset: destination)
        mainImageLayerViewModel.subLayers = mainImageLayerViewModel.subLayers.reversed()

        mainImageLayerViewModel.updateMergedSubLayers()
    }
}

struct SubImageListView_Previews: PreviewProvider {
    static var previews: some View {

        @StateObject var viewModel = MainImageLayerViewModel()
        @State var selectedSubImageAlpha: Int = 0
        SubImageListView(
            mainImageLayerViewModel: viewModel,
            selectedSubImageAlpha: $selectedSubImageAlpha)
    }
}
