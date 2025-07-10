import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
  }

  static Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    // Check microphone permission
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      onError('Microphone permission denied');
      return;
    }

    await initialize();
    
    if (!_isInitialized) {
      onError('Speech recognition not available');
      return;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        localeId: 'ja-JP', // Japanese locale
      );
    } catch (e) {
      onError('Failed to start listening: $e');
    }
  }

  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  static bool get isListening => _speech.isListening;

  static Future<List<String>> getSupportedLanguages() async {
    await initialize();
    if (!_isInitialized) return [];
    
    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  static Future<bool> isAvailable() async {
    await initialize();
    return _isInitialized;
  }
}