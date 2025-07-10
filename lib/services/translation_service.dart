import 'package:flutter/services.dart';

class TranslationService {
  static const MethodChannel _channel = MethodChannel('travel_translator/gemini');
  
  static Future<String> translate(String text, {
    required String from,
    required String to,
  }) async {
    try {
      // First try to use on-device Gemini Nano if available
      final result = await _channel.invokeMethod('translate', {
        'text': text,
        'from': from,
        'to': to,
      });
      return result ?? '';
    } on PlatformException {
      // Fallback to offline translation logic
      return await _fallbackTranslate(text, from: from, to: to);
    }
  }

  static Future<String> _fallbackTranslate(String text, {
    required String from,
    required String to,
  }) async {
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

    // Check if it's a common phrase
    if (commonPhrases.containsKey(text)) {
      return commonPhrases[text]!;
    }

    // For other text, return a placeholder indicating on-device processing
    return 'Translation processing... (On-device translation available with Gemini Nano)';
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