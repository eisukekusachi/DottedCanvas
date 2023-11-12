//
//  Input.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/28.
//

import Foundation
import ZipArchive

enum InputError: Error {
    case failedToUnzipFile
    case failedToLoadJson
}

enum Input {
    static func unzipFile(from zipFileURL: URL, to dstFolderURL: URL) throws {
        if !SSZipArchive.unzipFile(atPath: zipFileURL.path, toDestination: dstFolderURL.path) {
            throw InputError.failedToUnzipFile
        }
    }
    static func loadJson<T: Decodable>(url: URL) -> T? {
        guard let stringJson: String = try? String(contentsOf: url, encoding: .utf8),
              let dataJson: Data = stringJson.data(using: .utf8)
        else { return nil }

        return try? JSONDecoder().decode(T.self, from: dataJson)
    }
}
