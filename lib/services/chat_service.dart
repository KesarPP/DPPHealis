import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name as requested by the user
  static const String _chatsCollection = 'Coachuserchats';

  /// Generates a consistent chat document ID based on patient and coach IDs
  static String _getChatDocId(String patientId, String coachId) {
    return '${patientId}_$coachId';
  }

  /// Sends a message to the specified chat
  static Future<void> sendMessage({
    required String patientId,
    required String coachId,
    required String text,
    required String senderId,
    required bool isFromPatient,
    String? attachmentName,
    String? attachmentType,
    String? attachmentPath,
  }) async {
    final chatDocId = _getChatDocId(patientId, coachId);
    final chatRef = _firestore.collection(_chatsCollection).doc(chatDocId);

    final now = FieldValue.serverTimestamp();

    // The message data
    final messageData = {
      'text': text,
      'senderId': senderId,
      'timestamp': now,
      'isFromPatient': isFromPatient,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentType != null) 'attachmentType': attachmentType,
      if (attachmentPath != null) 'attachmentPath': attachmentPath,
    };

    // The chat metadata to update the parent document
    final chatMetadata = {
      'patientId': patientId,
      'coachId': coachId,
      'lastMessageText': attachmentName != null ? '📎 $attachmentName' : text,
      'lastMessageTime': now,
      'unreadByCoach': isFromPatient ? FieldValue.increment(1) : 0,
      'unreadByPatient': isFromPatient ? 0 : FieldValue.increment(1),
    };

    final batch = _firestore.batch();
    
    // 1. Update the parent document with latest info
    batch.set(chatRef, chatMetadata, SetOptions(merge: true));
    
    // 2. Add the message to the messages subcollection
    final messageRef = chatRef.collection('messages').doc();
    batch.set(messageRef, messageData);

    await batch.commit();
  }

  /// Resets the unread count for the given user role
  static Future<void> markChatAsRead({
    required String patientId,
    required String coachId,
    required bool isCoach,
  }) async {
    final chatDocId = _getChatDocId(patientId, coachId);
    await _firestore.collection(_chatsCollection).doc(chatDocId).set(
      {
        if (isCoach) 'unreadByCoach': 0,
        if (!isCoach) 'unreadByPatient': 0,
      },
      SetOptions(merge: true),
    );
  }

  /// Returns a stream of messages for a specific chat, ordered by timestamp
  static Stream<QuerySnapshot> getChatStream(String patientId, String coachId) {
    final chatDocId = _getChatDocId(patientId, coachId);
    return _firestore
        .collection(_chatsCollection)
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Sets the online status of a coach
  static Future<void> setCoachOnlineStatus(String coachId, bool isOnline) async {
    await _firestore.collection('coaches').doc(coachId).set(
      {'isOnline': isOnline},
      SetOptions(merge: true),
    );
  }

  /// Returns a stream of the coach's online status
  static Stream<bool> getCoachOnlineStatusStream(String coachId) {
    return _firestore.collection('coaches').doc(coachId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['isOnline'] as bool? ?? true;
      }
      return true; // Default to true if not set
    });
  }
}
