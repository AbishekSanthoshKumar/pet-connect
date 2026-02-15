import 'package:flutter/material.dart';

class VetDashboard extends StatelessWidget {

  const VetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Veterinarian Dashboard")),
      body: Center(
        child: Text(
          "Welcome Veterinarian",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
