//
//  SubImageListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageListView: View {
    @ObservedObject var viewModel: DotImageLayerViewModel
    @Binding var selectedImageAlpha: Int
    var didSelectItem: ((Int) -> Void)?

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
        TwoRowsSliderView(
            title: "Alpha",
            value: $selectedImageAlpha,
            style: sliderStyle,
            range: range) { value in

            viewModel.updateLayer(id: viewModel.selectedLayer?.id,
                                  alpha: value)
        }
            .padding()
    }

    private func decreaseAlpha() {
        guard let data = viewModel.selectedLayer else { return }
        let alpha = max(data.alpha - 1, range.lowerBound)
        viewModel.updateLayer(id: viewModel.selectedLayer?.id, alpha: alpha)
    }
    private func increaseAlpha() {
        guard let data = viewModel.selectedLayer else { return }
        let alpha = min(data.alpha + 1, range.upperBound)
        viewModel.updateLayer(id: viewModel.selectedLayer?.id, alpha: alpha)
    }
    private var subImageList: some View {
        List {
            ForEach(Array(viewModel.layers.enumerated().reversed()),
                    id: \.element) { index, layer in

                SubImageListItem(selected: layer == viewModel.selectedLayer,
                                 imageData: layer,
                                 onTapVisibleButton: { result in

                    viewModel.updateLayer(id: result.id, isVisible: !result.isVisible)
                    viewModel.updateMergedLayers()
                })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedLayer = layer
                        selectedImageAlpha = layer.alpha

                        didSelectItem?(index)
                    }
            }
            .onMove(perform: moveListItem)
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
    private func moveListItem(from source: IndexSet, to destination: Int) {
        viewModel.layers = viewModel.layers.reversed()
        viewModel.layers.move(fromOffsets: source, toOffset: destination)
        viewModel.layers = viewModel.layers.reversed()

        viewModel.updateMergedLayers()
    }
}

struct SubImageListView_Previews: PreviewProvider {
    static var previews: some View {

        @StateObject var viewModel = DotImageLayerViewModel()
        @State var selectedImageAlpha: Int = 0
        SubImageListView(viewModel: viewModel,
                         selectedImageAlpha: $selectedImageAlpha)
    }
}
