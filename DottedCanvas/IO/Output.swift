//
//  Output.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation
import ZipArchive

enum OutputError: Error {
    case invalidData
    case couldNotFindFile
    case failedToCreateImage
    case failedToZip
    case unknownReason(debugInfo: String)
}

enum Output {
    static func createZip(folderURL: URL, zipFileURL: URL) throws {
        let success = SSZipArchive.createZipFile(atPath: zipFileURL.path,
                                                  withContentsOfDirectory: folderURL.path)
        if !success {
            throw OutputError.failedToZip
        }
    }
}
