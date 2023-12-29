//
//  IdentifiableByString.swift
//  
//
//  Created by Nick Sarno on 12/9/23.
//

import Foundation

public protocol IdentifiableByString: Identifiable {
    var id: String { get }
}

extension Array where Element: IdentifiableByString {
    func asDictionary() -> [String: Element] {
        var dictionary = [String: Element]()
        for element in self {
            dictionary[element.id] = element
        }
        return dictionary
    }
}
