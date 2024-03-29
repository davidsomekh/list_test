// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
      apiKey: "AIzaSyD3lMrCCqv8xI0s0Q6kgfySY35RTu8Bseg",
      authDomain: "fcmweb-5368f.firebaseapp.com",
      projectId: "fcmweb-5368f",
      storageBucket: "fcmweb-5368f.appspot.com",
      messagingSenderId: "34522456568",
      appId: "1:34522456568:web:2eef055ca6ae8f5c89f60d",
      measurementId: "G-36SNYEVRR7");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJp6Vm8YGRpTtdyZzJngWvKsk8q2YupUI',
    appId: '1:34522456568:android:9754c2d02fe5e91389f60d',
    messagingSenderId: '',
    projectId: 'fcmweb-5368f',
    storageBucket: 'fcmweb-5368f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    androidClientId: '',
    iosClientId: '',
    iosBundleId: 'com.example.list_test',
  );
}
