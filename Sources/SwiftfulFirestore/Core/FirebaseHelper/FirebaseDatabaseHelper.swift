//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/29/23.
//

import Foundation
import FirebaseFirestore

struct FirebaseDatabaseHelper<T : Codable & IdentifiableByString>: DatabaseHelperProtocol {
    
    private let collection: CollectionReference
    private let type: T.Type

    init(collection: String, type: T.Type) {
        self.collection = Firestore.firestore().collection(collection)
        self.type = type
    }

    /// Create or overwrite document. Merge: TRUE
    func setDocument(id: String, document: T) async throws {
        try await collection.setDocument(id: id, document: document)
    }
    
    /// Create or overwrite document. Merge: TRUE
    func setDocument(document: T) async throws {
        try await collection.setDocument(document: document)
    }
    
    /// Create or overwrite document. Merge: TRUE
//    func setDocument(id: String, dict: [String:Any]) async throws {
//        try await collection.setDocument(id: id, dict: dict)
//    }
    
    /// Update existing document.
    // Deprecate?
//    func updateDocument<T:Codable>(id: String, document: T) async throws {
//        let dict = try document.asJsonDictionary()
//        try await self.document(id).updateData(dict)
//    }
    
    /// Update existing document.
//    func updateDocument<T:Codable & IdentifiableByString>(document: T) async throws {
//        let dict = try document.asJsonDictionary()
//        try await self.document(document.id).updateData(dict)
//    }
    
    // Deprecate?
    /// Update existing document.
//    func updateDocument(id: String, dict: [String:Any]) async throws {
//        try await self.document(id).updateData(dict)
//    }
    
    /// Get existing document.
    func getDocument(id: String) async throws -> T {
        try await collection.getDocument(id: id)
    }
    
    /// Get existing documents.
    func getDocuments(ids: [String]) async throws -> [T] {
        try await collection.getDocuments(ids: ids)
    }
    
    /// Get existing documents via Query.
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        try await collection.getDocumentsQuery(query: query)
    }
    
    /// Get all existing documents.
//    func getAllDocuments<T:Codable & IdentifiableByString>() async throws -> [T] {
//        try await self.getDocuments(as: [T].self)
//    }
    
//    func getAllDocuments<T:Codable & IdentifiableByString>(whereField field: String, isEqualTo filterValue: String) async throws -> [T] {
//        try await self.whereField(field, isEqualTo: filterValue).getAllDocuments()
//    }
    
    /// Add listener to document and stream changes to document.
    func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error> {
        collection.streamDocument(id: id, onListenerConfigured: onListenerConfigured)
    }
    
    /// Add listener to collection and stream changes to all documents.
    func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        collection.addSnapshotStream(as: [T].self, onListenerConfigured: onListenerConfigured)
    }
        
    /// Delete document.
    func deleteDocument(id: String) async throws {
        try await collection.deleteDocument(id: id)
    }
    
    /// Delete array of documents.
    func deleteDocuments(ids: [String]) async throws {
        try await collection.deleteDocuments(ids: ids)
    }
    
    /// Delete all documents.
    func deleteAllDocuments() async throws {
        try await collection.deleteAllDocuments()
    }

}

