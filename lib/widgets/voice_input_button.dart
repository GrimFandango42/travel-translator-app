import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTextCaptured;
  final Function(bool) onLoadingChanged;

  const VoiceInputButton({
    super.key,
    required this.onTextCaptured,
    required this.onLoadingChanged,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isListening ? _stopListening : _startListening,
      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
      label: Text(_isListening ? 'Stop' : 'Voice'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isListening ? Colors.red : null,
        foregroundColor: _isListening ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _startListening() async {
    setState(() => _isListening = true);
    widget.onLoadingChanged(true);
    
    try {
      await VoiceService.startListening(
        onResult: (text) {
          widget.onTextCaptured(text);
          setState(() => _isListening = false);
          widget.onLoadingChanged(false);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice recognition error: $error')),
          );
          setState(() => _isListening = false);
          widget.onLoadingChanged(false);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting voice recognition: $e')),
      );
      setState(() => _isListening = false);
      widget.onLoadingChanged(false);
    }
  }

  void _stopListening() {
    VoiceService.stopListening();
    setState(() => _isListening = false);
    widget.onLoadingChanged(false);
  }
}