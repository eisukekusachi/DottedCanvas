//
//  Output.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation
import ZipArchive

enum OutputError: Error {
    case failedToZip
}

enum Output {

    static let zipSuffix: String = "zip"
    static let jsonFileName: String = "data.dat"
    static let thumbnailName: String = "thumbnail.png"
    static let tmpFolder: String = "tmpFolder"

    static func zipFolder(from srcURL: URL, to zipFileURL: URL) throws {
        let success = SSZipArchive.createZipFile(atPath: zipFileURL.path,
                                                 withContentsOfDirectory: srcURL.path)
        if !success {
            throw OutputError.failedToZip
        }
    }
}
