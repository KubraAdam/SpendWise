import 'package:firebase_auth/firebase_auth.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
   // Kayıt olma işlemi
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Firebase Auth kullanarak kullanıcı kaydı yapma
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Kayıt hatası: $e");
      return null;
    }
  }

  
  // Kullanıcıyı e-posta ve şifre ile giriş yaparak oturum açma fonksiyonu
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;  // Giriş başarılı olursa kullanıcıyı döndür
    } catch (e) {
      print('Giriş hatası: $e');
      return null;  // Hata varsa null döndür
    }
  }

  // Kullanıcı Girişi (Login)
Future<User?> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    print("Giriş hatası: $e");
    return null;
  }
}

// Kullanıcı Çıkışı (Logout)
Future<void> signOut() async {
  await _auth.signOut();
}


}
