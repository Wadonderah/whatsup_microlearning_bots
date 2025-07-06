# Firebase SHA Key Setup Guide

This guide will help you generate and configure SHA keys for Firebase authentication, specifically for Google Sign-In to work properly.

## Prerequisites

- Java Development Kit (JDK) installed
- Android Studio or Flutter SDK
- Access to your Firebase project console

## Step 1: Generate Debug SHA Keys

### Method 1: Using Keytool (Recommended)

For **Windows**:
```bash
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```

For **macOS/Linux**:
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```

### Method 2: Using Gradle

Navigate to your project's android directory and run:
```bash
cd android
./gradlew signingReport
```

### Method 3: Using Flutter

```bash
flutter build apk --debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Step 2: Generate Release SHA Keys

### Create Release Keystore (if not exists)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Get SHA from Release Keystore

```bash
keytool -list -v -alias upload -keystore ~/upload-keystore.jks
```

## Step 3: Extract SHA Keys

From the keytool output, look for these lines:

```
Certificate fingerprints:
         SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
         SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**Copy both SHA1 and SHA256 values** - you'll need both for Firebase.

## Step 4: Add SHA Keys to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Select the **General** tab
5. Scroll down to **Your apps** section
6. Click on your Android app
7. Click **Add fingerprint**
8. Add both SHA1 and SHA256 keys:
   - Add the SHA1 key first
   - Click **Add fingerprint** again
   - Add the SHA256 key

## Step 5: Download Updated google-services.json

1. After adding the SHA keys, download the updated `google-services.json`
2. Replace the existing file in `android/app/google-services.json`
3. Make sure the file is in the correct location: `android/app/google-services.json`

## Step 6: Verify Configuration

### Check Package Name

Ensure your package name in Firebase matches your app:
- Firebase Console → Project Settings → General → Your apps
- Should match the `applicationId` in `android/app/build.gradle`

### Default Package Name
```
com.example.whatsup_microlearning_bots
```

## Step 7: Test Google Sign-In

1. Build and run your app
2. Try Google Sign-In functionality
3. Check logs for any authentication errors

## Troubleshooting

### Common Issues

1. **"Developer Error" in Google Sign-In**
   - SHA keys not added to Firebase
   - Wrong package name
   - Outdated google-services.json

2. **"Sign in failed" error**
   - Check SHA keys are correct
   - Verify package name matches
   - Ensure Google Sign-In is enabled in Firebase Auth

3. **Keystore not found**
   - Run a debug build first: `flutter run`
   - Check if Android SDK is properly installed

### Debug Commands

Check if debug keystore exists:
```bash
# Windows
dir %USERPROFILE%\.android\debug.keystore

# macOS/Linux
ls -la ~/.android/debug.keystore
```

## Quick Reference

### Default Debug Keystore Info
- **Location**: `~/.android/debug.keystore` (macOS/Linux) or `%USERPROFILE%\.android\debug.keystore` (Windows)
- **Alias**: `androiddebugkey`
- **Store Password**: `android`
- **Key Password**: `android`

### Firebase Console URLs
- **Project Settings**: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/general`
- **Authentication**: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication`

## Security Notes

- **Never commit release keystores** to version control
- **Keep release keystore passwords secure**
- **Use different keystores for debug and release**
- **Backup your release keystore** - losing it means you can't update your app

## Next Steps

After completing SHA key setup:

1. ✅ Test Google Sign-In in debug mode
2. ✅ Generate release keystore for production
3. ✅ Add release SHA keys to Firebase
4. ✅ Test release build
5. ✅ Configure app signing for Play Store

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Review Android Studio logcat
3. Verify all steps were completed correctly
4. Ensure internet connectivity for authentication
