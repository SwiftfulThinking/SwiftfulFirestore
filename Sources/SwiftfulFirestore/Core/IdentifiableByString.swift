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
