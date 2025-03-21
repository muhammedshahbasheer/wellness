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
    apiKey: 'AIzaSyDEaEf6jp_sotoMOShwl7PlsUc5MSQUXhw',
    appId: '1:742505616228:web:d9634e866ddb3bcf612071',
    messagingSenderId: '742505616228',
    projectId: 'wellness-f8da6',
    authDomain: 'wellness-f8da6.firebaseapp.com',
    storageBucket: 'wellness-f8da6.firebasestorage.app',
    measurementId: 'G-JXMZ41069D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-DgbbVRZe_ke9r8X_j8nLikojqsoWMDA',
    appId: '1:742505616228:android:695ae8c87d531438612071',
    messagingSenderId: '742505616228',
    projectId: 'wellness-f8da6',
    storageBucket: 'wellness-f8da6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiZPQK37oVsYFRf74F_bHPMTJoQB8GYIo',
    appId: '1:742505616228:ios:6d40a5a37779a819612071',
    messagingSenderId: '742505616228',
    projectId: 'wellness-f8da6',
    storageBucket: 'wellness-f8da6.firebasestorage.app',
    iosBundleId: 'com.example.wellness',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiZPQK37oVsYFRf74F_bHPMTJoQB8GYIo',
    appId: '1:742505616228:ios:6d40a5a37779a819612071',
    messagingSenderId: '742505616228',
    projectId: 'wellness-f8da6',
    storageBucket: 'wellness-f8da6.firebasestorage.app',
    iosBundleId: 'com.example.wellness',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEaEf6jp_sotoMOShwl7PlsUc5MSQUXhw',
    appId: '1:742505616228:web:7500e6057fe3dd30612071',
    messagingSenderId: '742505616228',
    projectId: 'wellness-f8da6',
    authDomain: 'wellness-f8da6.firebaseapp.com',
    storageBucket: 'wellness-f8da6.firebasestorage.app',
    measurementId: 'G-DD5DDT4ELZ',
  );
}
