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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC2u2oevgwqQWRSXwWT5BrEkAwoztAEVyw',
    appId: '1:705187340292:web:2fc3858d2ccfd7a51d9551',
    messagingSenderId: '705187340292',
    projectId: 'flutterchat-e84e9',
    authDomain: 'flutterchat-e84e9.firebaseapp.com',
    storageBucket: 'flutterchat-e84e9.firebasestorage.app',
    measurementId: 'G-XEH5DG8RG1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiqC0vneuUQRtLW07oGs9E9Cucx1PV9rs',
    appId: '1:705187340292:android:886c96c07958c72a1d9551',
    messagingSenderId: '705187340292',
    projectId: 'flutterchat-e84e9',
    storageBucket: 'flutterchat-e84e9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIrJYdWHF4dkaqOrva6ozxChDyAqjJHMU',
    appId: '1:705187340292:ios:dc0702d287e51f471d9551',
    messagingSenderId: '705187340292',
    projectId: 'flutterchat-e84e9',
    storageBucket: 'flutterchat-e84e9.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2u2oevgwqQWRSXwWT5BrEkAwoztAEVyw',
    appId: '1:705187340292:web:127632342108f17d1d9551',
    messagingSenderId: '705187340292',
    projectId: 'flutterchat-e84e9',
    authDomain: 'flutterchat-e84e9.firebaseapp.com',
    storageBucket: 'flutterchat-e84e9.firebasestorage.app',
    measurementId: 'G-FYCV5PF3BB',
  );
}
