import 'package:flutter/material.dart';
import 'package:mobile/main.dart'; // Import de la page principale après connexion
import 'package:mobile/screens/widget.dart'; // Import des widgets personnalisés
import 'package:shared_preferences/shared_preferences.dart'; // Pour stocker des données localement
import 'package:mobile/services/api_services.dart'; // Pour appeler les services API (connexion)

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  ConnexionPageState createState() => ConnexionPageState();
}

class ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool seSouvenirDeMoi = false;

  void _seConnecter() async {
    String email = emailController.text.trim();
    String motDePasse = passwordController.text;

    try {
      var data = await ApiService.postRequest(
        'auth/login',
        {
          'email': email,
          'password': motDePasse,
        },
      );

      if (data != null && data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['user']['role']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        _afficherErreur("Identifiants incorrects.");
      }
    } catch (e) {
      _afficherErreur("Erreur lors de la connexion.");
      print("Erreur de connexion : $e");
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 35),

                    // Logo circulaire
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Titre et sous-titre
                    const Text(
                      'Bon retour !',
                      style: TextStyle(
                        color: Color.fromARGB(255, 122, 150, 133),
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),

                    // Champ email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Champ mot de passe
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton de connexion
                    CustomButton(
                      text: 'Se connecter',
                      onPressed: _seConnecter,
                      backgroundColor: const Color.fromARGB(255, 145, 189, 146),
                      textColor: Colors.white,
                      icon: Icons.person_add,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
