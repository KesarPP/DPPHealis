import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dpp_app/screens/puzzles_journey_screen.dart';
import 'package:dpp_app/providers/food_notifiers.dart';
import 'package:dpp_app/services/session_video_progress_service.dart';
import 'package:dpp_app/providers/journal_launcher.dart';

void main() {
  testWidgets('PuzzlesJourneyScreen render test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FoodDiaryNotifier()),
          ChangeNotifierProvider(create: (_) => SessionVideoProgressService()),
          ChangeNotifierProvider(create: (_) => JournalLaunchNotifier()),
        ],
        child: const MaterialApp(
          home: PuzzlesJourneyScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(PuzzlesJourneyScreen), findsOneWidget);
  });
}
