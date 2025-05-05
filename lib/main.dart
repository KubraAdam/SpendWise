import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:kisiselfinansapp/theme/theme_mode_notifier.dart'; // Tema yöneticisi
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/income_expenses_screen.dart'; // 🔥 Yeni ekranı import ettik
import 'package:kisiselfinansapp/screens/receipt_ocr_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModeNotifier(), // Tema sağlayıcı
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context); // Theme değişimi için

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kişisel Finans',
      theme: ThemeData.light(), // Açık tema
      darkTheme: ThemeData.dark(), // Karanlık tema
      themeMode: themeNotifier.themeMode, // Tema modunu kullan
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const DashboardScreen(); // Kullanıcı giriş yaptıysa
          } else {
            return const LoginScreen(); // Giriş yapmadıysa
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/income_expenses': (context) => const IncomeExpensesScreen(), // 🔥 Yeni route ekledik
        '/receipt_ocr': (context) => const ReceiptOCRScreen(),


      },
    );
  }
}
