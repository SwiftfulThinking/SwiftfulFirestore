# SwiftfulFirestore

Convenience functions for using Firebase Firestore with Swift Concurrency. Most functions are extensions on `CollectionReference`.

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>

Add SwiftfulFirestore to your project.

```
https://github.com/SwiftfulThinking/SwiftfulFirestore.git
```

Import the package.

```swift
import SwiftfulFirestore
```

Optionally conform your models to `StringIdentifiable` (from [IdentifiableByString](https://github.com/SwiftfulThinking/IdentifiableByString)):

```swift
struct Movie: Codable, StringIdentifiable {
    let id = UUID().uuidString
    let title: String
}
```

</details>

## Create or Overwrite Document

```swift
// With StringIdentifiable — uses document.id automatically
try await collection.setDocument(document: movie)

// With explicit ID
try await collection.setDocument(id: movie.id, document: movie)

// With raw dictionary
try await collection.setDocument(id: movie.id, dict: ["title": "Inception"])
```

All `setDocument` methods use `merge: true`.

## Update Existing Document

```swift
try await collection.updateDocument(id: movie.id, document: movie)
try await collection.updateDocument(id: movie.id, dict: ["title": "Updated Title"])
```

## Get Documents

```swift
// Single document
let movie: Movie = try await collection.getDocument(id: movieId)

// Multiple documents by ID (fetched in parallel, returned in order)
let movies: [Movie] = try await collection.getDocuments(ids: [id1, id2, id3])

// All documents in collection (requires StringIdentifiable)
let allMovies: [Movie] = try await collection.getAllDocuments()
```

## Stream Documents

Stream real-time updates via `AsyncThrowingStream`:

```swift
// Stream a single document
let stream: AsyncThrowingStream<Movie, Error> = collection.streamDocument(id: movieId)

for try await movie in stream {
    // Document updated
}

// Stream all documents in collection
let stream: AsyncThrowingStream<[Movie], Error> = collection.streamAllDocuments()

for try await movies in stream {
    // Collection updated
}

// Stream individual document changes (added, modified, removed)
let stream: AsyncThrowingStream<DocumentChange<Movie>, Error> = collection.streamAllDocumentChanges()

for try await change in stream {
    switch change.type {
    case .added:    // document added
    case .modified: // document modified
    case .removed:  // document removed
    }
    let movie = change.document
}
```

## Delete Documents

```swift
// Single document
try await collection.deleteDocument(id: movieId)

// Multiple documents
try await collection.deleteDocuments(ids: [id1, id2, id3])

// All documents in collection
try await collection.deleteAllDocuments()
```

## Utilities

Convert any `Encodable` to a JSON dictionary:

```swift
let dict = try movie.asJsonDictionary()  // [String: Any]
```

## Claude Code

This package includes a `.claude/swiftful-firestore-rules.md` with usage guidelines and integration advice for projects using [Claude Code](https://claude.ai/claude-code).

## Platform Support

- **iOS 15.0+**
- **macOS 10.15+**

## License

SwiftfulFirestore is available under the MIT license.
