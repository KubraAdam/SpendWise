// auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisiselfinansapp/screens/login_screen.dart';
import 'package:kisiselfinansapp/register_screen.dart';
import 'package:kisiselfinansapp/main_page.dart'; // MainPage'i import et

class AuthScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcıyı kontrol etme ve yönlendirme
  void _checkUserAuth(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Kullanıcı zaten giriş yapmış, anasayfaya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), // MainPage'e yönlendir
      );
    } else {
      // Kullanıcı giriş yapmamış, giriş ekranını göster
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama başlatıldığında kullanıcıyı kontrol et
    _checkUserAuth(context);

    return Scaffold(
      backgroundColor: Colors.blueAccent.shade100,
      body: Center(
        child: CircularProgressIndicator(), // Yükleniyor göstergesi
      ),
    );
  }
}
