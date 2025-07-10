import 'package:flutter/material.dart';
import '../widgets/translation_input.dart';
import '../widgets/camera_capture_button.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/translation_output.dart';
import '../widgets/quick_phrases.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _inputText = '';
  String _translatedText = '';
  bool _isLoading = false;

  void _updateInput(String text) {
    setState(() {
      _inputText = text;
    });
  }

  void _updateTranslation(String translation) {
    setState(() {
      _translatedText = translation;
      _isLoading = false;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Translator'),
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Japanese Input',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TranslationInput(
                      onTextChanged: _updateInput,
                      text: _inputText,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CameraCaptureButton(
                          onTextCaptured: _updateInput,
                          onLoadingChanged: _setLoading,
                        ),
                        VoiceInputButton(
                          onTextCaptured: _updateInput,
                          onLoadingChanged: _setLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Translation Output
            Expanded(
              child: TranslationOutput(
                inputText: _inputText,
                translatedText: _translatedText,
                isLoading: _isLoading,
                onTranslationComplete: _updateTranslation,
                onLoadingChanged: _setLoading,
              ),
            ),
            
            // Quick Phrases
            const SizedBox(height: 16),
            QuickPhrases(
              onPhraseSelected: _updateInput,
            ),
          ],
        ),
      ),
    );
  }
}