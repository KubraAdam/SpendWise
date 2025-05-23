import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:kisiselfinansapp/theme/theme_mode_notifier.dart';
import '../screens/login_screen.dart';
import 'package:kisiselfinansapp/screens/receipt_ocr_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C027B),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeModeNotifier>(context).themeMode == ThemeMode.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () {
              Provider.of<ThemeModeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C027B), Color(0xFF8899CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Welcome, ${user?.email ?? "Guest"}!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            _dashboardButton(context, 'Income & Expenses', 'assets/images/income_expenses_icon.png', '/income_expenses'),
            _dashboardButton(context, 'Budget Planning', 'assets/images/budget_planning_icon.png', '/budget_planning'),
            _dashboardButton(context, 'Smart Spending', 'assets/images/smart_spending_icon.png', '/smart_spending'),
            _dashboardButton(context, 'Receipt OCR', 'assets/images/receipt_ocr_icon.png', '/receipt_ocr'),
            _dashboardButton(context, 'Subscription Tracking', 'assets/images/subscription_tracking_icon.png', '/subscription_tracking'),
            _dashboardButton(context, 'Financial Goals', 'assets/images/financial_goals_icon.png', '/financial_goals'),
            _dashboardButton(context, 'Data Visualization', 'assets/images/data_visualization_icon.png', '/data_visualization'),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C027B),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1C027B)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Profil sayfasına yönlendirme burada yapılacak
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Ayarlar sayfasına yönlendirme burada yapılacak
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Bildirimler sayfasına yönlendirme burada yapılacak
            },
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardButton(BuildContext context, String title, String iconPath, String routeName) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(iconPath, width: 40, height: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          print("Navigating to $routeName with userId: $userId");

          if (routeName == '/receipt_ocr') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiptOCRScreen()),
            );
          } else if ((routeName == '/subscription_tracking' || routeName == '/financial_goals' || routeName == '/data_visualization') && userId != null) {
            Navigator.pushNamed(context, routeName, arguments: userId);
          } else {
            Navigator.pushNamed(context, routeName);
          }
        },
      ),
    );
  }
} 
