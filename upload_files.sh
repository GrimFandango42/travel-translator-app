#!/bin/bash

# Upload all project files to GitHub
echo "Uploading files to GitHub..."

# Upload lib directory files
for file in lib/screens/home_screen.dart lib/widgets/translation_input.dart lib/widgets/camera_capture_button.dart lib/widgets/voice_input_button.dart lib/widgets/translation_output.dart lib/widgets/quick_phrases.dart lib/services/translation_service.dart lib/services/camera_service.dart lib/services/voice_service.dart lib/services/tts_service.dart; do
    echo "Uploading $file..."
    gh api /repos/GrimFandango42/travel-translator-app/contents/$file -X PUT --field message="Add $file" --field content="$(base64 < $file)" || echo "Failed to upload $file"
done

# Upload Android files
gh api /repos/GrimFandango42/travel-translator-app/contents/android/app/src/main/AndroidManifest.xml -X PUT --field message="Add AndroidManifest.xml" --field content="$(base64 < android/app/src/main/AndroidManifest.xml)"

gh api /repos/GrimFandango42/travel-translator-app/contents/android/app/src/main/kotlin/com/example/travel_translator/MainActivity.kt -X PUT --field message="Add MainActivity.kt" --field content="$(base64 < android/app/src/main/kotlin/com/example/travel_translator/MainActivity.kt)"

echo "Upload complete!"