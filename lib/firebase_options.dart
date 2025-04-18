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
    apiKey: 'AIzaSyDGS3AetzkA2eX0eTtVon-zZwVoN7Of8O4',
    appId: '1:193622782630:web:4e7f6918bf2750f0e5fa67',
    messagingSenderId: '193622782630',
    projectId: 'heywork-e844a',
    authDomain: 'heywork-e844a.firebaseapp.com',
    storageBucket: 'heywork-e844a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAgoMzuyNyStOxglT2ov-SpnjTOd21TYQ',
    appId: '1:193622782630:android:c64c96f2a8630b59e5fa67',
    messagingSenderId: '193622782630',
    projectId: 'heywork-e844a',
    storageBucket: 'heywork-e844a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1THbgVNIezSGPnkhJAZIJTusnYd412PM',
    appId: '1:193622782630:ios:89798feb702527aae5fa67',
    messagingSenderId: '193622782630',
    projectId: 'heywork-e844a',
    storageBucket: 'heywork-e844a.firebasestorage.app',
    iosBundleId: 'com.example.heyWork',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1THbgVNIezSGPnkhJAZIJTusnYd412PM',
    appId: '1:193622782630:ios:89798feb702527aae5fa67',
    messagingSenderId: '193622782630',
    projectId: 'heywork-e844a',
    storageBucket: 'heywork-e844a.firebasestorage.app',
    iosBundleId: 'com.example.heyWork',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDGS3AetzkA2eX0eTtVon-zZwVoN7Of8O4',
    appId: '1:193622782630:web:b75d58405fdb4813e5fa67',
    messagingSenderId: '193622782630',
    projectId: 'heywork-e844a',
    authDomain: 'heywork-e844a.firebaseapp.com',
    storageBucket: 'heywork-e844a.firebasestorage.app',
  );

}