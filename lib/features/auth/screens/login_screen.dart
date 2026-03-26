import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/register_screen.dart';
import 'package:frontend/features/dashboard/admin_dashboard.dart';
import 'package:frontend/features/dashboard/caretaker_dashboard.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    
    setState(() => isLoading = true);

    try {
    final res = await ApiService.login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
    );

    final status = res["status"];
    final data = res["data"];

    if (status == 200) {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isLoggedIn", true);
    await prefs.setInt("user_id", data["id"]);
    await prefs.setString("role", data["role"]);
    await prefs.setString("name", data["name"]);

    Widget dashboard;

    switch (data["role"]) {
    case "owner":
    dashboard = const OwnerDashboard();
    break;
    case "vet":
    dashboard = const VetDashboard();
    break;
    case "caretaker":
    dashboard = const CaretakerDashboard();
    break;
    case "admin":
    dashboard = const AdminDashboard();
    break;
    default:
    dashboard = const LoginScreen();
    }

    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => dashboard),
    );
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(data["error"] ?? "Login failed")),
    );
    }
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: $e")),
    );
    } finally {
    setState(() => isLoading = false);
    }
    

  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF57C00);

    
    return Scaffold(
    body: Stack(
    fit: StackFit.expand,
    children: [
    Image.asset(
    'assets/images/nature-bg.jpg',
    fit: BoxFit.cover,
    ),
    Container(color: Colors.black45),

    Center(
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    child: Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    const Icon(Icons.pets,
    size: 48, color: Colors.white38),
    const SizedBox(height: 12),
    const Text(
    "Welcome Back",
    style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.white),
    ),
    const SizedBox(height: 24),

    _buildTextField(
    controller: _emailController,
    label: "Email",
    icon: Icons.email,
    ),
    const SizedBox(height: 16),

    _buildTextField(
    controller: _passwordController,
    label: "Password",
    icon: Icons.lock,
    obscureText: true,
    ),
    const SizedBox(height: 24),

    SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
    onPressed: isLoading ? null : _login,
    style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    ),
    child: isLoading
    ? const CircularProgressIndicator(
    color: Colors.white)
        : const Text("Login"),
    ),
    ),

    const SizedBox(height: 20),

    GestureDetector(
    onTap: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
    builder: (_) => const RegisterScreen()),
    );
    },
    child: const Text(
    "Don't have an account? Register",
    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, ),
    ),
    )
    ],
    ),
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    );
    

  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
