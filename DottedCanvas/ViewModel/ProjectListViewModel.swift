//
//  ProjectFileListViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

class ProjectListViewModel: ObservableObject {

    @Published var projects: [ProjectDataInList]

    let input: InputProtocol
    let output: OutputProtocol

    convenience init() {
        self.init(projects: [], input: Input(), output: Output())
    }
    init(projects: [ProjectDataInList], input: InputProtocol, output: OutputProtocol) {
        self.projects = projects
        self.input = input
        self.output = output
    }

    func loadListProjectData(zipFileURL: URL, tmpFolderURL: URL) async throws -> ProjectDataInList {
        return try loadProjectData(zipFileURL: zipFileURL, tmpFolderURL: tmpFolderURL) { (data, folderURL) in
            return ProjectDataInList(
                projectName: zipFileURL.fileName!,
                folderURL: folderURL,
                latestUpdateDate: data.latestUpdateDate
            )
        }
    }
    func loadProjectData(zipFileURL: URL, tmpFolderURL: URL) throws -> ProjectData {
        return try loadProjectData(zipFileURL: zipFileURL, tmpFolderURL: tmpFolderURL) { (data, folderURL) in
            return ProjectData(codableData: data,
                               folderURL: folderURL)
        }
    }

    func upsertProjectDataInList(_ newProjectData: ProjectData?, projectName: String) {
        guard let newProjectData = newProjectData else { return }

        // Find an existing project by name or create a new one
        if let existingIndex = projects.enumerated().reversed().first(where: { $0.element.projectName == projectName })?.offset {
            let project = ProjectDataInList(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)
            projects[existingIndex] = project

        } else {
            let project = ProjectDataInList(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)
            projects.append(project)
        }
    }

    func saveProject(projectData: ProjectData, tmpFolderURL: URL, zipFileURL: URL) throws {

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(atPath: tmpFolderURL.path)
        }

        try FileManager.createNewDirectory(url: tmpFolderURL)
        try write(projectData: projectData, to: tmpFolderURL)
        try output.zip(folderURL: tmpFolderURL, zipFileURL: zipFileURL)
    }

    private func loadProjectData<T>(zipFileURL: URL, tmpFolderURL: URL, projectDataBuilder: (ProjectCodableData, URL) -> T?) throws -> T {

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(at: tmpFolderURL)
        }

        // Unzip the contents of the ZIP file
        try FileManager.createNewDirectory(url: tmpFolderURL)
        try input.unzip(srcZipURL: zipFileURL, to: tmpFolderURL)

        if let data: ProjectCodableData = input.loadJson(url: tmpFolderURL.appendingPathComponent(jsonFileName)) {
            if let projectData = projectDataBuilder(data, tmpFolderURL) {
                return projectData
            }
        }

        throw InputError.failedToLoadJson
    }

    private func write(projectData: ProjectData, to folder: URL) throws {

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
                to: folder.appendingPathComponent(jsonFileName),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            throw error
        }

        do {
            // Write mainImage thumbnail
            let imageURL = folder.appendingPathComponent(thumbnailName)
            try projectData.mainImageThumbnail?.pngData()?.write(to: imageURL)
        } catch {
            throw error
        }

        // Write subImage
        for i in 0..<projectData.subImageLayers.count {
            do {
                let imageURL = folder.appendingPathComponent(projectData.subImageLayers[i].imagePath)
                try projectData.subImageLayers[i].image?.pngData()?.write(to: imageURL)
            } catch {
                throw error
            }
        }
    }
}
