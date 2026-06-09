import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/main.dart';
import 'package:dpp_app/screens/login_screen.dart';
import 'package:dpp_app/screens/signup_screen.dart';
import 'package:dpp_app/screens/clinician_dashboard_screen.dart';
import 'package:dpp_app/screens/clinician_profile_screen.dart';
import 'package:dpp_app/screens/dashboard_screen.dart';

void main() {
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

  testWidgets('Patient Login Flow Navigation Test', (WidgetTester tester) async {
    await setupTestWindow(tester);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Doctor/Coach'), findsOneWidget);

    // Ensure login button is visible and tap it
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify that we navigated to the Patient's MainShell and show DashboardScreen
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    await resetTestWindow(tester);
  });

  testWidgets('Doctor/Coach Login, Avatar Navigation, and Sign Out Flow Test', (WidgetTester tester) async {
    await setupTestWindow(tester);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.text('Welcome!'), findsOneWidget);

    // Find and tap the 'Doctor/Coach' toggle
    final coachToggle = find.text('Doctor/Coach');
    await tester.ensureVisible(coachToggle);
    await tester.tap(coachToggle);
    await tester.pumpAndSettle();

    // Tap Login
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify that we navigated to ClinicianDashboardScreen
    expect(find.byType(ClinicianDashboardScreen), findsOneWidget);
    expect(find.text('Clinician Dashboard'), findsOneWidget);
    expect(find.text('ACTIVE RISK'), findsOneWidget);

    // Locate the Doctor Avatar gesture detector in the top-left
    final avatarFinder = find.descendant(
      of: find.byType(ClinicianDashboardScreen),
      matching: find.byType(GestureDetector),
    ).first;

    // Tap the Doctor Avatar to navigate to the profile screen
    await tester.tap(avatarFinder);
    await tester.pumpAndSettle();

    // Verify that we navigated to ClinicianProfileScreen
    expect(find.byType(ClinicianProfileScreen), findsOneWidget);
    expect(find.text('Dr. Alexander Ross'), findsOneWidget);
    expect(find.text('Clinician Profile'), findsOneWidget);

    // Tap the 'Sign Out' button
    final signOutButton = find.widgetWithText(OutlinedButton, 'Sign Out');
    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    // Verify that we are back on the LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);

    await resetTestWindow(tester);
  });

  testWidgets('SignUp Screen Redirection Test', (WidgetTester tester) async {
    await setupTestWindow(tester);

    // Build our app
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Tap the "Sign Up" button on Login Screen
    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    // Verify we are on the SignUp Screen
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // Select Doctor/Coach option on Sign Up
    final coachToggle = find.descendant(
      of: find.byType(SignUpScreen),
      matching: find.text('Doctor/Coach'),
    );
    await tester.ensureVisible(coachToggle);
    await tester.tap(coachToggle);
    await tester.pumpAndSettle();

    // Tap SignUp button
    final signUpSubmit = find.descendant(
      of: find.byType(SignUpScreen),
      matching: find.widgetWithText(ElevatedButton, 'Sign Up'),
    );
    await tester.ensureVisible(signUpSubmit);
    await tester.tap(signUpSubmit);
    await tester.pumpAndSettle();

    // Verify it navigated to ClinicianDashboardScreen
    expect(find.byType(ClinicianDashboardScreen), findsOneWidget);

    await resetTestWindow(tester);
  });
}
