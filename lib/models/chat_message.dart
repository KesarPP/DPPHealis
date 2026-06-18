import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String? id;
  final String text;
  final bool isUser;
  final String time;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? false,
      time: data['time'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'time': time,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
