import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'ffq_excel_service.dart';
import 'auth_service.dart';

class FfqUploadService {
  static final FfqUploadService _instance = FfqUploadService._internal();

  factory FfqUploadService() => _instance;

  FfqUploadService._internal();

  Future<void> uploadFfqExcel() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    
    final userId = user.uid;
    final filePath = FfqExcelService().filePath;
    
    if (filePath == null || !File(filePath).existsSync()) {
      print('FFQ Excel file not found.');
      return;
    }
    
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = false;
    if (connectivityResult is List) {
       isOffline = connectivityResult.contains(ConnectivityResult.none);
    } else {
       isOffline = connectivityResult == ConnectivityResult.none;
    }
    
    if (isOffline) {
      await _setPendingUpload(true);
      return;
    }

    try {
      final file = File(filePath);
      
      // Convert Excel to Base64 string
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Save base64 string directly to Firestore to bypass Storage entirely
      await FirebaseFirestore.instance.collection('FFQ').doc(userId).set({
        'excelBase64': base64String,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Clear pending upload if successful
      await _setPendingUpload(false);
      
      print('FFQ Excel uploaded as Base64 to Firestore successfully.');
    } catch (e) {
      print('Error uploading FFQ Excel as Base64: $e');
      await _setPendingUpload(true);
    }
  }
  
  Future<void> _setPendingUpload(bool isPending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pendingFfqUpload', isPending);
  }
  
  Future<void> retryPendingUpload() async {
    final prefs = await SharedPreferences.getInstance();
    final isPending = prefs.getBool('pendingFfqUpload') ?? false;
    
    if (isPending) {
      print('Retrying pending FFQ upload...');
      await uploadFfqExcel();
    }
  }
}
