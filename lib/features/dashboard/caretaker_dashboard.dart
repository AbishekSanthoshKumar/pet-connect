import 'package:flutter/material.dart';

class CaretakerDashboard extends StatelessWidget {

  const CaretakerDashboard({super.key});

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
