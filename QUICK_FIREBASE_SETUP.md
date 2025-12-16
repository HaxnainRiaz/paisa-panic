# Quick Firebase Setup - Step by Step

## Your Package Name
**Android**: `com.example.paisa_panic` (from `android/app/build.gradle.kts`)

---

## Easiest Method: Use Firebase Console Web UI

### 1. Create Firebase Project
- Go to: https://console.firebase.google.com/
- Click "Add project"
- Name: `paisa-panic`
- Create project

### 2. Add Android App
- Click Android icon in Firebase Console
- Package name: `com.example.paisa_panic` ⬅️ **Use this exact name**
- Download `google-services.json`
- Place in: `android/app/google-services.json`

### 3. Update Android Build Files

**File: `android/build.gradle.kts`** - Add at the top:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**File: `android/app/build.gradle.kts`** - Add:
1. At the top with other plugins:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

2. In dependencies section:
```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

### 4. Get Firebase Config Values

In Firebase Console:
- Go to **Project Settings** (gear icon)
- Scroll to **Your apps** section
- Click on your Android app
- You'll see:
  - **Project ID**: `your-project-id`
  - **App ID**: `1:123456789:android:abc123`
  - **API Key**: `AIza...`
  - **Messaging Sender ID**: `123456789`

### 5. Update `lib/firebase_options.dart`

Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',  // From Firebase Console
  appId: 'YOUR_ACTUAL_APP_ID',     // From Firebase Console
  messagingSenderId: 'YOUR_SENDER_ID', // From Firebase Console
  projectId: 'your-project-id',    // From Firebase Console
  storageBucket: 'your-project-id.appspot.com',
);
```

### 6. Enable Services

**Authentication:**
- Firebase Console > Authentication > Get started
- Sign-in method > Email/Password > Enable

**Firestore:**
- Firebase Console > Firestore Database > Create database
- Start in test mode
- Choose location
- Enable

**Security Rules:**
- Firestore > Rules tab
- Paste this:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```
- Click Publish

### 7. Install Dependencies
```bash
flutter pub get
```

### 8. Test
```bash
flutter run
```

---

## Alternative: Install Firebase CLI First

If you want to use the automatic method:

1. **Install Node.js** (if not installed): https://nodejs.org/
2. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```
3. **Login:**
   ```bash
   firebase login
   ```
4. **Configure:**
   ```bash
   dart pub global run flutterfire_cli:flutterfire configure
   ```

---

## Verification Checklist

After setup, verify:
- [ ] `google-services.json` is in `android/app/`
- [ ] `firebase_options.dart` has real values (not placeholders)
- [ ] Authentication is enabled in Firebase Console
- [ ] Firestore is created and rules are published
- [ ] App runs without Firebase initialization errors
- [ ] You can create an account (test signup)

---

## Common Issues

**"DefaultFirebaseOptions not found"**
- Make sure `firebase_options.dart` exists
- Check it's imported in `main.dart`

**"google-services.json not found"**
- Download from Firebase Console
- Place in `android/app/google-services.json`

**"Authentication failed"**
- Check Email/Password is enabled in Firebase Console
- Verify you're using correct email format

**"Permission denied"**
- Check Firestore security rules are published
- Make sure user is authenticated before accessing data

