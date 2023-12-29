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
