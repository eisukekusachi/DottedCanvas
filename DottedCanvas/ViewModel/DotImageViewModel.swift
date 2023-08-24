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
    func updateSelectedSubImageData(_ data: SubImageData)

    func insertSubImageData(_ data: SubImageData, at index: Int) -> Bool
    func removeSubImageData(_ index: Int) -> Bool
}

class DotImageViewModel: ObservableObject, DotImageViewModelProtocol {

    @Published var mainImage: UIImage?
    @Published var subImageDataArray: [SubImageData]

    @Published var selectedSubImageData: SubImageData?
    @Published var selectedSubImageAlpha: Int = 0

    private var cancellables: Set<AnyCancellable> = []

    var storedCreationData = DotImageCreationData()

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
            selectedSubImageAlpha = data.alpha
        }

        commonInit()
    }
    private func commonInit() {
        $selectedSubImageAlpha
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateMainImage()
            })
            .store(in: &cancellables)
    }

    func updateMainImage() {
        mainImage = flatteningSubImages
    }
    func updateSelectedSubImageData(_ data: SubImageData) {
        selectedSubImageData = data
        selectedSubImageAlpha = data.alpha
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

            if selectedSubImageData?.id == id {
                selectedSubImageAlpha = alpha
            }
        }

        if selectedSubImageData?.id == id {
            selectedSubImageData = subImageDataArray[index]
        }
    }

    func appendSubImageData(_ data: SubImageData) {
        subImageDataArray.append(data)
        updateSelectedSubImageData(data)
    }

    @discardableResult
    func insertSubImageData(_ data: SubImageData, at index: Int) -> Bool {
        guard   index >= 0 &&
                index <= subImageDataArray.count
        else {
            return false
        }

        subImageDataArray.insert(data, at: index)
        updateSelectedSubImageData(data)

        return true
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
            selectedSubImageData = subImageDataArray[index]
        }

        return true
    }
}

extension DotImageViewModel {
    private func getIndex(from id: UUID) -> Int? {
        for (index, elem) in subImageDataArray.enumerated() where elem.id == id {
            return index
        }
        return nil
    }
}
