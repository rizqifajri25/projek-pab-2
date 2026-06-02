import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
        appId: 'REPLACE_WITH_FIREBASE_APP_ID',
        messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
        projectId: 'padel-finder-palembang',
        authDomain: 'padel-finder-palembang.firebaseapp.com',
        storageBucket: 'padel-finder-palembang.appspot.com',
      );
}
