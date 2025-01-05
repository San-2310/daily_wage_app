import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id; // The notification document ID in Firestore
  String userId; // The user to whom the notification is sent
  String title; // Title of the notification (e.g., "Job Status Changed")
  String
      message; // Detailed message (e.g., "Your job application was accepted.")
  bool isRead; // Whether the notification has been read
  DateTime timestamp; // Time when the notification was created

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  // Convert the notification object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }

  // Convert Firestore document to a NotificationModel object
  factory NotificationModel.fromFirestore(Map<String, dynamic> doc) {
    return NotificationModel(
      id: doc['id'],
      userId: doc['userId'],
      title: doc['title'],
      message: doc['message'],
      isRead: doc['isRead'] ?? false,
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }
}
