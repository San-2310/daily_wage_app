import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/auth/login_screen.dart';
import 'package:daily_wage_app/pages/navigator_screen.dart';
import 'package:daily_wage_app/providers/application_provider.dart';
import 'package:daily_wage_app/providers/job_provider.dart';
import 'package:daily_wage_app/providers/theme_provider.dart';
import 'package:daily_wage_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await ensureIdFieldsInFirestore();
  await initializeNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Update icon path if necessary

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (Platform.isAndroid) {
    // Request notifications permission on Android using permission_handler
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permissions granted on Android.");
    } else {
      print("Notification permissions denied on Android.");
    }
  } else if (Platform.isIOS) {
    // Request notifications permission on iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}

Future<void> ensureIdFieldsInFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    List<String> collectionNames = ['jobs', 'users', 'applications'];

    for (String collectionName in collectionNames) {
      QuerySnapshot collectionSnapshot =
          await firestore.collection(collectionName).get();

      for (QueryDocumentSnapshot doc in collectionSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('id')) {
          await firestore
              .collection(collectionName)
              .doc(doc.id)
              .update({'id': doc.id});
          print(
              'Added "id" field to document ${doc.id} in collection "$collectionName".');
        } else {
          print(
              'Document ${doc.id} in collection "$collectionName" already has an "id" field.');
        }
      }
    }

    print('All collections have been processed.');
  } catch (e) {
    print('Error while processing collections: $e');
  }
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Start listening for notifications if user is logged in
      listenForNotifications(
          user.uid); // Pass the user ID to listen for notifications
    }

    return MaterialApp(
      theme: themeProvider.theme,
      debugShowCheckedModeBanner: false,
      home: user != null
          ? NavigatorScreen()
          : const LoginScreen(), // Check if user is logged in
    );
  }
}

// Function to listen for notifications when the user is logged in
void listenForNotifications(String userId) {
  final notificationService = NotificationService();
  notificationService.listenForNotifications(
      userId, flutterLocalNotificationsPlugin);
}

// Future<void> _initializeFCM() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Request permission on iOS
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   print("User granted permission: ${settings.authorizationStatus}");

//   // Get the FCM token (you can store this token in the user document in Firestore)
//   String? token = await messaging.getToken();
//   print("FCM Token: $token");

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Message received: ${message.notification?.title}');
//     // Handle foreground notification here
//   });

//   // Handle background messages
//   FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

//   // Listen for changes in application status (assuming you have an 'applications' collection)
//   FirebaseFirestore.instance
//       .collection('applications')
//       .snapshots()
//       .listen((snapshot) {
//     for (var doc in snapshot.docs) {
//       var data = doc.data();
//       String status = data['status'];
//       String jobId = data['jobId'];
//       String workerId = data['workerId'];

//       // If the status changes (application accepted, rejected, or job details updated)
//       if (status == 'accepted' || status == 'rejected' || status == 'updated') {
//         _sendApplicationStatusNotification(workerId, status, jobId);
//       }
//     }
//   });
// }

// // Function to send notification to worker when application status changes
// Future<void> _sendApplicationStatusNotification(
//     String workerId, String status, String jobId) async {
//   // Fetch the worker's FCM token from Firestore (assuming the worker document contains FCM token)
//   DocumentSnapshot workerDoc =
//       await FirebaseFirestore.instance.collection('users').doc(workerId).get();
//   String? fcmToken = workerDoc[
//       'fcmToken']; // Ensure the worker's FCM token is stored in Firestore

//   if (fcmToken != null) {
//     // Create the message content based on status
//     String title = 'Application Status Update';
//     String body = 'Your application for job $jobId has been $status.';

//     // Send the notification
//     FCMService fcmService = FCMService();
//     await fcmService.sendNotification(fcmToken, title, body);
//   }
// }

// // Background message handler
// Future<void> _backgroundMessageHandler(RemoteMessage message) async {
//   print("Background Message: ${message.notification?.title}");
// }
