import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Owner Dashboard")),
      body: Center(
        child: Text(
          "Welcome Pet Owner",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
