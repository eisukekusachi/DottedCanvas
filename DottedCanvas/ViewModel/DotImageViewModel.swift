//
//  DotImageViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit
import Combine

protocol DotImageViewModelProtocol {
    var mainImage: UIImage? { get }

    var flatteningSubImages: UIImage? { get }
    var subImageDataArray: [SubImageData] { get }

    func updateMainImage()

    func addSubImageData(_ newData: SubImageData)
    func removeCurrentSubImageData()
}

enum DotImageViewModelError: Error {
    case failedToLoadJson
}

class DotImageViewModel: ObservableObject, DotImageViewModelProtocol {

    @Published var mainImage: UIImage?
    @Published var subImageDataArray: [SubImageData]

    @Published var selectedSubImageData: SubImageData?

    private var cancellables: Set<AnyCancellable> = []

    var fileName: String = Calendar.currentDate

    var latestUpdateDate: Date = Date()

    var dotImageData: DotImageData? {
        DotImageData(mainImage: mainImage?.resize(sideLength: 256, scale: 1),
                     subImageDataArray: subImageDataArray,
                     subImageIndex: getCurrentSubImageIndex() ?? 0,
                     latestUpdateDate: latestUpdateDate)
    }
    var flatteningSubImages: UIImage? {
        var image: UIImage?

        subImageDataArray.forEach { data in
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
        return image
    }
    var subImageDataArrayIndex: Int {
        subImageDataArray.firstIndex(where: { $0 == selectedSubImageData }) ?? 0
    }

    convenience init() {
        self.init(dataArray: [])
    }
    init(dataArray: [SubImageData]) {
        subImageDataArray = dataArray

        if subImageDataArray.count != 0, let data = subImageDataArray.first {
            selectedSubImageData = data
        }

        $selectedSubImageData
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateMainImage()
            })
            .store(in: &cancellables)
    }

    func saveDataAsZipFile(src srcFolder: URL, to zipFileURL: URL) throws {
        try dotImageData?.writeData(to: srcFolder)
        try Output.createZip(folderURL: srcFolder, zipFileURL: zipFileURL)
    }
    func loadData(from folderURL: URL) throws {
        let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)

        if let data: DotImageCodableData = Input.loadJson(url: jsonFileURL) {

            let newSubImageDataArray: [SubImageData] = data.subImages.map {
                SubImageData(codableData: $0, folderURL: folderURL)
            }

            subImageDataArray = newSubImageDataArray
            updateSubImageData(index: data.selectedSubImageIndex)

        } else {
            throw DotImageViewModelError.failedToLoadJson
        }
    }

    func addSubImageData(_ newData: SubImageData) {
        if subImageDataArray.isEmpty {
            appendSubImageData(newData)
        } else {
            insertSubImageData(newData, at: subImageDataArrayIndex + 1)
        }

        selectedSubImageData = newData
        updateMainImage()
    }

    func appendSubImageData(_ data: SubImageData) {
        subImageDataArray.append(data)
        selectedSubImageData = data
    }

    @discardableResult
    func insertSubImageData(_ data: SubImageData, at index: Int) -> Bool {
        guard   index >= 0 &&
                index <= subImageDataArray.count
        else {
            return false
        }

        subImageDataArray.insert(data, at: index)
        selectedSubImageData = data

        return true
    }

    func removeCurrentSubImageData() {
        if removeSubImageData(subImageDataArrayIndex) {
            updateMainImage()
        }
    }

    @discardableResult
    func removeSubImageData(_ index: Int) -> Bool {
        guard   subImageDataArray.count != 0 &&
                index >= 0 &&
                index < subImageDataArray.count
        else {
            return false
        }

        let tmpCurrentData = subImageDataArray[index]

        subImageDataArray.remove(at: index)

        if subImageDataArray.count == 0 {
            selectedSubImageData = nil

        } else if selectedSubImageData == tmpCurrentData {
            let index = min(max(0, index), subImageDataArray.count - 1)
            let data = subImageDataArray[index]
            selectedSubImageData = data
        }

        return true
    }

    func reset() {
        mainImage = nil
        subImageDataArray = []
        selectedSubImageData = nil

        fileName = Calendar.currentDate
        latestUpdateDate = Date()
    }

    func getCurrentSubImageIndex() -> Int? {
        if let selectedSubImageData {
            return getIndex(from: selectedSubImageData.id)
        }
        return nil
    }
    func getIndex(from id: UUID) -> Int? {
        for (index, elem) in subImageDataArray.enumerated() where elem.id == id {
            return index
        }
        return nil
    }

    func updateMainImage() {
        mainImage = flatteningSubImages
        latestUpdateDate = Date()
    }

    func updateSubImageData(index selectedSubImageIndex: Int) {
        if selectedSubImageIndex < subImageDataArray.count {
            let data = subImageDataArray[selectedSubImageIndex]
            selectedSubImageData = data
        }
    }

    func updateSubImageData(id: UUID?, isVisible: Bool? = nil, alpha: Int? = nil) {
        guard let id = id, let index = getIndex(from: id) else {
            return
        }

        if let isVisible = isVisible {
            subImageDataArray[index].isVisible = isVisible
        }

        if let alpha = alpha {
            subImageDataArray[index].alpha = alpha
        }

        if selectedSubImageData?.id == id {
            selectedSubImageData = subImageDataArray[index]
        }
    }
}
