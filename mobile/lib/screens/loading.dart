import 'package:flutter/material.dart';
import 'package:mobile/screens/signin.dart';
import 'package:mobile/screens/signup.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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

          // Contenu par-dessus
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image de la plante
                Image.asset(
                  'assets/plante.jpg',
                  width: 300,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 300,
                      color: Colors.red,
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Logo circulaire
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  width: 70,
                  height: 70,
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
                          size: 50,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bouton Sign In
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Signin()),
                    );
                  },
                  child: const Text('Sign In'),
                ),

                const SizedBox(height: 10),

                // Lien Create Account
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Signup()),
                    );
                  },
                  child: const Text(
                    'Create an Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
