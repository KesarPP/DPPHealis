import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/main.dart';
import 'package:dpp_app/screens/login_screen.dart';
import 'package:dpp_app/screens/signup_screen.dart';
import 'package:dpp_app/screens/clinician_dashboard_screen.dart';
import 'package:dpp_app/screens/clinician_profile_screen.dart';
import 'package:dpp_app/screens/coach_profile_screen.dart';
import 'package:dpp_app/screens/dashboard_screen.dart';
import 'package:dpp_app/screens/risk_assessment_step1_screen.dart';
import 'package:dpp_app/screens/risk_assessment_step2_screen.dart';
import 'package:dpp_app/screens/gpaq_step1_screen.dart';
import 'package:dpp_app/screens/gpaq_step2_screen.dart';
import 'package:dpp_app/screens/gpaq_step3_screen.dart';
import 'package:dpp_app/screens/gpaq_step4_screen.dart';
import 'package:dpp_app/screens/gpaq_results_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  setUpAll(() {
    WebViewPlatform.instance = MockWebViewPlatform();
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

  testWidgets('Patient Login Flow Navigation Test', (WidgetTester tester) async {
    await setupTestWindow(tester);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Doctor/Coach'), findsOneWidget);

    // Ensure login button is visible and tap it
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Verify we are on RiskAssessmentStep1Screen
    expect(find.byType(RiskAssessmentStep1Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 2/7)'), findsOneWidget);

    // Tap Continue on Step 1 Screen
    final continueButton1 = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.tap(continueButton1);
    await tester.pumpAndSettle();

    // Verify we are on RiskAssessmentStep2Screen
    expect(find.byType(RiskAssessmentStep2Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 3/7)'), findsOneWidget);

    // Tap Continue on Step 2 Screen
    final continueButton2 = find.descendant(
      of: find.byType(RiskAssessmentStep2Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueButton2);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep1Screen
    expect(find.byType(GPAQStep1Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 4/7)'), findsOneWidget);

    // Tap Continue on GPAQ Step 1 Screen
    final continueGPAQ1 = find.descendant(
      of: find.byType(GPAQStep1Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ1);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep2Screen
    expect(find.byType(GPAQStep2Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 5/7)'), findsOneWidget);

    // Tap Continue on GPAQ Step 2 Screen
    final continueGPAQ2 = find.descendant(
      of: find.byType(GPAQStep2Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ2);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep3Screen
    expect(find.byType(GPAQStep3Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 6/7)'), findsOneWidget);

    // Tap Continue on GPAQ Step 3 Screen
    final continueGPAQ3 = find.descendant(
      of: find.byType(GPAQStep3Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ3);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep4Screen
    expect(find.byType(GPAQStep4Screen), findsOneWidget);
    expect(find.text('Risk Assessment (Step 7/7)'), findsOneWidget);

    // Tap Continue on GPAQ Step 4 Screen
    final calculateActivityScoreButton = find.descendant(
      of: find.byType(GPAQStep4Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(calculateActivityScoreButton);
    await tester.pumpAndSettle();

    // Verify we are on GPAQResultsScreen
    expect(find.byType(GPAQResultsScreen), findsOneWidget);
    expect(find.text('Activity Results'), findsOneWidget);

    // Tap Go to Dashboard on GPAQResultsScreen
    final goToDashboardButton = find.descendant(
      of: find.byType(GPAQResultsScreen),
      matching: find.widgetWithText(ElevatedButton, 'Go to Dashboard'),
    );
    await tester.tap(goToDashboardButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify that we navigated to the Patient's MainShell and show DashboardScreen
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    // Navigate to Coach Chat Screen
    final coachTab = find.text('Coach');
    await tester.tap(coachTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify CoachChatScreen is displayed
    expect(find.text('Online'), findsOneWidget);

    // Tap the Coach PFP in the AppBar
    final coachPfp = find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.auto_awesome_rounded),
    );
    await tester.tap(coachPfp);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify we are on CoachProfileScreen
    expect(find.byType(CoachProfileScreen), findsOneWidget);
    expect(find.text('Dr. Sarah Mitchell'), findsOneWidget);
    // Verify that Sign Out and edit options are not present
    expect(find.text('Sign Out'), findsNothing);
    expect(find.byIcon(Icons.edit_rounded), findsNothing);

    // Go back
    final backButton = find.byType(BackButton);
    await tester.tap(backButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await resetTestWindow(tester);
  });

  testWidgets('Doctor/Coach Login, Avatar Navigation, and Sign Out Flow Test', (WidgetTester tester) async {
    await setupTestWindow(tester);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);

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
    expect(find.text('DPP Connect'), findsOneWidget);
    expect(find.text('TOTAL ACTIVE PARTICIPANTS'), findsOneWidget);

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
    expect(find.text('Dr. Sarah Mitchell'), findsOneWidget);
    expect(find.text('Senior Health Coach & Nutritionist'), findsOneWidget);

    // Tap the 'Sign Out' button
    final signOutButton = find.widgetWithText(OutlinedButton, 'Sign Out');
    await tester.ensureVisible(signOutButton);
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    // Verify that we are back on the LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

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

  testWidgets('Biometric Login Flow Navigation Test', (WidgetTester tester) async {
    await setupTestWindow(tester);

    // Register a mock handler on the local_auth channel
    const channel = MethodChannel('plugins.flutter.io/local_auth');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'isDeviceSupported') {
          return true;
        }
        if (methodCall.method == 'canCheckBiometrics') {
          return true;
        }
        if (methodCall.method == 'getAvailableBiometrics') {
          return ['fingerprint'];
        }
        if (methodCall.method == 'authenticate') {
          return true;
        }
        return null;
      },
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(const DPPApp());
    await tester.pumpAndSettle();

    // Verify we are on the Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Ensure the Biometric Login button is tapped
    final biometricButton = find.widgetWithText(OutlinedButton, 'Biometric Login');
    await tester.ensureVisible(biometricButton);
    await tester.tap(biometricButton);
    await tester.pumpAndSettle();

    // Verify we are on RiskAssessmentStep1Screen
    expect(find.byType(RiskAssessmentStep1Screen), findsOneWidget);

    // Tap Continue on Step 1 Screen
    final continueButton1 = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.tap(continueButton1);
    await tester.pumpAndSettle();

    // Verify we are on RiskAssessmentStep2Screen
    expect(find.byType(RiskAssessmentStep2Screen), findsOneWidget);

    // Tap Continue on Step 2 Screen
    final continueButton2 = find.descendant(
      of: find.byType(RiskAssessmentStep2Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueButton2);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep1Screen
    expect(find.byType(GPAQStep1Screen), findsOneWidget);

    // Tap Continue on GPAQ Step 1 Screen
    final continueGPAQ1 = find.descendant(
      of: find.byType(GPAQStep1Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ1);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep2Screen
    expect(find.byType(GPAQStep2Screen), findsOneWidget);

    // Tap Continue on GPAQ Step 2 Screen
    final continueGPAQ2 = find.descendant(
      of: find.byType(GPAQStep2Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ2);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep3Screen
    expect(find.byType(GPAQStep3Screen), findsOneWidget);

    // Tap Continue on GPAQ Step 3 Screen
    final continueGPAQ3 = find.descendant(
      of: find.byType(GPAQStep3Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(continueGPAQ3);
    await tester.pumpAndSettle();

    // Verify we are on GPAQStep4Screen
    expect(find.byType(GPAQStep4Screen), findsOneWidget);

    // Tap Continue on GPAQ Step 4 Screen
    final calculateActivityScoreButton = find.descendant(
      of: find.byType(GPAQStep4Screen),
      matching: find.widgetWithText(ElevatedButton, 'Continue'),
    );
    await tester.tap(calculateActivityScoreButton);
    await tester.pumpAndSettle();

    // Verify we are on GPAQResultsScreen
    expect(find.byType(GPAQResultsScreen), findsOneWidget);

    // Tap Go to Dashboard on GPAQResultsScreen
    final goToDashboardButton = find.descendant(
      of: find.byType(GPAQResultsScreen),
      matching: find.widgetWithText(ElevatedButton, 'Go to Dashboard'),
    );
    await tester.tap(goToDashboardButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Since it was 'Patient' role selected by default, verify we navigated to the Patient MainShell
    expect(find.byType(MainShell), findsOneWidget);

    // Reset the Mock handler
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);

    await resetTestWindow(tester);
  });
}

class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return MockPlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return MockPlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return MockPlatformNavigationDelegate(params);
  }
}

class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async {}
}

class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnProgress(void Function(int progress) onProgress) async {}
  @override
  Future<void> setOnPageStarted(void Function(String url) onPageStarted) async {}
  @override
  Future<void> setOnPageFinished(void Function(String url) onPageFinished) async {}
  @override
  Future<void> setOnWebResourceError(
    void Function(WebResourceError error) onWebResourceError,
  ) async {}
}
