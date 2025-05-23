import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:kisiselfinansapp/theme/theme_mode_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/income_expenses_screen.dart';
import 'screens/receipt_ocr_screen.dart';
import 'screens/receipt_list_screen.dart';
import 'firebase_options.dart';
import 'package:kisiselfinansapp/screens/budget_planning_screen.dart';
import 'package:kisiselfinansapp/screens/smart_spending_screen.dart';
import 'package:kisiselfinansapp/screens/subscription_tracking_screen.dart';
import 'package:kisiselfinansapp/screens/financial_goals_screen.dart';
import 'package:kisiselfinansapp/screens/data_visualization_screen.dart';

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/subscription_tracking') {
          final userId = settings.arguments as String?;
          if (userId == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('HATA: userId eksik (subscription_tracking)')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => SubscriptionTrackingScreen(userId: userId),
          );
        }
        if (settings.name == '/financial_goals') {
          final userId = settings.arguments as String?;
          if (userId == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('HATA: userId eksik (financial_goals)')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => FinancialGoalsScreen(userId: userId),
          );
        }
        if (settings.name == '/data_visualization') {
          final userId = settings.arguments as String?;
          if (userId == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('HATA: userId eksik (data_visualization)')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => DataVisualizationScreen(userId: userId),
          );
        }
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case '/income_expenses':
            return MaterialPageRoute(builder: (_) => const IncomeExpensesScreen());
          case '/receipt_ocr':
            return MaterialPageRoute(builder: (_) => const ReceiptOCRScreen());
          case '/receipt_list':
            return MaterialPageRoute(builder: (_) => const ReceiptListScreen());
          case '/budget_planning':
            return MaterialPageRoute(builder: (_) => const BudgetPlanningScreen());
          case '/smart_spending':
            return MaterialPageRoute(builder: (_) => const SmartSpendingScreen());
          default:
            return null;
        }
      },
    );
  }
}
