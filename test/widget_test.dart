import 'package:flutter_test/flutter_test.dart';

import 'package:travel_translator/main.dart';

void main() {
  testWidgets('Travel Translator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelTranslatorApp());

    // Verify that the app title is displayed.
    expect(find.text('Travel Translator'), findsOneWidget);

    // Verify that the input field is present.
    expect(find.text('Enter Japanese text or use camera/voice'), findsOneWidget);
  });
}