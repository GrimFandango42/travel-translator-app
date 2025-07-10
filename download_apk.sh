#!/bin/bash

# Automated APK Download Script for Termux
# Downloads the latest Travel Translator APK from GitHub Actions

REPO="GrimFandango42/travel-translator-app"
DOWNLOAD_DIR="$HOME/downloads/travel-translator"
TEMP_DIR="/tmp/travel-translator-download"

echo "🚀 Travel Translator APK Auto-Download"
echo "======================================"
echo "📱 Repository: $REPO"
echo "📂 Download directory: $DOWNLOAD_DIR"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "📦 Install with: pkg install gh"
    echo "🔑 Then authenticate with: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "🔑 Run: gh auth login"
    exit 1
fi

# Create download directories
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$TEMP_DIR"

echo "🔍 Checking for latest successful build..."

# Get latest successful workflow run
RUN_ID=$(gh run list -R "$REPO" --workflow="Enhanced CI/CD Pipeline" --status=success --limit=1 --json=databaseId --jq='.[0].databaseId')

if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
    echo "❌ No successful builds found"
    echo "🔗 Check: https://github.com/$REPO/actions"
    exit 1
fi

echo "✅ Found successful build: $RUN_ID"
echo "🔗 Build URL: https://github.com/$REPO/actions/runs/$RUN_ID"

# Download artifacts
echo ""
echo "📥 Downloading APK artifacts..."

cd "$TEMP_DIR"

# Download release APK
echo "🎯 Downloading release APK..."
if gh run download "$RUN_ID" -R "$REPO" -n "travel-translator-release-apk" --dir release 2>/dev/null; then
    echo "✅ Release APK downloaded"
    RELEASE_APK=$(find release -name "*.apk" | head -1)
    if [ -n "$RELEASE_APK" ]; then
        cp "$RELEASE_APK" "$DOWNLOAD_DIR/"
        RELEASE_FILE=$(basename "$RELEASE_APK")
        echo "📱 Release APK: $DOWNLOAD_DIR/$RELEASE_FILE"
    fi
else
    echo "⚠️  Release APK not found"
fi

# Download debug APK
echo "🐛 Downloading debug APK..."
if gh run download "$RUN_ID" -R "$REPO" -n "travel-translator-debug-apk" --dir debug 2>/dev/null; then
    echo "✅ Debug APK downloaded"
    DEBUG_APK=$(find debug -name "*.apk" | head -1)
    if [ -n "$DEBUG_APK" ]; then
        cp "$DEBUG_APK" "$DOWNLOAD_DIR/"
        DEBUG_FILE=$(basename "$DEBUG_APK")
        echo "🔧 Debug APK: $DOWNLOAD_DIR/$DEBUG_FILE"
    fi
else
    echo "⚠️  Debug APK not found"
fi

# Download build info
echo "📊 Downloading build info..."
if gh run download "$RUN_ID" -R "$REPO" -n "build-info-release" --dir info 2>/dev/null; then
    cp info/apk-info.txt "$DOWNLOAD_DIR/build-info.txt" 2>/dev/null
    echo "📋 Build info: $DOWNLOAD_DIR/build-info.txt"
fi

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Download Complete!"
echo "=================="

# List downloaded files
echo "📂 Downloaded files:"
ls -la "$DOWNLOAD_DIR"/*.apk 2>/dev/null || echo "⚠️  No APK files found"

echo ""
echo "📱 Installation Instructions:"
echo "1. Copy APK to your phone (if not already there)"
echo "2. Enable 'Install unknown apps' in Android settings"
echo "3. Install the APK: tap the file to install"
echo "4. Grant camera and microphone permissions"
echo ""

# Get the latest release APK for installation
LATEST_APK=$(ls -t "$DOWNLOAD_DIR"/*release*.apk 2>/dev/null | head -1)
if [ -n "$LATEST_APK" ]; then
    echo "🚀 Ready to install: $(basename "$LATEST_APK")"
    echo "💡 Run: termux-open \"$LATEST_APK\" (if on Termux)"
else
    echo "⚠️  No release APK found for installation"
fi

echo ""
echo "🔗 Repository: https://github.com/$REPO"
echo "📊 Actions: https://github.com/$REPO/actions"
echo "📦 Releases: https://github.com/$REPO/releases"