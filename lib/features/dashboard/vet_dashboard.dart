import 'package:flutter/material.dart';

class VetDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vet Dashboard")),
      body: Center(
        child: Text(
          "Welcome Vet",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
