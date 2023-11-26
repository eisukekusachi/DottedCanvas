//
//  MainViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit
import Combine

class MainViewModel: ObservableObject {
    @Published var mergedSubLayerImage: UIImage?

    @Published var subLayers: [SubLayerModel]
    @Published var selectedSubLayer: SubLayerModel?

    var dottedCanvasData: MainModel? {
        MainModel(mainImageThumbnail: mergedSubLayerImage?.resize(sideLength: 256, scale: 1),
                  subLayers: subLayers,
                  subLayerIndex: getSelectedSubLayerIndex() ?? 0,
                  latestUpdateDate: Date())
    }

    var selectedSubLayerIndex: Int {
        subLayers.firstIndex(where: { $0 == selectedSubLayer }) ?? 0
    }

    var projectName: String = Calendar.currentDate

    private var cancellables: Set<AnyCancellable> = []

    convenience init() {
        self.init(initialSubLayers: [])
    }
    init(initialSubLayers: [SubLayerModel]) {
        subLayers = initialSubLayers

        if subLayers.count != 0, let layer = subLayers.first {
            selectedSubLayer = layer
        }

        $selectedSubLayer
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateMergedSubLayers()
            })
            .store(in: &cancellables)
    }

    func getSubLayerIndex(from id: UUID) -> Int? {
        for (index, elem) in subLayers.enumerated() where elem.id == id {
            return index
        }
        return nil
    }

    func reset() {
        mergedSubLayerImage = nil
        subLayers = []
        selectedSubLayer = nil

        projectName = Calendar.currentDate
    }

    func getSelectedSubLayerIndex() -> Int? {
        if let selectedSubLayer {
            return getSubLayerIndex(from: selectedSubLayer.id)
        }
        return nil
    }
    func removeSelectedSubLayer() {
        if removeSubLayer(index: selectedSubLayerIndex) {
            updateMergedSubLayers()
        }
    }

    func loadData(fromZipFileURL zipFileURL: URL) throws -> MainModel {

        let uniqueFolderURL = URL.tmp.appendingPathComponent(UUID().uuidString)

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(at: uniqueFolderURL)
        }

        // Unzip the contents of the ZIP file
        try FileManager.createNewDirectory(url: uniqueFolderURL)
        try Input.unzipFile(from: zipFileURL, to: uniqueFolderURL)

        let jsonUrl = uniqueFolderURL.appendingPathComponent(Output.jsonFileName)
        if let data: MainModelCodable = Input.loadJson(url: jsonUrl) {
            return MainModel(codableData: data,
                             folderURL: uniqueFolderURL)

        } else {
            throw InputError.failedToLoadJson
        }
    }

    // MARK: Add, Remove, Update
    func addSubLayer(_ newLayer: SubLayerModel) {
        if subLayers.isEmpty {
            appendSubLayer(newLayer)
        } else {
            insertSubLayer(newLayer, at: selectedSubLayerIndex + 1)
        }

        selectedSubLayer = newLayer
        updateMergedSubLayers()
    }

    func appendSubLayer(_ newLayer: SubLayerModel) {
        subLayers.append(newLayer)
        selectedSubLayer = newLayer
    }

    @discardableResult
    func insertSubLayer(_ newLayer: SubLayerModel, at index: Int) -> Bool {
        guard   index >= 0 &&
                index <= subLayers.count
        else {
            return false
        }

        subLayers.insert(newLayer, at: index)
        selectedSubLayer = newLayer

        return true
    }

    @discardableResult
    func removeSubLayer(index: Int) -> Bool {
        guard   subLayers.count != 0 &&
                index >= 0 &&
                index < subLayers.count
        else {
            return false
        }

        let currentSubLayer = subLayers[index]

        subLayers.remove(at: index)

        if subLayers.count == 0 {
            selectedSubLayer = nil

        } else if selectedSubLayer == currentSubLayer {
            let newIndex = min(max(0, index), subLayers.count - 1)
            let newLayer = subLayers[newIndex]
            selectedSubLayer = newLayer
        }

        return true
    }

    func update(_ mainModel: MainModel) {
        subLayers = mainModel.subLayers
        updateSelectedSubLayer(index: mainModel.subLayerIndex)
    }
    func updateSelectedSubLayer(index: Int) {
        if index < subLayers.count {
            selectedSubLayer = subLayers[index]
        }
    }

    func updateSubLayer(id: UUID?, isVisible: Bool? = nil, alpha: Int? = nil) {
        guard let id = id, let index = getSubLayerIndex(from: id) else {
            return
        }

        if let isVisible = isVisible {
            subLayers[index].isVisible = isVisible
        }

        if let alpha = alpha {
            subLayers[index].alpha = alpha
        }

        if selectedSubLayer?.id == id {
            selectedSubLayer = subLayers[index]
        }
    }

    func updateMergedSubLayers() {
        var image: UIImage?

        subLayers.forEach { data in
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
        mergedSubLayerImage = image
    }
}
