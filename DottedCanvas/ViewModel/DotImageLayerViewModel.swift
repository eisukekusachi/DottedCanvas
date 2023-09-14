//
//  DotImageViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit
import Combine

protocol ImageLayerManager {
    var mergedLayers: UIImage? { get }
    var layers: [SubImageData] { get }

    func addLayer(_ newData: SubImageData)
    func removeLayer(index: Int) -> Bool
    func updateLayer(id: UUID?, isVisible: Bool?, alpha: Int?)
    func updateMergedLayers()
}

class DotImageLayerViewModel: ObservableObject, ImageLayerManager {

    @Published var mergedLayers: UIImage?
    @Published var layers: [SubImageData]

    @Published var selectedLayer: SubImageData?

    var imageData: DotImageData? {
        DotImageData(mainImage: mergedLayers?.resize(sideLength: 256, scale: 1),
                     subImageDataArray: layers,
                     subImageIndex: getSelectedLayerIndex() ?? 0,
                     latestUpdateDate: latestUpdateDate)
    }

    var selectedLayerIndex: Int {
        layers.firstIndex(where: { $0 == selectedLayer }) ?? 0
    }

    var projectName: String = Calendar.currentDate
    var latestUpdateDate: Date = Date()

    private var cancellables: Set<AnyCancellable> = []

    convenience init() {
        self.init(initialLayers: [])
    }
    init(initialLayers: [SubImageData]) {
        layers = initialLayers

        if layers.count != 0, let data = layers.first {
            selectedLayer = data
        }

        $selectedLayer
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateMergedLayers()
            })
            .store(in: &cancellables)
    }

    func getLayerIndex(from id: UUID) -> Int? {
        for (index, elem) in layers.enumerated() where elem.id == id {
            return index
        }
        return nil
    }

    func reset() {
        mergedLayers = nil
        layers = []
        selectedLayer = nil

        projectName = Calendar.currentDate
        latestUpdateDate = Date()
    }

    func getSelectedLayerIndex() -> Int? {
        if let selectedLayer {
            return getLayerIndex(from: selectedLayer.id)
        }
        return nil
    }
    func removeSelectedSubImageData() {
        if removeLayer(index: selectedLayerIndex) {
            updateMergedLayers()
        }
    }

    // MARK: Add, Remove, Update
    func addLayer(_ newData: SubImageData) {
        if layers.isEmpty {
            appendSubImageData(newData)
        } else {
            insertSubImageData(newData, at: selectedLayerIndex + 1)
        }

        selectedLayer = newData
        updateMergedLayers()
    }

    func appendSubImageData(_ newData: SubImageData) {
        layers.append(newData)
        selectedLayer = newData
    }

    @discardableResult
    func insertSubImageData(_ newData: SubImageData, at index: Int) -> Bool {
        guard   index >= 0 &&
                index <= layers.count
        else {
            return false
        }

        layers.insert(newData, at: index)
        selectedLayer = newData

        return true
    }

    @discardableResult
    func removeLayer(index: Int) -> Bool {
        guard   layers.count != 0 &&
                index >= 0 &&
                index < layers.count
        else {
            return false
        }

        let tmpCurrentData = layers[index]

        layers.remove(at: index)

        if layers.count == 0 {
            selectedLayer = nil

        } else if selectedLayer == tmpCurrentData {
            let index = min(max(0, index), layers.count - 1)
            let data = layers[index]
            selectedLayer = data
        }

        return true
    }

    func updateSelectedLayer(index: Int) {
        if index < layers.count {
            selectedLayer = layers[index]
        }
    }

    func updateLayer(id: UUID?, isVisible: Bool? = nil, alpha: Int? = nil) {
        guard let id = id, let index = getLayerIndex(from: id) else {
            return
        }

        if let isVisible = isVisible {
            layers[index].isVisible = isVisible
        }

        if let alpha = alpha {
            layers[index].alpha = alpha
        }

        if selectedLayer?.id == id {
            selectedLayer = layers[index]
        }
    }

    func updateMergedLayers() {
        var image: UIImage?

        layers.forEach { data in
            if data.isVisible {
                if let newImage = data.image?.withAlpha(CGFloat(data.alpha) / 255.0) {

                    if image == nil {
                        image = newImage

                    } else {
                        image = image?.merge(with: newImage, alpha: CGFloat(data.alpha) / 255.0)
                    }
                }
            }
        }

        mergedLayers = image
        latestUpdateDate = Date()
    }
}
