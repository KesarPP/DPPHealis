import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the current ISO-8601 week key (e.g. "2026_W47").
  static String getCurrentWeekKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    // ISO-8601: find nearest Thursday
    final thursday = d.add(Duration(days: (4 - d.weekday)));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final dayDiff = thursday.difference(firstDayOfYear).inDays;
    final weekNumber = (dayDiff / 7).floor() + 1;
    return '${thursday.year}_W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Ensures a user has an entry in /leaderboard projection.
  /// Also performs automatic weekly points rollover if a new week has started
  /// and syncs lifetime points from users/{uid} if missing.
  static Future<void> ensureLeaderboardEntry(String uid, String name) async {
    try {
      final docRef = _db.collection('leaderboard').doc(uid);
      final doc = await docRef.get();
      final currentWeek = getCurrentWeekKey();

      // Read current points from users collection to avoid starting at 0 if points exist
      int existingTotalPoints = 0;
      try {
        final userDoc = await _db.collection('users').doc(uid).get();
        if (userDoc.exists) {
          existingTotalPoints = (userDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}

      if (!doc.exists) {
        await docRef.set({
          'name': name.trim().isNotEmpty ? name.trim() : 'User',
          'totalPoints': existingTotalPoints,
          'weeklyPoints': 0,
          'weekKey': currentWeek,
          'badgesCount': (existingTotalPoints / 100).floor(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data();
        final storedWeekKey = data?['weekKey'] as String?;
        final updateData = <String, dynamic>{
          'name': name.trim().isNotEmpty ? name.trim() : 'User',
        };

        // If calendar week has rolled over, reset weeklyPoints to 0
        if (storedWeekKey != currentWeek) {
          updateData['weeklyPoints'] = 0;
          updateData['weekKey'] = currentWeek;
        }

        if (existingTotalPoints > 0) {
          updateData['totalPoints'] = existingTotalPoints;
          updateData['badgesCount'] = (existingTotalPoints / 100).floor();
        }

        await docRef.set(updateData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error ensuring leaderboard entry: $e');
    }
  }

  /// Updates the displayed name in the leaderboard projection.
  static Future<void> updateLeaderboardName(String uid, String newName) async {
    try {
      if (newName.trim().isEmpty) return;
      await _db.collection('leaderboard').doc(uid).set({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating leaderboard name: $e');
    }
  }

  /// Award points for a specific action.
  /// 
  /// [action]: The category of action (e.g., 'food_logged', 'activity_met').
  /// [points]: Number of points to award.
  /// [referenceId]: A unique identifier to prevent duplicate points for the same action (e.g., date, week number, or food item ID).
  static Future<void> awardPoints({
    required String action,
    required int points,
    required String referenceId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[PointsService] Cannot award points: No logged in user.');
        return;
      }
      
      final String uid = user.uid;
      final currentWeekKey = getCurrentWeekKey();
      
      // Store history in users/{uid}/points_history/{action_referenceId}
      final String docId = '${action}_$referenceId';
      final historyRef = _db.collection('users').doc(uid).collection('points_history').doc(docId);
      final userRef = _db.collection('users').doc(uid);
      final leaderboardRef = _db.collection('leaderboard').doc(uid);

      // 1. Check history to prevent duplicate points
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        debugPrint('[PointsService] Points already awarded for $docId');
        return;
      }

      // 2. Record points history
      await historyRef.set({
        'action': action,
        'points': points,
        'referenceId': referenceId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Increment user total points
      await userRef.set({
        'totalPoints': FieldValue.increment(points),
      }, SetOptions(merge: true));

      // 4. Read latest user profile and leaderboard status
      final userDoc = await userRef.get();
      final currentPoints = (userDoc.data()?['totalPoints'] as num? ?? points).toInt();
      final userName = (userDoc.data()?['name'] as String?) ?? user.displayName ?? 'User';

      final leaderboardDoc = await leaderboardRef.get();
      final storedWeekKey = leaderboardDoc.data()?['weekKey'] as String?;
      final storedWeeklyPoints = (leaderboardDoc.data()?['weeklyPoints'] as num? ?? 0).toInt();

      int newWeeklyPoints;
      if (storedWeekKey == currentWeekKey) {
        newWeeklyPoints = storedWeeklyPoints + points;
      } else {
        // New week: start fresh with this action's points
        newWeeklyPoints = points;
      }

      final badgesCount = (currentPoints / 100).floor();

      // 5. Update /leaderboard/{uid}
      await leaderboardRef.set({
        'name': userName,
        'totalPoints': currentPoints,
        'weeklyPoints': newWeeklyPoints,
        'weekKey': currentWeekKey,
        'badgesCount': badgesCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[PointsService] Successfully awarded $points points to $userName ($uid)! Total: $currentPoints, Weekly: $newWeeklyPoints');
    } catch (e) {
      debugPrint('[PointsService] Error awarding points: $e');
    }
  }
}
