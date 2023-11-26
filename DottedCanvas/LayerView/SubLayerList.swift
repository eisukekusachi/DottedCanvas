//
//  SubLayerList.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubLayerList: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var selectedSubImageAlpha: Int
    var didSelectLayer: ((Int) -> Void)?

    private let style = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let range = 0 ... 255

    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))

    var body: some View {
        selectedSubLayerAlphaSlider
        subLayerList
    }
}

extension SubLayerList {
    private var selectedSubLayerAlphaSlider: some View {
        TwoRowsSliderView(
            title: "Alpha",
            value: $selectedSubImageAlpha,
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
                    id: \.element) { index, sublayer in

                SubLayerListItem(
                    subLayer: sublayer,
                    selected: sublayer == viewModel.selectedSubLayer,
                    didTapVisibleButton: { result in

                        viewModel.updateSubLayer(id: sublayer.id, isVisible: result)
                        viewModel.updateMergedSubLayers()
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedSubLayer = sublayer
                        selectedSubImageAlpha = sublayer.alpha

                        didSelectLayer?(index)
                    }
            }
            .onMove(perform: moveItem)
        }
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
    }
    private func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.subLayers = viewModel.subLayers.reversed()
        viewModel.subLayers.move(fromOffsets: source, toOffset: destination)
        viewModel.subLayers = viewModel.subLayers.reversed()

        viewModel.updateMergedSubLayers()
    }
}

struct SubLayerList_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = MainViewModel()
        @State var selectedSubImageAlpha: Int = 0
        SubLayerList(
            viewModel: viewModel,
            selectedSubImageAlpha: $selectedSubImageAlpha)
    }
}
