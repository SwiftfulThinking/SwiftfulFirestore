//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/29/23.
//

import Foundation
import FirebaseFirestore

actor MockDatabase<T : Codable & IdentifiableByString> {
    
    @Published private(set) var data: [String: T]
    
    init(data: [T]) {
        self._data = Published(wrappedValue: data.asDictionary())
    }
    
    func setDocument(id: String, document: T) async throws {
        data[id] = document
    }
    
    func setDocument(document: T) async throws {
        data[document.id] = document
    }
        
    func getDocument(id: String) async throws -> T {
        guard let item = data[id] else {
            throw URLError(.dataNotAllowed)
        }
        
        return item
    }
    
    func getDocuments(ids: [String]) async throws -> [T] {
        data.filter({ ids.contains($0.key) }).map({ $0.value })
    }
    
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        // NOTE: Query does not work on MOCK data.
        data.map({ $0.value })
    }
        
    func deleteDocument(id: String) async throws {
        data.removeValue(forKey: id)
    }
    
    func deleteDocuments(ids: [String]) async throws {
        for id in ids {
            data.removeValue(forKey: id)
        }
    }
    
    func deleteAllDocuments() async throws {
        data.removeAll()
    }
}

struct MockDatabaseHelper<T : Codable & IdentifiableByString>: DatabaseHelperProtocol {
    
    private let database: MockDatabase<T>

    init(startingData data: [T]) {
        self.database = MockDatabase(data: data)
    }

    /// Create or overwrite document. Merge: TRUE
    func setDocument(id: String, document: T) async throws {
        try await database.setDocument(document: document)
    }
    
    /// Create or overwrite document. Merge: TRUE
    func setDocument(document: T) async throws {
        try await database.setDocument(document: document)
    }
    
    /// Get existing document.
    func getDocument(id: String) async throws -> T {
        try await database.getDocument(id: id)
    }
    
    /// Get existing documents.
    func getDocuments(ids: [String]) async throws -> [T] {
        try await database.getDocuments(ids: ids)
    }
    
    /// Get existing documents via Query.
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        try await database.getDocumentsQuery(query: query)
    }
    
    /// Add listener to document and stream changes to document.
    func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream(T.self) { continuation in
            Task {
                for await value in await database.$data.values {
                    if let item = value[id] {
                        continuation.yield(item)
                    }
                }
            }
        }
    }
    
    /// Add listener to collection and stream changes to all documents.
    func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        AsyncThrowingStream([T].self) { continuation in
            Task {
                for await value in await database.$data.values {
                    continuation.yield(value.map({ $0.value }))
                }
            }
        }
    }
        
    /// Delete document.
    func deleteDocument(id: String) async throws {
        try await database.deleteDocument(id: id)
    }
    
    /// Delete array of documents.
    func deleteDocuments(ids: [String]) async throws {
        try await database.deleteDocuments(ids: ids)
    }
    
    /// Delete all documents.
    func deleteAllDocuments() async throws {
        try await database.deleteAllDocuments()
    }

}

