// lib/providers/journal_launcher.dart  (NEW)
//
// Single entry point for "open the journal on session X".
// Every place that should open a session's journal (journey-map level nodes,
// SessionsScreen "Watch Video", etc.) calls launchSessionJournal(...) and then
// switches to the Manuscript tab. ManuscriptScreen listens to this notifier,
// swaps to that session's video and opens the book automatically.
//
// requestId increments on EVERY call, so tapping the same level twice still
// re-opens the journal.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class JournalLaunchNotifier extends ChangeNotifier {
  String? _sessionId;
  int _requestId = 0;

  String? get sessionId => _sessionId;
  int get requestId => _requestId;

  void open(String sessionId) {
    _sessionId = sessionId;
    _requestId++;
    notifyListeners();
  }
}

/// Level 1 -> 'session_01', level 16 -> 'session_16'.
String sessionIdForLevel(int level) =>
    'session_${level.toString().padLeft(2, '0')}';

/// Call from a tap handler. Does NOT switch tabs (the caller already knows how
/// to do that, e.g. `MainShell.of(context)?.selectedIndex = 1`).
void launchSessionJournal(BuildContext context, String sessionId) {
  try {
    Provider.of<JournalLaunchNotifier>(context, listen: false).open(sessionId);
  } catch (_) {}
}
