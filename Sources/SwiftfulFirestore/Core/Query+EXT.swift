//
//  Query+EXT.swift
//  SwiftfulFirestore
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation
import FirebaseFirestore
import IdentifiableByString

public extension Query {
    
    /// Get all existing documents.
    func getAllDocuments<T:Codable & StringIdentifiable>() async throws -> [T] {
        try await self.getDocuments(as: [T].self)
    }
    
}

extension Query {
    
    enum QueryError: Error {
        case noDocumentsFound
    }
    
    func getDocuments<T>(as type: [T].Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ try $0.data(as: T.self) })
    }
    
    
    // Note: similar to DocumentReference.addSnapshotStream

    func addSnapshotStream<T>(as type: [T].Type) -> AsyncThrowingStream<[T], Error> where T : Decodable {
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

    /// Stream individual document changes (added, modified, removed)
    /// More efficient than addSnapshotStream for large collections where you only need to process changes
    func addSnapshotStreamForChanges<T: Codable & Sendable>() -> AsyncThrowingStream<DocumentChange<T>, Error> {
        AsyncThrowingStream { continuation in
            nonisolated(unsafe) let listener = self.addSnapshotListener { querySnapshot, error in
                guard error == nil else {
                    continuation.finish(throwing: error)
                    return
                }

                guard let documentChanges = querySnapshot?.documentChanges else {
                    return
                }

                for change in documentChanges {
                    do {
                        let document = try change.document.data(as: T.self)
                        let documentChange = DocumentChange(
                            type: change.type.toChangeType(),
                            document: document
                        )
                        continuation.yield(documentChange)
                    } catch {
                        // Skip invalid documents
                        continue
                    }
                }
            }

            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
