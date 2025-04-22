import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_services.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  SigninState createState() => SigninState();
}

class SigninState extends State<Signin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  void _login() async {
    // Simulation d'une authentification
    String email = emailController.text;
    String password = passwordController.text;

    var data = await ApiService.postRequest(
      'auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    print(data);
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); //SharedPreferences est utilisé pour stocker des données localement sur l'appareil.
    await prefs.setString('token', data['token']); // sauvegarde un token
    await prefs.setString(
        'role', data['user']['role']); // sauvegarde role de user

    // Redirection vers la page principale après connexion
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         backgroundColor: Colors.red,
    //         content: Text(
    //             "Identifiants incorrects")), //SnackBar est une notification temporaire qui apparaît en bas de l'écran pour informer l'utilisateur.
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de fond
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/gris.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 5),
              Text(
                'Welcome Back',
                style: TextStyle(
                  color: Color.fromARGB(255, 143, 182, 158),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Login to your Account',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              SizedBox(height: 20),
              CustomButton(
                text: 'Log In',
                onPressed: () {
                  _login();
                },
                backgroundColor: const Color.fromARGB(255, 145, 189, 146),
                textColor: Colors.white,
                icon: Icons.person_add, // Optional: Add an icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
