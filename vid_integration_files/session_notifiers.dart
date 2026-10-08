import 'package:flutter/foundation.dart';

/// Tracks which DPP session the Manuscript/Journal tab should currently
/// display.
///
/// This exists because `ManuscriptScreen` lives inside `MainShell`'s
/// `IndexedStack` as a single long-lived instance (built once, in
/// `main.dart`'s `_screens` const list) rather than being pushed fresh
/// per session. A constructor parameter would freeze it at whatever
/// session was active the first time the tab was built. Instead, any
/// screen that wants to open a specific session's manuscript calls
/// `context.read<CurrentSessionNotifier>().setSession('session_06')`
/// and then switches to the Journal tab; `ManuscriptScreen` watches this
/// notifier and rebuilds with the right session.
class CurrentSessionNotifier extends ChangeNotifier {
  CurrentSessionNotifier([this._sessionId = 'session_01']);

  String _sessionId;
  String get sessionId => _sessionId;

  void setSession(String sessionId) {
    if (_sessionId == sessionId) return;
    _sessionId = sessionId;
    notifyListeners();
  }
}
