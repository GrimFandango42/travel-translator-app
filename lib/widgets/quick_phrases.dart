import 'package:flutter/material.dart';

class QuickPhrases extends StatelessWidget {
  final Function(String) onPhraseSelected;

  const QuickPhrases({
    super.key,
    required this.onPhraseSelected,
  });

  final List<Map<String, String>> _phrases = const [
    {'japanese': 'こんにちは', 'english': 'Hello'},
    {'japanese': 'ありがとうございます', 'english': 'Thank you'},
    {'japanese': 'すみません', 'english': 'Excuse me'},
    {'japanese': 'トイレはどこですか？', 'english': 'Where is the bathroom?'},
    {'japanese': 'いくらですか？', 'english': 'How much is it?'},
    {'japanese': '英語を話せますか？', 'english': 'Do you speak English?'},
    {'japanese': '助けてください', 'english': 'Please help me'},
    {'japanese': 'わかりません', 'english': 'I don\'t understand'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Phrases',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _phrases.map((phrase) {
                return ActionChip(
                  label: Text(phrase['japanese']!),
                  onPressed: () => onPhraseSelected(phrase['japanese']!),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}