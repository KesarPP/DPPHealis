import 'package:flutter/foundation.dart';

/// Tracks which DPP session the Manuscript/Journal tab should currently
/// display.
///
/// This exists so `ManuscriptScreen` can be used both as a persistent tab
/// in `MainShell` and as a directly pushed route (`ManuscriptScreen(sessionId: 'session_06')`).
class CurrentSessionNotifier extends ChangeNotifier {
  CurrentSessionNotifier([this._sessionId = 'session_01']);

  String _sessionId;
  String get sessionId => _sessionId;

  final Set<String> _completedSessions = {};
  Set<String> get completedSessions => Set.unmodifiable(_completedSessions);

  bool isSessionCompleted(String sessionId) => _completedSessions.contains(sessionId);

  void setSession(String sessionId) {
    if (_sessionId == sessionId) return;
    _sessionId = sessionId;
    notifyListeners();
  }

  void markSessionVideoCompleted(String sessionId) {
    if (_completedSessions.add(sessionId)) {
      notifyListeners();
    }
  }
}
