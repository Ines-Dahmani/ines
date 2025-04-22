import 'package:flutter/material.dart';
import 'package:mobile/services/api_services.dart';

import '../main.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomController = TextEditingController();

  Future<void> signup() async {
    // Simulation d'une authentification
    String email = emailController.text;
    String password = passwordController.text;
    String username = nomController.text;

    var data = await ApiService.postRequest(
      'auth/register',
      {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (data.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text(
                "register ok")), //SnackBar est une notification temporaire qui apparaît en bas de l'écran pour informer l'utilisateur.
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                "Identifiants incorrects")), //SnackBar est une notification temporaire qui apparaît en bas de l'écran pour informer l'utilisateur.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Image.asset(
              'assets/background.png', // Fixed image path
              width: 300, // Increased width for better visibility
              height: 300, // Increased height for better visibility
            ),
            SizedBox(height: 1),
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom & Prenom',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email ID',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 191, 245, 193), // Change button color
              ),
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
