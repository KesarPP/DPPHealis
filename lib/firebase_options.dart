import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmT3-o6EbRKPBx4pohSA5DOAdMAfRIN6g',
    appId: '1:511361480049:android:6189a4c0ee2fb245e1f2d0',
    messagingSenderId: '511361480049',
    projectId: 'dppproject-1998e',
    storageBucket: 'dppproject-1998e.firebasestorage.app',
  );
}