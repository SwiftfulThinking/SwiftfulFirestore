# SwiftfulFirestore 🏎️

Convenience functions for using Firebase Firestore with Swift Concurrency.

Most functions are an extension of CollectionReference.

## Usage

Import the package to your project.
* File -> Swift Packages -> Add Package Dependency
* Add URL for this repository: https://github.com/SwiftfulThinking/SwiftfulFirestore.git

#### Import the package to your file.
```swift
import SwiftfulFirestore
```

#### Conform to StringIdentifiable (optional).
```swift
struct Movie: Codable, StringIdentifiable {
    let id = UUID().uuidString
}
```

#### Create or overwrite document.
```swift
try await collection.setDocument(document: movie)
try await collection.setDocument(id: movie.id, document: movie)
```

#### Update existing document.
```swift
try await collection.updateDocument(document: movie)
try await collection.updateDocument(id: movie.id, document: movie)
try await collection.updateDocument(id: movie.id, dict: try movie.asJsonDictionary())
```

#### Get documents.
```swift
try await collection.getDocument(id: movie.id)
try await collection.getDocuments(ids: [movie.id, movie.id])
try await collection.getAllDocuments()
```

#### Stream documents (add listener via AsyncThrowingStream).
```swift
try await collection.streamDocument(id: movie.id) { listener in
     self.listener = listener
}

try await collection.streamAllDocuments { listener in
     self.listener = listener
}
```

#### Delete documents.
```swift
try await collection.deleteDocument(id: movie.id)
try await collection.deleteDocuments(ids: [movie.id, movie.id])
try await collection.deleteAllDocuments()
```
