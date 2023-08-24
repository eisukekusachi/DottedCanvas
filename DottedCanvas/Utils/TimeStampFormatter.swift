//
//  TimeStampFormatter.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import Foundation

enum TimeStampFormatter {
    static func currentTimestamp(template: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: .current)
        return dateFormatter.string(from: Date())
    }
}
