import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/localization/locales.dart';
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
import 'package:flutter_localization/flutter_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialized
  await Firebase.initializeApp(); // Initialize Firebase
  await ensureIdFieldsInFirestore();
  await initializeNotifications();
  await FlutterLocalization.instance
      .ensureInitialized(); // Ensure FlutterLocalization is initialized
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
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    configureLocalization();
    super.initState();
  }

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
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      home: user != null
          ? NavigatorScreen()
          : const LoginScreen(), // Check if user is logged in
    );
  }

  void configureLocalization() {
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = onTranslatedLanguage;
  }

  void onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }
}

// Function to listen for notifications when the user is logged in
void listenForNotifications(String userId) {
  final notificationService = NotificationService();
  notificationService.listenForNotifications(
      userId, flutterLocalNotificationsPlugin);
}
