import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_video_progress_service.dart';

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
/// Validates level unlock status before launching if progress service is available.
void launchSessionJournal(BuildContext context, String sessionId, {bool enforceLock = true}) {
  try {
    if (enforceLock) {
      final progressService =
          Provider.of<SessionVideoProgressService?>(context, listen: false);
      final levelNum =
          int.tryParse(sessionId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      if (progressService != null && !progressService.isLevelUnlocked(levelNum)) {
        final msg = progressService.getLockedLevelMessage(levelNum);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF1B3D6D),
          ),
        );
        return;
      }
    }
    Provider.of<JournalLaunchNotifier>(context, listen: false).open(sessionId);
  } catch (_) {
    try {
      Provider.of<JournalLaunchNotifier>(context, listen: false).open(sessionId);
    } catch (_) {}
  }
}
