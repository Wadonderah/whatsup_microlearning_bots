# WhatsApp MicroLearning Bot - Setup Guide

This guide will help you fix the common issues and properly configure your Flutter application.

## 🚨 Current Issues Fixed

### 1. Asset Loading Issues (404 Errors)
**Problem**: Flutter can't find image assets
**Status**: ✅ FIXED

**What was done**:
- Created `AssetManager` utility class for safe asset loading
- Added fallback widgets for missing assets
- Updated splash screen to use safe asset loading
- Fixed asset paths in code

**Next Steps**:
1. Add actual image files to `assets/images/` directories
2. Replace placeholder assets with real images

### 2. Google Sign-In Configuration
**Problem**: Missing Google OAuth client configuration
**Status**: ⚠️ NEEDS CONFIGURATION

**What was done**:
- Added Google Sign-In meta tag to `web/index.html`
- Added Firebase scripts

**Required Action**:
```html
<!-- In web/index.html, replace YOUR_GOOGLE_CLIENT_ID with actual client ID -->
<meta name="google-signin-client_id" content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
```

**How to get Google Client ID**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to APIs & Services → Credentials
4. Find your OAuth 2.0 Client ID for Web application
5. Copy the Client ID

### 3. Firebase Configuration
**Problem**: Firebase not properly initialized
**Status**: ✅ PARTIALLY FIXED

**What was done**:
- Updated `main.dart` with proper Firebase initialization
- Added Firebase initialization checks in AuthService
- Updated AuthProvider to handle initialization states
- Added proper error handling in splash screen

**Required Action**:
1. Update `lib/firebase_options.dart` with your actual Firebase config
2. Replace placeholder values with real Firebase project settings

### 4. Pointer Binding Errors
**Problem**: Input field focus issues on web
**Status**: ✅ FIXED

**What was done**:
- Added input focus fix script to `web/index.html`
- Added loading screen with proper styling

## 🔧 Configuration Steps

### Step 1: Firebase Setup

1. **Update Firebase Options**:
   Edit `lib/firebase_options.dart` and replace placeholder values:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'your-actual-api-key',
     appId: '1:123456789:web:your-actual-app-id',
     messagingSenderId: 'your-actual-sender-id',
     projectId: 'your-actual-project-id',
     authDomain: 'your-project.firebaseapp.com',
     storageBucket: 'your-project.appspot.com',
   );
   ```

2. **Get Firebase Config**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings → General
   - Scroll to "Your apps" section
   - Click on your web app
   - Copy the config values

### Step 2: Google Sign-In Setup

1. **Update web/index.html**:
   Replace `YOUR_GOOGLE_CLIENT_ID` with your actual client ID

2. **Enable Google Sign-In in Firebase**:
   - Firebase Console → Authentication → Sign-in method
   - Enable Google provider
   - Add your domain to authorized domains

### Step 3: Asset Setup

1. **Add Missing Images**:
   Create these directories and add images:
   ```
   assets/images/splash/
   ├── brain_animation.gif
   ├── logo_animated.gif
   ├── loading_animation.gif
   └── welcome_animation.gif

   assets/images/onboarding/
   ├── onboarding_1.png
   ├── onboarding_2.png
   ├── onboarding_3.png
   └── onboarding_4.png
   ```

2. **Image Requirements**:
   - Format: GIF for animations, PNG for static
   - Size: Optimized for web (< 500KB each)
   - Dimensions: 200x200px for splash animations

### Step 4: Environment Variables

1. **Create .env file** (if not exists):
   ```env
   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_MESSAGING_SENDER_ID=your-sender-id
   FIREBASE_APP_ID=your-app-id

   # Google Sign-In
   GOOGLE_WEB_CLIENT_ID=your-google-client-id

   # Other configurations...
   ```

## 🧪 Testing

### Test Asset Loading
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Test Firebase Connection
1. Check browser console for Firebase errors
2. Try authentication features
3. Verify Firestore connection

### Test Google Sign-In
1. Click Google Sign-In button
2. Check for "Developer Error" messages
3. Verify successful authentication

## 🔍 Troubleshooting

### Assets Still Not Loading
1. Check file paths match exactly
2. Ensure files exist in correct directories
3. Run `flutter clean && flutter pub get`
4. Check browser network tab for 404 errors

### Firebase Errors
1. Verify all config values are correct
2. Check Firebase project settings
3. Ensure Firebase services are enabled
4. Check browser console for detailed errors

### Google Sign-In Issues
1. Verify client ID is correct
2. Check authorized domains in Google Cloud Console
3. Ensure Google provider is enabled in Firebase Auth
4. Clear browser cache and cookies

## 📱 Production Deployment

### Web Deployment
1. Update `web/index.html` with production Firebase config
2. Ensure all assets are included in build
3. Test on different browsers
4. Verify HTTPS is enabled for authentication

### Mobile Deployment
1. Update `android/app/google-services.json`
2. Update `ios/Runner/GoogleService-Info.plist`
3. Test on physical devices
4. Verify push notifications work

## 🆘 Getting Help

If you encounter issues:
1. Check browser console for errors
2. Review Firebase project settings
3. Verify all configuration files are updated
4. Test with a fresh browser session

## ✅ Verification Checklist

- [ ] Firebase config updated with real values
- [ ] Google Client ID added to web/index.html
- [ ] Asset files added to correct directories
- [ ] .env file configured
- [ ] App runs without 404 errors
- [ ] Firebase authentication works
- [ ] Google Sign-In works
- [ ] No console errors in browser

Once all items are checked, your app should be fully functional!
