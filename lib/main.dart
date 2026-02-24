import 'package:flutter/material.dart';
import 'package:frontend/features/auth/providers/login_provider.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/dashboard/caretaker_dashboard.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PetConnectApp());
}

class PetConnectApp extends StatelessWidget {
  const PetConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: MaterialApp(
        title: 'PetConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const VetDashboard(),
      ),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');

    if (mounted) {
      if (role != null) {
        _navigateToDashboard(role);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;
    switch (role) {
      case 'Owner':
        dashboard = const OwnerDashboard();
        break;
      case 'Vet':
        dashboard = const VetDashboard();
        break;
      case 'Caretaker':
        dashboard = const CaretakerDashboard();
        break;
      default:
        dashboard = const LoginScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
