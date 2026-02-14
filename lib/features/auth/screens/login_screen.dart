import 'package:flutter/material.dart';
import '../../dashboard/owner_dashboard.dart';
import '../../dashboard/vet_dashboard.dart';
import '../../dashboard/caretaker_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String selectedRole = "Owner";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PetConnect Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedRole,
              items: ["Owner", "Vet", "Caretaker"]
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              decoration: InputDecoration(labelText: "Login As"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {

                if (selectedRole == "Owner") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OwnerDashboard()));
                }
                else if (selectedRole == "Vet") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => VetDashboard()));
                }
                else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CaretakerDashboard()));
                }

              },
              child: Text("Login"),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegisterScreen()));
              },
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
