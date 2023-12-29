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

public struct DatabaseHelper<T:DatabaseHelperProtocol> {
    
    private let provider: T
    
    public init(provider: T) {
        self.provider = provider
    }
    
}
