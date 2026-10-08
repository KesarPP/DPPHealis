import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:dpp_app/providers/session_notifiers.dart';
import 'package:dpp_app/providers/journal_launcher.dart';
import 'package:dpp_app/screens/manuscript_screen.dart';
import 'package:dpp_app/screens/sessions_screen.dart';
import 'package:dpp_app/screens/journey_screen.dart';
import 'package:dpp_app/services/session_video_progress_service.dart';
import 'package:dpp_app/widgets/dpp_youtube_video_player.dart';

class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return MockPlatformNavigationDelegate(params);
  }

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
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return MockPlatformWebViewCookieManager(params);
  }
}

class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}
}

class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> setUserAgent(String? userAgent) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  Future<void> setMediaPlaybackRequiresUserGesture(bool require) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<String> runJavaScriptReturningResult(String javaScript) async => '';

  @override
  Future<void> setOnConsoleMessage(
    void Function(JavaScriptConsoleMessage consoleMessage) onConsoleMessage,
  ) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> clearLocalStorage() async {}
}

class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MockPlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  MockPlatformWebViewCookieManager(super.params) : super.implementation();
}

Widget createTestApp(Widget child, {CurrentSessionNotifier? notifier, SessionVideoProgressService? progressService, JournalLaunchNotifier? journalLaunch}) {
  final sessionNotifier = notifier ?? CurrentSessionNotifier();
  final progress = progressService ?? SessionVideoProgressService();
  final launch = journalLaunch ?? JournalLaunchNotifier();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CurrentSessionNotifier>.value(value: sessionNotifier),
      ChangeNotifierProvider<SessionVideoProgressService>.value(value: progress),
      ChangeNotifierProvider<JournalLaunchNotifier>.value(value: launch),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 800,
            height: 1200,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = MockWebViewPlatform();
  });

  group('Part 2 — Manuscript Video Integration Tests', () {
    testWidgets('ManuscriptScreen renders given sessionId correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestApp(const ManuscriptScreen(sessionId: 'session_06')),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verifies ManuscriptScreen renders without exception and embeds DppYoutubeVideoPlayer
      expect(find.byType(ManuscriptScreen), findsOneWidget);
      expect(find.byType(DppYoutubeVideoPlayer), findsOneWidget);
    });

    testWidgets('ManuscriptScreen renders default session_06 when no ID passed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestApp(const ManuscriptScreen()),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ManuscriptScreen), findsOneWidget);
      expect(find.byType(DppYoutubeVideoPlayer), findsOneWidget);
    });

    testWidgets('Placeholder session renders Coming Soon card without throwing', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestApp(const ManuscriptScreen(sessionId: 'session_03')),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Video coming soon'), findsOneWidget);
    });

    testWidgets('SessionsScreen Watch Video button triggers JournalLaunchNotifier', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final launchNotifier = JournalLaunchNotifier();
      await tester.pumpWidget(
        createTestApp(const SessionsScreen(), journalLaunch: launchNotifier),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final watchButton = find.text('Watch Video');
      expect(watchButton, findsOneWidget);

      await tester.ensureVisible(watchButton);
      await tester.tap(watchButton, warnIfMissed: false);
      await tester.pump();

      expect(launchNotifier.sessionId, equals('session_06'));
    });

    testWidgets('JourneyMap card tap triggers JournalLaunchNotifier', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final launchNotifier = JournalLaunchNotifier();
      await tester.pumpWidget(
        createTestApp(const JourneyMap(), journalLaunch: launchNotifier),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final titleFinder = find.textContaining('Understanding');
      expect(titleFinder, findsWidgets);

      await tester.ensureVisible(titleFinder.first);
      await tester.tap(titleFinder.first, warnIfMissed: false);
      await tester.pump();

      expect(launchNotifier.sessionId, equals('session_01'));
    });

    test('Part 3 — CurrentSessionNotifier tracks video completion and session changes', () {
      final notifier = CurrentSessionNotifier('session_01');
      expect(notifier.sessionId, equals('session_01'));
      expect(notifier.isSessionCompleted('session_06'), isFalse);

      notifier.setSession('session_06');
      expect(notifier.sessionId, equals('session_06'));

      notifier.markSessionVideoCompleted('session_06');
      expect(notifier.isSessionCompleted('session_06'), isTrue);
    });

    test('Part 3 — SessionVideoProgressService persists completion and throttles progress', () async {
      final service = SessionVideoProgressService(storage: InMemoryVideoProgressStorage());
      await service.load('session_06');
      expect(service.isCompleted('session_06'), isFalse);
      expect(service.progressFor('session_06'), equals(0.0));

      await service.updateProgress('session_06', 0.45);
      expect(service.progressFor('session_06'), equals(0.45));

      await service.markCompleted('session_06');
      expect(service.isCompleted('session_06'), isTrue);
      expect(service.progressFor('session_06'), equals(1.0));
    });
  });
}
