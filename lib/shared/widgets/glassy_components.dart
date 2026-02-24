// glassy_components.dart
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'dart:ui';

// --- Custom Dark Color Palette ---
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const MaterialColor _accentColor = Colors.orange;
const Color _containerColor = Color.fromARGB(255, 43, 42, 42);
const Color _lightShadowColor = Color.fromARGB(255, 61, 60, 60);
const Color _darkShadowColor = Color.fromARGB(255, 23, 23, 23);

// Make sure to include your NeumorphicGlassContainer here too 
// so both dashboards can use it!

class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIcon({required this.icon, required this.onPressed, Key? key})
      : super(key: key);

  @override
    @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      padding: EdgeInsets.zero,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: 'Logout',
      ),
    );
  }
}

// A Reusable Neumorphic/Glass Container
class NeumorphicGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final DecorationImage? image;

  const NeumorphicGlassContainer({
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.color,
    this.image,
    Key? key, required EdgeInsets padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        image: image,
        borderRadius: BorderRadius.circular(20),
        color: color ?? Colors.white.withOpacity(0.1),
        boxShadow: [
          // BoxShadow(
          //   color: _lightShadowColor.withOpacity(0.2),
          //   blurRadius: 8,
          //   spreadRadius: 1,
          //   offset: const Offset(-4, -4),
          // ),
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