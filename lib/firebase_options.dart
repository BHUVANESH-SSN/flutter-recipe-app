// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "AIzaSyAhQ-E0NIKV856JFL9ToCe-M5YUf8BQCDE",
      authDomain: "sample-app-ca0c9.firebaseapp.com",
      databaseURL: "https://sample-app-ca0c9-default-rtdb.firebaseio.com",
      projectId: "sample-app-ca0c9",
      storageBucket: "sample-app-ca0c9.firebasestorage.app",
      messagingSenderId: "234230520285",
      appId: "1:234230520285:web:b3965f12120542860f3e34",

    );
  }
}
