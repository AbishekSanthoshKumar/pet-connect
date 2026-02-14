import 'package:flutter/material.dart';

class CaretakerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caretaker Dashboard")),
      body: Center(
        child: Text(
          "Welcome Caretaker",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
