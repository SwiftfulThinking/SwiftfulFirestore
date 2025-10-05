//
//  DocumentChange.swift
//  SwiftfulFirestore
//
//  Created by Nick Sarno on 2025-10-04.
//

import Foundation
import FirebaseFirestore

/// Represents a document change with the changed document
public struct DocumentChange<T: Codable & Sendable>: Sendable {
    public let type: ChangeType
    public let document: T

    public init(type: ChangeType, document: T) {
        self.type = type
        self.document = document
    }
}

/// Type of document change
public enum ChangeType: Sendable {
    case added    // Document was added (includes initial load)
    case modified // Document was updated
    case removed  // Document was deleted
}

extension FirebaseFirestore.DocumentChangeType {
    func toChangeType() -> ChangeType {
        switch self {
        case .added: return .added
        case .modified: return .modified
        case .removed: return .removed
        }
    }
}
