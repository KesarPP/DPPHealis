import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Local fallback for unauthenticated users
  final _localMessagesController = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _localMessages = [];

  String? get currentUserId {
    try {
      // Use AuthService to be consistent with the rest of the app
      return AuthService().currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  CollectionReference get _chatCollection {
    final userId = currentUserId ?? 'anonymous';
    return _firestore.collection('chats').doc(userId).collection('messages');
  }

  Future<void> saveMessage(ChatMessage message) async {
    final uid = currentUserId;
    if (uid == null) {
      debugPrint('🚨 [AI Chat] currentUserId is NULL. Saving locally in memory. This will NOT appear in Firestore.');
      _localMessages.add(message);
      _localMessagesController.add(List.from(_localMessages));
      return;
    }

    try {
      debugPrint('🔥 [AI Chat] Attempting to save message to Firestore at: chats/$uid/messages');
      if (message.id != null) {
        await _chatCollection.doc(message.id).set(message.toFirestore());
      } else {
        await _chatCollection.add(message.toFirestore());
      }
      debugPrint('✅ [AI Chat] Successfully saved message to Firestore!');
    } catch (e) {
      debugPrint('❌ [AI Chat] Error saving message to Firestore: $e');
    }
  }

  Stream<List<ChatMessage>> getMessagesStream() {
    if (currentUserId == null) {
      Future.microtask(() => _localMessagesController.add(List.from(_localMessages)));
      return _localMessagesController.stream;
    }

    return _chatCollection
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }
}
