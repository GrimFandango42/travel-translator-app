# Building Travel Translator on Android (Termux)

## Option 1: Quick Deploy (Recommended)

Since Flutter is large to download on mobile data, here are alternative deployment methods:

### A. Use GitHub Codespaces (Free)
1. Push code to GitHub
2. Open in GitHub Codespaces (free tier: 60 hours/month)
3. Build APK in the cloud
4. Download APK to phone

### B. Use Online Flutter Compiler
1. Upload project to platforms like DartPad or FlutterFlow
2. Build APK online
3. Download to phone

### C. Use GitHub Actions (Automated)
1. Push code to GitHub
2. GitHub Actions automatically builds APK
3. Download from GitHub Releases

## Option 2: Full Local Build (Advanced)

If you want to build locally in Termux:

### 1. Install Dependencies
```bash
pkg update && pkg upgrade -y
pkg install -y wget curl unzip openjdk-21 gradle git
```

### 2. Download Flutter SDK
```bash
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz
```

### 3. Set Environment Variables
```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
echo 'export JAVA_HOME=/data/data/com.termux/files/usr/opt/openjdk' >> ~/.bashrc
echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

### 4. Install Android SDK
```bash
mkdir -p $HOME/android-sdk
cd $HOME/android-sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
cd cmdline-tools
mkdir latest
mv * latest/ 2>/dev/null || true
cd $HOME/android-sdk/cmdline-tools/latest/bin
./sdkmanager --install "platforms;android-33" "build-tools;33.0.0" "platform-tools"
```

### 5. Accept Licenses
```bash
cd $HOME/android-sdk/cmdline-tools/latest/bin
./sdkmanager --licenses
```

### 6. Build APK
```bash
cd ~/projects/travel_translator
flutter doctor
flutter pub get
flutter build apk --release
```

### 7. Install APK
```bash
# APK will be in build/app/outputs/flutter-apk/app-release.apk
# Install with: adb install build/app/outputs/flutter-apk/app-release.apk
# Or copy to /storage/emulated/0/Download/ and install manually
```

## Option 3: Simplified Build Script

Use the provided build script:

```bash
chmod +x build_apk.sh
./build_apk.sh
```

## Troubleshooting

### Common Issues:
1. **Out of storage**: Flutter SDK is ~700MB, Android SDK is ~500MB
2. **Memory issues**: Building requires 2GB+ RAM
3. **Network timeout**: Use WiFi for downloads
4. **Permission errors**: Enable developer options and USB debugging

### Solutions:
1. Use external storage: `termux-setup-storage`
2. Close other apps during build
3. Use stable WiFi connection
4. Enable "Install unknown apps" in Android settings

## Next Steps

Once you have the APK:
1. Install on your phone
2. Grant camera and microphone permissions
3. Test with Japanese text/voice
4. Use while traveling in Japan!

The app will use your Pixel's built-in Gemini Nano for on-device translation.