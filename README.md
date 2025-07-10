# Travel Translator

An on-device Japanese to English translator app optimized for travelers using Pixel phones and Gemini Nano AI.

## Features

- **Camera Text Capture**: Point your camera at Japanese signs, menus, or text to instantly translate
- **Voice Input**: Speak Japanese phrases for real-time translation
- **On-Device Processing**: Uses Gemini Nano for fast, private translations without internet
- **Traveler-Focused**: Quick access to common travel phrases and situations
- **Offline Mode**: Core functionality works without internet connection
- **Text-to-Speech**: Hear English pronunciations of translations
- **Simple UI**: Clean, intuitive interface designed for quick use while traveling

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

1. Ensure Flutter is installed on your development machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Connect your Pixel phone with USB debugging enabled
5. Run `flutter run` to install and launch the app

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

## Contributing

This is a demonstration app showcasing on-device AI capabilities. Feel free to fork and extend the functionality for your travel needs.

## License

MIT License - see LICENSE file for details.