//
//  SubImageListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageListView: View {
    @ObservedObject var dotImageLayerViewModel: DotImageLayerViewModel
    @Binding var selectedImageAlpha: Int
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
            value: $selectedImageAlpha,
            style: sliderStyle,
            range: range) { value in

                dotImageLayerViewModel.updateLayer(id: dotImageLayerViewModel.selectedLayer?.id,
                                                   alpha: value)
        }
            .padding()
    }
    private var imageList: some View {
        List {
            ForEach(Array(dotImageLayerViewModel.layers.enumerated().reversed()),
                    id: \.element) { index, layer in

                SubImageItem(
                    imageItem: layer,
                    selected: layer == dotImageLayerViewModel.selectedLayer,
                    didTapVisibleButton: { result in

                    dotImageLayerViewModel.updateLayer(id: layer.id, isVisible: result)
                    dotImageLayerViewModel.updateMergedLayers()
                })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dotImageLayerViewModel.selectedLayer = layer
                        selectedImageAlpha = layer.alpha

                        didSelectItem?(index)
                    }
            }
            .onMove(perform: moveItem)
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
    private func moveItem(from source: IndexSet, to destination: Int) {
        dotImageLayerViewModel.layers = dotImageLayerViewModel.layers.reversed()
        dotImageLayerViewModel.layers.move(fromOffsets: source, toOffset: destination)
        dotImageLayerViewModel.layers = dotImageLayerViewModel.layers.reversed()

        dotImageLayerViewModel.updateMergedLayers()
    }
}

struct SubImageListView_Previews: PreviewProvider {
    static var previews: some View {

        @StateObject var viewModel = DotImageLayerViewModel()
        @State var selectedImageAlpha: Int = 0
        SubImageListView(
            dotImageLayerViewModel: viewModel,
            selectedImageAlpha: $selectedImageAlpha)
    }
}
