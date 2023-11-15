//
//  ProjectFileListViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

class ProjectListViewModel: ObservableObject {

    @Published var projects: [ProjectListModel]

    convenience init() {
        self.init(projects: [])
    }
    init(projects: [ProjectListModel]) {
        self.projects = projects
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
        if let data: ProjectCodableData = Input.loadJson(url: jsonUrl) {
            return ProjectListModel(
                projectName: zipFileURL.fileName!,
                folderURL: uniqueFolderURL,
                latestUpdateDate: data.latestUpdateDate
            )

        } else {
            throw InputError.failedToLoadJson
        }
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

    private func loadProjectData<T>(zipFileURL: URL, tmpFolderURL: URL, projectDataBuilder: (ProjectCodableData, URL) -> T?) throws -> T {

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(at: tmpFolderURL)
        }

        // Unzip the contents of the ZIP file
        try FileManager.createNewDirectory(url: tmpFolderURL)
        try Input.unzipFile(from: zipFileURL, to: tmpFolderURL)

        if let data: ProjectCodableData = Input.loadJson(url: tmpFolderURL.appendingPathComponent(Output.jsonFileName)) {
            if let projectData = projectDataBuilder(data, tmpFolderURL) {
                return projectData
            }
        }

        throw InputError.failedToLoadJson
    }

    func saveData(projectData: ProjectData, zipFileURL: URL) throws {

        let uniqueFolderURL = URL.tmp.appendingPathComponent(UUID().uuidString)

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(atPath: uniqueFolderURL.path)
        }

        try FileManager.createNewDirectory(url: uniqueFolderURL)


        // Create codable data
        let codableData = ProjectCodableData(
            subImageCodableDataArray: projectData.subImageLayers.map { SubImageCodableData(data: $0) },
            selectedIndex: projectData.subImageLayerIndex
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
            try projectData.mainImageThumbnail?.pngData()?.write(to: imageURL)
        } catch {
            throw error
        }

        // Write subImage
        for i in 0..<projectData.subImageLayers.count {
            do {
                let imageURL = uniqueFolderURL.appendingPathComponent(projectData.subImageLayers[i].imagePath)
                try projectData.subImageLayers[i].image?.pngData()?.write(to: imageURL)
            } catch {
                throw error
            }
        }

        try Output.zipFolder(from: uniqueFolderURL, to: zipFileURL)
    }
}
