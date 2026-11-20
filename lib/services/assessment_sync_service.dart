import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Service responsible for storing comprehensive IDRS & GPAQ assessment
/// responses in Firestore and syncing them in real-time to a Master Google Sheet.
class AssessmentSyncService {
  /// Default Google Apps Script Web App URL.
  static String defaultWebhookUrl =
      'https://script.google.com/macros/s/AKfycbwkaBhu1xjistf3DY_CucnJyDMhrweH6LeDK4X7lWg8ok8U4yD_sZvUnLudSJjJgjI_1g/exec';

  static Future<String?> _getWebhookUrl() async {
    if (defaultWebhookUrl.trim().isNotEmpty) {
      return defaultWebhookUrl.trim();
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('app_config').doc('integrations').get();
      if (doc.exists && doc.data() != null) {
        final url = doc.data()!['google_sheets_webhook'] as String?;
        if (url != null && url.trim().isNotEmpty) {
          return url.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Syncs full IDRS assessment response to Firestore and Google Sheets.
  static Future<void> syncIdrsResponse({
    required int age,
    required bool isMan,
    required double height,
    required double weight,
    required double waist,
    required double bmi,
    required int parentDiabetic, // 1: Yes, 2: No, 3: Don't Know
    required int siblingDiabetic, // 1: Yes, 2: No, 3: Don't Know
    required int hasHighBP, // 1: Yes, 2: No
    required int prescribedBPMedication, // 1: Yes, 2: No, 0: N/A
    required int exerciseLevel, // 1: Regular, 2: Mild/occasional, 3: No exercise
    required int idrsScore,
    required String riskLevel,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    String name = user?.displayName ?? '';
    String email = user?.email ?? '';
    String phone = user?.phoneNumber ?? '';

    // Try to fetch additional profile details from Firestore if missing from Auth
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        if (name.isEmpty) name = data['name'] ?? '';
        if (email.isEmpty) email = data['email'] ?? '';
        if (phone.isEmpty) phone = data['phoneNumber'] ?? data['phone'] ?? '';
      }
    } catch (_) {}

    final now = DateTime.now();
    final timestampStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final parentDiabeticText = parentDiabetic == 1
        ? 'Yes'
        : parentDiabetic == 2
            ? 'No'
            : "Don't Know";
    final siblingDiabeticText = siblingDiabetic == 1
        ? 'Yes'
        : siblingDiabetic == 2
            ? 'No'
            : "Don't Know";
    final highBPText = hasHighBP == 1 ? 'Yes' : 'No';
    final bpMedText = prescribedBPMedication == 1
        ? 'Yes'
        : prescribedBPMedication == 2
            ? 'No'
            : 'N/A';
    final exerciseLevelText = exerciseLevel == 1
        ? 'Regular vigorous exercise'
        : exerciseLevel == 2
            ? 'Mild/occasional exercise'
            : 'No exercise / Sedentary';

    final idrsData = {
      'type': 'IDRS',
      'timestamp': timestampStr,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': isMan ? 'Male' : 'Female',
      'height': height.toStringAsFixed(1),
      'weight': weight.toStringAsFixed(1),
      'bmi': bmi.toStringAsFixed(1),
      'waist': waist.toStringAsFixed(1),
      'parentDiabetic': parentDiabeticText,
      'siblingDiabetic': siblingDiabeticText,
      'hasHighBP': highBPText,
      'prescribedBPMedication': bpMedText,
      'exerciseLevel': exerciseLevelText,
      'idrsScore': idrsScore,
      'riskLevel': riskLevel,
    };

    // 1. Post to Google Sheets Webhook FIRST (independent of Firestore)
    try {
      final webhookUrl = await _getWebhookUrl();
      if (webhookUrl != null && webhookUrl.isNotEmpty) {
        await _postToGoogleSheets(webhookUrl, idrsData);
      }
    } catch (sheetErr) {
      debugPrint('Google Sheets IDRS sync error: $sheetErr');
    }

    // 2. Save full data to Firestore user document & user subcollection (permitted by rules)
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'idrsDetails': idrsData,
          'idrsScore': idrsScore,
          'riskLevel': riskLevel,
          'hasIdrsResult': true,
          'waist': waist,
          'currentWeight': weight,
          'height': height,
          'age': age,
          'gender': isMan ? 'male' : 'female',
          'parentDiabetic': parentDiabeticText,
          'siblingDiabetic': siblingDiabeticText,
          'hasHighBP': highBPText,
          'prescribedBPMedication': bpMedText,
          'exerciseLevel': exerciseLevelText,
          'bmi': bmi,
          'lastIdrsDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Subcollection under user (always permitted)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('idrs_history')
            .doc('idrs_${now.millisecondsSinceEpoch}')
            .set(idrsData);
      } catch (userErr) {
        debugPrint('Firestore user doc IDRS save error: $userErr');
      }

      // 3. Optional global collection backup (isolated in case rules deny)
      try {
        final docId = '${userId}_${now.millisecondsSinceEpoch}';
        await FirebaseFirestore.instance.collection('idrs_responses').doc(docId).set({
          ...idrsData,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (globalErr) {
        debugPrint('Firestore idrs_responses global save warning (rules): $globalErr');
      }
    }
  }

  /// Syncs full GPAQ assessment response to Firestore and Google Sheets.
  static Future<void> syncGpaqResponse({
    required bool workVigorous,
    required int workVigorousDays,
    required int workVigorousMinutes,
    required bool workModerate,
    required int workModerateDays,
    required int workModerateMinutes,
    required bool travel,
    required int travelDays,
    required int travelMinutes,
    required bool recVigorous,
    required int recVigorousDays,
    required int recVigorousMinutes,
    required bool recModerate,
    required int recModerateDays,
    required int recModerateMinutes,
    required int sedentaryMinutes,
    required int workVigorousMet,
    required int workModerateMet,
    required int travelMet,
    required int recVigorousMet,
    required int recModerateMet,
    required int totalMetMinutes,
    required String activityLevel,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    String name = user?.displayName ?? '';
    String email = user?.email ?? '';
    String phone = user?.phoneNumber ?? '';

    // Try to fetch additional profile details from Firestore if missing from Auth
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        if (name.isEmpty) name = data['name'] ?? '';
        if (email.isEmpty) email = data['email'] ?? '';
        if (phone.isEmpty) phone = data['phoneNumber'] ?? data['phone'] ?? '';
      }
    } catch (_) {}

    final now = DateTime.now();
    final timestampStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final sedentaryHours = (sedentaryMinutes / 60.0).toStringAsFixed(1);

    final gpaqData = {
      'type': 'GPAQ',
      'timestamp': timestampStr,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'workVigorous': workVigorous,
      'workVigorousDays': workVigorous ? workVigorousDays : 0,
      'workVigorousMinutes': workVigorous ? workVigorousMinutes : 0,
      'workModerate': workModerate,
      'workModerateDays': workModerate ? workModerateDays : 0,
      'workModerateMinutes': workModerate ? workModerateMinutes : 0,
      'travel': travel,
      'travelDays': travel ? travelDays : 0,
      'travelMinutes': travel ? travelMinutes : 0,
      'recVigorous': recVigorous,
      'recVigorousDays': recVigorous ? recVigorousDays : 0,
      'recVigorousMinutes': recVigorous ? recVigorousMinutes : 0,
      'recModerate': recModerate,
      'recModerateDays': recModerate ? recModerateDays : 0,
      'recModerateMinutes': recModerate ? recModerateMinutes : 0,
      'sedentaryMinutes': sedentaryMinutes,
      'sedentaryHours': sedentaryHours,
      'workVigorousMet': workVigorousMet,
      'workModerateMet': workModerateMet,
      'travelMet': travelMet,
      'recVigorousMet': recVigorousMet,
      'recModerateMet': recModerateMet,
      'totalMetMinutes': totalMetMinutes,
      'activityLevel': activityLevel,
    };

    // 1. Post to Google Sheets Webhook FIRST (independent of Firestore)
    try {
      final webhookUrl = await _getWebhookUrl();
      if (webhookUrl != null && webhookUrl.isNotEmpty) {
        await _postToGoogleSheets(webhookUrl, gpaqData);
      }
    } catch (sheetErr) {
      debugPrint('Google Sheets GPAQ sync error: $sheetErr');
    }

    // 2. Save full data to Firestore user document & subcollection
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'gpaqDetails': gpaqData,
          'gpaqMetMinutes': totalMetMinutes,
          'gpaqLevel': activityLevel,
          'hasGpaqResult': true,
          'lastGpaqDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Subcollection under user (always permitted)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('gpaq_history')
            .doc('gpaq_${now.millisecondsSinceEpoch}')
            .set(gpaqData);
      } catch (userErr) {
        debugPrint('Firestore user doc GPAQ save error: $userErr');
      }

      // 3. Optional global collection backup (isolated in case rules deny)
      try {
        final docId = '${userId}_${now.millisecondsSinceEpoch}';
        await FirebaseFirestore.instance.collection('gpaq_responses').doc(docId).set({
          ...gpaqData,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (globalErr) {
        debugPrint('Firestore gpaq_responses global save warning (rules): $globalErr');
      }
    }
  }

  /// Sends JSON data to the Google Apps Script Web App following redirects.
  static Future<void> _postToGoogleSheets(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Google Apps Script returns 302 redirect upon executing doPost successfully
      if (response.statusCode >= 200 && response.statusCode <= 302) {
        debugPrint('✅ Successfully appended ${data['type']} row to Master Google Sheet.');
      } else {
        debugPrint('⚠️ Google Sheets webhook responded with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception while posting to Google Sheets webhook: $e');
    }
  }
}
