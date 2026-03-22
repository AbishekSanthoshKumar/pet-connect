// glassy_components.dart
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:frontend/core/logout_helper.dart';

// --- Custom Dark Color Palette ---
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const MaterialColor _accentColor = Colors.orange;
const Color _containerColor = Color.fromARGB(255, 43, 42, 42);
const Color _lightShadowColor = Color.fromARGB(255, 61, 60, 60);
const Color _darkShadowColor = Color.fromARGB(255, 23, 23, 23);

class GlassyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback logout;
  final bool showEmergency;

  const GlassyAppBar({
    super.key,
    required this.logout,
    this.showEmergency = true,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      height: preferredSize.height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // App title/logo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PetConnect',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryTextColor,
                      ),
                    ),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Emergency button if shown
              if (showEmergency)
                AppBarIcon(
                  icon: Icons.emergency,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency contact opened'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              const SizedBox(width: 12),
              // Logout
              AppBarIcon(
                icon: Icons.logout,
                onPressed: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIcon({required this.icon, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      width: 40,
      height: 40,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Icon(icon, color: _secondaryTextColor, size: 24),
      ),
    );
  }
}

class NeumorphicGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final DecorationImage? image;

  const NeumorphicGlassContainer({
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.color,
    this.image,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        image: image,
        borderRadius: BorderRadius.circular(20),
        color: color ?? Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: _darkShadowColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(4, 4),
          ),
        ],
        border: Border.all(
          color: _lightShadowColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: child,
        ),
      ),
    );
  }
}

