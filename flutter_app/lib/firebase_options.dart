// ─────────────────────────────────────────────────────────────────────────────
// firebase_options.dart  –  PLACEHOLDER
//
// Replace the values below with your actual Firebase project credentials.
//
// The recommended way is to run:
//   flutterfire configure
// which auto-generates this file from your Firebase project.
//
// Alternatively fill in the values manually from your Firebase console:
//   Project settings → Your apps → SDK setup and configuration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Replace all **** values with your real Firebase credentials ──────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '****',
    appId: '****',
    messagingSenderId: '****',
    projectId: '****',
    authDomain: '****',
    storageBucket: '****',
    measurementId: '****',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '****',
    appId: '****',
    messagingSenderId: '****',
    projectId: '****',
    storageBucket: '****',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '****',
    appId: '****',
    messagingSenderId: '****',
    projectId: '****',
    storageBucket: '****',
    iosBundleId: 'com.example.instagramCloneFlutter',
  );
}
