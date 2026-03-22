import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/dashboard/caretaker_dashboard.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:frontend/features/dashboard/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = "OWNER";
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  final url = Uri.parse("http://10.0.2.2:3000/api/users/register");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "username": _usernameController.text,
        "password": _passwordController.text,
        "role": selectedRole.toUpperCase()
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', selectedRole);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );

      Widget dashboard;

      switch (selectedRole) {
        case "OWNER":
          dashboard = const OwnerDashboard();
          break;
        case "VET":
          dashboard = const VetDashboard();
          break;
        case "CARETAKER":
          dashboard = const CaretakerDashboard();
          break;
        case "ADMIN":
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
        SnackBar(content: Text(data["message"] ?? "Registration failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
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
            alignment: const Alignment(-0.5, 0),
          ),
          Container(color: Colors.black45),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final form = Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              const Icon(
                                Icons.pets,
                                size: 48,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Join PetConnect today",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Name Field
                              _buildTextField(
                                controller: _nameController,
                                label: "Full Name",
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              _buildTextField(
                                controller: _emailController,
                                label: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),

                              // Phone Field
                              _buildTextField(
                                controller: _phoneController,
                                label: "Phone Number",
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),

                              // Username Field
                              _buildTextField(
                                controller: _usernameController,
                                label: "Username",
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password Field
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: "Confirm Password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),

                              // Role Selection
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "I am a...",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildRoleSelector(),
                              const SizedBox(height: 28),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              return isWide
                  ? Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(child: form),
                      ],
                    )
                  : form;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white54),
      ),
      child: Row(
        children: [
          _buildRoleOption("Owner", "🐾"),
          _buildRoleOption("Vet", "👨‍⚕️"),
          _buildRoleOption("Caretaker", "🏠"),
          _buildRoleOption("Admin", "👨‍💼"),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String role, String emoji) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF57C00).withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
