# 🔥 Firebase Setup Guide for WhatsApp MicroLearning Bot

## 🚨 URGENT: Firebase Configuration Required

Your app is currently using **placeholder Firebase configuration** which is causing the "internal error" when creating accounts.

## 📋 Step-by-Step Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `whatsup-microlearning-bot` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Click "Create project"

### 2. Enable Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable these providers:
   - ✅ **Email/Password** (for manual signup)
   - ✅ **Google** (for Google Sign-In)

### 3. Configure Web App
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to "Your apps" section
3. Click **Web** icon (`</>`)
4. Enter app nickname: `whatsup-microlearning-web`
5. ✅ Check "Also set up Firebase Hosting"
6. Click "Register app"
7. **Copy the Firebase config object** (you'll need this!)

### 4. Update Firebase Configuration

#### A. Update `lib/firebase_options.dart`
Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',           // From Firebase config
  appId: 'YOUR_ACTUAL_APP_ID',             // From Firebase config  
  messagingSenderId: 'YOUR_SENDER_ID',     // From Firebase config
  projectId: 'your-actual-project-id',     // Your Firebase project ID
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
);
```

#### B. Update `web/index.html`
Replace lines 98-103 with your actual config:

```html
window.firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "your-project.firebaseapp.com", 
  projectId: "your-actual-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_ACTUAL_APP_ID"
};
```

### 5. Configure Google Sign-In

#### A. Get Google Client ID
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Google** provider
3. Copy the **Web client ID**

#### B. Update `web/index.html`
Replace line 25:
```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
```

#### C. Update Environment Config
In `lib/core/config/environment_config.dart`, set:
```dart
static const String googleWebClientId = 'YOUR_ACTUAL_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
```

### 6. Configure Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to your users)
5. Click "Done"

### 7. Test the Setup
1. Run: `flutter clean && flutter pub get`
2. Run: `flutter run -d chrome` (for web testing)
3. Try creating an account with email/password
4. Try Google Sign-In

## 🔧 Quick Fix for Testing (Temporary)

If you want to test immediately without setting up Firebase:

1. **Disable Firebase temporarily** in `lib/main.dart`:
```dart
// Comment out Firebase initialization
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

2. **Use local storage only** for testing UI/UX

## 🆘 Common Issues

### "Internal Error" on Signup
- ❌ **Cause**: Invalid Firebase configuration
- ✅ **Fix**: Update `firebase_options.dart` with real values

### "Google Sign-In not available"  
- ❌ **Cause**: Missing Google Client ID or wrong platform
- ✅ **Fix**: Add proper Google Client ID in `web/index.html`

### "Network Error"
- ❌ **Cause**: Firebase project not accessible
- ✅ **Fix**: Check project ID and API key

## 📞 Need Help?

1. Check Firebase Console for any error messages
2. Look at browser developer console for detailed errors
3. Verify all configuration values are correct
4. Ensure Firebase project has Authentication and Firestore enabled

---

**⚠️ Security Note**: Never commit real Firebase API keys to public repositories. Use environment variables for production.
