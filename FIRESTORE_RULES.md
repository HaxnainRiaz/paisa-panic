# Firestore Security Rules (example)

Use these rules as a starting point to ensure that only authenticated users can access their own data (including categories).

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Allow users to read/write their own user document
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;

      // Categories collection stored under users/{userId}/categories/{categoryId}
      match /categories/{categoryId} {
        // Only authenticated user can read/write their categories
        allow read, write: if request.auth != null && request.auth.uid == userId;

        // Optional: enforce fields and types
        allow create: if request.auth != null
                       && request.auth.uid == userId
                       && request.resource.data.keys().hasOnly(['id','name','type','icon','isCustom'])
                       && request.resource.data.name is string
                       && (request.resource.data.type == 'income' || request.resource.data.type == 'expense')
                       && request.resource.data.isCustom is bool;

        allow update: if request.auth != null && request.auth.uid == userId;
        allow delete: if request.auth != null && request.auth.uid == userId;
      }

      // Transactions and other per-user collections
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Default: deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Notes:

- Deploy rules via Firebase Console or `firebase deploy --only firestore:rules`.

- Adjust the validation checks to fit your app's fields and constraints.
