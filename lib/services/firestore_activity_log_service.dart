import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/activity_log.dart';
import 'activity_log_service.dart';

class FirestoreActivityLogService
    implements ActivityLogService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  @override
  Future<List<ActivityLog>> getTodayActivityLogs() async {
    @override
    Future<List<ActivityLog>> getTodayActivityLogs() async {
      final user = _auth.currentUser;

      if (user == null) {
        return [];
      }

      final now = DateTime.now();

      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final startOfTomorrow = startOfDay.add(
        const Duration(days: 1),
      );

      final snapshot = await _firestore
          .collection('logs')
          .doc(user.uid)
          .collection('activity_entries')
          .where(
        'createdAt',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(startOfDay),
      )
          .where(
        'createdAt',
        isLessThan:
        Timestamp.fromDate(startOfTomorrow),
      )
          .orderBy(
        'createdAt',
        descending: true,
      )
          .get();

      return snapshot.docs.map((doc) {
        return ActivityLog.fromFirestore(
          id: doc.id,
          data: doc.data(),
        );
      }).toList();
    }
  }
}