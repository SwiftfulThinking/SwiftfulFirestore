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
    
    func setDocument(id: String, document: T) {
        data[id] = document
        print("did set 1 :: \(data.count)")
    }
    
    func setDocument(document: T) {
        data[document.id] = document
        print("did set 2 :: \(data.count)")
    }
        
    func getDocument(id: String) throws -> T {
        guard let item = data[id] else {
            throw URLError(.dataNotAllowed)
        }
        
        return item
    }
    
    func getDocuments(ids: [String]) -> [T] {
        data.filter({ ids.contains($0.key) }).map({ $0.value })
    }
    
    func getDocumentsQuery(query: @escaping (CollectionReference) -> Query) -> [T] {
        // NOTE: Query does not work on MOCK data.
        print("GETTING DOCUMENTS: \(data.count)")
        return data.map({ $0.value })
    }
    
    func getAllDocuments() -> [T] {
        data.map({ $0.value })
    }
        
    func deleteDocument(id: String) {
        data.removeValue(forKey: id)
    }
    
    func deleteDocuments(ids: [String]) {
        for id in ids {
            data.removeValue(forKey: id)
        }
    }
    
    func deleteAllDocuments() {
        data.removeAll()
    }
}
