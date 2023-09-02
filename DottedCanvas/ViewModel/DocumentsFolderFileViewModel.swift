//
//  DocumentsFolderFileViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

class DocumentsFolderFileViewModel: ObservableObject {

    @Published var fileDataArray: [DocumentsFolderFileData]

    convenience init() {
        self.init(dataArray: [])
    }
    init(dataArray: [DocumentsFolderFileData]) {
        fileDataArray = dataArray
    }

    func appendDocumentsFolderFile() async throws {
        let folderURL = URL.documents.appendingPathComponent("unzipFolder")
        defer {
            try? removeExistingFolder(at: folderURL)
        }
        try createFolder(at: folderURL)

        await withThrowingTaskGroup(of: Void.self) { group in
            for zipURL in URL.documents.allURLs where zipURL.hasSuffix("zip") {
                group.addTask { [weak self] in
                    let unzippedFileURL = folderURL.appendingPathComponent(zipURL.lastPathComponent)
                    defer {
                        try? self?.removeExistingFolder(at: unzippedFileURL)
                    }
                    try self?.createFolder(at: unzippedFileURL)
                    try self?.unzipFile(from: zipURL, to: unzippedFileURL)
                    try self?.appendDocumentsFileData(in: unzippedFileURL)
                }
            }
        }
    }

    func upsert(title: String, imageData: DotImageData?) {
        guard let imageData = imageData else { return }

        var fileExists: Bool = false

        for (index, data) in fileDataArray.enumerated().reversed() where data.title == title {
            updateFileData(index: index, title: title, imageData: imageData)
            fileExists = true
        }

        if !fileExists {
            appendFileData(title: title, imageData: imageData)
        }
    }
}

extension DocumentsFolderFileViewModel {
    private func removeExistingFolder(at url: URL) throws {
        try? FileManager.default.removeItem(at: url)
    }
    private func createFolder(at url: URL) throws {
        try FileManager.createNewDirectory(url: url)
    }

    private func unzipFile(from sourceURL: URL, to destinationURL: URL) throws {
        try Input.unzip(srcZipURL: sourceURL, to: destinationURL)
    }

    private func appendDocumentsFileData(in folderURL: URL) throws {
        let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)
        let thumbnailURL = folderURL.appendingPathComponent(thumbnailName)

        if let data: DotImageCodableData = Input.loadJson(url: jsonFileURL),
           let imageData = try? Data(contentsOf: thumbnailURL),
           let fileName = folderURL.lastPathComponent.components(separatedBy: ".").first {

            let fileData = DocumentsFolderFileData(title: fileName,
                                                   thumbnail: UIImage(data: imageData),
                                                   latestUpdateDate: data.latestUpdateDate)

            DispatchQueue.main.async { [weak self] in
                self?.fileDataArray.append(fileData)
            }
        }
    }

    private func updateFileData(index: Int, title: String, imageData: DotImageData) {
        fileDataArray[index] = DocumentsFolderFileData(
            title: title,
            thumbnail: imageData.mainImage?.resize(to: CGSize(width: 256, height: 256)),
            latestUpdateDate: imageData.latestUpdateDate
        )
    }

    private func appendFileData(title: String, imageData: DotImageData) {
        fileDataArray.append(
            DocumentsFolderFileData(
                title: title,
                thumbnail: imageData.mainImage?.resize(to: CGSize(width: 256, height: 256)),
                latestUpdateDate: imageData.latestUpdateDate
            )
        )
    }
}
