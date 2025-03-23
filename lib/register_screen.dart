import 'package:flutter/material.dart';
import 'package:kisiselfinansapp/auth_service.dart';  // AuthService'i import et
import 'package:kisiselfinansapp/screens/login_screen.dart'; // Login ekranını import et

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleScreen;  // Kayıt ekranına geçiş için fonksiyon

  const RegisterScreen({Key? key, required this.toggleScreen}) : super(key: key);  // const ekleyin ve key parametresini ekleyin

  @override
  RegisterScreenState createState() => RegisterScreenState();  // _RegisterScreenState yerine RegisterScreenState
}

class RegisterScreenState extends State<RegisterScreen> {  // Private olmamalı
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    var user = await _authService.registerWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null) {
      print("Kayıt başarılı: ${user.email}");
    } else {
      print("Kayıt başarısız!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text("Kayıt Ol"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Giriş yap ekranına git
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(toggleScreen: widget.toggleScreen)),
                );
              },
              child: Text("Zaten bir hesabınız var mı? Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
