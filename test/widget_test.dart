// This is a basic Flutter widget test.
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpp_app/main.dart';
import 'package:dpp_app/screens/splash_screen.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test - verifies initial launch', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());

    // Verify that the splash screen is shown
    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the splash screen timer and animation finish
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
