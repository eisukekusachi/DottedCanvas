//
//  ProjectDataInList.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

struct ProjectDataInList: Identifiable, Hashable {
    var id: UUID = UUID()
    var projectName: String
    var thumbnail: UIImage?
    var latestUpdateDate: Date = Date()

    init(projectName: String,
         thumbnail: UIImage?,
         latestUpdateDate: Date) {

        self.projectName = projectName
        self.thumbnail = thumbnail
        self.latestUpdateDate = latestUpdateDate
    }

    init(projectName: String,
         folderURL: URL,
         latestUpdateDate: Date) {

        self.projectName = projectName
        self.latestUpdateDate = latestUpdateDate

        if let imageData = try? Data(contentsOf: folderURL.appendingPathComponent(thumbnailName)) {
            self.thumbnail = UIImage(data: imageData)
        }
    }
}
