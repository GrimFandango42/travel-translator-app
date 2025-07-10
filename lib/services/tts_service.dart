import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  static Future<void> speak(String text) async {
    await initialize();
    
    if (text.isEmpty) return;
    
    // Stop any current speech
    await _tts.stop();
    
    try {
      await _tts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static Future<void> setLanguage(String language) async {
    await initialize();
    await _tts.setLanguage(language);
  }

  static Future<void> setSpeechRate(double rate) async {
    await initialize();
    await _tts.setSpeechRate(rate);
  }

  static Future<void> setVolume(double volume) async {
    await initialize();
    await _tts.setVolume(volume);
  }

  static Future<void> setPitch(double pitch) async {
    await initialize();
    await _tts.setPitch(pitch);
  }

  static Future<List<String>> getAvailableLanguages() async {
    await initialize();
    return await _tts.getLanguages;
  }

  static Future<bool> isLanguageAvailable(String language) async {
    await initialize();
    return await _tts.isLanguageAvailable(language);
  }
}