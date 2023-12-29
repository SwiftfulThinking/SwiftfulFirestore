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
    
    func streamDocument(id: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<T, Error>
    func streamAllDocuments(onListenerConfigured: @escaping (ListenerRegistration) -> Void) -> AsyncThrowingStream<[T], Error>
        
    func deleteDocument(id: String) async throws
    func deleteDocuments(ids: [String]) async throws
    func deleteAllDocuments() async throws
}

public struct DatabaseHelper {
    
    private let provider: any DatabaseHelperProtocol
    
    public init(provider: any DatabaseHelperProtocol) {
        self.provider = provider
    }
    
    public init<T:Codable & IdentifiableByString>(config: DatabaseConfiguration<T>) {
        
        switch config {
        case .mock(let startingData, _):
            self.provider = MockDatabaseHelper(startingData: startingData ?? [])
        case .firebase(let collection, let type):
            self.provider = FirebaseDatabaseHelper(collection: collection, type: type)
        }
    }
    
}


public enum DatabaseConfiguration<T: Codable & IdentifiableByString> {
    case mock(startingData: [T]?, type: T.Type), firebase(collection: String, type: T.Type)
}
