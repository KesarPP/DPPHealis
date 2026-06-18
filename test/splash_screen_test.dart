import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpp_app/main.dart';
import 'package:dpp_app/screens/splash_screen.dart';
import 'package:dpp_app/screens/login_screen.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });
  // Helper to configure a larger screen size for mobile tests
  Future<void> setupTestWindow(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
  }

  Future<void> resetTestWindow(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('SplashScreen Initial State and Timed Transition Test', (WidgetTester tester) async {
    await setupTestWindow(tester);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());

    // Verify SplashScreen is loaded as initial page
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // Verify brand assets/elements exist
    expect(find.text('Diabetes'), findsOneWidget);
    expect(find.text('Prevention'), findsOneWidget);
    expect(find.text('— Program —'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Initial frame renders and starts animation. Run animation to end.
    await tester.pump(const Duration(milliseconds: 1500));

    // Wait until the redirection timer triggers (2.6 seconds total)
    // Pump 1.2s to exceed 2.6 seconds total timer duration
    await tester.pump(const Duration(milliseconds: 1200));
    
    // Settle the page route transition animation (fade transition takes 700ms)
    await tester.pumpAndSettle();

    // Verify that the app transitioned successfully to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

    await resetTestWindow(tester);
  });
}
