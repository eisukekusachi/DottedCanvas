//
//  ProjectFileListViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import SwiftUI

class ProjectListViewModel: ObservableObject {

    @Published var projects: [ProjectListModel]

    var isProjectsEmptyBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.projects.isEmpty
            },
            set: { _ in

            }
        )
    }

    convenience init() {
        self.init(projects: [])
    }
    init(projects: [ProjectListModel]) {
        self.projects = projects
    }

    func upsertData(projectName: String, newThumbnail: UIImage?) {
        // If the project data is found in the array, update it. if not found, add it to the array.
        let projectData = ProjectListModel(
            projectName: projectName,
            thumbnail: newThumbnail,
            latestUpdateDate: Date())

        if let existingIndex = projects.enumerated().reversed().first(where: { $0.element.projectName == projectName })?.offset {
            projects[existingIndex] = projectData

        } else {
            projects.append(projectData)
        }
    }

    func loadData(fromZipFileURL zipFileURL: URL) throws -> ProjectListModel {
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
            return ProjectListModel(
                projectName: zipFileURL.fileName!,
                folderURL: uniqueFolderURL,
                latestUpdateDate: data.latestUpdateDate
            )

        } else {
            throw InputError.failedToLoadJson
        }
    }

    func saveData(mainModel: MainModel, zipFileURL: URL) throws {
        let uniqueFolderURL = URL.tmp.appendingPathComponent(UUID().uuidString)

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(atPath: uniqueFolderURL.path)
        }

        try FileManager.createNewDirectory(url: uniqueFolderURL)


        // Create codable data
        let codableData = MainModelCodable(
            subLayerDataCoableArray: mainModel.subLayers.map { SubLayerModelCodable(data: $0) },
            selectedIndex: mainModel.subLayerIndex
        )

        do {
            // Encode codableData to JSON
            let data = try JSONEncoder().encode(codableData)
            let jsonstr = String(data: data, encoding: .utf8)!

            // Write JSON to file
            try jsonstr.write(
                to: uniqueFolderURL.appendingPathComponent(Output.jsonFileName),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            throw error
        }

        do {
            // Write mainImage thumbnail
            let imageURL = uniqueFolderURL.appendingPathComponent(Output.thumbnailName)
            try mainModel.mainImageThumbnail?.pngData()?.write(to: imageURL)
        } catch {
            throw error
        }

        // Write subImage
        for i in 0 ..< mainModel.subLayers.count {
            do {
                let imageURL = uniqueFolderURL.appendingPathComponent(mainModel.subLayers[i].imagePath)
                try mainModel.subLayers[i].image?.pngData()?.write(to: imageURL)
            } catch {
                throw error
            }
        }

        try Output.zipFolder(from: uniqueFolderURL, to: zipFileURL)
    }
}
