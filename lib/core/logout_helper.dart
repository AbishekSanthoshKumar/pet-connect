import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';

Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Remove stored session data
  await prefs.remove('user_role');
  await prefs.remove('token'); // if you're storing JWT later
  await prefs.remove('user_id');

  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}