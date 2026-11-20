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
  /// Also performs automatic weekly points rollover if a new week has started.
  static Future<void> ensureLeaderboardEntry(String uid, String name) async {
    try {
      final docRef = _db.collection('leaderboard').doc(uid);
      final doc = await docRef.get();
      final currentWeek = getCurrentWeekKey();

      if (!doc.exists) {
        await docRef.set({
          'name': name.trim().isNotEmpty ? name.trim() : 'User',
          'totalPoints': 0,
          'weeklyPoints': 0,
          'weekKey': currentWeek,
          'badgesCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data();
        final storedWeekKey = data?['weekKey'] as String?;
        // If calendar week has rolled over, reset weeklyPoints to 0
        if (storedWeekKey != currentWeek) {
          await docRef.set({
            'weeklyPoints': 0,
            'weekKey': currentWeek,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
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
      if (user == null) return;
      
      final String uid = user.uid;
      final currentWeekKey = getCurrentWeekKey();
      
      // Store history in users/{uid}/points_history/{action_referenceId}
      final String docId = '${action}_$referenceId';
      final historyRef = _db.collection('users').doc(uid).collection('points_history').doc(docId);
      final userRef = _db.collection('users').doc(uid);
      final leaderboardRef = _db.collection('leaderboard').doc(uid);

      await _db.runTransaction((transaction) async {
        final historyDoc = await transaction.get(historyRef);
        final userDoc = await transaction.get(userRef);
        final leaderboardDoc = await transaction.get(leaderboardRef);
        
        if (!historyDoc.exists) {
          // Add to history to prevent duplicates
          transaction.set(historyRef, {
            'action': action,
            'points': points,
            'referenceId': referenceId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          // Increment user total points
          transaction.set(userRef, {
            'totalPoints': FieldValue.increment(points),
          }, SetOptions(merge: true));

          final currentPoints = (userDoc.data()?['totalPoints'] as num? ?? 0).toInt();
          final newTotalPoints = currentPoints + points;
          final userName = (userDoc.data()?['name'] as String?) ?? user.displayName ?? 'User';

          // Determine weekly points with week rollover
          final storedWeekKey = leaderboardDoc.data()?['weekKey'] as String?;
          final storedWeeklyPoints = (leaderboardDoc.data()?['weeklyPoints'] as num? ?? 0).toInt();

          int newWeeklyPoints;
          if (storedWeekKey == currentWeekKey) {
            newWeeklyPoints = storedWeeklyPoints + points;
          } else {
            // New week: start fresh with this action's points
            newWeeklyPoints = points;
          }

          final badgesCount = (newTotalPoints / 100).floor();

          // Sync projection to /leaderboard/{uid}
          transaction.set(leaderboardRef, {
            'name': userName,
            'totalPoints': newTotalPoints,
            'weeklyPoints': newWeeklyPoints,
            'weekKey': currentWeekKey,
            'badgesCount': badgesCount,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          debugPrint('Points already awarded for $docId');
        }
      });
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }
}
