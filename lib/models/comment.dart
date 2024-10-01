import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String threatId;
  final String userId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.threatId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      threatId: data['threatId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] is Timestamp 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.parse(data['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threatId': threatId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}