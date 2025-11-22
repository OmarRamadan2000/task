#!/bin/bash

# Facebook Key Hash Generator for Android
# This script generates the key hashes needed for Facebook Login configuration

echo "=================================="
echo "Facebook Key Hash Generator"
echo "=================================="
echo ""

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo "Error: openssl is not installed"
    echo "Install it with: brew install openssl"
    exit 1
fi

# Debug Key Hash
echo "1. DEBUG Key Hash (for development):"
echo "-----------------------------------"
if [ -f ~/.android/debug.keystore ]; then
    DEBUG_HASH=$(keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android 2>/dev/null | openssl sha1 -binary | openssl base64)
    echo "Key Hash: $DEBUG_HASH"
    echo ""
    echo "Add this to Facebook Console → Android Platform → Key Hashes"
else
    echo "Debug keystore not found at ~/.android/debug.keystore"
fi

echo ""
echo "2. RELEASE Key Hash (for production):"
echo "--------------------------------------"
if [ -f ~/upload-keystore.jks ]; then
    echo "Enter your keystore password when prompted:"
    RELEASE_HASH=$(keytool -exportcert -alias upload -keystore ~/upload-keystore.jks 2>/dev/null | openssl sha1 -binary | openssl base64)
    if [ ! -z "$RELEASE_HASH" ]; then
        echo "Key Hash: $RELEASE_HASH"
        echo ""
        echo "Add this to Facebook Console → Android Platform → Key Hashes"
    else
        echo "Failed to generate release key hash. Check your password."
    fi
else
    echo "Release keystore not found at ~/upload-keystore.jks"
    echo "If you have a release keystore elsewhere, run:"
    echo "keytool -exportcert -alias YOUR_ALIAS -keystore /path/to/keystore.jks | openssl sha1 -binary | openssl base64"
fi

echo ""
echo "=================================="
echo "Next Steps:"
echo "=================================="
echo "1. Copy the key hash(es) above"
echo "2. Go to: https://developers.facebook.com/apps"
echo "3. Select your app → Settings → Basic"
echo "4. Scroll to Android platform section"
echo "5. Add Package Name: com.example.task"
echo "6. Add Class Name: com.example.task.MainActivity"
echo "7. Paste the key hashes in 'Key Hashes' field"
echo "8. Save changes"
echo ""
