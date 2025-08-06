//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation
import FirebaseFirestore
import IdentifiableByString

public extension Query {
    
    /// Get all existing documents.
    func getAllDocuments<T:Codable & StringIdentifiable & Sendable>() async throws -> [T] {
        try await self.getDocuments(as: [T].self)
    }
    
}

extension Query {
    
    enum QueryError: Error {
        case noDocumentsFound
    }
    
    func getDocuments<T>(as type: [T].Type) async throws -> [T] where T : Decodable & Sendable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ try $0.data(as: T.self) })
    }
    
    
    // Note: similar to DocumentReference.addSnapshotStream

    func addSnapshotStream<T>(as type: [T].Type) -> AsyncThrowingStream<[T], Error> where T : Decodable & Sendable {
        AsyncThrowingStream([T].self) { continuation in
            let listener = self.addSnapshotListener { querySnapshot, error in
                guard error == nil else {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    continuation.finish(throwing: QueryError.noDocumentsFound)
                    return
                }
                
                do {
                    let items = try documents.compactMap({ try $0.data(as: T.self) })
                    continuation.yield(items)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
