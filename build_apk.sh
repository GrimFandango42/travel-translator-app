#!/bin/bash

# Travel Translator APK Build Script for Termux
# This script automates the Flutter setup and APK building process

set -e

echo "🚀 Travel Translator APK Build Script"
echo "======================================"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "❌ This script is designed for Termux on Android"
    exit 1
fi

# Create build directory
mkdir -p ~/build_logs
LOG_FILE=~/build_logs/build_$(date +%Y%m%d_%H%M%S).log

echo "📝 Logging to: $LOG_FILE"

# Function to log and display
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "🔧 Installing required packages..."
pkg update -y >> "$LOG_FILE" 2>&1
pkg install -y wget curl unzip openjdk-21 gradle git >> "$LOG_FILE" 2>&1

log "📱 Setting up Android SDK..."
ANDROID_HOME="$HOME/android-sdk"
mkdir -p "$ANDROID_HOME"
cd "$ANDROID_HOME"

if [ ! -f "cmdline-tools/latest/bin/sdkmanager" ]; then
    log "⬇️ Downloading Android SDK tools..."
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    unzip -q commandlinetools-linux-9477386_latest.zip
    cd cmdline-tools
    mkdir -p latest
    mv * latest/ 2>/dev/null || true
    cd "$ANDROID_HOME"
    rm -f commandlinetools-linux-9477386_latest.zip
fi

# Set environment variables
export JAVA_HOME="/data/data/com.termux/files/usr/opt/openjdk"
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

log "🔧 Installing Android SDK components..."
cd "$ANDROID_HOME/cmdline-tools/latest/bin"
yes | ./sdkmanager --install "platforms;android-33" "build-tools;33.0.0" "platform-tools" >> "$LOG_FILE" 2>&1

log "🔧 Accepting Android licenses..."
yes | ./sdkmanager --licenses >> "$LOG_FILE" 2>&1

log "📦 Setting up Flutter..."
FLUTTER_HOME="$HOME/flutter"
if [ ! -d "$FLUTTER_HOME" ]; then
    cd ~
    log "⬇️ Downloading Flutter SDK (this may take a while)..."
    wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
    log "📦 Extracting Flutter..."
    tar xf flutter_linux_3.24.5-stable.tar.xz >> "$LOG_FILE" 2>&1
    rm flutter_linux_3.24.5-stable.tar.xz
fi

export PATH="$PATH:$FLUTTER_HOME/bin"

log "🔍 Running Flutter doctor..."
flutter doctor >> "$LOG_FILE" 2>&1

log "🏗️ Building APK..."
cd ~/projects/travel_translator

# Get dependencies
log "📦 Getting Flutter dependencies..."
flutter pub get >> "$LOG_FILE" 2>&1

# Build APK
log "🔨 Building release APK..."
flutter build apk --release >> "$LOG_FILE" 2>&1

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    log "✅ APK built successfully!"
    log "📱 APK location: $APK_PATH"
    
    # Copy APK to Downloads folder for easy access
    DOWNLOADS_DIR="/storage/emulated/0/Download"
    if [ -d "$DOWNLOADS_DIR" ]; then
        cp "$APK_PATH" "$DOWNLOADS_DIR/travel_translator.apk"
        log "📁 APK copied to Downloads folder: travel_translator.apk"
    fi
    
    log "🎉 Build completed successfully!"
    log "📋 Next steps:"
    log "   1. Install APK: tap on travel_translator.apk in Downloads"
    log "   2. Enable 'Install unknown apps' if prompted"
    log "   3. Grant camera and microphone permissions"
    log "   4. Start translating Japanese text!"
else
    log "❌ APK build failed. Check log file: $LOG_FILE"
    exit 1
fi