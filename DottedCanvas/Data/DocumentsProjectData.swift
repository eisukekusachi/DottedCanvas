//
//  DocumentsProjectData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

struct DocumentsProjectData: Identifiable, Hashable {
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
}
