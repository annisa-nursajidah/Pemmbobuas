// File ini di-generate berdasarkan google-services.json
// Project: sobat-beres
// Package: com.example.uaspemmob

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android - dari google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSQYhz2Uhi0I9Ye8UMeOijAZPVbF67ANk',
    appId: '1:933905113120:android:f1c63dceb4b65c8d529c45',
    messagingSenderId: '933905113120',
    projectId: 'sobat-beres',
    storageBucket: 'sobat-beres.firebasestorage.app',
  );

  // Web (tambahkan jika diperlukan)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDSQYhz2Uhi0I9Ye8UMeOijAZPVbF67ANk',
    appId: '1:933905113120:android:f1c63dceb4b65c8d529c45',
    messagingSenderId: '933905113120',
    projectId: 'sobat-beres',
    storageBucket: 'sobat-beres.firebasestorage.app',
  );

  // iOS (tambahkan jika diperlukan)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSQYhz2Uhi0I9Ye8UMeOijAZPVbF67ANk',
    appId: '1:933905113120:android:f1c63dceb4b65c8d529c45',
    messagingSenderId: '933905113120',
    projectId: 'sobat-beres',
    storageBucket: 'sobat-beres.firebasestorage.app',
  );

  // macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSQYhz2Uhi0I9Ye8UMeOijAZPVbF67ANk',
    appId: '1:933905113120:android:f1c63dceb4b65c8d529c45',
    messagingSenderId: '933905113120',
    projectId: 'sobat-beres',
    storageBucket: 'sobat-beres.firebasestorage.app',
  );

  // Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDSQYhz2Uhi0I9Ye8UMeOijAZPVbF67ANk',
    appId: '1:933905113120:android:f1c63dceb4b65c8d529c45',
    messagingSenderId: '933905113120',
    projectId: 'sobat-beres',
    storageBucket: 'sobat-beres.firebasestorage.app',
  );
}
