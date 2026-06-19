import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _chatCollection {
    final userId = currentUserId ?? 'anonymous';
    return _firestore.collection('chats').doc(userId).collection('messages');
  }

  Future<void> saveMessage(ChatMessage message) async {
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
