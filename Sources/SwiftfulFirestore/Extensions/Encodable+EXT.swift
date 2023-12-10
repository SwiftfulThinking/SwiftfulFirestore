//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation

public extension Encodable {
    func asJsonDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
