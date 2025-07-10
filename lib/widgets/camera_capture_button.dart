import 'package:flutter/material.dart';
import '../services/camera_service.dart';

class CameraCaptureButton extends StatelessWidget {
  final Function(String) onTextCaptured;
  final Function(bool) onLoadingChanged;

  const CameraCaptureButton({
    super.key,
    required this.onTextCaptured,
    required this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        onLoadingChanged(true);
        try {
          final capturedText = await CameraService.captureAndExtractText();
          if (capturedText.isNotEmpty) {
            onTextCaptured(capturedText);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error capturing text: $e')),
          );
        } finally {
          onLoadingChanged(false);
        }
      },
      icon: const Icon(Icons.camera_alt),
      label: const Text('Camera'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}