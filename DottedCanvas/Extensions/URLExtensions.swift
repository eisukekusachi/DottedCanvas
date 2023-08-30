//
//  URLExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation

extension URL {
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
