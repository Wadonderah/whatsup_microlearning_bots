# PowerShell script to generate SHA keys for Firebase
# Run this script to get your SHA-1 and SHA-256 keys

Write-Host "=== Firebase SHA Key Generator ===" -ForegroundColor Green
Write-Host ""

# Check if keytool is available
try {
    $keytoolVersion = keytool -help 2>$null
    Write-Host "✓ Keytool found" -ForegroundColor Green
} catch {
    Write-Host "✗ Keytool not found. Please install Java JDK." -ForegroundColor Red
    Write-Host "Download from: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
    exit 1
}

# Define keystore path
$debugKeystorePath = "$env:USERPROFILE\.android\debug.keystore"

Write-Host "Looking for debug keystore at: $debugKeystorePath" -ForegroundColor Cyan

# Check if debug keystore exists
if (Test-Path $debugKeystorePath) {
    Write-Host "✓ Debug keystore found" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "=== Generating SHA Keys ===" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Generate SHA keys
        $output = keytool -list -v -alias androiddebugkey -keystore $debugKeystorePath -storepass android -keypass android 2>&1
        
        # Extract SHA1 and SHA256
        $sha1 = ($output | Select-String "SHA1:").ToString().Split(":")[1].Trim()
        $sha256 = ($output | Select-String "SHA256:").ToString().Split(":")[1].Trim()
        
        Write-Host "=== YOUR SHA KEYS ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "SHA1:   $sha1" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host "SHA256: $sha256" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host ""
        
        # Save to file
        $outputFile = "firebase_sha_keys.txt"
        @"
Firebase SHA Keys for WhatsApp MicroLearning Bot
Generated: $(Get-Date)

SHA1:   $sha1
SHA256: $sha256

Instructions:
1. Copy both SHA keys above
2. Go to Firebase Console: https://console.firebase.google.com/
3. Select your project
4. Go to Project Settings > General
5. Find your Android app
6. Click 'Add fingerprint'
7. Add the SHA1 key first, then add the SHA256 key
8. Download the updated google-services.json
9. Replace android/app/google-services.json with the new file

Package Name: com.example.whatsup_microlearning_bots
"@ | Out-File -FilePath $outputFile -Encoding UTF8
        
        Write-Host "✓ SHA keys saved to: $outputFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
        Write-Host "1. Copy the SHA keys above" -ForegroundColor White
        Write-Host "2. Go to Firebase Console" -ForegroundColor White
        Write-Host "3. Add both keys to your Android app" -ForegroundColor White
        Write-Host "4. Download updated google-services.json" -ForegroundColor White
        Write-Host "5. Replace android/app/google-services.json" -ForegroundColor White
        
    } catch {
        Write-Host "✗ Error generating SHA keys: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "✗ Debug keystore not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Creating debug keystore..." -ForegroundColor Yellow
    
    # Create .android directory if it doesn't exist
    $androidDir = "$env:USERPROFILE\.android"
    if (!(Test-Path $androidDir)) {
        New-Item -ItemType Directory -Path $androidDir -Force
        Write-Host "✓ Created .android directory" -ForegroundColor Green
    }
    
    # Run a Flutter build to generate the debug keystore
    Write-Host "Running Flutter build to generate debug keystore..." -ForegroundColor Cyan
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    
    try {
        flutter build apk --debug
        Write-Host "✓ Debug build completed" -ForegroundColor Green
        
        # Check again for keystore
        if (Test-Path $debugKeystorePath) {
            Write-Host "✓ Debug keystore created successfully" -ForegroundColor Green
            Write-Host ""
            Write-Host "Please run this script again to generate SHA keys." -ForegroundColor Yellow
        } else {
            Write-Host "✗ Debug keystore still not found after build" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "✗ Error building app: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual steps:" -ForegroundColor Yellow
        Write-Host "1. Open Android Studio" -ForegroundColor White
        Write-Host "2. Open this project" -ForegroundColor White
        Write-Host "3. Build > Build Bundle(s) / APK(s) > Build APK(s)" -ForegroundColor White
        Write-Host "4. Run this script again" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "=== Additional Information ===" -ForegroundColor Cyan
Write-Host "Debug Keystore Location: $debugKeystorePath" -ForegroundColor White
Write-Host "Alias: androiddebugkey" -ForegroundColor White
Write-Host "Store Password: android" -ForegroundColor White
Write-Host "Key Password: android" -ForegroundColor White
Write-Host ""
Write-Host "For release builds, you'll need to generate a separate keystore." -ForegroundColor Yellow
Write-Host "See docs/firebase_sha_setup.md for complete instructions." -ForegroundColor Yellow

Read-Host "Press Enter to exit"
