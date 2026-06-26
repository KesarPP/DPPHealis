import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ndpp_constants.dart';
import 'activity_metrics_engine.dart';
import 'auth_service.dart';

class AchievementsService {
  static const String _earnedPrefsKey = 'ndpp_permanent_earned_achievements';
  static const String _mealCountCacheKey = 'ndpp_cached_meal_log_count';

  /// Evaluates achievements nightly or on trigger, permanently persisting earned status
  static Future<List<Achievement>> evaluateAndSync({
    required List<DailyAggregate> trailing30Days,
    required int programWeek,
    BuildContext? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService();
    final uid = authService.isFirebaseInitialized ? authService.currentUser?.uid : null;

    // 1. Load permanent earned achievements map (id -> DateTime ISO)
    Map<String, DateTime> earnedMap = {};
    final String? earnedJson = prefs.getString('${_earnedPrefsKey}_$uid');
    if (earnedJson != null) {
      try {
        final decoded = json.decode(earnedJson) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          earnedMap[key] = DateTime.parse(val as String);
        });
      } catch (_) {}
    }

    // 2. Fetch Meal Log Count (local cache + Firestore fallback)
    int mealLogCount = prefs.getInt('${_mealCountCacheKey}_$uid') ?? 0;
    if (uid != null) {
      try {
        final countQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('food_logs')
            .count()
            .get();
        final int fetchedCount = countQuery.count ?? mealLogCount;
        if (fetchedCount > mealLogCount) {
          mealLogCount = fetchedCount;
          await prefs.setInt('${_mealCountCacheKey}_$uid', mealLogCount);
        }
      } catch (_) {}
    }

    // 3. Fetch Baseline & Current Weight
    double baselineWeight = 90.0;
    double currentWeight = 84.0;
    if (uid != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('weight_history')
            .orderBy('date', descending: false)
            .get();
        if (snap.docs.isNotEmpty) {
          baselineWeight = (snap.docs.first.data()['weight'] as num?)?.toDouble() ?? 90.0;
          currentWeight = (snap.docs.last.data()['weight'] as num?)?.toDouble() ?? 84.0;
        }
      } catch (_) {}
    }

    // 4. Evaluate across engine
    final achievements = ActivityMetricsEngine.evaluateAchievements(
      pastDays: trailing30Days,
      mealLogCount: mealLogCount,
      baselineWeight: baselineWeight,
      currentWeight: currentWeight,
      riskScore: 28.0, // Standalone questionnaire risk score fallback
      programWeek: programWeek,
      earnedMap: earnedMap,
    );

    // 5. Detect newly earned badges
    bool mapChanged = false;
    List<String> newlyEarnedTitles = [];

    for (final a in achievements) {
      if (a.status == AchievementStatus.earned && !earnedMap.containsKey(a.id)) {
        earnedMap[a.id] = a.earnedDate ?? DateTime.now();
        mapChanged = true;
        newlyEarnedTitles.add(a.title);
      }
    }

    // 6. Permanently persist updated earned status
    if (mapChanged) {
      final toStore = {};
      earnedMap.forEach((k, v) => toStore[k] = v.toIso8601String());
      await prefs.setString('${_earnedPrefsKey}_$uid', json.encode(toStore));

      if (uid != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'earned_achievements': toStore,
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      // Trigger toast / notification
      if (context != null && context.mounted && newlyEarnedTitles.isNotEmpty) {
        _showUnlockToast(context, newlyEarnedTitles);
      }
    }

    return achievements;
  }

  static void _showUnlockToast(BuildContext context, List<String> titles) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.military_tech_rounded, color: Color(0xFFEAB308), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Achievement Unlocked!', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                  Text(titles.join(', '), style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
