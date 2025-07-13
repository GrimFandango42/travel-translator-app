import 'package:flutter/services.dart';

class TranslationService {
  static const MethodChannel _channel = MethodChannel('travel_translator/gemini');
  
  static Future<String> translate(String text, {
    required String from,
    required String to,
  }) async {
    // Debug: Log what we're translating
    print('TranslationService: Translating "$text" from $from to $to');
    
    try {
      // First try to use on-device Gemini Nano if available
      final result = await _channel.invokeMethod('translate', {
        'text': text,
        'from': from,
        'to': to,
      });
      print('TranslationService: Gemini result: $result');
      return result ?? '';
    } on PlatformException catch (e) {
      print('TranslationService: Gemini not available, using fallback: $e');
      // Fallback to offline translation logic
      final fallbackResult = await _fallbackTranslate(text, from: from, to: to);
      print('TranslationService: Fallback result: $fallbackResult');
      return fallbackResult;
    }
  }

  static Future<String> _fallbackTranslate(String text, {
    required String from,
    required String to,
  }) async {
    // Ensure we're translating FROM Japanese TO English
    if (from != 'ja' || to != 'en') {
      return 'Translation only supports Japanese to English';
    }

    // Basic fallback with common phrases
    final commonPhrases = {
      'こんにちは': 'Hello',
      'ありがとうございます': 'Thank you',
      'すみません': 'Excuse me',
      'トイレはどこですか？': 'Where is the bathroom?',
      'いくらですか？': 'How much is it?',
      '英語を話せますか？': 'Do you speak English?',
      '助けてください': 'Please help me',
      'わかりません': 'I don\'t understand',
      'おはようございます': 'Good morning',
      'こんばんは': 'Good evening',
      'さようなら': 'Goodbye',
      'はい': 'Yes',
      'いいえ': 'No',
      'お水をください': 'Water please',
      'メニューを見せてください': 'Please show me the menu',
      'お会計をお願いします': 'Check please',
      '駅はどこですか？': 'Where is the station?',
      'ホテルはどこですか？': 'Where is the hotel?',
      '病院はどこですか？': 'Where is the hospital?',
      '警察はどこですか？': 'Where is the police station?',
    };

    // Check if it's a common phrase - return exact English translation
    if (commonPhrases.containsKey(text)) {
      return commonPhrases[text]!;
    }

    // For other text, return English message indicating limited translation
    return 'English translation available with Gemini Nano integration';
  }

  static Future<bool> isGeminiNanoAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}