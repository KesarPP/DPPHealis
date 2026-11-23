import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin storage abstraction so the service can be unit-tested without
/// touching the real SharedPreferences plugin (which needs platform channels).
abstract class VideoProgressStorage {
  Future<bool?> getBool(String key);
  Future<double?> getDouble(String key);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setDouble(String key, double value);
  Future<void> setString(String key, String value);
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
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
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

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
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
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async => _store[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _store[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _store[key] = value;
}

/// Distinct unlock states for the 16 DPP levels according to Section 8.
enum LevelUnlockStatus {
  /// State D: Both Condition A (video completed) and Condition B (7 days elapsed) are met.
  unlocked,

  /// State A: Previous video is incomplete AND 7-day weekly waiting period has not elapsed.
  videoIncompleteAndTimeRemaining,

  /// State B: Previous video is completed, BUT 7-day waiting period has not elapsed yet.
  videoCompletedAndTimeRemaining,

  /// State C: 7-day waiting period has elapsed, BUT previous video is incomplete.
  videoIncompleteAndTimeElapsed,
}

/// Authoritative centralized progression and video progress service for HEALIS DPP.
///
/// Implements dual-condition sequential level unlocking across all 16 levels:
///   - Level 1: Unlocked by default when the DPP program begins.
///   - Level N (2..16): Requires BOTH:
///       Condition A: Previous level's video is genuinely completed.
///       Condition B: At least 7 complete days (168 hours) have elapsed since Level N-1 unlocked.
///
/// Timestamps are recorded in UTC and persisted across app restarts.
class SessionVideoProgressService extends ChangeNotifier {
  SessionVideoProgressService({VideoProgressStorage? storage, DateTime? initialTime})
      : _storage = storage ?? SharedPreferencesVideoStorage() {
    loadAll(null, initialTime);
  }

  final VideoProgressStorage _storage;

  final Map<String, bool> _completed = {};
  final Map<String, double> _progress = {};
  final Map<String, String> _coverage = {};
  final Map<int, DateTime> _unlockTimestamps = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  String _completedKey(String sessionId) => '${sessionId}_video_completed';
  String _progressKey(String sessionId) => '${sessionId}_video_progress';
  String _coverageKey(String sessionId) => '${sessionId}_video_coverage';
  String _unlockKey(int level) => 'level_${level.toString().padLeft(2, '0')}_unlocked_at';

  bool isCompleted(String sessionId) => _completed[sessionId] ?? false;

  /// Progress in the 0.0–1.0 range.
  double progressFor(String sessionId) => _progress[sessionId] ?? 0.0;

  String? coverageFor(String sessionId) => _coverage[sessionId];

  /// Loads persisted state for a single session into memory.
  Future<void> load(String sessionId, [DateTime? now]) async {
    final completed = await _storage.getBool(_completedKey(sessionId));
    final progress = await _storage.getDouble(_progressKey(sessionId));
    final coverage = await _storage.getString(_coverageKey(sessionId));
    _completed[sessionId] = completed ?? false;
    _progress[sessionId] = progress ?? 0.0;
    if (coverage != null) _coverage[sessionId] = coverage;

    await _evaluateAndRecordEligibleUnlocks(now);
    notifyListeners();
  }

  /// Pre-loads all 16 core DPP sessions and level unlock timestamps into memory.
  Future<void> loadAll([List<String>? sessionIds, DateTime? now]) async {
    final ids = sessionIds ??
        List.generate(16, (i) => 'session_${(i + 1).toString().padLeft(2, '0')}');

    for (final id in ids) {
      final completed = await _storage.getBool(_completedKey(id));
      final progress = await _storage.getDouble(_progressKey(id));
      final coverage = await _storage.getString(_coverageKey(id));
      _completed[id] = completed ?? false;
      _progress[id] = progress ?? 0.0;
      if (coverage != null) _coverage[id] = coverage;
    }

    // Load persisted unlock timestamps for all 16 levels
    for (var i = 1; i <= 16; i++) {
      var raw = await _storage.getString(_unlockKey(i));
      raw ??= await _storage.getString('level_${i}_unlocked_at');
      if (raw != null && raw.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(raw.trim());
        if (parsed != null) {
          _unlockTimestamps[i] = parsed.toUtc();
        }
      }
    }

    // Level 1 is always unlocked by default at program start
    if (_unlockTimestamps[1] == null) {
      final start = (now ?? DateTime.now()).toUtc();
      _unlockTimestamps[1] = start;
      await _storage.setString(_unlockKey(1), start.toIso8601String());
    }

    await _evaluateAndRecordEligibleUnlocks(now);
    _isLoaded = true;
    notifyListeners();
  }

  /// Updates progress for a session (0.0–1.0) and persists it.
  /// Throttled: ignores changes smaller than 0.02 to avoid excessive storage writes.
  Future<void> updateProgress(String sessionId, double progress) async {
    final clamped = progress.clamp(0.0, 1.0);
    final current = _progress[sessionId] ?? -1.0;

    // Minimum 2% delta threshold or reaching 1.0 to avoid disk churn
    if ((clamped - current).abs() < 0.02 && clamped < 1.0) return;

    _progress[sessionId] = clamped;
    await _storage.setDouble(_progressKey(sessionId), clamped);
    notifyListeners();
  }

  /// Persists serialized watch coverage intervals.
  Future<void> saveCoverage(String sessionId, String serializedCoverage) async {
    _coverage[sessionId] = serializedCoverage;
    await _storage.setString(_coverageKey(sessionId), serializedCoverage);
  }

  /// Marks a session's video as completed automatically and re-evaluates level progression.
  Future<void> markCompleted(String sessionId, [DateTime? now]) async {
    final wasAlreadyCompleted = _completed[sessionId] == true;
    if (!wasAlreadyCompleted) {
      _completed[sessionId] = true;
      _progress[sessionId] = 1.0;
      await _storage.setBool(_completedKey(sessionId), true);
      await _storage.setDouble(_progressKey(sessionId), 1.0);
    }

    // Re-evaluate eligibility for subsequent levels
    await _evaluateAndRecordEligibleUnlocks(now);
    notifyListeners();
  }

  /// Internal evaluator that unlocks eligible levels sequentially.
  /// A level N (2..16) unlocks at the earliest instant BOTH Condition A and B are satisfied.
  Future<void> _evaluateAndRecordEligibleUnlocks([DateTime? now]) async {
    final current = (now ?? DateTime.now()).toUtc();

    if (_unlockTimestamps[1] == null) {
      _unlockTimestamps[1] = current;
      await _storage.setString(_unlockKey(1), current.toIso8601String());
    }

    for (var k = 2; k <= 16; k++) {
      if (_unlockTimestamps[k] != null) continue;

      // Sequential guarantee: previous level must be unlocked
      if (_unlockTimestamps[k - 1] == null) break;

      final prevSessionId = 'session_${(k - 1).toString().padLeft(2, '0')}';
      final videoDone = isCompleted(prevSessionId);
      final prevUnlock = _unlockTimestamps[k - 1]!;
      final minEligibleTime = prevUnlock.add(const Duration(days: 7));
      final timeElapsed = !current.difference(prevUnlock).isNegative &&
          current.isAfter(minEligibleTime) || current.isAtSameMomentAs(minEligibleTime);

      if (videoDone && timeElapsed) {
        // Unlocked! Unlock timestamp is the moment both conditions became satisfied
        final unlockTime = current.isAfter(minEligibleTime) ? current : minEligibleTime;
        _unlockTimestamps[k] = unlockTime;
        await _storage.setString(_unlockKey(k), unlockTime.toIso8601String());
      } else {
        // Because progression is strictly sequential, stop checking higher levels
        break;
      }
    }
  }

  /// Explicitly triggers re-evaluation of progression (e.g. on resume or clock trigger).
  Future<void> checkProgression([DateTime? now]) async {
    await _evaluateAndRecordEligibleUnlocks(now);
    notifyListeners();
  }

  // ─── DUAL-CONDITION SEQUENTIAL LEVEL UNLOCKING ────────────────────────────

  /// Returns the authoritative unlock timestamp for [level] in UTC, if unlocked.
  DateTime? getLevelUnlockTimestamp(int level) => _unlockTimestamps[level];

  /// Manually records authoritative unlock timestamp for [level] (useful in tests/admin).
  Future<void> recordLevelUnlock(int level, [DateTime? timestamp]) async {
    final ts = (timestamp ?? DateTime.now()).toUtc();
    _unlockTimestamps[level] = ts;
    await _storage.setString(_unlockKey(level), ts.toIso8601String());
    notifyListeners();
  }

  /// Authoritative check if [level] is accessible.
  /// Level 1 is always unlocked.
  /// Level N (2..16) is unlocked iff:
  ///   1. Level N-1 is unlocked.
  ///   2. Level N-1's video is completed (Condition A).
  ///   3. At least 7 complete days have elapsed since Level N-1 unlocked (Condition B).
  bool isLevelUnlocked(int level, [DateTime? now]) {
    if (level <= 1) return true;
    if (level > 16) return false;

    // Already recorded unlock timestamp
    if (_unlockTimestamps[level] != null) return true;

    // Strict sequential rule: previous level must be unlocked
    if (!isLevelUnlocked(level - 1, now)) return false;

    return getLevelUnlockStatus(level, now) == LevelUnlockStatus.unlocked;
  }

  /// Whether the next level following [previousLevel] can be unlocked.
  bool canUnlockNextLevel(int previousLevel, [DateTime? now]) {
    return isLevelUnlocked(previousLevel + 1, now);
  }

  /// Returns the exact moment when the 7-day waiting period for [level] completes.
  /// Exactly 7 complete days (168 hours) after Level N-1 unlocked.
  DateTime? getNextUnlockEligibilityTime(int level) {
    if (level <= 1) return getLevelUnlockTimestamp(1);
    final prevUnlock = getLevelUnlockTimestamp(level - 1);
    if (prevUnlock == null) return null;
    return prevUnlock.add(const Duration(days: 7));
  }

  /// Duration remaining until the 7-day period expires for [level].
  /// Returns Duration.zero if 7 days have already elapsed.
  Duration getRemainingUnlockDuration(int level, [DateTime? now]) {
    if (level <= 1) return Duration.zero;
    final target = getNextUnlockEligibilityTime(level);
    if (target == null) return const Duration(days: 7);
    final current = (now ?? DateTime.now()).toUtc();
    final diff = target.difference(current);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Returns the unlock status for [level] among the 4 states (Section 8).
  LevelUnlockStatus getLevelUnlockStatus(int level, [DateTime? now]) {
    if (level <= 1) return LevelUnlockStatus.unlocked;
    if (_unlockTimestamps[level] != null) return LevelUnlockStatus.unlocked;

    final prevLevel = level - 1;
    // Sequential prerequisite: previous level must be unlocked
    if (!isLevelUnlocked(prevLevel, now)) {
      return LevelUnlockStatus.videoIncompleteAndTimeRemaining;
    }

    final prevSessionId = 'session_${prevLevel.toString().padLeft(2, '0')}';
    final isVideoCompleted = isCompleted(prevSessionId);

    final prevUnlock = getLevelUnlockTimestamp(prevLevel);
    final current = (now ?? DateTime.now()).toUtc();
    final bool isTimeElapsed;
    if (prevUnlock == null) {
      isTimeElapsed = false;
    } else {
      final elapsed = current.difference(prevUnlock);
      isTimeElapsed = !elapsed.isNegative && elapsed >= const Duration(days: 7);
    }

    if (isVideoCompleted && isTimeElapsed) {
      return LevelUnlockStatus.unlocked;
    } else if (isVideoCompleted && !isTimeElapsed) {
      return LevelUnlockStatus.videoCompletedAndTimeRemaining;
    } else if (!isVideoCompleted && isTimeElapsed) {
      return LevelUnlockStatus.videoIncompleteAndTimeElapsed;
    } else {
      return LevelUnlockStatus.videoIncompleteAndTimeRemaining;
    }
  }

  /// User-friendly message explaining why [level] is locked.
  String getLockedLevelMessage(int level, [DateTime? now]) {
    final status = getLevelUnlockStatus(level, now);
    switch (status) {
      case LevelUnlockStatus.unlocked:
        return 'Unlocked';
      case LevelUnlockStatus.videoCompletedAndTimeRemaining:
        final rem = getRemainingUnlockDuration(level, now);
        final days = rem.inDays;
        final hours = rem.inHours % 24;
        if (days > 0) {
          final s = days == 1 ? '' : 's';
          return 'Video completed! Your next level unlocks in $days day$s.';
        } else if (hours > 0) {
          final s = hours == 1 ? '' : 's';
          return 'Video completed! Your next level unlocks in $hours hour$s.';
        } else {
          final mins = rem.inMinutes.clamp(1, 60);
          final s = mins == 1 ? '' : 's';
          return 'Video completed! Your next level unlocks in $mins minute$s.';
        }
      case LevelUnlockStatus.videoIncompleteAndTimeElapsed:
        return 'Complete the previous session video to unlock your next level.';
      case LevelUnlockStatus.videoIncompleteAndTimeRemaining:
        return 'Complete the previous session video. Your next level will unlock after the weekly waiting period.';
    }
  }

  /// Returns true if the session corresponding to [level] has been completed.
  bool isLevelCompleted(int level) {
    final sessionId = 'session_${level.toString().padLeft(2, '0')}';
    return isCompleted(sessionId);
  }

  /// Returns the current active session (the highest unlocked session that is incomplete,
  /// or the highest unlocked session).
  String get currentActiveSessionId {
    String lastUnlocked = 'session_01';
    for (var i = 1; i <= 16; i++) {
      if (isLevelUnlocked(i)) {
        lastUnlocked = 'session_${i.toString().padLeft(2, '0')}';
        if (!isCompleted(lastUnlocked)) {
          return lastUnlocked;
        }
      } else {
        break;
      }
    }
    return lastUnlocked;
  }

  /// For testing/dev tools only — clears a session's stored state.
  Future<void> reset(String sessionId) async {
    _completed[sessionId] = false;
    _progress[sessionId] = 0.0;
    _coverage.remove(sessionId);
    await _storage.setBool(_completedKey(sessionId), false);
    await _storage.setDouble(_progressKey(sessionId), 0.0);
    await _storage.setString(_coverageKey(sessionId), '');

    final levelNum = int.tryParse(sessionId.replaceAll(RegExp(r'[^0-9]'), ''));
    if (levelNum != null && levelNum > 1) {
      _unlockTimestamps.remove(levelNum);
      await _storage.setString(_unlockKey(levelNum), '');
    }
    notifyListeners();
  }

  /// Resets all progression state for development or testing.
  Future<void> resetAll([DateTime? now]) async {
    _completed.clear();
    _progress.clear();
    _coverage.clear();
    _unlockTimestamps.clear();

    for (var i = 1; i <= 16; i++) {
      final id = 'session_${i.toString().padLeft(2, '0')}';
      await _storage.setBool(_completedKey(id), false);
      await _storage.setDouble(_progressKey(id), 0.0);
      await _storage.setString(_coverageKey(id), '');
      await _storage.setString(_unlockKey(i), '');
      await _storage.setString('level_${i}_unlocked_at', '');
    }

    final start = (now ?? DateTime.now()).toUtc();
    _unlockTimestamps[1] = start;
    await _storage.setString(_unlockKey(1), start.toIso8601String());
    notifyListeners();
  }
}
