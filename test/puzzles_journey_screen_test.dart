import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpp_app/screens/puzzles_journey_screen.dart';

void main() {
  testWidgets('PuzzlesJourneyScreen render test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    
    await tester.pumpWidget(
      const MaterialApp(
        home: PuzzlesJourneyScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
