import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On web we need explicit FirebaseOptions. On Android/iOS native config files
  // (google-services.json / GoogleService-Info.plist) are used when calling
  // Firebase.initializeApp() with no arguments.
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  await MobileAds.instance.initialize();
  runApp(const RoutineMateApp());
}

class RoutineMateApp extends StatelessWidget {
  const RoutineMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoutineMate',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('RoutineMate 초기 설정 완료 🚀')),
      ),
    );
  }
}
