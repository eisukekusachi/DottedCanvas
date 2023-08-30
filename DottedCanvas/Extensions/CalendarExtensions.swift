//
//  CalendarExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/26.
//

import Foundation

extension Calendar {
    static var currentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = .current

        return dateFormatter.string(from: Date())
    }
}
