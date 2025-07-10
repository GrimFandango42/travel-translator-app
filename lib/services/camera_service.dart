import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String> captureAndExtractText() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return '';

      // For now, return a placeholder message
      // In a real implementation, this would use OCR
      return 'Image captured - OCR processing would happen here with on-device ML';
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      // Placeholder for text extraction
      return 'Text extraction from image would happen here';
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  static Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw Exception('Failed to get available cameras: $e');
    }
  }
}