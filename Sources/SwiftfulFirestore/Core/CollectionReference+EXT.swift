//
//  CollectionReference+EXT.swift
//
//
//  Created by Nick Sarno on 12/9/23.
//

import Foundation
import FirebaseFirestore

public extension CollectionReference {
    
    /// Create or overwrite document. Merge: TRUE
    func setDocument<T:Codable>(id: String, document: T) async throws {
        try self.document(id).setData(from: document, merge: true)
    }
    
    /// Create or overwrite document. Merge: TRUE
    func setDocument<T:Codable & IdentifiableByString>(document: T) async throws {
        try self.document(document.id).setData(from: document, merge: true)
    }
    
    /// Create or overwrite document. Merge: TRUE
    func setDocument(id: String, dict: [String:Any]) async throws {
        try await self.document(id).setData(dict, merge: true)
    }
    
    /// Update existing document.
    // Deprecate?
    func updateDocument<T:Codable>(id: String, document: T) async throws {
        let dict = try document.asJsonDictionary()
        try await self.document(id).updateData(dict)
    }
    
    /// Update existing document.
//    func updateDocument<T:Codable & IdentifiableByString>(document: T) async throws {
//        let dict = try document.asJsonDictionary()
//        try await self.document(document.id).updateData(dict)
//    }
    
    // Deprecate?
    /// Update existing document.
    func updateDocument(id: String, dict: [String:Any]) async throws {
        try await self.document(id).updateData(dict)
    }
    
    /// Get existing document.
    func getDocument<T:Codable>(id: String) async throws -> T {
        try await self.document(id).getDocument(as: T.self)
    }
    
    /// Get existing documents.
    func getDocuments<T:Codable>(ids: [String]) async throws -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            var datas: [(index: Int, model: T)] = []
            datas.reserveCapacity(ids.count)
            
            for (index, id) in ids.enumerated() {
                group.addTask {
                    (index, try await self.document(id).getDocument(as: T.self))
                }
            }
            
            for try await data in group {
                datas.append(data)
            }
            
            // Sort in same order they arrived in
            datas.sort(by: { $0.index < $1.index })
            
            return datas.map({ $0.model })
        }
    }
    
    /// Get existing documents via Query.
    func getDocumentsQuery<T:Codable>(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        let updatedQuery = query(self)
        return try await updatedQuery.getDocuments(as: [T].self)
    }
    
    /// Get all existing documents.
//    func getAllDocuments<T:Codable & IdentifiableByString>() async throws -> [T] {
//        try await self.getDocuments(as: [T].self)
//    }
    
    func getAllDocuments<T:Codable & IdentifiableByString>(whereField field: String, isEqualTo filterValue: String) async throws -> [T] {
        try await self.whereField(field, isEqualTo: filterValue).getAllDocuments()
    }
    
    /// Add listener to document and stream changes to document.
    func streamDocument<T:Codable>(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error> {
        self.document(id).addSnapshotStream(as: T.self, onListenerConfigured: onListenerConfigured)
    }
    
    /// Add listener to collection and stream changes to all documents.
    func streamAllDocuments<T:Codable>(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        self.addSnapshotStream(as: [T].self, onListenerConfigured: onListenerConfigured)
    }
        
    /// Delete document.
    func deleteDocument(id: String) async throws {
        try await self.document(id).delete()
    }
    
    /// Delete array of documents.
    func deleteDocuments(ids: [String]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            ids.forEach { id in
                group.addTask {
                    try await self.document(id).delete()
                }
            }
            try await group.waitForAll()
        }
    }
    
    /// Delete all documents.
    func deleteAllDocuments() async throws {
        let snapshot = try await self.getDocuments()
        
        return try await withThrowingTaskGroup(of: Void.self) { group in
            snapshot.documents.forEach { document in
                group.addTask {
                    try await self.document(document.documentID).delete()
                }
            }
            try await group.waitForAll()
        }
    }

}
