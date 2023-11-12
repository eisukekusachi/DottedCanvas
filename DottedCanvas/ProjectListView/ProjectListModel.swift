//
//  ProjectListModel.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

struct ProjectListModel: Identifiable, Hashable {

    let id: UUID
    let projectName: String
    let thumbnail: UIImage?
    let latestUpdateDate: Date

    init(projectName: String,
         thumbnail: UIImage?,
         latestUpdateDate: Date) {

        self.id = UUID()
        self.projectName = projectName
        self.thumbnail = thumbnail
        self.latestUpdateDate = latestUpdateDate
    }

    init(projectName: String,
         folderURL: URL,
         latestUpdateDate: Date) {

        self.id = UUID()
        self.projectName = projectName

        if let imageData = try? Data(contentsOf: folderURL.appendingPathComponent(ProjectData.thumbnailName)) {
            self.thumbnail = UIImage(data: imageData)
        } else {
            self.thumbnail = nil
        }
        
        self.latestUpdateDate = latestUpdateDate
    }
}
