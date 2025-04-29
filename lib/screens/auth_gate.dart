import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Uygulama açılırken bekleme animasyonu
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Kullanıcı giriş yapmış → Dashboard'a git
          return const DashboardScreen();
        } else {
          // Kullanıcı giriş yapmamış → Login ekranı göster
          return const LoginScreen();
        }
      },
    );
  }
}
