//
//  DocumentsFolderFileData.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import UIKit

struct DocumentsFolderFileData: Identifiable {
    var id: UUID = UUID()
    var title: String
    var thumbnail: UIImage?
    var latestUpdateDate: Date = Date()

    init(title: String, thumbnail: UIImage?, latestUpdateDate: Date) {
        self.title = title
        self.thumbnail = thumbnail
        self.latestUpdateDate = latestUpdateDate
    }
}
