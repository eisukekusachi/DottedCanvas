//
//  LayerListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

/// A list that manages layers and allows for reordering, updating visibility, and updating alpha.
struct LayerListView: View {
    @ObservedObject var viewModel: MainViewModel

    private let style = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let range = 0 ... 255

    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))

    var body: some View {
        selectedSubLayerAlphaSlider
        subLayerList
    }
}

extension LayerListView {
    private var selectedSubLayerAlphaSlider: some View {
        TwoRowsSliderView(
            title: "Alpha",
            value: $viewModel.selectedSubImageAlpha,
            style: sliderStyle,
            range: range) { value in
                viewModel.updateSubLayer(id: viewModel.selectedSubLayer?.id,
                                         alpha: value)
        }
            .padding()
    }
    private var subLayerList: some View {
        List {
            ForEach(Array(viewModel.subLayers.enumerated().reversed()),
                    id: \.element) { _, sublayer in

                LayerListItem(
                    subLayer: sublayer,
                    selected: sublayer == viewModel.selectedSubLayer,
                    didTapVisibleButton: { result in
                        viewModel.updateSubLayer(id: sublayer.id, isVisible: result)
                        viewModel.updateMergedSubLayers()
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedSubLayer = sublayer
                        viewModel.selectedSubImageAlpha = sublayer.alpha
                    }
            }
                    .onMove(perform: { source, destination in
                        viewModel.subLayers = viewModel.subLayers.reversed()
                        viewModel.subLayers.move(fromOffsets: source, toOffset: destination)
                        viewModel.subLayers = viewModel.subLayers.reversed()

                        viewModel.updateMergedSubLayers()
                    })
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
}

struct LayerListView_Previews: PreviewProvider {
    static var previews: some View {
        LayerListView(viewModel: MainViewModel())
    }
}
