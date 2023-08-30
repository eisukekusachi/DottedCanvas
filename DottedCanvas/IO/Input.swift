//
//  Input.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/28.
//

import Foundation

enum Input {
    static func loadJson<T: Decodable>(url: URL) -> T? {
        guard let stringJson: String = try? String(contentsOf: url, encoding: .utf8),
              let dataJson: Data = stringJson.data(using: .utf8)
        else { return nil }

        return try? JSONDecoder().decode(T.self, from: dataJson)
    }
}
