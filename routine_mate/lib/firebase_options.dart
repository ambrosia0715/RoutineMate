// Placeholder firebase_options.dart
// Minimal stub that returns a `FirebaseOptions` from the firebase_core package.
// Replace by running `flutterfire configure` to generate a full, correct file.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    // TODO: Replace these placeholder values by running `flutterfire configure`
    // or by filling in the values from your Firebase console.
    return const FirebaseOptions(
      apiKey: 'REPLACE_WITH_API_KEY',
      appId: 'REPLACE_WITH_APP_ID',
      messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
      projectId: 'REPLACE_WITH_PROJECT_ID',
      authDomain: null,
      databaseURL: null,
      storageBucket: null,
      measurementId: null,
    );
  }
}
