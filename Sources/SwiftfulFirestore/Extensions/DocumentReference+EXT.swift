//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {
    
    enum DocumentError: Error {
        case noDocumentFound
    }
    
    // Note: similar to Query.addSnapshotStream
    
    func addSnapshotStream<T>(as type: T.Type) -> AsyncThrowingStream<T, Error> where T : Decodable {
        AsyncThrowingStream(T.self) { continuation in
            let listener = self.addSnapshotListener { documentSnapshot, error in
                guard error == nil else {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documentSnapshot else {
                    continuation.finish(throwing: DocumentError.noDocumentFound)
                    return
                }
                
                do {
                    let item = try documentSnapshot.data(as: T.self)
                    continuation.yield(item)
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
