// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQvVMoNTSRBwIHawAVhKtGFNxnCxTcr3s',
    appId: '1:671144197215:web:32f707df821f1302122fea',
    messagingSenderId: '671144197215',
    projectId: 'daily-wage-app',
    authDomain: 'daily-wage-app.firebaseapp.com',
    storageBucket: 'daily-wage-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4rJZ1sKv56QbunhpqmxAYbScgtsBjDAY',
    appId: '1:671144197215:android:3d773be8aec6af32122fea',
    messagingSenderId: '671144197215',
    projectId: 'daily-wage-app',
    storageBucket: 'daily-wage-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuFb-JYJMTGBtBnL651ZdIMuiUgSSJvZI',
    appId: '1:671144197215:ios:79950aab4bd0a6ae122fea',
    messagingSenderId: '671144197215',
    projectId: 'daily-wage-app',
    storageBucket: 'daily-wage-app.firebasestorage.app',
    iosBundleId: 'com.example.dailyWageApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAuFb-JYJMTGBtBnL651ZdIMuiUgSSJvZI',
    appId: '1:671144197215:ios:79950aab4bd0a6ae122fea',
    messagingSenderId: '671144197215',
    projectId: 'daily-wage-app',
    storageBucket: 'daily-wage-app.firebasestorage.app',
    iosBundleId: 'com.example.dailyWageApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBQvVMoNTSRBwIHawAVhKtGFNxnCxTcr3s',
    appId: '1:671144197215:web:2b98a5706016b0b6122fea',
    messagingSenderId: '671144197215',
    projectId: 'daily-wage-app',
    authDomain: 'daily-wage-app.firebaseapp.com',
    storageBucket: 'daily-wage-app.firebasestorage.app',
  );
}
