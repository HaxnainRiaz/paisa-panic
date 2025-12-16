# Firebase Setup Guide for Money Tracker App

## Prerequisites
- Flutter SDK installed
- A Google account
- Node.js installed (for Firebase CLI)

## Method 1: Automatic Setup (Recommended)

### Step 1: Install Firebase CLI

**Option A: Using npm (if you have Node.js)**
```bash
npm install -g firebase-tools
```

**Option B: Using standalone installer (Windows)**
1. Download from: https://github.com/firebase/firebase-tools/releases
2. Or use Chocolatey: `choco install firebase-cli`

**Verify installation:**
```bash
firebase --version
```

### Step 2: Login to Firebase
```bash
firebase login
```
This will open a browser for authentication.

### Step 3: Configure FlutterFire
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

**OR if flutterfire is in PATH:**
```bash
flutterfire configure
```

**What this does:**
- Lists your Firebase projects
- Lets you select/create a project
- Generates `lib/firebase_options.dart` automatically
- Configures all platforms

---

## Method 2: Manual Setup (If CLI doesn't work)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `paisa-panic`
4. Click **Continue**
5. **Disable** Google Analytics (optional)
6. Click **Create project**
7. Wait, then click **Continue**

### Step 2: Add Android App

1. In Firebase Console, click the **Android icon** (or "Add app")
2. Enter package name: Check your `android/app/build.gradle` file for `applicationId`
   - Usually: `com.example.paisa_panic`
3. Enter app nickname: `Paisa Panic Android`
4. Click **Register app**
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

**Update `android/app/build.gradle`:**
```gradle
dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

**Update `android/build.gradle`:**
```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**Update `android/app/build.gradle` (at the bottom):**
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 3: Add iOS App (if needed)

1. Click the **iOS icon**
2. Enter bundle ID: Check `ios/Runner.xcodeproj` or `ios/Runner/Info.plist`
   - Usually: `com.example.paisaPanic`
3. Enter app nickname: `Paisa Panic iOS`
4. Click **Register app**
5. Download `GoogleService-Info.plist`
6. Place it in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Add Web App (if needed)

1. Click the **Web icon** (`</>`)
2. Enter app nickname: `Paisa Panic Web`
3. Click **Register app**
4. **Copy the Firebase configuration** - you'll need this

### Step 5: Manually Create firebase_options.dart

Create/update `lib/firebase_options.dart` with your Firebase config:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.paisaPanic',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.paisaPanic',
  );
}
```

**Where to find these values:**

1. **Project ID**: Firebase Console > Project Settings > General tab
2. **API Keys**: Firebase Console > Project Settings > General tab > Your apps section
3. **App IDs**: Same location as API keys
4. **Messaging Sender ID**: Same location (Cloud Messaging Sender ID)

### Step 6: Enable Firebase Services

#### Enable Authentication:
1. Firebase Console > **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Click **Email/Password**
5. **Enable** it
6. Click **Save**

#### Enable Firestore Database:
1. Firebase Console > **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to you)
5. Click **Enable**

### Step 7: Set Firestore Security Rules

1. Firestore Database > **Rules** tab
2. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
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

3. Click **Publish**

### Step 8: Install Dependencies

```bash
flutter pub get
```

### Step 9: Test the Connection

```bash
flutter run
```

---

## Quick Setup Checklist

- [ ] Firebase project created
- [ ] Android app registered (google-services.json added)
- [ ] iOS app registered (if needed)
- [ ] Web app registered (if needed)
- [ ] `firebase_options.dart` configured
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Security rules set
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs without Firebase errors

---

## Troubleshooting

### "Firebase not initialized"
- Check `firebase_options.dart` has correct values
- Verify `google-services.json` is in `android/app/`
- Make sure `main.dart` calls `Firebase.initializeApp()`

### "Authentication not enabled"
- Firebase Console > Authentication > Sign-in method
- Enable Email/Password

### "Permission denied" in Firestore
- Check security rules are published
- Verify user is authenticated

### "Package name mismatch"
- Check `android/app/build.gradle` for `applicationId`
- Must match Firebase Console Android app package name

---

## Need Help?

1. Check Firebase Console for errors
2. Check Flutter console output
3. Verify all configuration files are in place
4. Make sure you've enabled required services
