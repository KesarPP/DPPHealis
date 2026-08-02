import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      
      // Store history in users/{uid}/points_history/{action_referenceId}
      final String docId = '${action}_$referenceId';
      final historyRef = _db.collection('users').doc(uid).collection('points_history').doc(docId);
      final userRef = _db.collection('users').doc(uid);

      await _db.runTransaction((transaction) async {
        final historyDoc = await transaction.get(historyRef);
        
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
        } else {
          debugPrint('Points already awarded for $docId');
        }
      });
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }
}
