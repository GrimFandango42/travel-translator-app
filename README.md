# Travel Translator 🚧 **Work in Progress**

An on-device Japanese to English translator app optimized for travelers using Pixel phones and Gemini Nano AI.

> **⚠️ DEVELOPMENT STATUS**: This project is currently in active development. Core translation features are functional with basic Japanese phrase support, but advanced features like Gemini Nano integration and camera OCR are still being implemented.

## Features

### ✅ **Currently Working**
- **Text Input Translation**: Type Japanese text for English translation (20+ common phrases supported)
- **Voice Input**: Speak Japanese phrases for real-time translation
- **Quick Travel Phrases**: Instant access to essential travel expressions
- **Text-to-Speech**: Hear English pronunciations of translations
- **Simple UI**: Clean, intuitive Material Design interface
- **Offline Mode**: Core phrase translation works without internet

### 🚧 **In Development**
- **Camera Text Capture**: OCR integration for signs, menus, and documents (UI ready, OCR pending)
- **Gemini Nano Integration**: On-device AI for advanced translation (infrastructure ready)
- **Expanded Phrase Library**: More comprehensive Japanese phrase coverage
- **Advanced Voice Processing**: Improved speech recognition accuracy

## Key Technologies

- **Flutter**: Cross-platform mobile app framework
- **Gemini Nano**: Google's on-device AI model for translation
- **ML Kit**: Google's machine learning toolkit for text recognition
- **Speech-to-Text**: Voice input for Japanese phrases
- **Text-to-Speech**: Audio output for English translations

## Device Requirements

- Pixel phone (Pixel 8 Pro or newer recommended)
- Android 13+ 
- Gemini Nano support (automatically available on compatible Pixel devices)

## Installation

### Quick Install (Recommended)
1. **Download Latest APK**: 
   - Go to [GitHub Actions](https://github.com/GrimFandango42/travel-translator-app/actions)
   - Download the latest successful build artifacts
   - Install `travel-translator-release.apk` on your Android phone

2. **Enable Installation**: 
   - Settings → Security → "Install unknown apps" → Enable for your file manager

### Development Build
1. Ensure Flutter is installed on your development machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Connect your Pixel phone with USB debugging enabled
5. Run `flutter run` to install and launch the app

### Automated Deployment
The project includes automated CI/CD pipeline with scripts for easy deployment:
```bash
./deploy_to_phone.sh  # Auto-deploy to connected phone
./download_apk.sh     # Download latest GitHub build
```

## Usage

1. **Text Input**: Type Japanese text directly into the input field
2. **Camera**: Tap the camera button to capture text from signs, menus, or documents
3. **Voice**: Tap the microphone button and speak Japanese phrases
4. **Quick Phrases**: Tap common travel phrases for instant translation
5. **Audio**: Tap the speaker icon to hear English pronunciation
6. **Copy**: Tap the copy icon to save translations to clipboard

## Privacy

- All translations are processed on-device using Gemini Nano
- No text or voice data is sent to external servers
- Camera images are processed locally and not stored
- Voice input is processed locally without cloud services

## Development Status & Roadmap

### 🎯 **Current Phase**: Core Translation Features
- ✅ Basic Japanese phrase translation (20+ phrases)
- ✅ Voice input and text-to-speech output
- ✅ Clean UI with Material Design 3
- ✅ Automated CI/CD pipeline with GitHub Actions

### 🔮 **Next Phase**: Advanced AI Integration
- 🚧 Gemini Nano on-device translation
- 🚧 Camera OCR with ML Kit
- 🚧 Expanded phrase library
- 🚧 Performance optimizations

### 📝 **Known Limitations**
- Translation currently limited to pre-defined phrases
- Camera feature shows placeholder (OCR integration pending)
- Requires internet for voice recognition

## Contributing

This is an active development project showcasing on-device AI capabilities for travel translation. Contributions welcome:

1. **Translation Phrases**: Add more common Japanese travel phrases
2. **UI/UX Improvements**: Enhance user experience and accessibility  
3. **Feature Implementation**: Help implement Gemini Nano or ML Kit features
4. **Testing**: Report bugs and test on different devices

Feel free to fork, create issues, or submit pull requests!

## License

MIT License - see LICENSE file for details.