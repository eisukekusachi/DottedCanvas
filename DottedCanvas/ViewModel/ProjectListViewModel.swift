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

    func loadAllProjectData(allURLs: [URL]) async throws {
        let folderURL = URL.documents.appendingPathComponent("unzipFolder")
        defer {
            try? FileManager.default.removeItem(at: folderURL)
        }
        try FileManager.createNewDirectory(url: folderURL)

        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                for zipURL in allURLs where zipURL.hasSuffix("zip") {
                    group.addTask { [weak self] in
                        let unzippedFileURL = folderURL.appendingPathComponent(zipURL.lastPathComponent)
                        defer {
                            try? FileManager.default.removeItem(at: unzippedFileURL)
                        }
                        try FileManager.createNewDirectory(url: unzippedFileURL)
                        try Input.unzip(srcZipURL: zipURL, to: unzippedFileURL)
                        try self?.appendProjectData(in: unzippedFileURL)
                    }
                }
            }
        }
    }

    func upsertProjectData(_ newProjectData: ProjectData?, projectName: String) {
        guard let newProjectData = newProjectData else { return }

        let result = projects.enumerated().reversed().first(where: { $0.element.projectName == projectName })

        if let result {
            let project = DocumentsProjectData(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)

            projects[result.offset] = project

        } else {
            let project = DocumentsProjectData(
                projectName: projectName,
                thumbnail: newProjectData.mainImageThumbnail,
                latestUpdateDate: newProjectData.latestUpdateDate)

            projects.append(project)
        }
    }

    private func appendProjectData(in folderURL: URL) throws {
        let jsonFileURL = folderURL.appendingPathComponent(jsonFileName)
        let thumbnailURL = folderURL.appendingPathComponent(thumbnailName)

        if let data: MainImageCodableData = Input.loadJson(url: jsonFileURL),
           let imageData = try? Data(contentsOf: thumbnailURL),
           let projectName = folderURL.lastPathComponent.components(separatedBy: ".").first {

            DispatchQueue.main.async { [weak self] in
                let project = DocumentsProjectData(
                    projectName: projectName,
                    thumbnail: UIImage(data: imageData),
                    latestUpdateDate: data.latestUpdateDate)

                self?.projects.append(project)
            }
        }
    }
}
