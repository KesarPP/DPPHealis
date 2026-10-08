import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin storage abstraction so the service can be unit-tested without
/// touching the real SharedPreferences plugin (which needs platform
/// channels). Swap [SharedPreferencesVideoStorage] for another
/// implementation if the project later moves to Hive/SQLite/Firebase —
/// nothing outside this file needs to change.
abstract class VideoProgressStorage {
  Future<bool?> getBool(String key);
  Future<double?> getDouble(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setDouble(String key, double value);
}

class SharedPreferencesVideoStorage implements VideoProgressStorage {
  @override
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
}

/// In-memory implementation, useful for widget/unit tests.
class InMemoryVideoProgressStorage implements VideoProgressStorage {
  final Map<String, Object> _store = {};

  @override
  Future<bool?> getBool(String key) async => _store[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _store[key] as double?;

  @override
  Future<void> setBool(String key, bool value) async => _store[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _store[key] = value;
}

/// Persists and exposes video completion/progress state per session.
///
/// Keys follow the pattern requested in the spec:
///   session_01_video_completed = true
///   session_01_video_progress  = 0.73
///
/// This is a [ChangeNotifier] so the existing session UI can either listen
/// to it directly (e.g. via `ListenableBuilder`/`AnimatedBuilder`) or a
/// wrapping Provider/Riverpod/Bloc layer can forward its notifications —
/// whichever state-management approach the rest of HEALIS already uses.
class SessionVideoProgressService extends ChangeNotifier {
  SessionVideoProgressService({VideoProgressStorage? storage})
      : _storage = storage ?? SharedPreferencesVideoStorage();

  final VideoProgressStorage _storage;

  final Map<String, bool> _completed = {};
  final Map<String, double> _progress = {};

  String _completedKey(String sessionId) => '${sessionId}_video_completed';
  String _progressKey(String sessionId) => '${sessionId}_video_progress';

  bool isCompleted(String sessionId) => _completed[sessionId] ?? false;

  /// Progress in the 0.0–1.0 range.
  double progressFor(String sessionId) => _progress[sessionId] ?? 0.0;

  /// Loads persisted state for a session into memory. Call this when a
  /// session video screen opens, before relying on [isCompleted] /
  /// [progressFor].
  Future<void> load(String sessionId) async {
    final completed = await _storage.getBool(_completedKey(sessionId));
    final progress = await _storage.getDouble(_progressKey(sessionId));
    _completed[sessionId] = completed ?? false;
    _progress[sessionId] = progress ?? 0.0;
    notifyListeners();
  }

  /// Updates progress for a session (0.0–1.0) and persists it. Cheap to
  /// call frequently — call this from the player's onProgressChanged.
  Future<void> updateProgress(String sessionId, double progress) async {
    final clamped = progress.clamp(0.0, 1.0);
    // Avoid redundant writes/notifications for tiny fluctuations.
    if ((_progress[sessionId] ?? -1) == clamped) return;
    _progress[sessionId] = clamped;
    await _storage.setDouble(_progressKey(sessionId), clamped);
    notifyListeners();
  }

  /// Marks a session's video as completed and persists it. Idempotent —
  /// safe to call more than once, but the caller (the player widget) is
  /// still responsible for only firing its completion callback once per
  /// viewing session.
  Future<void> markCompleted(String sessionId) async {
    if (_completed[sessionId] == true) return;
    _completed[sessionId] = true;
    _progress[sessionId] = 1.0;
    await _storage.setBool(_completedKey(sessionId), true);
    await _storage.setDouble(_progressKey(sessionId), 1.0);
    notifyListeners();
  }

  /// For testing/dev tools only — clears a session's stored state.
  Future<void> reset(String sessionId) async {
    _completed[sessionId] = false;
    _progress[sessionId] = 0.0;
    await _storage.setBool(_completedKey(sessionId), false);
    await _storage.setDouble(_progressKey(sessionId), 0.0);
    notifyListeners();
  }
}
