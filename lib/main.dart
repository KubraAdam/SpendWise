import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:kisiselfinansapp/theme/theme_mode_notifier.dart'; // Tema yöneticisi
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/income_expenses_screen.dart';
import 'screens/receipt_ocr_screen.dart';
import 'screens/receipt_list_screen.dart'; // 👈 Bu satır eklendi
import 'firebase_options.dart';
import 'package:kisiselfinansapp/screens/budget_planning_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kişisel Finans',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,

      // 
      home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (snapshot.hasData) {
      return const DashboardScreen(); // ✅ Giriş yaptıysa burası
    } else {
      return const LoginScreen(); // ❌ Giriş yapmadıysa burası
    }
  },
),


      // 🧭 Route'lar aynı kaldı
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/income_expenses': (context) => const IncomeExpensesScreen(),
        '/receipt_ocr': (context) => const ReceiptOCRScreen(),
        '/receipt_list': (context) => const ReceiptListScreen(),
        '/budget_planning': (context) => const BudgetPlanningScreen(),

      },
    );
  }
}
