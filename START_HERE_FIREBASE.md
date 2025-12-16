# 🚀 Start Here: Connect to Firebase

## Simplest Method (No CLI needed)

### Step 1: Create Firebase Project
1. Visit: https://console.firebase.google.com/
2. Click **"Add project"**
3. Name it: `paisa-panic`
4. Click through the setup (disable Analytics if you want)
5. Click **"Create project"**

### Step 2: Add Android App to Firebase
1. In Firebase Console, click the **Android icon** (📱)
2. **Package name**: `com.example.paisa_panic` ⬅️ **Copy this exactly**
3. App nickname: `Paisa Panic`
4. Click **"Register app"**
5. **Download** `google-services.json`
6. **Move** the file to: `android/app/google-services.json`

### Step 3: Update Android Build Files

**Edit `android/build.gradle.kts`** - Add this at the top:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**Edit `android/app/build.gradle.kts`** - Make these changes:

1. Add plugin at the top (with other plugins):
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← ADD THIS LINE
}
```

2. Add Firebase dependencies (find the `dependencies` section or add it):
```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

### Step 4: Get Your Firebase Config

1. In Firebase Console, click the **⚙️ gear icon** > **Project settings**
2. Scroll down to **"Your apps"** section
3. Click on your **Android app**
4. You'll see these values - **copy them**:
   - **Project ID**: `paisa-panic-xxxxx` (or similar)
   - **App ID**: `1:123456789:android:abc123def456`
   - **API Key**: `AIzaSy...` (long string)
   - **Messaging Sender ID**: `123456789`

### Step 5: Update firebase_options.dart

Open `lib/firebase_options.dart` and replace the Android section with your actual values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'PASTE_YOUR_API_KEY_HERE',           // From Step 4
  appId: 'PASTE_YOUR_APP_ID_HERE',             // From Step 4
  messagingSenderId: 'PASTE_SENDER_ID_HERE',    // From Step 4
  projectId: 'PASTE_PROJECT_ID_HERE',          // From Step 4
  storageBucket: 'PASTE_PROJECT_ID_HERE.appspot.com',  // Use same Project ID
);
```

### Step 6: Enable Firebase Services

**Enable Authentication:**
1. Firebase Console > **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click **"Email/Password"**
5. **Toggle ON** "Enable"
6. Click **"Save"**

**Enable Firestore:**
1. Firebase Console > **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"**
4. Choose a location (pick closest to you)
5. Click **"Enable"**

**Set Security Rules:**
1. In Firestore, go to **"Rules"** tab
2. Replace everything with:
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
3. Click **"Publish"**

### Step 7: Install & Run

```bash
flutter pub get
flutter run
```

---

## ✅ Verification

After running the app:
1. Try to **create an account** - should work!
2. Check Firebase Console > **Authentication** - you should see the new user
3. Complete budget setup - should save to Firestore
4. Check Firebase Console > **Firestore Database** - you should see data

---

## 🆘 Troubleshooting

**"Firebase not initialized"**
- Check `firebase_options.dart` has real values (not "YOUR_...")
- Verify `google-services.json` is in `android/app/`

**"google-services.json not found"**
- Download it from Firebase Console
- Make sure it's in `android/app/` folder

**"Authentication failed"**
- Make sure Email/Password is enabled in Firebase Console

**"Permission denied"**
- Check Firestore security rules are published
- Make sure you're logged in before accessing data

---

## 📝 Files You Need to Edit

1. ✅ `android/build.gradle.kts` - Add classpath
2. ✅ `android/app/build.gradle.kts` - Add plugin & dependencies
3. ✅ `android/app/google-services.json` - Download from Firebase
4. ✅ `lib/firebase_options.dart` - Add your config values

That's it! 🎉

