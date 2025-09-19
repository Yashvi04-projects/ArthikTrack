import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'onboarding_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFBFF),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD5AC6F),
              ),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return const OnboardingScreen(); // or HomeScreen()
        }
        
        return const AuthScreen();
      },
    );
  }
}
