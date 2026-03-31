import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/dashboard/caretaker_dashboard.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:frontend/features/dashboard/admin_dashboard.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _licenseController = TextEditingController();

  String selectedRole = "Owner";
  bool isLoading = false;

  // Role-specific controllers


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRole == "Admin" && _adminCodeController.text.trim() != "4951") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Admin Access Code"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.register({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text.trim(),
        "role": selectedRole.toLowerCase(),
        "specialist": _specializationController.text.trim(),
        "experience": _experienceController.text.trim(),
        "license": _licenseController.text.trim(),
      });

      final statusCode = res["statusCode"];
      final data = res["data"];

      if (statusCode == 200 || statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", data["role"]);
        await prefs.setInt("user_id", data["id"]);
        await prefs.setString("access_token", data["access_token"]);
        await prefs.setString("name", data["name"]);


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );

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
          SnackBar(content: Text(data["error"] ?? "Registration failed")),
        );
      }
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      print("e $e");
      print("stackTrace $stackTrace");
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
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              _buildTextField(
                                controller: _nameController,
                                label: "Full Name",
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: "Phone Number",
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: "Confirm Password",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
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
                              if (selectedRole == "Vet" || selectedRole == "Caretaker") ...[
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _specializationController,
                                  label: selectedRole == "Vet" ? "Specialization (e.g. Surgery)" : "Service Focus",
                                  icon: Icons.workspace_premium,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _experienceController,
                                  label: "Experience (Years/Details)",
                                  icon: Icons.history,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _licenseController,
                                  label: "License Number / ID",
                                  icon: Icons.badge,
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (selectedRole == "Admin") ...[
                                _buildTextField(
                                  controller: _adminCodeController,
                                  label: "Admin Access Code *",
                                  icon: Icons.vpn_key,
                                  obscureText: true,
                                ),
                                const SizedBox(height: 16),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
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
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF57C00).withValues(alpha: 0.3)
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
