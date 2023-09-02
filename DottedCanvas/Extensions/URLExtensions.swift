//
//  URLExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation

extension URL {
    var allURLs: [URL] {
        if FileManager.default.fileExists(atPath: self.path) {
            do {
                let contentUrls = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

                return contentUrls.map {
                    let filePath = $0.lastPathComponent
                    return self.appendingPathComponent(filePath)
                }
            } catch {
                print(error)
            }
        }
        return []
    }
    func hasSuffix(_ suffix: String) -> Bool {
        let nameArray = self.path.components(separatedBy: ".")

        if nameArray.count > 1, let fileSuffix = nameArray.last {
            return fileSuffix == suffix
        }
        return false
    }

    static var documents: URL {
        URL(fileURLWithPath: NSHomeDirectory() + "/Documents")
    }
    static var tmp: URL {
        URL(fileURLWithPath: NSHomeDirectory() + NSHomeDirectory() + "/Documents/tmp")
    }
    static var workInProgress: URL {
        URL(fileURLWithPath: NSHomeDirectory() + NSHomeDirectory() + "/Documents/workinprogress")
    }
}
