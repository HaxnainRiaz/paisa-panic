# Setup Instructions for Money Tracker App

## Firebase Configuration

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database

2. **Configure Firebase for Flutter**
   - Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Run: `flutterfire configure`
   - This will generate `lib/firebase_options.dart` with your project credentials

3. **Firestore Security Rules**
   Set up these security rules in Firestore:

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

4. **Authentication Setup**
   - In Firebase Console, go to Authentication
   - Enable "Email/Password" sign-in method
   - No additional configuration needed

## Running the App

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Features Implemented

✅ **Authentication Flow**
- Splash screen with auth state check
- Login/Signup with Firebase Auth
- Forgot password functionality
- Auth guards on protected routes
- Automatic redirect to budget setup for new users

✅ **Navigation System**
- Top AppBar on all screens
- Bottom Navigation Bar (mobile)
- Drawer navigation (web + mobile)
- Responsive navigation based on screen size

✅ **Budget Setup Flow**
- Guided 4-step budget setup
- Period selection (Monthly/Weekly)
- Budget amount input
- Category allocation (optional)
- Review & confirm

✅ **Responsive UI**
- SafeArea on all screens
- SingleChildScrollView for scrollable content
- LayoutBuilder for responsive layouts
- No fixed heights/widths
- Proper overflow handling
- Mobile-first, adaptive for web

✅ **Real Data Integration**
- Firestore for user data
- Per-user transactions
- Per-user budgets
- Per-user categories
- Stream-based real-time updates

✅ **Screens Updated**
- Dashboard (real data, responsive)
- Add Income (Firestore integration)
- Add Expense (Firestore integration)
- Transaction History (needs update)
- Budget Screen (needs update)
- Reports Screen (needs update)
- Profile Screen (needs update)
- Categories Screen (needs update)

## Remaining Tasks

Some screens still need to be updated to use real Firestore data:
- Transaction History Screen
- Budget Screen  
- Reports Screen
- Profile Screen
- Categories Screen

These screens currently have the structure but may need Firestore integration updates.

## Testing

1. **Create a new account** - Should redirect to budget setup
2. **Complete budget setup** - Should then access dashboard
3. **Add transactions** - Should save to Firestore
4. **View dashboard** - Should show real-time data
5. **Test navigation** - Drawer, BottomNav, AppBar should all work
6. **Test responsive** - Try on mobile and web

## Troubleshooting

- **Firebase not initialized**: Make sure you've run `flutterfire configure`
- **Auth errors**: Check Firebase Console > Authentication is enabled
- **Firestore errors**: Check security rules are set correctly
- **Build errors**: Run `flutter clean` then `flutter pub get`

