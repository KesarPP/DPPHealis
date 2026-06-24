import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Local fallback for unauthenticated users
  final _localMessagesController = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _localMessages = [];

  String? get currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  CollectionReference get _chatCollection {
    final userId = currentUserId ?? 'anonymous';
    return _firestore.collection('chats').doc(userId).collection('messages');
  }

  Future<void> saveMessage(ChatMessage message) async {
    if (currentUserId == null) {
      _localMessages.add(message);
      _localMessagesController.add(List.from(_localMessages));
      return;
    }

    try {
      if (message.id != null) {
        await _chatCollection.doc(message.id).set(message.toFirestore());
      } else {
        await _chatCollection.add(message.toFirestore());
      }
    } catch (e) {
      debugPrint('Error saving message: $e');
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
