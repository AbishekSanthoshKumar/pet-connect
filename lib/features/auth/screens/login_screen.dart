import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/providers/login_provider.dart';
import 'package:frontend/features/dashboard/caretaker_dashboard.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:frontend/features/auth/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF57C00); // Orange color for buttons

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/dog_and_cat.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.5, 0),
          ),
          Container(color: Colors.black38),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final form = Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: const _LoginForm(primaryColor: primaryColor),
                      ),
                    ),
                  ),
                ),
              );

              return isWide
                  ? Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        // Left side, shows background
                        Expanded(child: form),
                        // Right side, has the form
                      ],
                    )
                  : form;
            },
          ),
        ],
      ),
    );
  }
}

enum _LoginStep { enterMobile, enterOtp, selectRole }

class _LoginForm extends StatefulWidget {
  final Color primaryColor;

  const _LoginForm({Key? key, required this.primaryColor}) : super(key: key);

  @override
  __LoginFormState createState() => __LoginFormState();
}

class __LoginFormState extends State<_LoginForm> {
  final _mobileNumberController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedRole = "Owner";
  _LoginStep _currentStep = _LoginStep.enterMobile;

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitMobileNumber() {
    setState(() {
      _currentStep = _LoginStep.enterOtp;
    });
  }

  void _submitOtp() {
    setState(() {
      _currentStep = _LoginStep.selectRole;
    });
  }

  Future<void> _onRoleSelected(String? role) async {
    if (role != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);

      setState(() {
        _selectedRole = role;
      });

      // Navigate to the correct dashboard
      switch (role) {
        case "Owner":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OwnerDashboard()),
          );
          break;
        case "Vet":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VetDashboard()),
          );
          break;
        case "Caretaker":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CaretakerDashboard()),
          );
          break;
      }
    }
  }

  Future<void> _socialLogin(String provider) async {
    // TODO: Implement social login logic
    print('Social login with $provider');
    // For now, let's just navigate to the role selection
    setState(() {
      _currentStep = _LoginStep.selectRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Icon(Icons.pets, size: 48, color: Colors.white38),
          const SizedBox(height: 16),
          // Title
          const Text(
            "Pet Connect",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Welcome back! Sign in to continue",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 32),

          if (_currentStep == _LoginStep.enterMobile)
            _buildMobileStep()
          else if (_currentStep == _LoginStep.enterOtp)
            _buildOtpStep()
          else
            _buildRoleStep(),

          if (_currentStep != _LoginStep.selectRole) ...[
            const SizedBox(height: 24),
            // OR CONTINUE WITH
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white70)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "OR CONTINUE WITH",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 24),

            // Social Logins
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _SocialLoginButton(
                  label: "Google",
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 24,
                    width: 24,
                  ),
                  onTap: () => _socialLogin('Google'),
                ),
                _SocialLoginButton(
                  label: "Apple",
                  icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                  onTap: () => _socialLogin('Apple'),
                ),
                _SocialLoginButton(
                  label: "Instagram",
                  icon: Image.asset(
                    'assets/images/instagram.png',
                    height: 24,
                    width: 24,
                  ),
                  onTap: () => _socialLogin('Instagram'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Mobile Number",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextField(
          onSubmitted: (value) => _submitMobileNumber(),
          controller: _mobileNumberController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your mobile number",
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white70),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitMobileNumber,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(double.infinity, 40),
          ),
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Enter OTP",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextField(
          onSubmitted: (value) => _submitOtp(),
          controller: _otpController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter the OTP",
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white70),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(double.infinity, 40),
          ),
          child: const Text(
            "Verify OTP",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "I am a...",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        _NeumorphicGlassButton(
          text: "Owner",
          onPressed: () => _onRoleSelected("Owner"),
        ),
        const SizedBox(height: 16),
        _NeumorphicGlassButton(
          text: "Vet",
          onPressed: () => _onRoleSelected("Vet"),
        ),
        const SizedBox(height: 16),
        _NeumorphicGlassButton(
          text: "Caretaker",
          onPressed: () => _onRoleSelected("Caretaker"),
        ),
        const SizedBox(height: 32),
        InkWell(
          onTap: () {
            setState(() {
              _currentStep = _LoginStep.enterMobile;
              _mobileNumberController.clear();
              _otpController.clear();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: Colors.white.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeumorphicGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NeumorphicGlassButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.white.withOpacity(0.15),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialLoginButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white38,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}
