import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(child: Text('No user is signed in')),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp',
                descending: true) // Order by timestamp (latest first)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          // List of notifications fetched from Firestore
          final notifications = snapshot.data!.docs.map((doc) {
            return NotificationModel.fromFirestore(
                doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return GestureDetector(
                onTap: () {
                  // Handle tap, e.g., mark as read or navigate to details
                  // You can update the notification's `isRead` status here if needed.
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .update({'isRead': true});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color:
                        notification.isRead ? Colors.grey[200] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    trailing: Text(
                      DateFormat('MMM dd, yyyy hh:mm a')
                          .format(notification.timestamp),
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
