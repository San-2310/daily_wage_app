import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/job_model.dart';
import 'package:daily_wage_app/models/user_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/application_model.dart';
import '../models/notification_model.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Radius of the Earth in km
  final phi1 = lat1 * pi / 180;
  final phi2 = lat2 * pi / 180;
  final deltaPhi = (lat2 - lat1) * pi / 180;
  final deltaLambda = (lon2 - lon1) * pi / 180;

  final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // Distance in km
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a notification for a user
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // Add notification to Firestore collection 'notifications'
      DocumentReference docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore());
      print("Notification added with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding notification: $e");
    }
  }

  // Notify workers about a new job posting
  Future<void> notifyWorkerOfNewJobPosting(
      String jobId, String jobTitle, String jobDetails) async {
    try {
      // Fetch the job details
      DocumentSnapshot jobSnapshot =
          await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
      Job job = Job.fromFirestore(
          jobSnapshot.data() as Map<String, dynamic>, jobSnapshot.id);

      if (job.latitude == null || job.longitude == null) {
        print("Job does not have location information.");
        return;
      }

      // Get workers with the "worker" role and their location
      QuerySnapshot workersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .get();

      for (var workerDoc in workersSnapshot.docs) {
        AppUser worker = AppUser.fromFirestore(
            workerDoc.data() as Map<String, dynamic>, workerDoc.id);

        // Skip workers without location information
        if (worker.latitude == null || worker.longitude == null) {
          continue;
        }

        // Calculate the distance between the worker and the job
        double distance = calculateDistance(
            worker.latitude!, worker.longitude!, job.latitude!, job.longitude!);

        // If the worker is within a 10km radius, send the notification
        if (distance <= 10.0) {
          NotificationModel notification = NotificationModel(
            userId: worker.id,
            title: 'New Job Posting: $jobTitle',
            message: jobDetails,
            timestamp: DateTime.now(),
          );

          // Add the notification to Firestore (or send directly depending on your logic)
          await addNotification(notification);
          print("Worker ${worker.id} notified about the new job posting.");
        }
      }
    } catch (e) {
      print("Error sending job posting notification: $e");
    }
  }

  // Notify workers about their job application status update
  Future<void> notifyWorkerOfApplicationStatus(
      Application application, String jobTitle) async {
    try {
      String statusMessage;
      switch (application.status) {
        case 'accepted':
          statusMessage =
              'Your job application for "$jobTitle" has been accepted.';
          break;
        case 'rejected':
          statusMessage =
              'Your job application for "$jobTitle" has been rejected.';
          break;
        case 'applied':
        default:
          statusMessage =
              'Your job application for "$jobTitle" is still pending.';
          break;
      }

      NotificationModel notification = NotificationModel(
        userId: application.workerId,
        title: 'Application Status Update',
        message: statusMessage,
        timestamp: DateTime.now(),
      );

      await addNotification(notification);
      print("Worker notified about application status.");
    } catch (e) {
      print("Error sending application status notification: $e");
    }
  }

  // Notify employers when a new application is submitted for their job
  Future<void> notifyEmployerOfNewApplication(
      String employerId, String jobTitle, String workerName) async {
    try {
      String message = '$workerName has applied for your job: "$jobTitle".';

      NotificationModel notification = NotificationModel(
        userId: employerId,
        title: 'New Job Application',
        message: message,
        timestamp: DateTime.now(),
      );

      await addNotification(notification);
      print("Employer notified about new application.");
    } catch (e) {
      print("Error sending application notification to employer: $e");
    }
  }

  // Function to listen for new notifications for a user
  Future<void> listenForNotifications(String userId,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead',
            isEqualTo: false) // Assuming you will manage 'isRead' field
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        var notificationData = doc.data() as Map<String, dynamic>;
        NotificationModel notification =
            NotificationModel.fromFirestore(notificationData);

        // Show local notification
        _showLocalNotification(notification, flutterLocalNotificationsPlugin);

        // Mark the notification as read
        markNotificationAsRead(doc.id);
      }
    });
  }

  // Show local notification
  Future<void> _showLocalNotification(NotificationModel notification,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notification.title,
      notification.message,
      platformDetails,
      payload: 'item x', // Optional payload
    );
  }

  // Function to mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      print("Notification marked as read.");
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }
}
