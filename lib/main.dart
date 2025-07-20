import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'onboarding_screen.dart'; // Make sure the file is named onboarding_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArthikTrack',
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(), // 👈 Show your onboarding screen
    );
  }
}
