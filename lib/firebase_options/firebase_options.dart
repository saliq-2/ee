import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (Platform.isIOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:66599593714:ios:4f03f693ba5ee6ffee526b',
        apiKey: 'AIzaSyAB-_BJZub8qAYPhK5cO-4V11tgEEyGUg4',
        projectId: 'cukadmin',
        messagingSenderId: '66599593714',
        iosBundleId: 'com.example.ecalendar',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:66599593714:android:45bfdc2ba321d479ee526b',
        apiKey: 'AIzaSyAB-_BJZub8qAYPhK5cO-4V11tgEEyGUg4',
        projectId: 'cukadmin',
        messagingSenderId: '66599593714',
      );

    }

  }
}