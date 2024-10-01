import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms if needed
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyAbCGv5VBVytDctilPt8mmSNDWOuJ_84hQ',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? '1:207542021871:web:46ac9d62daf3e3ac0b751a',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '207542021871',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'block-86f69',
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'block-86f69.firebaseapp.com',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'block-86f69.appspot.com',
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? 'G-TMPW9GK2F4',
  );
}