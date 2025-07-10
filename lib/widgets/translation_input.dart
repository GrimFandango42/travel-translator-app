import 'package:flutter/material.dart';

class TranslationInput extends StatefulWidget {
  final Function(String) onTextChanged;
  final String text;

  const TranslationInput({
    super.key,
    required this.onTextChanged,
    required this.text,
  });

  @override
  State<TranslationInput> createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(TranslationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Enter Japanese text or use camera/voice',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
      onChanged: widget.onTextChanged,
      style: const TextStyle(fontSize: 16),
    );
  }
}