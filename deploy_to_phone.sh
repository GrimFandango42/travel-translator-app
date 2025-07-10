#!/bin/bash

# Automatic Phone Deployment Script
# Downloads and installs Travel Translator APK directly to connected phone

REPO="GrimFandango42/travel-translator-app"
DOWNLOAD_DIR="$HOME/downloads/travel-translator"
PACKAGE_NAME="com.example.travel_translator"

echo "📱 Travel Translator Auto-Deploy to Phone"
echo "=========================================="
echo ""

# Check dependencies
echo "🔍 Checking dependencies..."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "📦 Install with: pkg install gh"
    exit 1
fi

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB is not installed"
    echo "📦 Install with: pkg install android-tools"
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "🔑 Run: gh auth login"
    exit 1
fi

echo "✅ All dependencies available"
echo ""

# Check for connected devices
echo "🔍 Checking for connected devices..."
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No devices connected via ADB"
    echo ""
    echo "📱 To connect your phone:"
    echo "1. Enable Developer Options:"
    echo "   - Settings → About phone → Tap Build number 7 times"
    echo "2. Enable USB Debugging:"
    echo "   - Settings → Developer Options → USB Debugging"
    echo "3. Connect phone via USB cable"
    echo "4. Accept USB debugging prompt on phone"
    echo "5. Run: adb devices (to verify connection)"
    echo ""
    echo "💡 Alternative: Use wireless debugging (Android 11+)"
    echo "   - Settings → Developer Options → Wireless debugging"
    echo "   - Pair device with: adb pair <IP>:<PORT>"
    echo "   - Connect with: adb connect <IP>:<PORT>"
    exit 1
fi

echo "✅ Found $DEVICES connected device(s)"
adb devices
echo ""

# Download latest APK
echo "📥 Downloading latest APK..."
if [ -f "./download_apk.sh" ]; then
    ./download_apk.sh
    if [ $? -ne 0 ]; then
        echo "❌ Failed to download APK"
        exit 1
    fi
else
    echo "❌ download_apk.sh not found"
    exit 1
fi

# Find the latest release APK
LATEST_APK=$(ls -t "$DOWNLOAD_DIR"/*release*.apk 2>/dev/null | head -1)
if [ -z "$LATEST_APK" ]; then
    echo "❌ No release APK found"
    exit 1
fi

echo ""
echo "🚀 Deploying to phone..."
echo "📦 APK: $(basename "$LATEST_APK")"

# Check if app is already installed
if adb shell pm list packages | grep -q "$PACKAGE_NAME"; then
    echo "🔄 App already installed, upgrading..."
    adb install -r "$LATEST_APK"
else
    echo "📱 Installing new app..."
    adb install "$LATEST_APK"
fi

if [ $? -eq 0 ]; then
    echo "✅ Installation successful!"
    echo ""
    echo "📱 Travel Translator has been installed on your phone"
    echo "🎯 You can now find it in your app drawer"
    echo ""
    echo "🚀 Optional: Launch the app now"
    read -p "Launch Travel Translator? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎯 Launching Travel Translator..."
        adb shell am start -n "$PACKAGE_NAME/.MainActivity"
        echo "📱 App launched on your phone!"
    fi
else
    echo "❌ Installation failed"
    echo "🔧 Check ADB connection and try again"
    exit 1
fi

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo "📱 Travel Translator is now installed on your phone"
echo "🇯🇵 Perfect for your travels in Japan!"
echo ""
echo "💡 To redeploy later, just run: ./deploy_to_phone.sh"