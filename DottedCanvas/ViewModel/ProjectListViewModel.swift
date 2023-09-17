//
//  ProjectFileListViewModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

class ProjectListViewModel: ObservableObject {

    @Published var projects: [DocumentsProjectData]

    convenience init() {
        self.init(projects: [])
    }
    init(projects: [DocumentsProjectData]) {
        self.projects = projects
    }

    func getProjectDataArray(from allURLs: [URL]) async throws -> [DocumentsProjectData] {
        return try await withThrowingTaskGroup(of: DocumentsProjectData?.self) { group in
            var dataArray: [DocumentsProjectData] = []
            let folderURL = URL.documents.appendingPathComponent("unzipFolder")

            // Clean up the temporary folder when done
            defer {
                try? FileManager.default.removeItem(at: folderURL)
            }

            // Add tasks to unzip and load data for each ZIP file
            for zipURL in allURLs where zipURL.hasSuffix("zip") {
                group.addTask { [weak self] in
                    return try await self?.loadProjectData(srcZipURL: zipURL, dstFolderURL: folderURL)
                }
            }

            // Collect the results of the tasks
            for try await data in group {
                if let data {
                    dataArray.append(data)
                }
            }

            return dataArray
        }
    }

    func upsertProjectData(_ newProjectData: ProjectData?, projectName: String) {
        guard let newProjectData = newProjectData else { return }

        // Find an existing project by name or create a new one
        if let existingIndex = projects.enumerated().reversed().first(where: { $0.element.projectName == projectName })?.offset {
            let project = DocumentsProjectData(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)
            projects[existingIndex] = project

        } else {
            let project = DocumentsProjectData(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)
            projects.append(project)
        }
    }

    private func loadProjectData(srcZipURL: URL, dstFolderURL: URL) async throws -> DocumentsProjectData? {
        guard let projectName = srcZipURL.lastPathComponent.components(separatedBy: ".").first else { return nil }

        let tmpFolderURL = dstFolderURL.appendingPathComponent(projectName)

        // Clean up the temporary folder when done
        defer {
            try? FileManager.default.removeItem(at: tmpFolderURL)
        }

        // Unzip the contents of the ZIP file
        try FileManager.createNewDirectory(url: tmpFolderURL)
        try Input.unzip(srcZipURL: srcZipURL, to: tmpFolderURL)

        // Load data from JSON and thumbnail files
        let jsonFileURL = tmpFolderURL.appendingPathComponent(jsonFileName)
        let thumbnailURL = tmpFolderURL.appendingPathComponent(thumbnailName)

        if let data: MainImageCodableData = Input.loadJson(url: jsonFileURL),
           let imageData = try? Data(contentsOf: thumbnailURL) {

            return DocumentsProjectData(
                projectName: projectName,
                thumbnail: UIImage(data: imageData),
                latestUpdateDate: data.latestUpdateDate)
        }
        return nil
    }
}
