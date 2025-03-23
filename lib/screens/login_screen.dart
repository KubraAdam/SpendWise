import 'package:flutter/material.dart';
import 'package:kisiselfinansapp/auth_service.dart';  // auth_service.dart dosyasını import et

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false; // Yükleniyor durumunu takip etmek için bir değişken

  // Kullanıcıyı giriş yapması için çağırılan method
  void _signIn() async {
    setState(() {
      _isLoading = true; // Giriş yaparken loading göstermek için true yapıyoruz
    });

    var user = await _authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false; // Giriş işlemi tamamlandıktan sonra loading'i false yapıyoruz
    });

    if (user != null) {
      print("Giriş başarılı: ${user.email}");
      // Başarılı giriş sonrası yapılacak işlemleri buraya ekleyebilirsiniz
    } else {
      print("Giriş başarısız!");
      // Kullanıcıya hata mesajı gösterebiliriz
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Giriş başarısız! Lütfen e-posta ve şifrenizi kontrol edin."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-mail"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Eğer giriş yapılıyorsa loading göstereceğiz
                : ElevatedButton(
                    onPressed: _signIn,
                    child: Text("Giriş Yap"),
                  ),
          ],
        ),
      ),
    );
  }
}
