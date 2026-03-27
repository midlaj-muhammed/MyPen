// File generated manually based on google-services.json
// For web config: go to Firebase Console → Project Settings → Your apps → Web app → SDK setup
// and replace the web DefaultFirebaseOptions values below.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── Android config (from google-services.json) ───────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCL5K970o7wTWgPB7TOh4mKtL_pBT6nQ4',
    appId: '1:169510030505:android:eb0de07a75475d5c2e2db8',
    messagingSenderId: '169510030505',
    projectId: 'mypensflutter',
    storageBucket: 'mypensflutter.firebasestorage.app',
  );

  // ─── Web config (from Firebase Console) ──────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQg4B3yqz86yiooYDllhwJ07NWT2_NHqA',
    appId: '1:169510030505:web:2fff155ebe9d0d922e2db8',
    messagingSenderId: '169510030505',
    projectId: 'mypensflutter',
    storageBucket: 'mypensflutter.firebasestorage.app',
    authDomain: 'mypensflutter.firebaseapp.com',
    measurementId: 'G-QB70EKC5LD',
  );
}
