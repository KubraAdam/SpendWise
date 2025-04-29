import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // Uygulamada giriş sonrası yönleneceğin sayfa

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Kullanıcı oturum açmışsa
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen(); // Giriş yapılmamışsa login ekranı
          } else {
            return HomeScreen(); // Giriş yapılmışsa ana ekran
          }
        }

        // Yüklenme durumu
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
