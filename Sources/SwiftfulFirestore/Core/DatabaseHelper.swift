//
//  File.swift
//  
//
//  Created by Nick Sarno on 12/29/23.
//

import Foundation
import FirebaseFirestore

struct DatabaseHelper<T : Codable & IdentifiableByString> {
    
    let collection: CollectionReference
    let type: T.Type

    init(collection: String, type: T.Type) {
        self.collection = Firestore.firestore().collection(collection)
        self.type = type
    }

}

