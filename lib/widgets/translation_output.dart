import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';

class TranslationOutput extends StatefulWidget {
  final String inputText;
  final String translatedText;
  final bool isLoading;
  final Function(String) onTranslationComplete;
  final Function(bool) onLoadingChanged;

  const TranslationOutput({
    super.key,
    required this.inputText,
    required this.translatedText,
    required this.isLoading,
    required this.onTranslationComplete,
    required this.onLoadingChanged,
  });

  @override
  State<TranslationOutput> createState() => _TranslationOutputState();
}

class _TranslationOutputState extends State<TranslationOutput> {
  String _lastTranslatedInput = '';

  @override
  void didUpdateWidget(TranslationOutput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputText != oldWidget.inputText && 
        widget.inputText.isNotEmpty && 
        widget.inputText != _lastTranslatedInput) {
      _translateText();
    }
  }

  void _translateText() async {
    if (widget.inputText.isEmpty) return;
    
    widget.onLoadingChanged(true);
    _lastTranslatedInput = widget.inputText;
    
    try {
      final translation = await TranslationService.translate(
        widget.inputText,
        from: 'ja',
        to: 'en',
      );
      widget.onTranslationComplete(translation);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation error: $e')),
      );
      widget.onLoadingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'English Translation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.translatedText.isNotEmpty)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => TTSService.speak(widget.translatedText),
                        tooltip: 'Play audio',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.translatedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        },
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : widget.translatedText.isEmpty
                        ? const Text(
                            'Translation will appear here...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Text(
                              widget.translatedText,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}