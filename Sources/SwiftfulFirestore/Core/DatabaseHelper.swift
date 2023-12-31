//
//  DatabaseHelper.swift
//
//
//  Created by Nick Sarno on 12/29/23.
//

import Foundation
import FirebaseFirestore

public protocol DatabaseHelperProtocol {
    associatedtype T = (Codable & IdentifiableByString)
    func setDocument(id: String, document: T) async throws
    func setDocument(document: T) async throws
    
    func getDocument(id: String) async throws -> T
    func getDocuments(ids: [String]) async throws -> [T]
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T]
    func getAllDocuments() async throws -> [T]
    
    func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error>
    func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error>
        
    func deleteDocument(id: String) async throws
    func deleteDocuments(ids: [String]) async throws
    func deleteAllDocuments() async throws
}

struct AnyDatabaseHelper<T:Codable & IdentifiableByString>: DatabaseHelperProtocol {
    private let _setDocument: (String, T) async throws -> Void
    private let _setDocument2: (T) async throws -> Void
    
    private let _getDocument: (String) async throws -> T
    private let _getDocuments: ([String]) async throws -> [T]
    private let _getDocumentsQuery: (@escaping (CollectionReference) -> Query) async throws -> [T]
    private let _getAllDocuments: () async throws -> [T]
    
    private let _streamDocument: (String, @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error>
    private let _streamDocuments: (@escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error>
    
    private let _deleteDocument: (String) async throws -> Void
    private let _deleteDocuments: ([String]) async throws -> Void
    private let _deleteAllDocuments: () async throws -> Void

    init<U:DatabaseHelperProtocol>(_ helper: U) where U.T == T {
        self._setDocument = helper.setDocument
        self._setDocument2 = helper.setDocument
        
        self._getDocument = helper.getDocument
        self._getDocuments = helper.getDocuments
        self._getDocumentsQuery = helper.getDocumentsQuery
        self._getAllDocuments = helper.getAllDocuments
        
        self._streamDocument = helper.streamDocument
        self._streamDocuments = helper.streamAllDocuments
        
        self._deleteDocument = helper.deleteDocument
        self._deleteDocuments = helper.deleteDocuments
        self._deleteAllDocuments = helper.deleteAllDocuments
    }
    
    func setDocument(id: String, document: T) async throws {
        try await _setDocument(id, document)
    }
    
    func setDocument(document: T) async throws {
        try await _setDocument2(document)
    }
    
    func getDocument(id: String) async throws -> T {
        try await _getDocument(id)
    }
    
    func getDocuments(ids: [String]) async throws -> [T] {
        try await _getDocuments(ids)
    }
        
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        try await _getDocumentsQuery(query)
    }
    
    func getAllDocuments() async throws -> [T] {
        try await _getAllDocuments()
    }

    func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error> {
        _streamDocument(id, onListenerConfigured)
    }
    
    func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        _streamDocuments(onListenerConfigured)
    }
    
    func deleteDocument(id: String) async throws {
        try await _deleteDocument(id)
    }
    
    func deleteDocuments(ids: [String]) async throws {
        try await _deleteDocuments(ids)
    }
    
    func deleteAllDocuments() async throws {
        try await _deleteAllDocuments()
    }

}


public enum DatabaseConfiguration<T: Codable & IdentifiableByString> {
    case mock(mock: MockDatabase<T>?, type: T.Type), firebase(collection: String, type: T.Type)
}

public struct DatabaseHelper<T:Codable & IdentifiableByString>: DatabaseHelperProtocol {
    private let provider: AnyDatabaseHelper<T>
    
    public init(config: DatabaseConfiguration<T>) {
        
        switch config {
        case .mock(let data, _):
            self.provider = AnyDatabaseHelper(MockDatabaseHelper(database: data ?? MockDatabase(data: [])))
        case .firebase(let collection, let type):
            self.provider = AnyDatabaseHelper(FirebaseDatabaseHelper(collection: collection, type: type))
        }
    }
    
    public func setDocument(id: String, document: T) async throws {
        try await provider.setDocument(id: id, document: document)
    }
    
    public func setDocument(document: T) async throws {
        try await provider.setDocument(document: document)
    }
    
    public func getDocument(id: String) async throws -> T {
        try await provider.getDocument(id: id)
    }
    
    public func getDocuments(ids: [String]) async throws -> [T] {
        try await provider.getDocuments(ids: ids)
    }
    
    public func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) async throws -> [T] {
        try await provider.getDocumentsQuery(query: query)
    }
    
    public func getAllDocuments() async throws -> [T] {
        try await provider.getAllDocuments()
    }
    
    public func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error> {
        provider.streamDocument(id: id, onListenerConfigured: onListenerConfigured)
    }
    
    public func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error> {
        provider.streamAllDocuments(onListenerConfigured: onListenerConfigured)
    }
    
    public func deleteDocument(id: String) async throws {
        try await provider.deleteDocument(id: id)
    }
    
    public func deleteDocuments(ids: [String]) async throws {
        try await provider.deleteDocuments(ids: ids)
    }
    
    public func deleteAllDocuments() async throws {
        try await provider.deleteAllDocuments()
    }

}
