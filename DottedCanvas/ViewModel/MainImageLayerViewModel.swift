//
//  DotImageViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit
import Combine

protocol ImageLayerManager {
    var mergedSubLayers: UIImage? { get }
    var subLayers: [SubImageData] { get }

    func addSubLayer(_ newData: SubImageData)
    func removeSubLayer(index: Int) -> Bool
    func updateSubLayer(id: UUID?, isVisible: Bool?, alpha: Int?)
    func updateMergedSubLayers()
}

class MainImageLayerViewModel: ObservableObject, ImageLayerManager {

    @Published var mergedSubLayers: UIImage?
    @Published var subLayers: [SubImageData]

    @Published var selectedSubLayer: SubImageData?

    var projectData: ProjectData? {
        ProjectData(mainImageThumbnail: mergedSubLayers?.resize(sideLength: 256, scale: 1),
                    subImageLayers: subLayers,
                    subImageLayerIndex: getSelectedSubLayerIndex() ?? 0,
                    latestUpdateDate: Date())
    }

    var selectedLayerIndex: Int {
        subLayers.firstIndex(where: { $0 == selectedSubLayer }) ?? 0
    }

    var projectName: String = Calendar.currentDate

    private var cancellables: Set<AnyCancellable> = []

    convenience init() {
        self.init(initialSubLayers: [])
    }
    init(initialSubLayers: [SubImageData]) {
        subLayers = initialSubLayers

        if subLayers.count != 0, let data = subLayers.first {
            selectedSubLayer = data
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
        mergedSubLayers = nil
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
        if removeSubLayer(index: selectedLayerIndex) {
            updateMergedSubLayers()
        }
    }

    func loadData(fromZipFileURL zipFileURL: URL) throws -> ProjectData {

        let uniqueFolderURL = URL.tmp.appendingPathComponent(UUID().uuidString)

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(at: uniqueFolderURL)
        }

        // Unzip the contents of the ZIP file
        try FileManager.createNewDirectory(url: uniqueFolderURL)
        try Input.unzipFile(from: zipFileURL, to: uniqueFolderURL)

        let jsonUrl = uniqueFolderURL.appendingPathComponent(Output.jsonFileName)
        if let data: ProjectCodableData = Input.loadJson(url: jsonUrl) {
            return ProjectData(codableData: data,
                               folderURL: uniqueFolderURL)

        } else {
            throw InputError.failedToLoadJson
        }
    }

    // MARK: Add, Remove, Update
    func addSubLayer(_ newData: SubImageData) {
        if subLayers.isEmpty {
            appendSubImageData(newData)
        } else {
            insertSubImageData(newData, at: selectedLayerIndex + 1)
        }

        selectedSubLayer = newData
        updateMergedSubLayers()
    }

    func appendSubImageData(_ newData: SubImageData) {
        subLayers.append(newData)
        selectedSubLayer = newData
    }

    @discardableResult
    func insertSubImageData(_ newData: SubImageData, at index: Int) -> Bool {
        guard   index >= 0 &&
                index <= subLayers.count
        else {
            return false
        }

        subLayers.insert(newData, at: index)
        selectedSubLayer = newData

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

        let tmpCurrentData = subLayers[index]

        subLayers.remove(at: index)

        if subLayers.count == 0 {
            selectedSubLayer = nil

        } else if selectedSubLayer == tmpCurrentData {
            let index = min(max(0, index), subLayers.count - 1)
            let data = subLayers[index]
            selectedSubLayer = data
        }

        return true
    }

    func update(_ projectData: ProjectData) {
        subLayers = projectData.subImageLayers
        updateSelectedSubLayer(index: projectData.subImageLayerIndex)
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

        mergedSubLayers = image
    }
}
