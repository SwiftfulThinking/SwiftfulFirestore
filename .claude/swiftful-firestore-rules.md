# SwiftfulFirestore

Convenience extensions on Firebase Firestore's `CollectionReference` and `Query` for Swift Concurrency. iOS 15+, macOS 10.15+.

IMPORTANT: This package is meant to be used alongside Firebase's Firestore SDK, not as a total replacement. It provides convenience wrappers for common CRUD and streaming operations. Query methods like `whereField`, `order(by:)`, `limit(to:)`, etc. are NOT overwritten — use the native Firestore query API for those, then call SwiftfulFirestore's convenience methods (like `getAllDocuments()`) on the resulting query.

## When to use SwiftfulFirestore

These methods are designed for models that conform to `Codable & StringIdentifiable`. The preference should always be to conform data models to these protocols (if possible without changing the model). In practice, basically every data model in the project should already conform to them.

**Decision flow:**
1. Check if the model conforms to `Codable & StringIdentifiable` (or can be made to)
2. If yes → use SwiftfulFirestore convenience methods for CRUD and streaming
3. If no and it can be added without changing the model's shape → add conformance and use SwiftfulFirestore
4. If no and conformance would require changing the model → use the native Firebase Firestore APIs directly
5. For query filtering/ordering → always use native Firestore query methods (`whereField`, `order`, `limit`, etc.)

## API

### CollectionReference Extensions

All methods are `public extension CollectionReference`.

#### Create / Overwrite (merge: true)

```swift
// With StringIdentifiable — uses document.id automatically
try await collection.setDocument(document: model)

// With explicit ID
try await collection.setDocument(id: "doc_id", document: model)

// With raw dictionary
try await collection.setDocument(id: "doc_id", dict: ["key": "value"])
```

All `setDocument` methods use `merge: true` — they create the document if it doesn't exist, or merge fields into the existing document.

#### Update Existing Document

```swift
try await collection.updateDocument(id: "doc_id", document: model)
try await collection.updateDocument(id: "doc_id", dict: ["key": "value"])
```

Unlike `setDocument`, `updateDocument` will fail if the document doesn't exist.

#### Get Documents

```swift
// Single document
let item: MyModel = try await collection.getDocument(id: "doc_id")

// Multiple documents by ID (fetched in parallel, returned in order)
let items: [MyModel] = try await collection.getDocuments(ids: ["id1", "id2", "id3"])

// All documents in collection (requires Codable & StringIdentifiable)
let items: [MyModel] = try await collection.getAllDocuments()
```

#### Stream Documents (real-time listeners)

All stream methods return `AsyncThrowingStream`. The listener is automatically removed when the stream is cancelled.

```swift
// Stream a single document
let stream: AsyncThrowingStream<MyModel, Error> = collection.streamDocument(id: "doc_id")
for try await item in stream {
    // Document updated in real-time
}

// Stream all documents in collection
let stream: AsyncThrowingStream<[MyModel], Error> = collection.streamAllDocuments()
for try await items in stream {
    // Full collection snapshot on each change
}

// Stream individual document changes (more efficient for large collections)
let stream: AsyncThrowingStream<DocumentChange<MyModel>, Error> = collection.streamAllDocumentChanges()
for try await change in stream {
    switch change.type {
    case .added:    // document added (includes initial load)
    case .modified: // document updated
    case .removed:  // document deleted
    }
    let document = change.document
}
```

#### Delete Documents

```swift
try await collection.deleteDocument(id: "doc_id")
try await collection.deleteDocuments(ids: ["id1", "id2", "id3"])
try await collection.deleteAllDocuments()
```

### Query Extensions

```swift
// Get all documents matching a query (requires Codable & StringIdentifiable)
let items: [MyModel] = try await query.getAllDocuments()
```

Queries also support the same streaming methods as collections via internal extensions.

### DocumentChange

```swift
public struct DocumentChange<T: Codable & Sendable>: Sendable {
    public let type: ChangeType
    public let document: T
}

public enum ChangeType: Sendable {
    case added     // Document was added (includes initial load)
    case modified  // Document was updated
    case removed   // Document was deleted
}
```

### Encodable Extension

```swift
// Convert any Encodable to a JSON dictionary
let dict: [String: Any] = try model.asJsonDictionary()
```

## Usage Patterns

### Defining a collection reference

```swift
import FirebaseFirestore

let usersCollection = Firestore.firestore().collection("users")
```

### CRUD operations on a user model

```swift
struct UserModel: Codable, StringIdentifiable {
    var id: String { userId }
    let userId: String
    let email: String?
    let displayName: String?
}

// Create or update
try await usersCollection.setDocument(document: user)

// Read
let user: UserModel = try await usersCollection.getDocument(id: userId)

// Update specific fields
try await usersCollection.updateDocument(id: userId, dict: [
    "display_name": "New Name"
])

// Delete
try await usersCollection.deleteDocument(id: userId)
```

### Real-time sync with a Task

```swift
var listener: Task<Void, Error>?

func startListening(userId: String) {
    listener = Task {
        let stream: AsyncThrowingStream<UserModel, Error> = usersCollection.streamDocument(id: userId)
        for try await user in stream {
            self.currentUser = user
        }
    }
}

func stopListening() {
    listener?.cancel()
}
```

### Querying with filters

Use native Firestore query methods, then call SwiftfulFirestore's `getAllDocuments()`:

```swift
let premiumUsers: [UserModel] = try await usersCollection
    .whereField("is_premium", isEqualTo: true)
    .getAllDocuments()
```
