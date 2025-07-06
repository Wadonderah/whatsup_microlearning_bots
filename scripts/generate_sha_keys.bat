@echo off
echo === Firebase SHA Key Generator ===
echo.

REM Check if keytool is available
keytool -help >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Keytool not found. Please install Java JDK.
    echo Download from: https://www.oracle.com/java/technologies/downloads/
    pause
    exit /b 1
)

echo [OK] Keytool found

REM Define keystore path
set KEYSTORE_PATH=%USERPROFILE%\.android\debug.keystore

echo Looking for debug keystore at: %KEYSTORE_PATH%

REM Check if debug keystore exists
if exist "%KEYSTORE_PATH%" (
    echo [OK] Debug keystore found
    echo.
    echo === Generating SHA Keys ===
    echo.
    
    REM Generate SHA keys and save to temp file
    keytool -list -v -alias androiddebugkey -keystore "%KEYSTORE_PATH%" -storepass android -keypass android > temp_sha_output.txt 2>&1
    
    echo === YOUR SHA KEYS ===
    echo.
    
    REM Extract and display SHA1
    for /f "tokens=2 delims=:" %%a in ('findstr "SHA1:" temp_sha_output.txt') do (
        set SHA1=%%a
        set SHA1=!SHA1: =!
    )
    
    REM Extract and display SHA256
    for /f "tokens=2 delims=:" %%a in ('findstr "SHA256:" temp_sha_output.txt') do (
        set SHA256=%%a
        set SHA256=!SHA256: =!
    )
    
    echo SHA1:   %SHA1%
    echo SHA256: %SHA256%
    echo.
    
    REM Save to file
    echo Firebase SHA Keys for WhatsApp MicroLearning Bot > firebase_sha_keys.txt
    echo Generated: %date% %time% >> firebase_sha_keys.txt
    echo. >> firebase_sha_keys.txt
    echo SHA1:   %SHA1% >> firebase_sha_keys.txt
    echo SHA256: %SHA256% >> firebase_sha_keys.txt
    echo. >> firebase_sha_keys.txt
    echo Instructions: >> firebase_sha_keys.txt
    echo 1. Copy both SHA keys above >> firebase_sha_keys.txt
    echo 2. Go to Firebase Console: https://console.firebase.google.com/ >> firebase_sha_keys.txt
    echo 3. Select your project >> firebase_sha_keys.txt
    echo 4. Go to Project Settings ^> General >> firebase_sha_keys.txt
    echo 5. Find your Android app >> firebase_sha_keys.txt
    echo 6. Click 'Add fingerprint' >> firebase_sha_keys.txt
    echo 7. Add the SHA1 key first, then add the SHA256 key >> firebase_sha_keys.txt
    echo 8. Download the updated google-services.json >> firebase_sha_keys.txt
    echo 9. Replace android/app/google-services.json with the new file >> firebase_sha_keys.txt
    echo. >> firebase_sha_keys.txt
    echo Package Name: com.example.whatsup_microlearning_bots >> firebase_sha_keys.txt
    
    echo [OK] SHA keys saved to: firebase_sha_keys.txt
    echo.
    echo === NEXT STEPS ===
    echo 1. Copy the SHA keys above
    echo 2. Go to Firebase Console
    echo 3. Add both keys to your Android app
    echo 4. Download updated google-services.json
    echo 5. Replace android/app/google-services.json
    
    REM Clean up temp file
    del temp_sha_output.txt
    
) else (
    echo [ERROR] Debug keystore not found
    echo.
    echo The debug keystore will be created when you build the app.
    echo Please run one of these commands first:
    echo.
    echo   flutter build apk --debug
    echo   OR
    echo   flutter run
    echo.
    echo Then run this script again.
    echo.
    echo Manual alternative:
    echo 1. Open Android Studio
    echo 2. Open this project
    echo 3. Build ^> Build Bundle^(s^) / APK^(s^) ^> Build APK^(s^)
    echo 4. Run this script again
)

echo.
echo === Additional Information ===
echo Debug Keystore Location: %KEYSTORE_PATH%
echo Alias: androiddebugkey
echo Store Password: android
echo Key Password: android
echo.
echo For release builds, you'll need to generate a separate keystore.
echo See docs/firebase_sha_setup.md for complete instructions.
echo.

pause
